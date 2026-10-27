#import "HSPDFArtBoxImageRep.h"
// A PDF page as an image of its art box (turned by the page's rotation).
@implementation HSPDFArtBoxImageRep
+ (BOOL)canInitWithData:(id)aData
{
    if (![NSPDFImageRep canInitWithData:aData])
        return NO;
    CGPDFDocumentRef document = [self newPdfDocumentFromData:aData];
    if (document == NULL)
        return NO;
    BOOL result = CGPDFDocumentGetPage(document, 1) != NULL;
    CGPDFDocumentRelease(document);
    return result;
}
+ (id)imageUnfilteredTypes
{
    return [NSArray arrayWithObject:(NSString *)kUTTypePDF];
}
+ (struct CGPDFDocument *)newPdfDocumentFromData:(id)aData
{
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)aData);
    if (provider == NULL)
        return NULL;
    CGPDFDocumentRef document = CGPDFDocumentCreateWithProvider(provider);
    CGDataProviderRelease(provider);
    return document;
}
+ (id)imageRepsForAllPDFPagesWithData:(id)aData
{
    NSMutableArray *reps = [NSMutableArray array];
    if (![NSPDFImageRep canInitWithData:aData])
        return reps;
    CGPDFDocumentRef document = [self newPdfDocumentFromData:aData];
    if (document == NULL)
        return reps;
    size_t count = CGPDFDocumentGetNumberOfPages(document);
    for (size_t page = 1; page <= count; page++) {
        HSPDFArtBoxImageRep *rep = [[HSPDFArtBoxImageRep alloc] initWithDocument:document page:CGPDFDocumentGetPage(document, page)];
        [reps addObject:rep];
        [rep release];
    }
    CGPDFDocumentRelease(document);
    return reps;
}
- (BOOL)draw
{
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextSaveGState(context);
    CGContextConcatCTM(context, _transform);
    CGContextDrawPDFPage(context, _page);
    CGContextRestoreGState(context);
    return YES;
}
- (void)dealloc
{
    CGPDFPageRelease(_page);
    CGPDFDocumentRelease(_document);
    [super dealloc];
}
// The size is the art box turned and rounded.
- (id)initWithDocument:(struct CGPDFDocument *)aDocument page:(struct CGPDFPage *)aPage
{
    self = [super init];
    if (self != nil) {
        _document = CGPDFDocumentRetain(aDocument);
        _page = CGPDFPageRetain(aPage);
        _transform = CGAffineTransformIdentity;
        CGRect box = CGPDFPageGetBoxRect(_page, kCGPDFArtBox);
        float angle = fmodf((float)CGPDFPageGetRotationAngle(_page) * (float)M_PI / -180.0f + 2.0f * (float)M_PI, 2.0f * (float)M_PI);
        float sine = sinf(angle), cosine = cosf(angle);
        CGRect turned = CGRectApplyAffineTransform(box, CGAffineTransformMake(cosine, sine, -sine, cosine, 0, 0));
        NSSize size = NSMakeSize(roundf(turned.size.width), roundf(turned.size.height));
        [self setSize:size];
        _transform = CGPDFPageGetDrawingTransform(_page, kCGPDFArtBox, CGRectMake(0, 0, size.width, size.height), 0, false);
    }
    return self;
}
// The first page.
- (id)initWithData:(id)aData
{
    CGPDFDocumentRef document = [[self class] newPdfDocumentFromData:aData];
    if (document != NULL) {
        CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
        if (page != NULL) {
            self = [self initWithDocument:document page:page];
            CGPDFDocumentRelease(document);
            return self;
        }
        CGPDFDocumentRelease(document);
    }
    [self release];
    return nil;
}
@end
