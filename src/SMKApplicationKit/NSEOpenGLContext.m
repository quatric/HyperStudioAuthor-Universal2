#import "NSEOpenGLContext.h"
#import <OpenGL/CGLMacro.h>
#import <pthread.h>

typedef struct __NSEOpenGLContextShareRecord ShareRecord;

// Guards the share records and categories (and each record's contexts).
static pthread_rwlock_t shareLock = PTHREAD_RWLOCK_INITIALIZER;
static CFMutableSetRef shareRecords;
// Category -> set of the share records' context sets.
static CFMutableDictionaryRef categoryContexts;

// The textures of a pixel buffer are keyed by themselves or, to look one up,
// by this ({NULL, ...} where an object has its class).
typedef struct {
    void *isa;
    NSUInteger target;
    NSInteger border;
} TextureKey;

static void getTextureKey(const void *key, NSUInteger *target, NSInteger *border)
{
    const TextureKey *k = key;
    if (!k->isa) {
        *target = k->target;
        *border = k->border;
    }
    else {
        *target = [(__NSEPixelBufferOpenGLTexture *)key target];
        *border = [(__NSEPixelBufferOpenGLTexture *)key border];
    }
}

static CFStringRef textureKeyDescription(const void *key)
{
    NSUInteger target;
    NSInteger border;
    getTextureKey(key, &target, &border);
    return CFStringCreateWithFormat(NULL, NULL, CFSTR("<target: 0x%lx, border: %li>"), (unsigned long)target, (long)border);
}

static Boolean textureKeysEqual(const void *a, const void *b)
{
    NSUInteger targetA, targetB;
    NSInteger borderA, borderB;
    getTextureKey(a, &targetA, &borderA);
    getTextureKey(b, &targetB, &borderB);
    return targetA == targetB && borderA == borderB;
}

static CFHashCode textureKeyHash(const void *key)
{
    NSUInteger target;
    NSInteger border;
    getTextureKey(key, &target, &border);
    return (target & 0x7fffffff) + ((CFHashCode)border << 31);
}

static const void *serviceRetain(CFAllocatorRef allocator, const void *value)
{
    return [(id)value serviceRetain];
}

static void serviceRelease(CFAllocatorRef allocator, const void *value)
{
    [(id)value serviceRelease];
}

// A buffer's entry: one texture or a dictionary of them.
static const void *entryRetain(CFAllocatorRef allocator, const void *value)
{
    if (CFGetTypeID(value) == CFDictionaryGetTypeID())
        return CFRetain(value);
    return [(id)value serviceRetain];
}

static void entryRelease(CFAllocatorRef allocator, const void *value)
{
    if (CFGetTypeID(value) == CFDictionaryGetTypeID())
        CFRelease(value);
    else
        [(id)value serviceRelease];
}

static CFStringRef shareRecordDescription(const void *record)
{
    return CFStringCreateWithFormat(NULL, NULL, CFSTR("<struct __NSEOpenGLContextShareRecord: %p>"), record);
}

static const void *anySetValue(CFSetRef set)
{
    CFIndex count = set ? CFSetGetCount(set) : 0;
    if (!count)
        return NULL;
    const void **values = malloc(count * sizeof *values);
    if (!values)
        return NULL;
    CFSetGetValues(set, values);
    const void *value = values[0];
    free(values);
    return value;
}

// Collects a context of each context set: the context, or a set of them.
static void collectShareContext(const void *contexts, void *context)
{
    CFTypeRef *found = context;
    id shareContext = (id)anySetValue(contexts);
    if (!shareContext)
        return;
    if (!*found)
        *found = [shareContext retain];
    else if (CFGetTypeID(*found) == CFSetGetTypeID())
        CFSetSetValue((CFMutableSetRef)*found, shareContext);
    else {
        CFMutableSetRef set = CFSetCreateMutable(NULL, 0, &kCFTypeSetCallBacks);
        if (set) {
            CFSetSetValue(set, shareContext);
            CFSetSetValue(set, *found);
            [(id)*found release];
            *found = set;
        }
    }
}

static void invalidateTexture(const void *texture, void *context)
{
    [(id)texture invalidate];
}

