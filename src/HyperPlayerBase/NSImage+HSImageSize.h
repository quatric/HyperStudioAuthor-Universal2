#import "HyperPlayerBasePrefix.h"


@interface NSImage (HSImageSize)
- (NSSize)hyperPixelsSize;
- (BOOL)isHyperVectorImage;
@end

@interface NSImage (HSImageDrawing)
- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds withAlignment:(NSUInteger)aAlignment scaling:(NSInteger)aScaling;
- (void)changeImageAlignment:(NSUInteger)aAlignment withBounds:(NSRect *)aBounds destination:(NSRect *)aDestination;
@end

@interface NSImage (HSImageRepresentation)
- (id)hyperPNGRepresentationWithWide:(NSInteger)aWide high:(NSInteger)aHigh;
- (id)hyperPNGRepresentation;
- (id)hyperRepresentationUsingType:(NSUInteger)aType properties:(id)aProperties;
- (id)hyperImageRepOfClass:(Class)aClass;
@end

@interface NSImage (HSImageConvert)
- (struct CGImage *)hyperQuartzImage;
@end

@interface NSImage (HSImageCreation)
+ (id)hyperImagesWithContentsOfPDFFile:(id)aFile;
+ (id)hyperImageWithContentsOfFile:(id)aFile;
+ (id)hyperImageWithData:(id)aData;
+ (id)hyperImageWithNSImage:(id)aImage;
+ (id)hyperImageWithCGImage:(struct CGImage *)aImage;
+ (id)hyperImageWithCGImage:(struct CGImage *)aImage size:(NSSize)aSize;
+ (id)hyperImageWithWindow:(id)aWindow;
+ (id)hyperImageWithView:(id)aView;
- (id)initWithHyperWindow:(id)aWindow frame:(NSRect)aFrame;
- (id)initWithHyperView:(id)aView;
@end

