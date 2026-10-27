#import "HSMediaStripAnimatingFilmCan.h"

@implementation HSMediaStripAnimatingFilmCan

/* i386 ivar offsets: _images=0x50, _isRenderingEnabled=0x54, _renderedImageIndex=0x58 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00053160 @ 00053160, 189 bytes * /

id FUN_00053160(id self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id self_01;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  self_00 = _objc_msgSend(self,sel_distancesToRightEdgeInAnimation);
  pvVar1 = _objc_msgSend(self_00,sel_count);
  self_01 = _objc_msgSend(cls_NSMutableData,sel_dataWithLength_,(int)pvVar1 * 4);
  pvVar2 = _objc_msgSend(self_01,sel_mutableBytes);
  if (pvVar1 != (id)0x0) {
    pvVar4 = (id)0x0;
    do {
      pvVar3 = _objc_msgSend(self_00,sel_objectAtIndex_,pvVar4);
      pvVar3 = _objc_msgSend(pvVar3,sel_unsignedIntValue);
      *(id *)((int)pvVar2 + (int)pvVar4 * 4) = pvVar3;
      pvVar4 = (id)((int)pvVar4 + 1);
    } while (pvVar4 < pvVar1);
  }
  return self_01;
}

*/
+ (id)generatedDataForDistancesToRightEdgeInAnimation
{
    NSArray *distances = [self distancesToRightEdgeInAnimation];
    NSUInteger count = [distances count];
    NSMutableData *data = [NSMutableData dataWithLength:count * 4];
    unsigned int *bytes = [data mutableBytes];
    for (NSUInteger i = 0; i < count; i++) {
        bytes[i] = [[distances objectAtIndex:i] unsignedIntValue];
    }
    return data;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005301b @ 0005301b, 325 bytes * /

id FUN_0005301b(id self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  cfstringStruct *self_01;
  cfstringStruct *pcVar2;
  
  if (DAT_003427c8 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar2 = &cfstr_tiff;
    self_01 = &cfstr_FilmCan_Animation;
    pvVar1 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_,&cfstr_FilmCan_Animation,&cfstr_tiff);
    if (pvVar1 != (id)0x0) {
      self_00 = _objc_msgSend(cls_NSBitmapImageRep,sel_alloc,self_01,pcVar2);
      pvVar1 = _objc_msgSend(cls_NSData,sel_dataWithContentsOfFile_,pvVar1);
      pvVar1 = _objc_msgSend(self_00,sel_initWithData_,pvVar1);
      self_01 = _objc_msgSend(pvVar1,sel_autorelease);
      pvVar1 = _objc_msgSend(self_01,sel_pixelsHigh);
      pcVar2 = (cfstringStruct *)(int)(float)((int)pvVar1 / 0x62);
      DAT_003427c8 = _objc_msgSend(self,
                                   sel_calculateDistancesToRightEdgeInAnimationForRep_iconCount_,
                                   self_01,pcVar2);
    }
    if (DAT_003427c8 == (id)0x0) {
      DAT_003427c8 = _objc_msgSend(cls_NSArray,sel_new,self_01,pcVar2);
    }
  }
  return DAT_003427c8;
}

*/
+ (id)distancesToRightEdgeInAnimation
{
    static id distances = nil;
    if (distances == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FilmCan_Animation" ofType:@"tiff"];
        if (path != nil) {
            NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithData:[NSData dataWithContentsOfFile:path]] autorelease];
            NSInteger iconCount = (int)(float)((int)[rep pixelsHigh] / 0x62);
            distances = [self calculateDistancesToRightEdgeInAnimationForRep:rep iconCount:iconCount];
        }
        if (distances == nil) {
            distances = [NSArray new];
        }
    }
    return distances;
}