static void freeShareRecord(ShareRecord *record)
{
    if (record->textures) {
        CFSetApplyFunction(record->textures, invalidateTexture, NULL);
        CFRelease(record->textures);
    }
    if (record->pixelBufferTextures)
        CFRelease(record->pixelBufferTextures);
    if (record->textureValidated) {
        pthread_cond_destroy(record->textureValidated);
        free(record->textureValidated);
    }
    pthread_mutex_destroy(&record->mutex);
    [record->category release];
    CFRelease(record->contexts);
    free(record);
}

// Forgets the textures of a pixel buffer that is going away.
static void removePixelBuffer(const void *value, void *buffer)
{
    ShareRecord *record = (ShareRecord *)value;
    if (!record->pixelBufferTextures)
        return;
    while (pthread_mutex_lock(&record->mutex));
    const void *entry = CFDictionaryGetValue(record->pixelBufferTextures, buffer);
    if (!entry) {
        pthread_mutex_unlock(&record->mutex);
        return;
    }
    entryRetain(NULL, entry);
    CFDictionaryRemoveValue(record->pixelBufferTextures, buffer);
    pthread_mutex_unlock(&record->mutex);
    entryRelease(NULL, entry);
}

// Removes a texture from a buffer's entry (the record's mutex held).
static void removeTexture(ShareRecord *record, CVPixelBufferRef buffer, const void *texture)
{
    CFTypeRef entry = CFDictionaryGetValue(record->pixelBufferTextures, buffer);
    if (!entry)
        return;
    if (entry == texture)
        CFDictionaryRemoveValue(record->pixelBufferTextures, buffer);
    else if (CFGetTypeID(entry) == CFDictionaryGetTypeID()) {
        if (CFDictionaryGetCount(entry) != 1)
            CFDictionaryRemoveValue((CFMutableDictionaryRef)entry, texture);
        else if (CFDictionaryContainsKey(entry, texture))
            CFDictionaryRemoveValue(record->pixelBufferTextures, buffer);
    }
}

// Whether the renderer is one whose textures should be cached in VRAM
// (shared, from client memory, is slow on them).
static BOOL prefersCachedTextures(CGLContextObj cgl_ctx)
{
    const char *vendor = (const char *)glGetString(GL_VENDOR);
    if (!vendor || strcmp(vendor, "NVIDIA Corporation"))
        return NO;
    const char *renderer = (const char *)glGetString(GL_RENDERER);
    return renderer && (!strcmp(renderer, "NVIDIA GeForce2 MX OpenGL Engine") ||
                        !strcmp(renderer, "NVIDIA GeForce4 MX OpenGL Engine"));
}

// An OpenGL context that shares its objects with the other contexts of its
// share category (when their formats allow it), knows its display's color
// space, and makes textures of pixel buffers, shared by the contexts.
@implementation NSEOpenGLContext

+ (id)contextWithFormatAttributesSequence:(unsigned int *)aSequence shareCategory:(id)aCategory
{
    NSOpenGLPixelFormat *format = [NSOpenGLPixelFormat NSE_pixelFormatWithAttributesSequence:aSequence];
    if (!format)
        return nil;
    return [self contextWithFormat:format shareCategory:aCategory];
}

+ (id)contextWithFormatAttributes:(unsigned int *)aAttributes shareCategory:(id)aCategory
{
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:(NSOpenGLPixelFormatAttribute *)aAttributes];
    if (!format)
        return nil;
    id context = [self contextWithFormat:format shareCategory:aCategory];
    [format release];
    return context;
}

