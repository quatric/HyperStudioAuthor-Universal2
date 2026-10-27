#import "HSMovieOpenGLRenderer.h"
#import "NSEOpenGLDrawableSupport.h"
#import "NSEPixelBufferOpenGLDrawable.h"
#import "NSETextureOpenGLDrawable.h"
#import "HSFunctions.h"

// A movie renderer drawing with OpenGL: frames come as textures (sRGB) and are
// drawn with a fragment shader that resamples them bilinearly within the part
// shown, keys out a transparent color and matches sRGB to the destination's
// profile through a 3D color lookup table. The shader's complexity depends on
// the renderer: 2 does everything; 1 (old ATI and NVIDIA cards) and 0 (Intel
// GMA) key out colors on the CPU, and 0 leaves the resampling to the texture
// unit, so the part shown is first copied into a texture of its own. Frames
// are drawn straight into the destination's OpenGL context when it shares
// with ours and the drawing is pixel-aligned (or multisampled), else through
// an offscreen OpenGL layer.

static const double kHSMovieOpenGLRendererFullTolerance = 0.9980392156862745;
static const unsigned int kHSMovieOpenGLRendererColorLUTGridPointCount = 32;

static const char *const kHSMovieOpenGLRendererShaderPrefix = "#version 110\n#define TEXTURE_RECTANGLE ";
static const char *const kHSMovieOpenGLRendererShaderMatchColorsDefine = "\n#define MATCH_COLORS ";

// Complexity 0: the texture unit's own filtering.
static const char *const kHSMovieOpenGLRendererShader0 =
    "\n#if TEXTURE_RECTANGLE\nuniform sampler2DRect texture;\n#define textureLookup texture2DRect\n#else\nuniform sampler2D texture;\n"
    "#define textureLookup texture2D\n#endif // TEXTURE_RECTANGLE\n#if MATCH_COLORS\nuniform bool matchColors;\nuniform sampler3D colorLUT;\n"
    "#endif // MATCH_COLORS\nvoid main()\n{\ngl_FragColor = textureLookup(texture, gl_TexCoord[0].st);\nif (gl_FragColor.a > 0.0)\n{\n"
    "#if MATCH_COLORS\nif (matchColors)\ngl_FragColor.rgb = texture3D(colorLUT, gl_FragColor.rgb / gl_FragColor.a).rgb * gl_FragColor.a;\n"
    "#endif // MATCH_COLORS\ngl_FragColor *= gl_Color;\n}\n}\n";

#define HS_MOVIE_OPENGL_RENDERER_RESAMPLING_HEADER \
    "\nuniform vec4 textureRect;\n#if TEXTURE_RECTANGLE\nuniform sampler2DRect texture;\n#define textureLookup texture2DRect\n" \
    "#define nativeToDenormalized(textureCoordinates) textureCoordinates\n#define denormalizedToNative(textureCoordinates) textureCoordinates\n" \
    "#else\nuniform sampler2D texture;\nuniform vec2 textureDimensions;\n#define textureLookup texture2D\n" \
    "#define nativeToDenormalized(textureCoordinates) (textureCoordinates * textureDimensions)\n" \
    "#define denormalizedToNative(textureCoordinates) (textureCoordinates / textureDimensions)\n#endif // TEXTURE_RECTANGLE\n"
#define HS_MOVIE_OPENGL_RENDERER_MATCH_COLORS_UNIFORMS \
    "#if MATCH_COLORS\nuniform bool matchColors;\nuniform sampler3D colorLUT;\n#endif // MATCH_COLORS\n"
#define HS_MOVIE_OPENGL_RENDERER_TEXTURE_COLOR \
    "vec4 textureColor(vec2 textureCoords)\n{\nvec4 result;\n" \
    "if ((textureRect[0] <= textureCoords.s) && (textureCoords.s <= textureRect[2]) && (textureRect[1] <= textureCoords.t) && (textureCoords.t <= textureRect[3]))\n" \
    "result = textureLookup(texture, textureCoords);\nelse result = vec4(0.0);\nreturn result;\n}\n"
#define HS_MOVIE_OPENGL_RENDERER_TEXELS \
    "void main()\n{\nvec2 textureCoords = nativeToDenormalized(gl_TexCoord[0].st);\nfloat a = fract(textureCoords.s + 0.5);\n" \
    "float aComplement = 1.0 - a;\nfloat b = fract(textureCoords.t + 0.5);\nfloat bComplement = 1.0 - b;\n" \
    "vec2 baseTexel = floor(textureCoords - 0.5) + 0.5;\nvec2 nextTexel = baseTexel + 1.0;\n" \
    "vec4 texel00Color = textureColor(denormalizedToNative(baseTexel));\n" \
    "vec4 texel10Color = textureColor(denormalizedToNative(vec2(nextTexel.s, baseTexel.t)));\n" \
    "vec4 texel01Color = textureColor(denormalizedToNative(vec2(baseTexel.s, nextTexel.t)));\n" \
    "vec4 texel11Color = textureColor(denormalizedToNative(nextTexel));\n"
#define HS_MOVIE_OPENGL_RENDERER_BLEND_TEXELS \
    "gl_FragColor = aComplement * bComplement * texel00Color + a * bComplement * texel10Color + aComplement * b * texel01Color + a * b * texel11Color;\n" \
    "if (gl_FragColor.a > 0.0)\n{\n#if MATCH_COLORS\nif (matchColors)\n" \
    "gl_FragColor.rgb = texture3D(colorLUT, gl_FragColor.rgb / gl_FragColor.a).rgb * gl_FragColor.a;\n" \
    "#endif // MATCH_COLORS\ngl_FragColor *= gl_Color;\n}\n}\n"

// Complexity 1: bilinear resampling within the part shown.
static const char *const kHSMovieOpenGLRendererShader1 =
    HS_MOVIE_OPENGL_RENDERER_RESAMPLING_HEADER
    "uniform bool isAlphaPremultiplied;\n"
    HS_MOVIE_OPENGL_RENDERER_MATCH_COLORS_UNIFORMS
    HS_MOVIE_OPENGL_RENDERER_TEXTURE_COLOR
    HS_MOVIE_OPENGL_RENDERER_TEXELS
    "if (!isAlphaPremultiplied)\n{\ntexel00Color.rgb *= texel00Color.a;\ntexel10Color.rgb *= texel10Color.a;\n"
    "texel01Color.rgb *= texel01Color.a;\ntexel11Color.rgb *= texel11Color.a;\n}\n"
    HS_MOVIE_OPENGL_RENDERER_BLEND_TEXELS;