+ (id)calculateDistancesToRightEdgeInAnimationForRep:(id)aRep iconCount:(NSInteger)aCount
{
    id pvVar1;
    int iVar3;

    pvVar1 = [NSMutableArray array];
    if (0 < aCount) {
        iVar3 = 0;
        do {
            [pvVar1 addObject:[NSNumber numberWithUnsignedInt:[self calculateDistanceToRightEdgeForIconWithRep:aRep iconCount:aCount animationStep:iVar3]]];
            iVar3 = iVar3 + 1;
        } while (aCount != iVar3);
    }
    return [[NSArray alloc] initWithArray:pvVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005326b @ 0005326b, 751 bytes * /

uint FUN_0005326b(id self,SEL _cmd,id calculateDistanceToRightEdgeForIconWithRep,int iconCount,
                 int animationStep)

{
  void *pvVar1;
  undefined4 uVar2;
  int iVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  size_t sVar10;
  id pvVar11;
  int iVar12;
  int iVar13;
  float fVar14;
  float fVar15;
  float fVar16;
  double dVar17;
  size_t sVar18;
  int local_1c;
  
  pvVar4 = _objc_msgSend(calculateDistanceToRightEdgeForIconWithRep,sel_pixelsHigh);
  pvVar5 = _objc_msgSend(calculateDistanceToRightEdgeForIconWithRep,sel_pixelsWide);
  pvVar6 = _objc_msgSend(calculateDistanceToRightEdgeForIconWithRep,sel_bitsPerPixel);
  pvVar7 = _objc_msgSend(calculateDistanceToRightEdgeForIconWithRep,sel_samplesPerPixel);
  pvVar8 = _objc_msgSend(cls_NSBitmapImageRep,sel_alloc);
  uVar2 = *(undefined4 *)PTR_00336350;
  pvVar9 = _objc_msgSend(calculateDistanceToRightEdgeForIconWithRep,sel_hasAlpha);
  pvVar11 = (id)(int)(float)(int)pvVar5;
  sVar10 = (size_t)((float)((int)pvVar6 >> 3) * (float)(int)pvVar5);
  fVar14 = (float)((int)pvVar4 / iconCount);
  sVar18 = 0;
  pvVar4 = _objc_msgSend(pvVar8,
                         sel_initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel_
                         ,0,pvVar11,(int)fVar14,(int)pvVar6 / (int)pvVar7,pvVar7,(uint)pvVar9 & 0xff
                         ,0,uVar2,sVar10,pvVar6);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  pvVar5 = _objc_msgSend(calculateDistanceToRightEdgeForIconWithRep,sel_bitmapData);
  pvVar6 = _objc_msgSend(pvVar4,sel_bitmapData);
  if (0.0 < fVar14) {
    iVar13 = 0;
    iVar12 = 1;
    do {
      iVar3 = iVar13 + (int)fVar14 * sVar10 * animationStep;
      pvVar1 = (void *)((int)pvVar6 + iVar13);
      iVar13 = iVar13 + sVar10;
      sVar18 = sVar10;
      _memcpy(pvVar1,(void *)((int)pvVar5 + iVar3),sVar10);
      fVar15 = (float)iVar12;
      iVar12 = iVar12 + 1;
    } while (fVar15 < fVar14);
  }
  pvVar5 = _objc_msgSend(pvVar4,sel_pixelsWide);
  pvVar6 = _objc_msgSend(pvVar4,sel_pixelsHigh);
  local_1c = 0;
  pvVar7 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  for (; sVar10 = (int)pvVar5 + local_1c, pvVar8 = pvVar6, -1 < (int)sVar10;
      local_1c = local_1c + -1) {
    for (; -1 < (int)pvVar8; pvVar8 = (id)((int)pvVar8 + -1)) {
      sVar18 = sVar10;
      pvVar11 = pvVar8;
      pvVar9 = _objc_msgSend(pvVar4,sel_colorAtX_y_,sVar10,pvVar8);
      if (pvVar9 != (id)0x0) {
        dVar17 = _objc_msgSend_fpret(pvVar9,sel_alphaComponent);
        fVar14 = (float)dVar17;
        if ((fVar14 != 0.0) || (NAN(fVar14))) {
          fVar15 = ABS(fVar14);
        }
        else {
          fVar15 = 1.0;
        }
        fVar16 = 0.0005;
        if (1.0 <= fVar15) {
          fVar16 = fVar15 * 0.0005;
        }
        if (fVar16 + 0.0 < fVar14) goto LAB_00053536;
      }
    }
  }
LAB_00053536:
  _objc_msgSend(pvVar7,sel_release,sVar18,pvVar11);
  return -local_1c;
}

*/
+ (NSUInteger)calculateDistanceToRightEdgeForIconWithRep:(id)aRep iconCount:(NSInteger)aCount animationStep:(NSInteger)aStep
{
    NSInteger pixelsHigh = [aRep pixelsHigh];
    NSInteger pixelsWide = [aRep pixelsWide];
    NSInteger bitsPerPixel = [aRep bitsPerPixel];
    NSInteger samplesPerPixel = [aRep samplesPerPixel];
    float width = (float)(int)pixelsWide;
    size_t rowBytes = (size_t)((float)((int)bitsPerPixel >> 3) * width);
    float height = (float)((int)pixelsHigh / (int)aCount);
    NSBitmapImageRep *icon = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                      pixelsWide:(int)width
                                                                      pixelsHigh:(int)height
                                                                   bitsPerSample:(int)bitsPerPixel / (int)samplesPerPixel
                                                                 samplesPerPixel:samplesPerPixel
                                                                        hasAlpha:[aRep hasAlpha]
                                                                        isPlanar:NO
                                                                  colorSpaceName:NSCalibratedRGBColorSpace
                                                                     bytesPerRow:rowBytes
                                                                    bitsPerPixel:bitsPerPixel] autorelease];
    unsigned char *source = [aRep bitmapData];
    unsigned char *destination = [icon bitmapData];
    if (0.0 < height) {
        int offset = 0;
        int index = 1;
        float counter;
        do {
            memcpy(destination + offset, source + offset + (int)height * rowBytes * aStep, rowBytes);
            offset += rowBytes;
            counter = (float)index;
            index++;
        } while (counter < height);
    }
    NSInteger iconWidth = [icon pixelsWide];
    NSInteger iconHeight = [icon pixelsHigh];
    int scanned = 0;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    for (; -1 < (int)iconWidth + scanned; scanned--) {
        for (NSInteger y = iconHeight; -1 < (int)y; y--) {
            NSColor *color = [icon colorAtX:(int)iconWidth + scanned y:y];
            if (color != nil) {
                float alpha = (float)[color alphaComponent];
                float a = alpha != 0.0 ? fabsf(alpha) : 1.0;
                float tol = 0.0005;
                if (1.0 <= a) {
                    tol = a * 0.0005;
                }
                if (tol + 0.0 < alpha) {
                    goto found;
                }
            }
        }
    }
found:
    [pool release];
    return -scanned;
}