// Shares with a context of the category if one can, else starts a share
// record of the category.
+ (id)contextWithFormat:(id)aFormat shareCategory:(id)aCategory
{
    CFTypeRef found = NULL;
    if (pthread_rwlock_rdlock(&shareLock))
        return nil;
    CFSetRef sets = categoryContexts && aCategory ? CFDictionaryGetValue(categoryContexts, aCategory) : NULL;
    if (sets)
        CFSetApplyFunction(sets, collectShareContext, &found);
    pthread_rwlock_unlock(&shareLock);
    NSEOpenGLContext *context = nil;
    if (found) {
        if (CFGetTypeID(found) == CFSetGetTypeID()) {
            for (id shareContext in (NSSet *)found)
                if ((context = [[NSEOpenGLContext alloc] initWithFormat:aFormat shareContext:shareContext]))
                    break;
        }
        else
            context = [[NSEOpenGLContext alloc] initWithFormat:aFormat shareContext:(id)found];
        CFRelease(found);
    }
    if (!context) {
        context = [[NSEOpenGLContext alloc] initWithFormat:aFormat shareContext:nil];
        if (!context)
            return nil;
        [context NSEOpenGLContext_shareInCategory:aCategory];
    }
    return [context autorelease];
}

+ (id)allocWithZone:(NSZone *)aZone
{
    NSEOpenGLContext *context = [super allocWithZone:aZone];
    if (context)
        context->_retainCount = 1;
    return context;
}