// Complexity 2: and keying out a color by hue, chroma and lightness.
static const char *const kHSMovieOpenGLRendererShader2 =
    HS_MOVIE_OPENGL_RENDERER_RESAMPLING_HEADER
    HS_MOVIE_OPENGL_RENDERER_MATCH_COLORS_UNIFORMS
    "uniform vec4 transparentColor;\nuniform vec3 transparentColorHCL;\nuniform vec3 transparentColorToleranceHCL;\n"
    HS_MOVIE_OPENGL_RENDERER_TEXTURE_COLOR
    "vec3 convertRGBToHCL(vec3 rgb)\n{\nfloat maxComponent = rgb.r;\nfloat minComponent = rgb.r;\nif (maxComponent < rgb.g)\n"
    "maxComponent = rgb.g;\nelse minComponent = rgb.g;\nif (maxComponent < rgb.b)\nmaxComponent = rgb.b;\n"
    "else if (minComponent > rgb.b)\nminComponent = rgb.b;\nvec3 result;\nresult.y = maxComponent - minComponent;\n"
    "result.z = 0.5 * (maxComponent + minComponent);\nif (result.y != 0.0)\n{\nif (rgb.g == maxComponent)\n"
    "result.x = 2.0 + rgb.b - rgb.r;\nelse if (rgb.b == maxComponent)\nresult.x = 4.0 + rgb.r - rgb.g;\nelse\n{\n"
    "if (rgb.g >= rgb.b)\nresult.x = rgb.g - rgb.b;\nelse result.x = 6.0 + rgb.g - rgb.b;\n}\n}\nreturn result;\n}\n"
    "vec3 colorDelta(vec3 hcl1, vec3 hcl2)\n{\nvec3 result;\nif ((hcl1.y == 0.0) || (hcl2.y == 0.0))\nresult.x = 0.0;\nelse\n{\n"
    "result.x = hcl1.x - hcl2.x;\nif (result.x < -3.0)\nresult.x += 6.0;\nelse if (result.x > 3.0)\nresult.x -= 6.0;\n"
    "result.x = clamp(result.x, -1.0, 1.0);\n}\nresult.y = hcl1.y - hcl2.y;\nresult.z = hcl1.z - hcl2.z;\nreturn result;\n}\n"
    "vec3 colorDeltaSign(vec3 colorDelta)\n{\nvec3 result;\nif (colorDelta.x < 0.0)\nresult.x = -1.0;\nelse result.x = 1.0;\n"
    "if (colorDelta.y < 0.0)\nresult.y = -1.0;\nelse result.y = 1.0;\nif (colorDelta.z < 0.0)\nresult.z = -1.0;\nelse result.z = 1.0;\n"
    "return result;\n}\nvoid removeColorIfNeeded(inout vec4 color)\n{\nif (color.a > 0.0)\n{\n"
    "vec3 colorDelta = colorDelta(convertRGBToHCL(color.rgb), transparentColorHCL);\n"
    "if (all(lessThanEqual(colorDelta * colorDeltaSign(colorDelta), transparentColorToleranceHCL)))\ncolor.a = 0.0;\n}\n}\n"
    HS_MOVIE_OPENGL_RENDERER_TEXELS
    "if (transparentColor.a >= 1.0)\n{\nremoveColorIfNeeded(texel00Color);\nremoveColorIfNeeded(texel10Color);\n"
    "removeColorIfNeeded(texel01Color);\nremoveColorIfNeeded(texel11Color);\n}\n"
    "texel00Color.rgb *= texel00Color.a;\ntexel10Color.rgb *= texel10Color.a;\ntexel01Color.rgb *= texel01Color.a;\n"
    "texel11Color.rgb *= texel11Color.a;\n"
    HS_MOVIE_OPENGL_RENDERER_BLEND_TEXELS;

// Renderers that can't run the full shader.
static const char *const kHSMovieOpenGLRendererComplexity1Renderers[] = {
    "ATI Technologies Inc.", "ATI Radeon X800 XT OpenGL Engine", "ATI Radeon 9550 OpenGL Engine", "ATI Radeon 9600 OpenGL Engine",
    "ATI Radeon 9600 XT OpenGL Engine", NULL,
    "NVIDIA Corporation", "NVIDIA NV34MAP OpenGL Engine", NULL,
    NULL
};
static const char *const kHSMovieOpenGLRendererComplexity0Renderers[] = {
    "Intel Inc.", "Intel GMA 950 OpenGL Engine", "Intel GMA X3100 OpenGL Engine", NULL,
    NULL
};

static unsigned int HSMovieOpenGLRendererShaderComplexity(CGLContextObj cgl_ctx)
{
    if (NSEOpenGLRendererIsListed(cgl_ctx, kHSMovieOpenGLRendererComplexity0Renderers))
        return 0;
    if (NSEOpenGLRendererIsListed(cgl_ctx, kHSMovieOpenGLRendererComplexity1Renderers))
        return 1;
    return 2;
}

static BOOL HSMovieOpenGLRendererIsNearMultiple(float aValue, float aStep, float aTolerance)
{
    float remainder = remainderf(aValue, aStep);
    return remainder >= -aTolerance && remainder <= aTolerance;
}

// A CTM that is a multiple of 90° with no shear and puts the rect's corners
// on device pixels (within 1/512).
static BOOL HSMovieOpenGLRendererIsPixelAligned(CGAffineTransform aTransform, NSRect aRect)
{
    float a = aTransform.a, b = aTransform.b, c = aTransform.c, d = aTransform.d;
    float deviceX = a * aRect.origin.x + c * aRect.origin.y + aTransform.tx;
    float deviceY = b * aRect.origin.x + d * aRect.origin.y + aTransform.ty;
    float rotation = a == 0 && b == 0 ? (float)(atan2f(d, c) - M_PI_2) : atan2f(b, a);
    if (rotation < 0)
        rotation = (float)(rotation + 2 * M_PI);
    double shear = atan2(a * c + b * d, a * d - b * c);
    if (shear < -M_PI_2)
        shear += M_PI;
    else if (shear > M_PI_2)
        shear -= M_PI;
    float shearNear = nextafterf((float)shear, 0);
    return HSMovieOpenGLRendererIsNearMultiple(rotation, (float)M_PI_2, 5e-05f)
        && shearNear >= -5e-05f && shearNear <= 5e-05f
        && HSMovieOpenGLRendererIsNearMultiple(deviceX, 1, 1.0f / 512)
        && HSMovieOpenGLRendererIsNearMultiple(deviceY, 1, 1.0f / 512)
        && HSMovieOpenGLRendererIsNearMultiple(a * aRect.size.width + c * aRect.size.height + deviceX, 1, 1.0f / 512)
        && HSMovieOpenGLRendererIsNearMultiple(b * aRect.size.width + d * aRect.size.height + deviceY, 1, 1.0f / 512);
}