+ (CGFloat)filmCanWidthDistanceBetweenFrameIndex:(NSUInteger)aIndex andFrameIndex:(NSUInteger)aIndex2
{
    unsigned int uVar1;

    uVar1 = aIndex2;
    if (aIndex2 <= aIndex) {
        uVar1 = aIndex;
        aIndex = aIndex2;
    }
    return (float)[self filmCanWidthDistanceForAnimationFramesRange:NSMakeRange(aIndex, uVar1 - aIndex)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00052ebb @ 00052ebb, 147 bytes * /

float FUN_00052ebb(id self,SEL _cmd,NSRange filmCanWidthDistanceForAnimationFramesRange)

{
  id pvVar1;
  uint uVar2;
  id pvVar3;
  
  if (filmCanWidthDistanceForAnimationFramesRange.length != 0) {
    pvVar3 = (id)(filmCanWidthDistanceForAnimationFramesRange.length +
                 filmCanWidthDistanceForAnimationFramesRange.location);
    pvVar1 = _objc_msgSend(self,sel_countOfDistancesToRightEdgeInAnimation);
    if (pvVar3 == pvVar1) {
      pvVar3 = (id)((int)pvVar3 + -1);
    }
    pvVar1 = _objc_msgSend(self,sel_distanceToRightEdgeInAnimationInFrameAtIndex_,pvVar3);
    pvVar3 = _objc_msgSend(self,sel_distanceToRightEdgeInAnimationInFrameAtIndex_,
                           filmCanWidthDistanceForAnimationFramesRange.location);
    if (pvVar1 != pvVar3) {
      uVar2 = (int)pvVar1 - (int)pvVar3 >> 0x1f;
      return (float)(int)(((int)pvVar1 - (int)pvVar3) + uVar2 ^ uVar2);
    }
  }
  return 0.0;
}

*/
+ (CGFloat)filmCanWidthDistanceForAnimationFramesRange:(NSRange)aRange
{
    if (aRange.length != 0) {
        NSUInteger end = aRange.length + aRange.location;
        if (end == [self countOfDistancesToRightEdgeInAnimation]) {
            end = end - 1;
        }
        int last = (int)[self distanceToRightEdgeInAnimationInFrameAtIndex:end];
        int first = (int)[self distanceToRightEdgeInAnimationInFrameAtIndex:aRange.location];
        if (last != first) {
            return (float)abs(last - first);
        }
    }
    return 0.0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00052d76 @ 00052d76, 325 bytes * /

id FUN_00052d76(id self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  cfstringStruct *self_01;
  cfstringStruct *pcVar2;
  
  if (DAT_003427c4 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar2 = &cfstr_tiff;
    self_01 = &cfstr_FilmCan_Animation;
    pvVar1 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_,&cfstr_FilmCan_Animation,&cfstr_tiff);
    if (pvVar1 != (id)0x0) {
      self_00 = _objc_msgSend(cls_NSBitmapImageRep,sel_alloc,self_01,pcVar2);
      pvVar1 = _objc_msgSend(cls_NSData,sel_dataWithContentsOfFile_,pvVar1);
      pvVar1 = _objc_msgSend(self_00,sel_initWithData_,pvVar1);
      self_01 = _objc_msgSend(pvVar1,sel_autorelease);
      pvVar1 = _objc_msgSend(self_01,sel_pixelsHigh);
      pcVar2 = (cfstringStruct *)(int)(float)((int)pvVar1 / 0x62);
      DAT_003427c4 = _objc_msgSend(self,sel_createImagesForRep_iconCount_,self_01,pcVar2);
    }
    if (DAT_003427c4 == (id)0x0) {
      DAT_003427c4 = _objc_msgSend(cls_NSArray,sel_new,self_01,pcVar2);
    }
  }
  return DAT_003427c4;
}

*/
+ (id)imagesForAnimation
{
    static id images = nil;
    if (images == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FilmCan_Animation" ofType:@"tiff"];
        if (path != nil) {
            NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithData:[NSData dataWithContentsOfFile:path]] autorelease];
            NSInteger iconCount = (int)(float)((int)[rep pixelsHigh] / 0x62);
            images = [self createImagesForRep:rep iconCount:iconCount];
        }
        if (images == nil) {
            images = [NSArray new];
        }
    }
    return images;
}

