#import "HyperPlayerBasePrefix.h"
#import "HSCGImageImageRep.h"


@interface HSOldFormatGraphicsImport : NSObject
{
    NSData *_backgroundPaletteData;
    NSData *_backgroundData;
    BOOL _isBackgroundPalatteDataAnalyzed;
    NSImage *_graphicItemImage;
    NSData *_graphicItemData;
    NSMutableData *_lastCellFrameData;
    NSBezierPath *_borderBezierPath;
}
- (id)HSOldFormatGraphicsImport_backgroundPaletteData;
- (id)backgroundColorAtIndex:(NSUInteger)aIndex;
- (void)setGraphicItemBorderBezierPath:(id)aPath;
- (id)graphicItemBorderBezierPath;
- (void)setGraphicItemData:(id)aData;
- (id)graphicItemData;
- (void)setBackgroundData:(id)aData;
- (id)backgroundData;
- (id)graphicItemImage;
- (id)backgroundImageWithRect:(NSRect)aRect depth:(short)aDepth packtype:(short)aPacktype flags:(short)aFlags;
- (id)imageFromIconData:(id)aData;
- (id)imageARGB8888PremultipliedDataForPPakData:(id)aData mask:(id)aMask width:(unsigned int *)aWidth height:(unsigned int *)aHeight bytesPerRow:(unsigned int *)aRow;
- (id)imageForPPakData:(id)aData mask:(id)aMask frameData:(id)aData2;
- (void)dealloc;
@end

@interface HSOldFormatGraphicsImportCGImageImageRep : HSCGImageImageRep
{
    NSData *_sourceData;
}
- (void)dealloc;
- (id)sourceData;
- (id)initWithCGImage:(struct CGImage *)aImage sourceData:(id)aData;
@end