// The texture of the buffer's contents for the target and border, made (if
// asked) and bound. Options: 1 copies the contents (else the texture uses the
// buffer's memory, keeping it locked), 2 caches the texture in VRAM, 4 keeps
// the unpack state.
- (id)bindTextureForPixelBuffer:(struct __CVBuffer *)aBuffer target:(NSUInteger)aTarget border:(NSInteger)aBorder specifyingIfNeeded:(BOOL)aNeeded withOptions:(NSInteger)aOptions
{
    TextureKey key = { NULL, aTarget, aBorder };
    if (!_shareRecord) {
        if (![self NSEOpenGLContext_createShareRecordAddingShareContext:nil remainingLocked:YES])
            return nil;
    }
    else if (!_shareRecord->pixelBufferTextures && pthread_rwlock_wrlock(&shareLock))
        return nil;
    ShareRecord *record = _shareRecord;
    if (!record->pixelBufferTextures) {
        // The write lock is held.
        if (!record->textures) {
            CFSetCallBacks callBacks = { 0, serviceRetain, serviceRelease, kCFTypeSetCallBacks.copyDescription,
                                         NULL, kCFEAlignedPointerSetCallBacks.hash };
            record->textures = CFSetCreateMutable(NULL, 0, &callBacks);
        }
        if (record->textures) {
            CFDictionaryValueCallBacks valueCallBacks = { 0, entryRetain, entryRelease,
                                                          kCFTypeDictionaryValueCallBacks.copyDescription, NULL };
            record->pixelBufferTextures = CFDictionaryCreateMutable(NULL, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks,
                                                                    &valueCallBacks);
        }
        pthread_rwlock_unlock(&shareLock);
        if (!record->pixelBufferTextures)
            return nil;
    }

    if (pthread_mutex_lock(&record->mutex))
        return nil;
    __NSEPixelBufferOpenGLTexture *texture = nil;
    BOOL isNewBuffer = NO;
    CFTypeRef entry = CFDictionaryGetValue(record->pixelBufferTextures, aBuffer);
    CFMutableDictionaryRef textures = NULL;
    if (!entry)
        isNewBuffer = YES;
    else if (CFGetTypeID(entry) == CFDictionaryGetTypeID()) {
        textures = (CFMutableDictionaryRef)entry;
        texture = (id)CFDictionaryGetValue(textures, &key);
        entry = NULL;
    }
    else if ([(__NSEPixelBufferOpenGLTexture *)entry target] == aTarget && [(__NSEPixelBufferOpenGLTexture *)entry border] == aBorder) {
        texture = (id)entry;
        entry = NULL;
    }

    if (texture) {
        // Another thread may still be specifying it.
        [texture retain];
        while (![texture isValidated]) {
            if (!record->textureValidated) {
                pthread_cond_t *condition = malloc(sizeof *condition);
                if (!condition)
                    break;
                if (pthread_cond_init(condition, NULL)) {
                    free(condition);
                    break;
                }
                record->textureValidated = condition;
            }
            if (pthread_cond_wait(record->textureValidated, &record->mutex))
                break;
        }
        if (![texture isValid]) {
            [texture release];
            texture = nil;
        }
        isNewBuffer = NO;
    }
    else if (aNeeded) {
        texture = [[__NSEPixelBufferOpenGLTexture alloc] initWithShareContexts:record->contexts target:aTarget
                                                                        border:aBorder pixelBuffer:aBuffer];
        if (texture) {
            if (textures)
                CFDictionarySetValue(textures, texture, texture);
            else if (!entry)
                CFDictionarySetValue(record->pixelBufferTextures, aBuffer, texture);
            else {
                // A second texture of the buffer.
                CFDictionaryKeyCallBacks keyCallBacks = { 0, NULL, NULL, textureKeyDescription, textureKeysEqual, textureKeyHash };
                CFDictionaryValueCallBacks valueCallBacks = { 0, serviceRetain, serviceRelease,
                                                              kCFTypeDictionaryValueCallBacks.copyDescription, NULL };
                textures = CFDictionaryCreateMutable(NULL, 0, &keyCallBacks, &valueCallBacks);
                if (!textures) {
                    [texture validateWithName:0 pixelBuffer:NO];
                    [texture release];
                    texture = nil;
                }
                else {
                    CFDictionarySetValue(textures, entry, entry);
                    CFDictionarySetValue(textures, texture, texture);
                    CFDictionarySetValue(record->pixelBufferTextures, aBuffer, textures);
                    CFRelease(textures);
                }
            }
        }
    }
    pthread_mutex_unlock(&record->mutex);
    if (!texture)
        return nil;

    CGLContextObj cgl_ctx = [self CGLContextObj];
    GLuint name = (GLuint)[texture name];
    if (name) {
        glBindTexture((GLenum)aTarget, name);
        if (aNeeded && (aOptions & 2))
            glTexParameteri((GLenum)aTarget, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_CACHED_APPLE);
        return [texture autorelease];
    }

    // Specify it.
    GLboolean clientStorage = !(aOptions & 1);
    BOOL removerAttached = YES;
    if (isNewBuffer) {
        __NSEOpenGLContextShareRecordPixelBufferRemover *remover =
            [[__NSEOpenGLContextShareRecordPixelBufferRemover alloc] initWithPixelBuffer:aBuffer];
        if (remover) {
            CVBufferSetAttachment(aBuffer, CFSTR("__NSEOpenGLContextShareRecordPixelBufferRemover"), remover,
                                  kCVAttachmentMode_ShouldNotPropagate);
            [remover release];
        }
        else
            removerAttached = NO;
    }
    GLint internalFormat = 0, rowLength = 0, alignment = 0;
    GLenum format = 0, type = 0;
    if (removerAttached && CVEPixelBufferIsOpenGLCompatible(aBuffer, &internalFormat, &format, &type, &rowLength, &alignment) &&
        CVPixelBufferLockBaseAddress(aBuffer, kCVPixelBufferLock_ReadOnly) == kCVReturnSuccess) {
        void *base = CVPixelBufferGetBaseAddress(aBuffer);
        if (base && (glGenTextures(1, &name), name)) {
            glBindTexture((GLenum)aTarget, name);
            GLint hint = (aOptions & 2) || prefersCachedTextures(cgl_ctx) ? GL_STORAGE_CACHED_APPLE : GL_STORAGE_SHARED_APPLE;
            glTexParameteri((GLenum)aTarget, GL_TEXTURE_STORAGE_HINT_APPLE, hint);
            glTexParameteri((GLenum)aTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            GLint savedRowLength = 0, savedAlignment = 0;
            GLboolean savedClientStorage = GL_FALSE;
            if (aOptions & 4) {
                glGetIntegerv(GL_UNPACK_ROW_LENGTH, &savedRowLength);
                glGetIntegerv(GL_UNPACK_ALIGNMENT, &savedAlignment);
                glGetBooleanv(GL_UNPACK_CLIENT_STORAGE_APPLE, &savedClientStorage);
                if (rowLength != savedRowLength)
                    glPixelStorei(GL_UNPACK_ROW_LENGTH, rowLength);
                if (alignment != savedAlignment)
                    glPixelStorei(GL_UNPACK_ALIGNMENT, alignment);
                if (!clientStorage != !savedClientStorage)
                    glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, clientStorage);
            }
            else {
                glPixelStorei(GL_UNPACK_ROW_LENGTH, rowLength);
                glPixelStorei(GL_UNPACK_ALIGNMENT, alignment);
                glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, clientStorage);
            }
            glTexImage2D((GLenum)aTarget, 0, internalFormat, (GLsizei)CVPixelBufferGetWidth(aBuffer),
                         (GLsizei)CVPixelBufferGetHeight(aBuffer), (GLint)aBorder, format, type, base);
            if (aOptions & 4) {
                if (!clientStorage != !savedClientStorage)
                    glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, savedClientStorage);
                if (savedRowLength != rowLength)
                    glPixelStorei(GL_UNPACK_ROW_LENGTH, savedRowLength);
                if (savedAlignment != alignment)
                    glPixelStorei(GL_UNPACK_ALIGNMENT, savedAlignment);
            }
        }
        // The texture keeps the buffer locked while it uses its memory.
        if (!clientStorage || !name)
            CVPixelBufferUnlockBaseAddress(aBuffer, kCVPixelBufferLock_ReadOnly);
    }

    while (pthread_mutex_lock(&record->mutex));
    [texture validateWithName:name pixelBuffer:clientStorage];
    if (!name) {
        CFTypeRef current = CFDictionaryGetValue(record->pixelBufferTextures, aBuffer);
        if (current == (CFTypeRef)texture)
            CFDictionaryRemoveValue(record->pixelBufferTextures, aBuffer);
        else if (current && CFGetTypeID(current) == CFDictionaryGetTypeID()) {
            if (CFDictionaryGetCount(current) != 1)
                CFDictionaryRemoveValue((CFMutableDictionaryRef)current, &key);
            else if (CFDictionaryContainsKey(current, &key))
                CFDictionaryRemoveValue(record->pixelBufferTextures, aBuffer);
        }
        [texture release];
        texture = nil;
    }
    else
        CFSetSetValue(record->textures, texture);
    if (record->textureValidated)
        pthread_cond_broadcast(record->textureValidated);
    pthread_mutex_unlock(&record->mutex);
    return [texture autorelease];
}