+ (id)createImagesForRep:(id)aRep iconCount:(NSInteger)aCount
{
    id pvVar1;
    int iVar3;

    pvVar1 = [NSMutableArray array];
    if (0 < aCount) {
        iVar3 = 0;
        do {
            [pvVar1 addObject:[self createImageForIconWithRep:aRep iconCount:aCount animationStep:iVar3]];
            iVar3 = iVar3 + 1;
        } while (aCount != iVar3);
    }
    return [[NSArray alloc] initWithArray:pvVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005359e @ 0005359e, 685 bytes * /

id FUN_0005359e(id self,SEL _cmd,id createImageForIconWithRep,int iconCount,int animationStep)

{
  void *pvVar1;
  undefined4 uVar2;
  int iVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id self_00;
  id pvVar8;
  int iVar9;
  size_t sVar10;
  int iVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  
  pvVar4 = _objc_msgSend(createImageForIconWithRep,sel_pixelsHigh);
  pvVar5 = _objc_msgSend(createImageForIconWithRep,sel_pixelsWide);
  pvVar6 = _objc_msgSend(createImageForIconWithRep,sel_bitsPerPixel);
  pvVar7 = _objc_msgSend(createImageForIconWithRep,sel_samplesPerPixel);
  self_00 = _objc_msgSend(cls_NSBitmapImageRep,sel_alloc);
  uVar2 = *(undefined4 *)PTR_00336350;
  pvVar8 = _objc_msgSend(createImageForIconWithRep,sel_hasAlpha);
  fVar12 = (float)(int)pvVar5;
  sVar10 = (size_t)((float)((int)pvVar6 >> 3) * fVar12);
  fVar13 = (float)((int)pvVar4 / iconCount);
  pvVar4 = _objc_msgSend(self_00,
                         sel_initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel_
                         ,0,(int)fVar12,(int)fVar13,(int)pvVar6 / (int)pvVar7,pvVar7,
                         (uint)pvVar8 & 0xff,0,uVar2,sVar10,pvVar6);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  pvVar5 = _objc_msgSend(createImageForIconWithRep,sel_bitmapData);
  pvVar6 = _objc_msgSend(pvVar4,sel_bitmapData);
  if (0.0 < fVar13) {
    iVar11 = 0;
    iVar9 = 1;
    do {
      iVar3 = iVar11 + (int)fVar13 * sVar10 * animationStep;
      pvVar1 = (void *)((int)pvVar6 + iVar11);
      iVar11 = iVar11 + sVar10;
      _memcpy(pvVar1,(void *)((int)pvVar5 + iVar3),sVar10);
      fVar14 = (float)iVar9;
      iVar9 = iVar9 + 1;
    } while (fVar14 < fVar13);
  }
  pvVar5 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar5 = _objc_msgSend(pvVar5,sel_initWithSize_,fVar12,fVar13);
  pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
  _objc_msgSend(pvVar5,sel_setCachedSeparately_,1);
  _objc_msgSend(pvVar5,sel_addRepresentation_,pvVar4);
  _objc_msgSend(pvVar5,sel_lockFocus);
  _objc_msgSend(pvVar5,sel_unlockFocus);
  return pvVar5;
}

*/
+ (id)createImageForIconWithRep:(id)aRep iconCount:(NSInteger)aCount animationStep:(NSInteger)aStep
{
    NSInteger pixelsHigh = [aRep pixelsHigh];
    NSInteger pixelsWide = [aRep pixelsWide];
    NSInteger bitsPerPixel = [aRep bitsPerPixel];
    NSInteger samplesPerPixel = [aRep samplesPerPixel];
    float width = (float)(int)pixelsWide;
    size_t rowBytes = (size_t)((float)((int)bitsPerPixel >> 3) * width);
    float height = (float)((int)pixelsHigh / (int)aCount);
    NSBitmapImageRep *icon = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                      pixelsWide:(int)width
                                                                      pixelsHigh:(int)height
                                                                   bitsPerSample:(int)bitsPerPixel / (int)samplesPerPixel
                                                                 samplesPerPixel:samplesPerPixel
                                                                        hasAlpha:[aRep hasAlpha]
                                                                        isPlanar:NO
                                                                  colorSpaceName:NSCalibratedRGBColorSpace
                                                                     bytesPerRow:rowBytes
                                                                    bitsPerPixel:bitsPerPixel] autorelease];
    unsigned char *source = [aRep bitmapData];
    unsigned char *destination = [icon bitmapData];
    if (0.0 < height) {
        int offset = 0;
        int index = 1;
        float counter;
        do {
            memcpy(destination + offset, source + offset + (int)height * rowBytes * aStep, rowBytes);
            offset += rowBytes;
            counter = (float)index;
            index++;
        } while (counter < height);
    }
    NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(width, height)] autorelease];
    [image setCachedSeparately:YES];
    [image addRepresentation:icon];
    [image lockFocus];
    [image unlockFocus];
    return image;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00052c03 @ 00052c03, 197 bytes * /