// A lookup table of the grid points of RGB in the source profile matched to
// the destination profile: RGBA bytes, red varying fastest. ColorSync
// replaces the color world's CWFillLookupTexture.
static BOOL HSMovieOpenGLRendererFillColorLUT(ColorSyncProfileRef aSource, ColorSyncProfileRef aDestination, unsigned int aGridPointCount, UInt8 *aLUT)
{
    NSArray *profiles = [NSArray arrayWithObjects:
        [NSDictionary dictionaryWithObjectsAndKeys:(id)aSource, kColorSyncProfile, kColorSyncRenderingIntentPerceptual, kColorSyncRenderingIntent,
                                                   kColorSyncTransformDeviceToPCS, kColorSyncTransformTag, nil],
        [NSDictionary dictionaryWithObjectsAndKeys:(id)aDestination, kColorSyncProfile, kColorSyncRenderingIntentPerceptual, kColorSyncRenderingIntent,
                                                   kColorSyncTransformPCSToDevice, kColorSyncTransformTag, nil], nil];
    ColorSyncTransformRef transform = ColorSyncTransformCreate((CFArrayRef)profiles, NULL);
    if (transform == NULL)
        return NO;
    size_t count = (size_t)aGridPointCount * aGridPointCount * aGridPointCount;
    float *grid = malloc(count * 3 * sizeof(float));
    if (grid == NULL) {
        CFRelease(transform);
        return NO;
    }
    float *point = grid;
    float step = 1.0f / (aGridPointCount - 1);
    for (unsigned int blue = 0; blue < aGridPointCount; blue++)
        for (unsigned int green = 0; green < aGridPointCount; green++)
            for (unsigned int red = 0; red < aGridPointCount; red++) {
                *point++ = red * step;
                *point++ = green * step;
                *point++ = blue * step;
            }
    bool converted = ColorSyncTransformConvert(transform, count, 1, grid, kColorSync32BitFloat, kColorSyncByteOrderDefault | kColorSyncAlphaNone, count * 3 * sizeof(float),
                                               grid, kColorSync32BitFloat, kColorSyncByteOrderDefault | kColorSyncAlphaNone, count * 3 * sizeof(float), NULL);
    CFRelease(transform);
    if (converted)
        for (size_t i = 0; i < count; i++) {
            for (int component = 0; component < 3; component++)
                aLUT[i * 4 + component] = (UInt8)lroundf(fminf(fmaxf(grid[i * 3 + component], 0), 1) * 255);
            aLUT[i * 4 + 3] = 255;
        }
    free(grid);
    return converted;
}

@implementation HSMovieOpenGLRenderer

- (BOOL)HSMovieOpenGLRenderer_updateFrameOpenGLProgram:(struct __HSFrameOpenGLProgram *)aProgram forTextureRectangle:(BOOL)aRectangle matchColors:(BOOL)aColors
{
    CGLContextObj cgl_ctx = _coreGLContext;
    unsigned int complexity = _frameOpenGLFragmentShaderComplexity;
    const char *sources[5] = { kHSMovieOpenGLRendererShaderPrefix, aRectangle ? "1" : "0", kHSMovieOpenGLRendererShaderMatchColorsDefine, aColors ? "1" : "0",
                               complexity == 0 ? kHSMovieOpenGLRendererShader0 : complexity == 1 ? kHSMovieOpenGLRendererShader1 : kHSMovieOpenGLRendererShader2 };
    glShaderSource(aProgram->f1, complexity <= 2 ? 5 : 0, sources, NULL);
    glCompileShader(aProgram->f1);
    GLint status = 0;
    glGetShaderiv(aProgram->f1, GL_COMPILE_STATUS, &status);
    if (status == 0)
        return aProgram->f6;
    glLinkProgram(aProgram->f0);
    status = 0;
    glGetProgramiv(aProgram->f0, GL_LINK_STATUS, &status);
    if (status == 0)
        return aProgram->f6;
    if (aColors && (aProgram->f4 = glGetUniformLocation(aProgram->f0, "matchColors")) == -1)
        return aProgram->f6;
    if (!aRectangle && complexity != 0 && (aProgram->f2 = glGetUniformLocation(aProgram->f0, "textureDimensions")) == -1)
        return aProgram->f6;
    if (complexity != 0 && (aProgram->f3 = glGetUniformLocation(aProgram->f0, "textureRect")) == -1)
        return aProgram->f6;
    if (complexity == 2) {
        if ((aProgram->f5.f1.transparentColorLocation = glGetUniformLocation(aProgram->f0, "transparentColor")) == -1
            || (aProgram->f5.f1.transparentColorHCLLocation = glGetUniformLocation(aProgram->f0, "transparentColorHCL")) == -1
            || (aProgram->f5.f1.transparentColorToleranceHCLLocation = glGetUniformLocation(aProgram->f0, "transparentColorToleranceHCL")) == -1)
            return aProgram->f6;
    } else if (complexity == 1 && (aProgram->f5.alphaPremultipicationFlagLocation = glGetUniformLocation(aProgram->f0, "isAlphaPremultiplied")) == -1)
        return aProgram->f6;
    aProgram->f6 = 1;
    return YES;
}

- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3
{
    NSColor *color = [aColor colorUsingColorSpace:_workingColorSpace];
    if (color != nil && aTolerance >= kHSMovieOpenGLRendererFullTolerance && aTolerance2 >= kHSMovieOpenGLRendererFullTolerance
        && aTolerance3 >= kHSMovieOpenGLRendererFullTolerance)
        return;
    CVOpenGLTextureRef frame = [self currentFrameImageBuffer];
    if (frame == NULL)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGAffineTransform transform = CGContextGetCTM(context);
    float opacity = 1;
    CFNumberRef alpha = CGEContextGetAttachmentForKey(context, (CFStringRef)kCGEContextAlphaAttachmentKey);
    if (alpha != NULL)
        CFNumberGetValue(alpha, kCFNumberFloatType, &opacity);
    struct OpaqueCMProfileRef *destinationProfile = (struct OpaqueCMProfileRef *)CGEContextGetAttachmentForKey(context, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey);
    if (destinationProfile != NULL && ![self HSMovieOpenGLRenderer_updateColorLUTIfNeededWithDestinationColorProfile:destinationProfile])
        return;
    CGLContextObj cgl_ctx = _coreGLContext;
    GLenum target = CVOpenGLTextureGetTarget(frame);
    BOOL isAlphaPremultiplied = color == nil && [(id)CVBufferGetAttachment(frame, (CFStringRef)kCVEImageBufferOpaquenessKey, NULL) boolValue];

    unsigned int complexity = HSMovieOpenGLRendererShaderComplexity(cgl_ctx);
    if (complexity != _frameOpenGLFragmentShaderComplexity) {
        if (_frameOpenGLProgram2D != NULL) {
            _frameOpenGLProgram2D->f6 = 0;
            _frameOpenGLProgram2D->f7 = 0;
        }
        if (_frameOpenGLProgram2DRect != NULL) {
            _frameOpenGLProgram2DRect->f6 = 0;
            _frameOpenGLProgram2DRect->f7 = 0;
        }
        _frameOpenGLFragmentShaderComplexity = complexity;
    }

    // Texture coordinates of the corners and the part of the texture shown.
    GLuint name;
    GLfloat lowerLeft[2], lowerRight[2], upperRight[2], upperLeft[2];
    GLfloat textureRect[4];
    GLfloat dimensions[2] = { 0, 0 };
    if (_frameOpenGLFragmentShaderComplexity == 2 || color == nil) {
        name = CVOpenGLTextureGetName(frame);
        CVOpenGLTextureGetCleanTexCoords(frame, lowerLeft, lowerRight, upperRight, upperLeft);
        float width = lowerRight[0] - lowerLeft[0], height = upperLeft[1] - lowerLeft[1];
        float x0 = (float)aRect2.origin.x * width + lowerLeft[0];
        float y0 = (float)aRect2.origin.y * height + lowerLeft[1];
        float dx = width * (float)aRect2.size.width, dy = height * (float)aRect2.size.height;
        float x1 = x0 + dx, y1 = y0 + dy;
        lowerLeft[0] = x0; lowerLeft[1] = y0;
        lowerRight[0] = x1; lowerRight[1] = y0;
        upperRight[0] = x1; upperRight[1] = y1;
        upperLeft[0] = x0; upperLeft[1] = y1;
        textureRect[0] = fminf(x0, x1);
        textureRect[1] = fminf(y0, y1);
        textureRect[2] = fmaxf(x0, x1);
        textureRect[3] = fmaxf(y0, y1);
        if (target != GL_TEXTURE_RECTANGLE_ARB || (_frameOpenGLFragmentShaderComplexity == 0 && isAlphaPremultiplied)) {
            CGSize size = CVImageBufferGetEncodedSize(frame);
            dimensions[0] = size.width;
            dimensions[1] = size.height;
        }
        if (_frameOpenGLFragmentShaderComplexity == 0) {
            float boundsWidth = ceilf(textureRect[2]) - floorf(textureRect[0]);
            float boundsHeight = ceilf(textureRect[3]) - floorf(textureRect[1]);
            if (target != GL_TEXTURE_RECTANGLE_ARB) {
                boundsWidth *= dimensions[0];
                boundsHeight *= dimensions[1];
            }
            // Anything but a whole opaque frame: the part shown goes into a
            // texture of its own, so filtering can't reach past its edges.
            if (!isAlphaPremultiplied || boundsWidth < dimensions[0] - 0.0019607844f || boundsHeight < dimensions[1] - 0.0019607844f) {
                if (_textureOpenGLDrawable == nil) {
                    _textureOpenGLDrawable = [[NSETextureOpenGLDrawable alloc] initWithOffscreenWindowDrawable:[_offscreenOpenGLRenderer offscreenWindowOpenGLDrawable]];
                    if (_textureOpenGLDrawable == nil)
                        return;
                }
                [_textureOpenGLDrawable setTarget:target];
                [_textureOpenGLDrawable setWidth:lroundf(boundsWidth) height:lroundf(boundsHeight) statically:YES];
                if ([_textureOpenGLDrawable lockOpenGLFocus] == nil)
                    return;
                float s0, s1, t0, t1, offsetX, offsetY;
                if (dx >= 0) {
                    s0 = floorf(lowerLeft[0]);
                    s1 = ceilf(lowerRight[0]);
                    offsetX = s0;
                } else {
                    s0 = ceilf(lowerLeft[0]);
                    s1 = floorf(lowerRight[0]);
                    offsetX = s1;
                }
                if (dy >= 0) {
                    t0 = floorf(lowerLeft[1]);
                    t1 = ceilf(upperLeft[1]);
                    offsetY = t0;
                } else {
                    t0 = ceilf(lowerLeft[1]);
                    t1 = floorf(upperLeft[1]);
                    offsetY = t1;
                }
                [self HSMovieOpenGLRenderer_prepareOffscreenOpenGLContextIfNeeded];
                GLboolean multisample = glIsEnabled(GL_MULTISAMPLE);
                if (multisample)
                    glDisable(GL_MULTISAMPLE);
                glClear(GL_COLOR_BUFFER_BIT);
                glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
                glEnable(GL_BLEND);
                glEnable(target);
                glBindTexture(target, name);
                glMatrixMode(GL_MODELVIEW);
                float *posttransform = [_textureOpenGLDrawable projectionPosttransform];
                if (posttransform == NULL)
                    glLoadIdentity();
                else
                    glLoadMatrixf(posttransform);
                glBegin(GL_QUADS);
                glTexCoord2f(s0, t0);
                glVertex2f(-1, -1);
                glTexCoord2f(s0, t1);
                glVertex2f(-1, 1);
                glTexCoord2f(s1, t1);
                glVertex2f(1, 1);
                glTexCoord2f(s1, t0);
                glVertex2f(1, -1);
                glEnd();
                glDisable(target);
                glDisable(GL_BLEND);
                glBlendFuncSeparate(GL_ONE, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
                if (multisample)
                    glEnable(GL_MULTISAMPLE);
                [_textureOpenGLDrawable unlockOpenGLFocus];
                name = (GLuint)[_textureOpenGLDrawable name];
                if (target != GL_TEXTURE_RECTANGLE_ARB) {
                    lowerLeft[0] *= dimensions[0];
                    lowerRight[0] *= dimensions[0];
                    lowerLeft[1] *= dimensions[1];
                    upperLeft[1] *= dimensions[1];
                }
                lowerLeft[0] -= offsetX;
                lowerRight[0] -= offsetX;
                lowerLeft[1] -= offsetY;
                upperLeft[1] -= offsetY;
                if (target != GL_TEXTURE_RECTANGLE_ARB) {
                    lowerLeft[0] /= boundsWidth;
                    lowerRight[0] /= boundsWidth;
                    lowerLeft[1] /= boundsHeight;
                    upperLeft[1] /= boundsHeight;
                }
                upperLeft[0] = lowerLeft[0];
                upperRight[0] = lowerRight[0];
                lowerRight[1] = lowerLeft[1];
                upperRight[1] = upperLeft[1];
                textureRect[0] -= offsetX;
                textureRect[1] -= offsetY;
                textureRect[2] -= offsetX;
                textureRect[3] -= offsetY;
                glBindTexture(target, name);
                glTexParameteri(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameteri(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                isAlphaPremultiplied = YES;
            }
        }
    } else {
        // The frame read back, the color keyed out of the part shown on the
        // CPU, and that bound as a texture.
        CVPixelBufferRef source = [[self HSMovieOpenGLRenderer_currentFramePixelBufferLink] pixelBuffer];
        if (source == NULL)
            return;
        size_t width = CVPixelBufferGetWidth(source);
        size_t height = CVPixelBufferGetHeight(source);
        if (width == 0 || height == 0)
            return;
        CGRect part = CGRectMake((float)aRect2.origin.x * (float)width, (float)aRect2.origin.y * (float)height,
                                 (float)aRect2.size.width * (float)width, (float)aRect2.size.height * (float)height);
        CGRect integral = CGRectIntegral(part);
        long x = lroundf(integral.origin.x);
        long y = lroundf(integral.origin.y);
        long partWidth = lroundf(integral.size.width);
        long partHeight = lroundf(integral.size.height);
        [_offscreenOpenGLRenderer setPixelsWide:partWidth pixelsHigh:partHeight statically:YES];
        [_offscreenOpenGLRenderer removeAllPixelBufferAttachmentsForMode:kCVAttachmentMode_ShouldPropagate];
        CFDictionaryRef attachments = CVBufferGetAttachments(source, kCVAttachmentMode_ShouldPropagate);
        if (attachments != NULL) {
            [_offscreenOpenGLRenderer setPixelBufferAttachments:(CFMutableDictionaryRef)attachments mode:kCVAttachmentMode_ShouldPropagate];
            [_offscreenOpenGLRenderer removePixelBufferAttachmentForKey:(struct __CFString *)kCVEImageBufferOpaquenessKey];
        }
        CVPixelBufferRef copy = [_offscreenOpenGLRenderer createEmptyPixelBuffer];
        if (copy == NULL)
            return;
        // Fix: the original leaked the copy when either buffer wouldn't lock.
        if (CVPixelBufferLockBaseAddress(copy, 0) != kCVReturnSuccess) {
            CVPixelBufferRelease(copy);
            return;
        }
        if (CVPixelBufferLockBaseAddress(source, kCVPixelBufferLock_ReadOnly) != kCVReturnSuccess) {
            CVPixelBufferUnlockBaseAddress(copy, 0);
            CVPixelBufferRelease(copy);
            return;
        }
        CGFloat components[4] = { 0, 0, 0, 0 };
        [color getComponents:components];
        UInt8 red = lroundf(components[0] * 255.0f);
        UInt8 green = lroundf(components[1] * 255.0f);
        UInt8 blue = lroundf(components[2] * 255.0f);
        // Pixel buffers run top down.
        size_t sourceRowBytes = CVPixelBufferGetBytesPerRow(source);
        const UInt8 *sourceBytes = (const UInt8 *)CVPixelBufferGetBaseAddress(source) + (height - y - partHeight) * sourceRowBytes + x * 4;
        OSType format = CVPixelBufferGetPixelFormatType(source);
        if (format == kCVPixelFormatType_32BGRA)
            HSBitmapBGRA8888PremultipliedCopyRemovingColorFromBGRA8888Premultiplied(CVPixelBufferGetBaseAddress(copy), CVPixelBufferGetBytesPerRow(copy), sourceBytes, sourceRowBytes,
                                                                                    partWidth, partHeight, red, green, blue, aTolerance, aTolerance2, aTolerance3);
        else if (format == kCVPixelFormatType_32ARGB)
            HSBitmapARGB8888PremultipliedCopyRemovingColorFromARGB8888Premultiplied(CVPixelBufferGetBaseAddress(copy), CVPixelBufferGetBytesPerRow(copy), sourceBytes, sourceRowBytes,
                                                                                    partWidth, partHeight, red, green, blue, aTolerance, aTolerance2, aTolerance3);
        CVPixelBufferUnlockBaseAddress(source, kCVPixelBufferLock_ReadOnly);
        CVPixelBufferUnlockBaseAddress(copy, 0);
        id texture = [[_offscreenOpenGLRenderer openGLContext] bindTextureForPixelBuffer:copy target:target border:0 specifyingIfNeeded:YES withOptions:4];
        CVPixelBufferRelease(copy);
        if (texture == nil)
            return;
        glTexParameteri(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        name = (GLuint)[(__NSEPixelBufferOpenGLTexture *)texture name];
        float x0 = (float)part.origin.x - x;
        float x1 = (float)part.size.width + x0;
        float y0 = (float)partHeight - ((float)part.origin.y - y);
        float y1 = y0 - (float)part.size.height;
        if (target != GL_TEXTURE_RECTANGLE_ARB) {
            x0 /= partWidth;
            x1 /= partWidth;
            y0 /= partHeight;
            y1 /= partHeight;
        }
        lowerLeft[0] = x0; lowerLeft[1] = y0;
        lowerRight[0] = x1; lowerRight[1] = y0;
        upperRight[0] = x1; upperRight[1] = y1;
        upperLeft[0] = x0; upperLeft[1] = y1;
        textureRect[0] = x0;
        textureRect[1] = y1;
        textureRect[2] = x1;
        textureRect[3] = y0;
        dimensions[0] = partWidth;
        dimensions[1] = partHeight;
        isAlphaPremultiplied = YES;
    }

    struct __HSFrameOpenGLProgram **program = target == GL_TEXTURE_RECTANGLE_ARB ? &_frameOpenGLProgram2DRect : &_frameOpenGLProgram2D;
    if (*program == NULL && (*program = [self HSMovieOpenGLRenderer_createFrameOpenGLProgram]) == NULL)
        return;
    if (!(*program)->f6 && ![self HSMovieOpenGLRenderer_updateFrameOpenGLProgram:*program forTextureRectangle:target == GL_TEXTURE_RECTANGLE_ARB matchColors:_colorLUT != NULL])
        return;

    // Straight into the destination's context when it can be.
    id destination = (id)CGEContextGetDestination(context, (CFStringRef)NSEOpenGLCGContextDestination);
    if (destination != nil) {
        NSEOpenGLContext *destinationContext = [destination destinationOpenGLContext];
        if (destinationContext != nil && [destinationContext sharesContext:[_offscreenOpenGLRenderer openGLContext]]) {
            GLint sampleBuffers = 0;
            [(NSOpenGLPixelFormat *)[destinationContext format] getValues:&sampleBuffers forAttribute:NSOpenGLPFASampleBuffers forVirtualScreen:[destinationContext currentVirtualScreen]];
            if (sampleBuffers != 0 || HSMovieOpenGLRendererIsPixelAligned(transform, aRect)) {
                id flushed = [destination flushCGContext];
                if (flushed != nil)
                    cgl_ctx = [flushed CGLContextObj];
            }
        }
    }

    BOOL isOffscreen = cgl_ctx == _coreGLContext;
    GLint previousProgram = 0;
    GLboolean blendWasEnabled = GL_FALSE;
    GLint equationRGB = 0, equationAlpha = 0, sourceRGB = 0, destinationRGB = 0, sourceAlpha = 0, destinationAlpha = 0;
    if (isOffscreen) {
        [_offscreenOpenGLRenderer removeAllPixelBufferAttachmentsForMode:kCVAttachmentMode_ShouldPropagate];
        CFDictionaryRef attachments = CVBufferGetAttachments(frame, kCVAttachmentMode_ShouldPropagate);
        if (attachments != NULL)
            [_offscreenOpenGLRenderer setPixelBufferAttachments:(CFMutableDictionaryRef)attachments mode:kCVAttachmentMode_ShouldPropagate];
        [_offscreenOpenGLRenderer removePixelBufferAttachmentForKey:(struct __CFString *)kCVEImageBufferOpaquenessKey];
        if (destinationProfile != NULL) {
            CGColorSpaceRef space = (CGColorSpaceRef)CGEContextGetAttachmentForKey(context, (CFStringRef)kCGEContextColorSpaceAttachmentKey);
            BOOL isMade = space == NULL;
            if (isMade && (space = CGColorSpaceCreateWithPlatformColorSpace(destinationProfile)) == NULL)
                return;
            [_offscreenOpenGLRenderer setPixelBufferAttachment:space forKey:(struct __CFString *)kCVImageBufferCGColorSpaceKey mode:kCVAttachmentMode_ShouldPropagate];
            if (isMade)
                CGColorSpaceRelease(space);
        }
        if (![_offscreenOpenGLRenderer beginOpenGLLayerForCGContext:context rect:NSRectToCGRect(aRect) opacity:opacity])
            return;
        [self HSMovieOpenGLRenderer_prepareOffscreenOpenGLContextIfNeeded];
        glClear(GL_COLOR_BUFFER_BIT);
        glEnable(GL_BLEND);
    } else {
        blendWasEnabled = glIsEnabled(GL_BLEND);
        glGetIntegerv(GL_BLEND_EQUATION_RGB, &equationRGB);
        glGetIntegerv(GL_BLEND_EQUATION_ALPHA, &equationAlpha);
        glGetIntegerv(GL_BLEND_SRC_RGB, &sourceRGB);
        glGetIntegerv(GL_BLEND_DST_RGB, &destinationRGB);
        glGetIntegerv(GL_BLEND_SRC_ALPHA, &sourceAlpha);
        glGetIntegerv(GL_BLEND_DST_ALPHA, &destinationAlpha);
        if (equationRGB != GL_FUNC_ADD || equationAlpha != GL_FUNC_ADD)
            glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD);
        if (sourceRGB != GL_ONE || destinationRGB != GL_ONE_MINUS_SRC_ALPHA || sourceAlpha != GL_ONE || destinationAlpha != GL_ONE_MINUS_SRC_ALPHA)
            glBlendFuncSeparate(GL_ONE, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        if (!blendWasEnabled)
            glEnable(GL_BLEND);
        glGetIntegerv(GL_CURRENT_PROGRAM, &previousProgram);
    }

    glUseProgram((*program)->f0);
    glUniform4fv((*program)->f3, 1, textureRect);
    if (target != GL_TEXTURE_RECTANGLE_ARB)
        glUniform2f((*program)->f2, dimensions[0], dimensions[1]);
    if (_colorLUT != NULL) {
        glUniform1i((*program)->f4, destinationProfile != NULL);
        if (!(*program)->f7) {
            // Original quirk kept: this leaves the program and the layer as they are.
            GLint location = glGetUniformLocation((*program)->f0, "colorLUT");
            if (location == -1)
                return;
            glUniform1i(location, 1);
            (*program)->f7 = 1;
        }
    }
    if (_frameOpenGLFragmentShaderComplexity == 2) {
        if (color == nil)
            glUniform4f((*program)->f5.f1.transparentColorLocation, 0, 0, 0, 0);
        else {
            CGFloat components[4] = { 0, 0, 0, 0 };
            [color getComponents:components];
            float red = components[0], green = components[1], blue = components[2];
            float minComponent = green <= red ? green : red;
            float maxComponent = green <= red ? red : green;
            if (blue > maxComponent)
                maxComponent = blue;
            else if (blue < minComponent)
                minComponent = blue;
            float chroma = maxComponent - minComponent;
            float hue = 0;
            if (chroma != 0) {
                if (maxComponent == green)
                    hue = blue + 2 - red;
                else if (maxComponent == blue)
                    hue = red + 4 - green;
                else
                    hue = blue <= green ? green - blue : green + 6 - blue;
            }
            glUniform4f((*program)->f5.f1.transparentColorLocation, red, green, blue, 1);
            glUniform3f((*program)->f5.f1.transparentColorHCLLocation, hue, chroma, (maxComponent + minComponent) * 0.5f);
            glUniform3f((*program)->f5.f1.transparentColorToleranceHCLLocation, aTolerance, aTolerance2, aTolerance3);
        }
    } else if (_frameOpenGLFragmentShaderComplexity == 1)
        glUniform1i((*program)->f5.alphaPremultipicationFlagLocation, isAlphaPremultiplied);

    glActiveTexture(GL_TEXTURE1);
    if (![self HSMovieOpenGLRenderer_bindCLUTTextureIfNeededInOpenGLContext:cgl_ctx]) {
        glActiveTexture(GL_TEXTURE0);
        return;
    }
    GLboolean texture3DWasEnabled = !isOffscreen && glIsEnabled(GL_TEXTURE_3D);
    if (!texture3DWasEnabled)
        glEnable(GL_TEXTURE_3D);
    glActiveTexture(GL_TEXTURE0);
    GLboolean targetWasEnabled = !isOffscreen && glIsEnabled(target);
    if (!targetWasEnabled)
        glEnable(target);
    glBindTexture(target, name);
    GLint filter = _frameOpenGLFragmentShaderComplexity == 0 ? GL_LINEAR : GL_NEAREST;
    glTexParameteri(target, GL_TEXTURE_MIN_FILTER, filter);
    glTexParameteri(target, GL_TEXTURE_MAG_FILTER, filter);
    glColor4f(opacity, opacity, opacity, opacity);
    float x = aRect.origin.x, y = aRect.origin.y;
    float maxX = aRect.size.width + x, maxY = aRect.size.height + y;
    // Fix: the original put the bottom corners at the rect's x for y.
    glBegin(GL_QUADS);
    glTexCoord2fv(lowerLeft);
    glVertex2f(x, y);
    glTexCoord2fv(upperLeft);
    glVertex2f(x, maxY);
    glTexCoord2fv(upperRight);
    glVertex2f(maxX, maxY);
    glTexCoord2fv(lowerRight);
    glVertex2f(maxX, y);
    glEnd();
    glColor4f(1, 1, 1, 1);
    if (isOffscreen)
        glDisable(GL_BLEND);
    else {
        if (!blendWasEnabled)
            glDisable(GL_BLEND);
        if (equationRGB != GL_FUNC_ADD || equationAlpha != GL_FUNC_ADD)
            glBlendEquationSeparate(equationRGB, equationAlpha);
        if (sourceRGB != GL_ONE || destinationRGB != GL_ONE_MINUS_SRC_ALPHA || sourceAlpha != GL_ONE || destinationAlpha != GL_ONE_MINUS_SRC_ALPHA)
            glBlendFuncSeparate(sourceRGB, destinationRGB, sourceAlpha, destinationAlpha);
    }
    if (!targetWasEnabled)
        glDisable(target);
    glBindTexture(target, 0);
    glActiveTexture(GL_TEXTURE1);
    if (!texture3DWasEnabled)
        glDisable(GL_TEXTURE_3D);
    glBindTexture(GL_TEXTURE_3D, 0);
    glActiveTexture(GL_TEXTURE0);
    glUseProgram(previousProgram);
    if (isOffscreen)
        [_offscreenOpenGLRenderer endOpenGLLayerForCGContext];
}

- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2
{
    [self drawCurrentFrameInRect:aRect fromRelativeRect:aRect2 withTransparentColor:nil hueTolerance:0 chromaTolerance:0 lightnessTolerance:0];
}

- (struct CGImage *)currentFrameImage
{
    if (_currentFrameImage == NULL && [self HSMovieOpenGLRenderer_currentFramePixelBufferLink] != nil)
        _currentFrameImage = [_currentFramePixelBufferLink newImageWithDecode:NULL interpolation:YES colorRenderingIntent:kCGRenderingIntentDefault];
    return _currentFrameImage;
}

// The frame texture drawn (upside down: pixel buffers run top down) into
// the offscreen drawable and read back.
- (id)HSMovieOpenGLRenderer_currentFramePixelBufferLink
{
    if (_currentFramePixelBufferLink != nil)
        return _currentFramePixelBufferLink;
    CVOpenGLTextureRef frame = [self currentFrameImageBuffer];
    if (frame == NULL)
        return nil;
    CGRect clean = CVImageBufferGetCleanRect(frame);
    long width = lroundf(clean.size.width);
    long height = lroundf(clean.size.height);
    if (width == 0 || height == 0)
        return nil;
    [_offscreenOpenGLRenderer setPixelsWide:width pixelsHigh:height statically:YES];
    [_offscreenOpenGLRenderer removeAllPixelBufferAttachmentsForMode:kCVAttachmentMode_ShouldPropagate];
    CFDictionaryRef attachments = CVBufferGetAttachments(frame, kCVAttachmentMode_ShouldPropagate);
    if (attachments != NULL)
        [_offscreenOpenGLRenderer setPixelBufferAttachments:(CFMutableDictionaryRef)attachments mode:kCVAttachmentMode_ShouldPropagate];
    if ([_offscreenOpenGLRenderer lockOpenGLFocus] == nil)
        return nil;
    CGLContextObj cgl_ctx = _coreGLContext;
    [self HSMovieOpenGLRenderer_prepareOffscreenOpenGLContextIfNeeded];
    GLboolean multisample = glIsEnabled(GL_MULTISAMPLE);
    if (multisample)
        glDisable(GL_MULTISAMPLE);
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    GLenum target = CVOpenGLTextureGetTarget(frame);
    glEnable(target);
    glBindTexture(target, CVOpenGLTextureGetName(frame));
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    GLfloat lowerLeft[2], lowerRight[2], upperRight[2], upperLeft[2];
    CVOpenGLTextureGetCleanTexCoords(frame, lowerLeft, lowerRight, upperRight, upperLeft);
    glBegin(GL_QUADS);
    glTexCoord2fv(lowerLeft);
    glVertex2f(-1, 1);
    glTexCoord2fv(upperLeft);
    glVertex2f(-1, -1);
    glTexCoord2fv(upperRight);
    glVertex2f(1, -1);
    glTexCoord2fv(lowerRight);
    glVertex2f(1, 1);
    glEnd();
    glDisable(target);
    glDisable(GL_BLEND);
    glBlendFuncSeparate(GL_ONE, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    if (multisample)
        glEnable(GL_MULTISAMPLE);
    _currentFramePixelBufferLink = [_offscreenOpenGLRenderer unlockOpenGLFocusAsPixelBufferLink];
    return _currentFramePixelBufferLink;
}

- (void)HSMovieOpenGLRenderer_prepareOffscreenOpenGLContextIfNeeded
{
    if (_isOffscreenOpenGLPrepared)
        return;
    CGLContextObj cgl_ctx = _coreGLContext;
    glClearColor(0, 0, 0, 0);
    glBlendEquation(GL_FUNC_ADD);
    glBlendFuncSeparate(GL_ONE, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    _isOffscreenOpenGLPrepared = 1;
}

// Binds the lookup table as a 3D texture (on the active unit), uploading it
// when it changed.
- (BOOL)HSMovieOpenGLRenderer_bindCLUTTextureIfNeededInOpenGLContext:(struct _CGLContextObject *)aContext
{
    CGLContextObj cgl_ctx = aContext;
    if (_colorLUTTexture != 0)
        glBindTexture(GL_TEXTURE_3D, _colorLUTTexture);
    if (_isColorLUTTextureValid)
        return YES;
    if (_colorLUTTexture == 0) {
        glGenTextures(1, &_colorLUTTexture);
        if (_colorLUTTexture == 0)
            return _isColorLUTTextureValid;
        glBindTexture(GL_TEXTURE_3D, _colorLUTTexture);
        glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    }
    GLint rowLength = 0, alignment = 4;
    GLboolean clientStorage = GL_FALSE;
    glGetIntegerv(GL_UNPACK_ROW_LENGTH, &rowLength);
    glGetIntegerv(GL_UNPACK_ALIGNMENT, &alignment);
    glGetBooleanv(GL_UNPACK_CLIENT_STORAGE_APPLE, &clientStorage);
    if (rowLength != 0)
        glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
    if (alignment != 4)
        glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
    if (!clientStorage)
        glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
    GLsizei count = _colorLUTGridPointCount;
    glTexImage3D(GL_TEXTURE_3D, 0, GL_RGBA, count, count, count, 0, GL_RGBA, GL_UNSIGNED_BYTE, _colorLUT);
    if (!clientStorage)
        glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_FALSE);
    if (rowLength != 0)
        glPixelStorei(GL_UNPACK_ROW_LENGTH, rowLength);
    if (alignment != 4)
        glPixelStorei(GL_UNPACK_ALIGNMENT, alignment);
    _isColorLUTTextureValid = 1;
    return YES;
}

// Makes the lookup table from sRGB to the destination profile when the
// destination changes; none is needed (and the texture counts as valid) when
// the destination is sRGB. Profiles are told apart by their MD5.
- (BOOL)HSMovieOpenGLRenderer_updateColorLUTIfNeededWithDestinationColorProfile:(struct OpaqueCMProfileRef *)aProfile
{
    char *colorLUT = _colorLUT;
    ColorSyncMD5 working = ColorSyncProfileGetMD5((ColorSyncProfileRef)_workingColorProfile);
    ColorSyncMD5 destination = ColorSyncProfileGetMD5((ColorSyncProfileRef)aProfile);
    BOOL result = NO;
    if (memcmp(destination.digest, _destinationColorProfileMD5, sizeof(_destinationColorProfileMD5)) != 0) {
        _isColorLUTTextureValid = 0;
        if (_colorLUT == NULL) {
            if (_frameOpenGLProgram2D != NULL) {
                _frameOpenGLProgram2D->f6 = 0;
                _frameOpenGLProgram2D->f7 = 0;
            }
            if (_frameOpenGLProgram2DRect != NULL) {
                _frameOpenGLProgram2DRect->f6 = 0;
                _frameOpenGLProgram2DRect->f7 = 0;
            }
        }
        memcpy(_destinationColorProfileMD5, destination.digest, sizeof(_destinationColorProfileMD5));
        colorLUT = NULL;
    }
    if (memcmp(destination.digest, working.digest, sizeof(destination.digest)) == 0) {
        _isColorLUTTextureValid = 1;
        if (_colorLUT != NULL) {
            if (_frameOpenGLProgram2D != NULL) {
                _frameOpenGLProgram2D->f6 = 0;
                _frameOpenGLProgram2D->f7 = 0;
            }
            if (_frameOpenGLProgram2DRect != NULL) {
                _frameOpenGLProgram2DRect->f6 = 0;
                _frameOpenGLProgram2DRect->f7 = 0;
            }
        }
        result = YES;
    } else if (colorLUT == NULL) {
        _colorLUTGridPointCount = kHSMovieOpenGLRendererColorLUTGridPointCount;
        if (_colorLUT == NULL)
            _colorLUT = malloc(_colorLUTGridPointCount * _colorLUTGridPointCount * _colorLUTGridPointCount * 4);
        if (_colorLUT != NULL && HSMovieOpenGLRendererFillColorLUT((ColorSyncProfileRef)_workingColorProfile, (ColorSyncProfileRef)aProfile, _colorLUTGridPointCount, (UInt8 *)_colorLUT)) {
            colorLUT = _colorLUT;
            result = YES;
        }
    } else
        result = YES;
    if (colorLUT != _colorLUT) {
        if (CGLLockContext(_coreGLContext) == kCGLNoError) {
            CGLContextObj cgl_ctx = _coreGLContext;
            if (_colorLUTTexture != 0) {
                glDeleteTextures(1, &_colorLUTTexture);
                _colorLUTTexture = 0;
            }
            CGLUnlockContext(_coreGLContext);
        }
        free(_colorLUT);
        _colorLUT = NULL;
    }
    return result;
}

// A fragment shader in a program; its source is set by
// HSMovieOpenGLRenderer_updateFrameOpenGLProgram:forTextureRectangle:matchColors:.
- (struct __HSFrameOpenGLProgram *)HSMovieOpenGLRenderer_createFrameOpenGLProgram
{
    struct __HSFrameOpenGLProgram *program = malloc(sizeof(struct __HSFrameOpenGLProgram));
    if (program == NULL)
        return NULL;
    CGLContextObj cgl_ctx = _coreGLContext;
    program->f1 = glCreateShader(GL_FRAGMENT_SHADER);
    if (program->f1 != 0) {
        program->f0 = glCreateProgram();
        if (program->f0 != 0) {
            glAttachShader(program->f0, program->f1);
            glDeleteShader(program->f1);
            // Fix: the original left the locations a program may not have
            // unset; -1 makes setting them do nothing.
            program->f2 = -1;
            program->f3 = -1;
            program->f4 = -1;
            program->f5.f1.transparentColorLocation = -1;
            program->f5.f1.transparentColorHCLLocation = -1;
            program->f5.f1.transparentColorToleranceHCLLocation = -1;
            program->f6 = 0;
            program->f7 = 0;
            return program;
        }
        glDeleteShader(program->f1);
    }
    free(program);
    return NULL;
}

- (void)invalidateCurrentFrame
{
    CGImageRelease(_currentFrameImage);
    _currentFrameImage = NULL;
    [_currentFramePixelBufferLink release];
    _currentFramePixelBufferLink = nil;
    [super invalidateCurrentFrame];
}

- (void)didUpdateCurrentFrameImageBuffer:(struct __CVBuffer *)aBuffer
{
    [super didUpdateCurrentFrameImageBuffer:aBuffer];
    if (aBuffer == NULL)
        return;
    if (CVBufferGetAttachment(aBuffer, kCVImageBufferCGColorSpaceKey, NULL) == NULL)
        CVBufferSetAttachment(aBuffer, kCVImageBufferCGColorSpaceKey, _workingCGColorSpace, kCVAttachmentMode_ShouldPropagate);
    CGLContextObj cgl_ctx = _coreGLContext;
    GLenum target = CVOpenGLTextureGetTarget(aBuffer);
    glBindTexture(target, CVOpenGLTextureGetName(aBuffer));
    glTexParameteri(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)dealloc
{
    CGImageRelease(_currentFrameImage);
    [_currentFramePixelBufferLink release];
    if (_coreGLContext != NULL && (_colorLUTTexture != 0 || _frameOpenGLProgram2D != NULL || _frameOpenGLProgram2DRect != NULL)
        && CGLLockContext(_coreGLContext) == kCGLNoError) {
        CGLContextObj cgl_ctx = _coreGLContext;
        if (_frameOpenGLProgram2D != NULL) {
            glDeleteProgram(_frameOpenGLProgram2D->f0);
            free(_frameOpenGLProgram2D);
        }
        if (_frameOpenGLProgram2DRect != NULL) {
            glDeleteProgram(_frameOpenGLProgram2DRect->f0);
            free(_frameOpenGLProgram2DRect);
        }
        if (_colorLUTTexture != 0)
            glDeleteTextures(1, &_colorLUTTexture);
        CGLUnlockContext(_coreGLContext);
    }
    free(_colorLUT);
    [_offscreenOpenGLRenderer release];
    [_textureOpenGLDrawable release];
    [_workingColorSpace release];
    CGColorSpaceRelease(_workingCGColorSpace);
    if (_workingColorProfile != NULL)
        CFRelease(_workingColorProfile);
    [super dealloc];
}

// An accelerated context (multisampled if possible) able to run fragment
// shaders, and an OpenGL texture visual context on it putting out sRGB.
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage
{
    _workingColorProfile = (struct OpaqueCMProfileRef *)CSEProfileCreateWithName((CFStringRef)kCSEsRGBProfile);
    if (_workingColorProfile != NULL)
        _workingCGColorSpace = CGColorSpaceCreateWithPlatformColorSpace(_workingColorProfile);
    if (_workingCGColorSpace != NULL)
        _workingColorSpace = [[NSColorSpace alloc] initWithColorSyncProfile:_workingColorProfile];
    if (_workingColorSpace != nil) {
        unsigned int attributes[] = {
            NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, NSOpenGLPFASampleBuffers, 1, NSOpenGLPFASamples, 6, 0,
            NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, 0,
            0
        };
        NSEOpenGLContext *context = [NSEOpenGLContext contextWithFormatAttributesSequence:attributes shareCategory:NSEDefaultOpenGLContextShareCategory];
        if (context != nil) {
            CGLContextObj cgl_ctx = [context CGLContextObj];
            _coreGLContext = cgl_ctx;
            const char *version = (const char *)glGetString(GL_VERSION);
            const GLubyte *extensions;
            if (version != NULL
                && (strncmp(version, "2.0", 3) >= 0
                    || ((extensions = glGetString(GL_EXTENSIONS)) != NULL && gluCheckExtension((const GLubyte *)"GL_ARB_shader_objects", extensions)
                        && gluCheckExtension((const GLubyte *)"GL_ARB_fragment_shader", extensions)))) {
                NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:(id)_workingCGColorSpace, kQTVisualContextOutputColorSpaceKey, nil];
                QTVisualContextRef visualContext = NULL;
                if (options != nil
                    && QTOpenGLTextureContextCreate(kCFAllocatorDefault, cgl_ctx, [[context format] CGLPixelFormatObj], (CFDictionaryRef)options, &visualContext) == noErr
                    && visualContext != NULL) {
                    self = [super initWithQTMovie:aMovie storage:aStorage visualContext:visualContext];
                    // Fix: the original keeps its own reference to the context too.
                    QTVisualContextRelease(visualContext);
                    if (self == nil)
                        return nil;
                    _offscreenOpenGLRenderer = [[NSEPixelBufferOpenGLDrawable alloc] initWithOpenGLContext:context];
                    if (_offscreenOpenGLRenderer != nil) {
                        [_offscreenOpenGLRenderer setPixelBufferExtensionDisabled:YES];
                        return self;
                    }
                }
            }
        }
    }
    [super release];
    return nil;
}

- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage visualContext:(struct OpaqueQTVisualContext *)aContext
{
    [self release];
    return nil;
}

@end
