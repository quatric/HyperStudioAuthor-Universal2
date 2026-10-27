#import "HyperPlayerBasePrefix.h"


@interface HSPDFArtBoxImageRep : NSImageRep
{
    struct CGPDFDocument *_document;
    struct CGPDFPage *_page;
    CGAffineTransform _transform;
}
+ (BOOL)canInitWithData:(id)aData;
+ (id)imageUnfilteredTypes;
+ (struct CGPDFDocument *)newPdfDocumentFromData:(id)aData;
+ (id)imageRepsForAllPDFPagesWithData:(id)aData;
- (BOOL)draw;
- (void)dealloc;
- (id)initWithDocument:(struct CGPDFDocument *)aDocument page:(struct CGPDFPage *)aPage;
- (id)initWithData:(id)aData;
@end