uint FUN_00052c03(id self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int iVar5;
  int iVar6;
  bool bVar7;
  
  if (DAT_003427bc == '\0') {
    DAT_003427bc = '\x01';
    pvVar2 = _objc_msgSend(self,sel_countOfDistancesToRightEdgeInAnimation);
    if (pvVar2 != (id)0x0) {
      iVar6 = -1;
      pvVar3 = _objc_msgSend(self,sel_distanceToRightEdgeInAnimationInFrameAtIndex_,(int)pvVar2 + -1
                            );
      iVar5 = 0;
      do {
        iVar1 = iVar5 + 1;
        pvVar4 = _objc_msgSend(self,sel_distanceToRightEdgeInAnimationInFrameAtIndex_,
                               (int)pvVar2 + iVar6);
        if (pvVar4 != pvVar3) break;
        iVar6 = iVar6 + -1;
        bVar7 = iVar5 != (int)pvVar2 + -1;
        iVar5 = iVar1;
      } while (bVar7);
      DAT_003427c0 = (int)pvVar2 - iVar1;
    }
  }
  return DAT_003427c0;
}

*/
+ (NSUInteger)indexOfFirstFrameWhenStripReachesMaxSize
{
    static BOOL computed = NO;
    static NSUInteger firstIndex = 0;
    if (!computed) {
        computed = YES;
        NSUInteger count = [self countOfDistancesToRightEdgeInAnimation];
        if (count != 0) {
            int offset = -1;
            NSUInteger last = [self distanceToRightEdgeInAnimationInFrameAtIndex:count - 1];
            int steps = 0;
            int next;
            BOOL more;
            do {
                next = steps + 1;
                NSUInteger distance = [self distanceToRightEdgeInAnimationInFrameAtIndex:count + offset];
                if (distance != last) {
                    break;
                }
                offset--;
                more = steps != (int)count - 1;
                steps = next;
            } while (more);
            firstIndex = count - next;
        }
    }
    return firstIndex;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00052a93 @ 00052a93, 368 bytes * /

uint FUN_00052a93(id self,SEL _cmd,uint distanceToRightEdgeInAnimationInFrameAtIndex)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  undefined4 *puVar3;
  uint uVar4;
  undefined4 *puVar5;
  int iVar6;
  cfstringStruct *pcVar7;
  
  if (DAT_003427b8 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_countOfDistancesToRightEdgeInAnimation);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar7 = &cfstr_hsdata;
    pvVar2 = _objc_msgSend(pvVar2,sel_pathForResource_ofType_,&cfstr_FilmCanAnimationFrames,
                           &cfstr_hsdata);
    if ((pvVar2 == (id)0x0) ||
       (self_00 = _objc_msgSend(cls_NSData,sel_dataWithContentsOfFile_,pvVar2,pcVar7),
       self_00 == (id)0x0)) {
      puVar5 = (undefined4 *)0x0;
      uVar4 = 0;
    }
    else {
      puVar5 = _objc_msgSend(self_00,sel_bytes,pvVar2,pcVar7);
      pvVar2 = _objc_msgSend(self_00,sel_length);
      uVar4 = (uint)pvVar2 >> 2;
    }
    iVar6 = (int)pvVar1 << 2;
    pvVar1 = _objc_msgSend(cls_NSMutableData,sel_dataWithLength_,iVar6,pcVar7);
    puVar3 = _objc_msgSend(pvVar1,sel_mutableBytes);
    for (; uVar4 != 0; uVar4 = uVar4 - 1) {
      *puVar3 = *puVar5;
      puVar5 = puVar5 + 1;
      puVar3 = puVar3 + 1;
    }
    pvVar2 = _objc_msgSend(cls_NSData,sel_alloc,iVar6);
    pvVar1 = _objc_msgSend(pvVar2,sel_initWithData_,pvVar1);
    DAT_003427b8 = _objc_msgSend(pvVar1,sel_bytes);
  }
  return *(uint *)((int)DAT_003427b8 + distanceToRightEdgeInAnimationInFrameAtIndex * 4);
}