// glFlush for a single buffered context.
- (void)flush
{
    GLint doubleBuffer = 0;
    [_format getValues:&doubleBuffer forAttribute:NSOpenGLPFADoubleBuffer forVirtualScreen:[self currentVirtualScreen]];
    if (!doubleBuffer) {
        CGLContextObj cgl_ctx = [self CGLContextObj];
        glFlush();
    }
    else
        [self flushBuffer];
}

- (void)setCurrentVirtualScreen:(NSInteger)aScreen
{
    [self invalidateColorProfile];
    [super setCurrentVirtualScreen:(GLint)aScreen];
}

- (void)getValues:(int *)aValues forParameter:(NSInteger)aParameter
{
    if (aParameter == NSOpenGLContextParameterSurfaceOpacity)
        *aValues = !_isSurfaceTransparent;
    else
        [super getValues:aValues forParameter:aParameter];
}

- (void)setValues:(int *)aValues forParameter:(NSInteger)aParameter
{
    if (aParameter == NSOpenGLContextParameterSurfaceOpacity)
        _isSurfaceTransparent = *aValues == 0;
    [super setValues:aValues forParameter:aParameter];
}

- (void)invalidateColorProfile
{
    [_colorSpace release];
    _colorSpace = nil;
    CGColorSpaceRelease(_coreGraphicsColorSpace);
    _coreGraphicsColorSpace = NULL;
    if (_colorSyncProfile) {
        CFRelease(_colorSyncProfile);
        _colorSyncProfile = NULL;
    }
}

- (id)colorSpace
{
    if (!_colorSpace && [self colorSyncProfile])
        _colorSpace = [[NSColorSpace alloc] initWithColorSyncProfile:_colorSyncProfile];
    return _colorSpace;
}

- (struct CGColorSpace *)CGColorSpace
{
    if (!_coreGraphicsColorSpace && [self colorSyncProfile])
        _coreGraphicsColorSpace = CGColorSpaceCreateWithPlatformColorSpace(_colorSyncProfile);
    return _coreGraphicsColorSpace;
}

// The profile of the display of the current virtual screen (a
// ColorSyncProfileRef).
- (struct OpaqueCMProfileRef *)colorSyncProfile
{
    if (!_colorSyncProfile) {
        GLint mask = 0;
        [_format getValues:&mask forAttribute:NSOpenGLPFAScreenMask forVirtualScreen:[self currentVirtualScreen]];
        if (mask) {
            CGDirectDisplayID display = CGOpenGLDisplayMaskToDisplayID(mask);
            if (display)
                _colorSyncProfile = (struct OpaqueCMProfileRef *)ColorSyncProfileCreateWithDisplayID(display);
        }
    }
    return _colorSyncProfile;
}

- (void)update
{
    [self invalidateColorProfile];
    [super update];
}

- (void)clearDrawable
{
    [self invalidateColorProfile];
    [super clearDrawable];
}

- (id)shareCategory
{
    return _shareRecord ? _shareRecord->category : nil;
}

- (BOOL)sharesContext:(id)aContext
{
    return _shareRecord && _shareRecord == [aContext NSEOpenGLContext_shareRecord];
}

- (id)format
{
    return _format;
}

// The last release takes the context out of its share record (and the
// record out of its category when it was the last context).
- (void)release
{
    if (__atomic_sub_fetch(&_retainCount, 1, __ATOMIC_SEQ_CST) == 0 && _shareRecord) {
        while (pthread_rwlock_wrlock(&shareLock));
        CFSetRemoveValue(_shareRecord->contexts, self);
        if (CFSetGetCount(_shareRecord->contexts)) {
            pthread_rwlock_unlock(&shareLock);
        }
        else {
            CFSetRemoveValue(shareRecords, _shareRecord);
            NSString *category = _shareRecord->category;
            CFMutableSetRef sets = category && categoryContexts ? (CFMutableSetRef)CFDictionaryGetValue(categoryContexts, category) : NULL;
            if (sets) {
                if (CFSetGetCount(sets) != 1)
                    CFSetRemoveValue(sets, _shareRecord->contexts);
                else if (CFSetContainsValue(sets, _shareRecord->contexts))
                    CFDictionaryRemoveValue(categoryContexts, category);
            }
            pthread_rwlock_unlock(&shareLock);
            freeShareRecord(_shareRecord);
            _shareRecord = NULL;
        }
    }
    [super release];
}

- (id)retain
{
    __atomic_add_fetch(&_retainCount, 1, __ATOMIC_SEQ_CST);
    return [super retain];
}

- (void)dealloc
{
    [_colorSpace release];
    CGColorSpaceRelease(_coreGraphicsColorSpace);
    if (_colorSyncProfile)
        CFRelease(_colorSyncProfile);
    [_format release];
    [super dealloc];
}

- (id)initWithFormat:(id)aFormat shareContext:(id)aContext
{
    if (!(self = [super initWithFormat:aFormat shareContext:aContext]))
        return nil;
    if ([aContext isKindOfClass:[NSEOpenGLContext class]] &&
        !(_shareRecord = [aContext NSEOpenGLContext_addShareContext:self])) {
        [self release];
        return nil;
    }
    _format = [aFormat retain];
    return self;
}

- (id)initWithFormatAttributesSequence:(unsigned int *)aSequence shareContext:(id)aContext
{
    NSOpenGLPixelFormat *format = [NSOpenGLPixelFormat NSE_pixelFormatWithAttributesSequence:aSequence];
    if (!format) {
        [self release];
        return nil;
    }
    return [self initWithFormat:format shareContext:aContext];
}

- (id)initWithFormatAttributes:(unsigned int *)aAttributes shareContext:(id)aContext
{
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:(NSOpenGLPixelFormatAttribute *)aAttributes];
    if (!format) {
        [self release];
        return nil;
    }
    self = [self initWithFormat:format shareContext:aContext];
    [format release];
    return self;
}