*/
+ (NSUInteger)distanceToRightEdgeInAnimationInFrameAtIndex:(NSUInteger)aIndex
{
    static const unsigned int *distances = NULL;
    if (distances == NULL) {
        NSUInteger count = [self countOfDistancesToRightEdgeInAnimation];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"FilmCanAnimationFrames" ofType:@"hsdata"];
        NSData *file = path != nil ? [NSData dataWithContentsOfFile:path] : nil;
        const unsigned int *source = NULL;
        NSUInteger words = 0;
        if (file != nil) {
            source = [file bytes];
            words = [file length] >> 2;
        }
        NSMutableData *buffer = [NSMutableData dataWithLength:count * 4];
        unsigned int *destination = [buffer mutableBytes];
        for (NSUInteger i = 0; i < words && i < count; i++) {
            destination[i] = source[i];
        }
        distances = [[[NSData alloc] initWithData:buffer] bytes];
    }
    return distances[aIndex];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00052a3a @ 00052a3a, 89 bytes * /

uint FUN_00052a3a(id self,SEL _cmd)

{
  id self_00;
  
  if (DAT_003427b0 != '\x01') {
    DAT_003427b0 = '\x01';
    self_00 = _objc_msgSend(self,sel_imagesForAnimation);
    DAT_003427b4 = _objc_msgSend(self_00,sel_count);
  }
  return (uint)DAT_003427b4;
}

*/
+ (NSUInteger)countOfDistancesToRightEdgeInAnimation
{
    static BOOL computed = NO;
    static NSUInteger count = 0;
    if (!computed) {
        computed = YES;
        count = [[self imagesForAnimation] count];
    }
    return count;
}

- (void)drawRect:(NSRect)aRect
{
    if ([self isRenderingEnabled]) {
        [self drawImage:[[self images] objectAtIndex:[self renderedImageIndex]]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0005384b @ 0005384b, 261 bytes * /

void FUN_0005384b(HSMediaStripAnimatingFilmCan *self,SEL _cmd,id drawImage)

{
  float extraout_EDX;
  undefined8 local_44;
  undefined8 local_3c;
  undefined4 local_34;
  undefined4 uStack_30;
  id local_2c;
  float fStack_28;
  undefined1 local_24 [12];
  float local_18;
  
  if (drawImage != (id)0x0) {
    _objc_msgSend(drawImage,sel_size);
    local_2c = _objc_msgSend(drawImage,sel_size);
    local_34 = 0;
    uStack_30 = 0;
    fStack_28 = extraout_EDX;
    _objc_msgSend_stret(local_24,self,sel_bounds);
    _NSOffsetRect(&local_44,CONCAT44(uStack_30,local_34),CONCAT44(fStack_28,local_2c),0,
                  local_18 - fStack_28);
    _objc_msgSend(drawImage,sel_drawInRect_fromRect_operation_fraction_,local_44,local_3c,
                  CONCAT44(uStack_30,local_34),CONCAT44(fStack_28,local_2c),2,0x3f800000);
  }
  return;
}

*/
- (void)drawImage:(id)aImage
{
    if (aImage != nil) {
        NSSize size = [aImage size];
        NSRect source = NSMakeRect(0.0, 0.0, size.width, size.height);
        NSRect bounds = [self bounds];
        NSRect destination = NSOffsetRect(source, 0.0, bounds.size.height - size.height);
        [aImage drawInRect:destination fromRect:source operation:NSCompositeSourceOver fraction:1.0];
    }
}

- (NSUInteger)maxRenderedImageIndex
{
    NSUInteger pvVar1;
    unsigned int uVar2;

    pvVar1 = [self countOfImages];
    if (pvVar1 == 0) {
        uVar2 = 0;
    }
    else {
        uVar2 = (int)pvVar1 - 1;
    }
    return uVar2;
}

- (void)setRenderedImageIndex:(NSUInteger)aIndex
{
    if (_renderedImageIndex != aIndex) {
        _renderedImageIndex = aIndex;
        if ([self isRenderingEnabled]) {
            [self setNeedsDisplay:YES];
        }
    }
}

- (NSUInteger)renderedImageIndex
{
    return _renderedImageIndex;
}

- (NSUInteger)countOfImages
{
    return (unsigned int)[[self images] count];
}

- (id)images
{
    id pvVar1;

    pvVar1 = _images;
    if (pvVar1 == nil) {
        pvVar1 = [[self class] imagesForAnimation];
        _images = pvVar1;
    }
    return pvVar1;
}

- (BOOL)isRenderingEnabled
{
    BOOL bVar2;

    if (_isRenderingEnabled == NO) {
        bVar2 = NO;
    }
    else {
        bVar2 = [self countOfImages] != 0;
    }
    return bVar2;
}

- (void)setIsRenderingEnabled:(BOOL)aEnabled
{
    BOOL pvVar1;

    pvVar1 = [self isRenderingEnabled];
    _isRenderingEnabled = aEnabled;
    if (([self isRenderingEnabled]) != (pvVar1)) {
        [self setNeedsDisplay:YES];
    }
}

- (void)dealloc
{
    [_images release];
    [super dealloc];
}

@end