- (void)NSEOpenGLContext_shareInCategory:(id)aCategory
{
    NSString *category = [aCategory copy];
    if (!category)
        return;
    if (!_shareRecord) {
        if (![self NSEOpenGLContext_createShareRecordAddingShareContext:nil remainingLocked:YES]) {
            [category release];
            return;
        }
    }
    else if (pthread_rwlock_wrlock(&shareLock)) {
        [category release];
        return;
    }
    if (!categoryContexts)
        categoryContexts = CFDictionaryCreateMutable(NULL, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if (categoryContexts) {
        CFMutableSetRef sets = (CFMutableSetRef)CFDictionaryGetValue(categoryContexts, category);
        if (!sets && (sets = CFSetCreateMutable(NULL, 0, &kCFEWeakObjectPointerSetCallBacks))) {
            CFDictionarySetValue(categoryContexts, category, sets);
            CFRelease(sets);
        }
        if (sets) {
            CFSetSetValue(sets, _shareRecord->contexts);
            [_shareRecord->category release];
            _shareRecord->category = category;
            category = nil;
        }
    }
    pthread_rwlock_unlock(&shareLock);
    [category release];
}

- (struct __NSEOpenGLContextShareRecord *)NSEOpenGLContext_addShareContext:(id)aContext
{
    if (!_shareRecord)
        [self NSEOpenGLContext_createShareRecordAddingShareContext:aContext remainingLocked:NO];
    else {
        if (pthread_rwlock_wrlock(&shareLock))
            return NULL;
        CFSetSetValue(_shareRecord->contexts, aContext);
        pthread_rwlock_unlock(&shareLock);
    }
    return _shareRecord;
}

- (BOOL)NSEOpenGLContext_createShareRecordAddingShareContext:(id)aContext remainingLocked:(BOOL)aLocked
{
    ShareRecord *record = calloc(1, sizeof *record);
    if (!record)
        return NO;
    if (!(record->contexts = CFSetCreateMutable(NULL, 0, &kCFEWeakObjectPointerSetCallBacks))) {
        free(record);
        return NO;
    }
    if (pthread_mutex_init(&record->mutex, NULL)) {
        CFRelease(record->contexts);
        free(record);
        return NO;
    }
    CFSetSetValue(record->contexts, self);
    if (aContext)
        CFSetSetValue(record->contexts, aContext);
    if (!pthread_rwlock_wrlock(&shareLock)) {
        if (!shareRecords) {
            CFSetCallBacks callBacks = { 0, NULL, NULL, shareRecordDescription, NULL, kCFEAlignedPointerSetCallBacks.hash };
            shareRecords = CFSetCreateMutable(NULL, 0, &callBacks);
        }
        if (shareRecords) {
            CFSetSetValue(shareRecords, record);
            _shareRecord = record;
            if (!aLocked)
                pthread_rwlock_unlock(&shareLock);
            return YES;
        }
        pthread_rwlock_unlock(&shareLock);
    }
    freeShareRecord(record);
    return NO;
}

- (struct __NSEOpenGLContextShareRecord *)NSEOpenGLContext_shareRecord
{
    return _shareRecord;
}

@end

// A pixel buffer's attachment: when the buffer goes, so do its textures.
@implementation __NSEOpenGLContextShareRecordPixelBufferRemover

- (void)dealloc
{
    if (shareRecords) {
        while (pthread_rwlock_rdlock(&shareLock));
        CFSetApplyFunction(shareRecords, removePixelBuffer, _pixelBuffer);
        pthread_rwlock_unlock(&shareLock);
    }
    [super dealloc];
}

- (id)initWithPixelBuffer:(struct __CVBuffer *)aBuffer
{
    if ((self = [super init]))
        _pixelBuffer = aBuffer;
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

// A texture of a pixel buffer, in the contexts of a share record. The record
// holds it by service retains; when the others' retains are gone it removes
// itself from the record and deletes its texture.
@implementation __NSEPixelBufferOpenGLTexture

+ (id)allocWithZone:(NSZone *)aZone
{
    __NSEPixelBufferOpenGLTexture *texture = [super allocWithZone:aZone];
    if (texture)
        texture->_effectiveRetainCount = 1;
    return texture;
}

// The buffer, while the texture uses its memory.
- (id)buffer
{
    return _isBufferOwner ? (id)_pixelBuffer : nil;
}

- (NSInteger)border
{
    return _border;
}

- (NSUInteger)target
{
    return _target;
}

- (NSUInteger)name
{
    return _name;
}

- (BOOL)isInContext:(id)aContext
{
    if (!_shareContexts)
        return NO;
    ShareRecord *record = [aContext NSEOpenGLContext_shareRecord];
    return record && record->contexts == _shareContexts;
}

- (void)invalidate
{
    if (__sync_bool_compare_and_swap(&_validnessBarrier, 1, 0))
        [self __NSEPixelBufferOpenGLTexture_invalidate];
}

- (BOOL)isValid
{
    return _shareContexts != NULL;
}

// A name of 0: it couldn't be made.
- (void)validateWithName:(NSUInteger)aName pixelBuffer:(BOOL)aBuffer
{
    if (!aName) {
        if (_shareContexts)
            CFRelease(_shareContexts);
        _shareContexts = NULL;
        return;
    }
    _validnessBarrier = 1;
    _name = (unsigned int)aName;
    if (aBuffer) {
        _isBufferOwner = 1;
        CVPixelBufferRetain(_pixelBuffer);
    }
}

- (BOOL)isValidated
{
    return _shareContexts ? _name != 0 : YES;
}

- (void)serviceRelease
{
    [super release];
}

- (id)serviceRetain
{
    return [super retain];
}

- (void)release
{
    if (__atomic_sub_fetch(&_effectiveRetainCount, 1, __ATOMIC_SEQ_CST) == 0 &&
        __sync_bool_compare_and_swap(&_validnessBarrier, 1, 2)) {
        while (pthread_rwlock_rdlock(&shareLock));
        NSEOpenGLContext *context = [(id)anySetValue(_shareContexts) retain];
        pthread_rwlock_unlock(&shareLock);
        if (context) {
            ShareRecord *record = [context NSEOpenGLContext_shareRecord];
            while (pthread_mutex_lock(&record->mutex));
            removeTexture(record, _pixelBuffer, self);
            CFSetRemoveValue(record->textures, self);
            pthread_mutex_unlock(&record->mutex);
            if (_name) {
                CGLContextObj cgl_ctx = [context CGLContextObj];
                if (CGLLockContext(cgl_ctx) == kCGLNoError) {
                    GLuint name = _name;
                    glDeleteTextures(1, &name);
                    CGLUnlockContext(cgl_ctx);
                }
            }
            [context release];
        }
        [self __NSEPixelBufferOpenGLTexture_invalidate];
    }
    [super release];
}

- (id)retain
{
    __atomic_add_fetch(&_effectiveRetainCount, 1, __ATOMIC_SEQ_CST);
    return [super retain];
}

- (void)__NSEPixelBufferOpenGLTexture_invalidate
{
    if (_shareContexts)
        CFRelease(_shareContexts);
    _shareContexts = NULL;
    if (_isBufferOwner)
        CVPixelBufferUnlockBaseAddress(_pixelBuffer, kCVPixelBufferLock_ReadOnly);
}

- (void)dealloc
{
    if (_isBufferOwner)
        CVPixelBufferRelease(_pixelBuffer);
    [super dealloc];
}

- (id)initWithShareContexts:(struct __CFSet *)aContexts target:(NSUInteger)aTarget border:(NSInteger)aBorder pixelBuffer:(struct __CVBuffer *)aBuffer
{
    if (!(self = [super init]))
        return nil;
    _shareContexts = (struct __CFSet *)CFRetain(aContexts);
    _target = (unsigned int)aTarget;
    _border = (int)aBorder;
    _pixelBuffer = aBuffer;
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

@implementation NSOpenGLPixelFormat (NSEOpenGLPixelFormat)

// The first format of the attribute lists (each ending with 0, the sequence
// with an empty list) that there is.
+ (id)NSE_pixelFormatWithAttributesSequence:(unsigned int *)aSequence
{
    NSOpenGLPixelFormat *format = nil;
    while (*aSequence) {
        if ((format = [[NSOpenGLPixelFormat alloc] initWithAttributes:(NSOpenGLPixelFormatAttribute *)aSequence]))
            break;
        while (*aSequence++);
    }
    return [format autorelease];
}

@end
