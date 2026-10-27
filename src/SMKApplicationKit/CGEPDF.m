#import "CGEPDF.h"
#import "CFEURL.h"

CGContextRef CGEPDFContextCreateWithCFData(CFMutableDataRef data, const CGRect *mediaBox, CFDictionaryRef auxiliaryInfo)
{
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData(data);
    if (!consumer)
        return NULL;
    CGContextRef context = CGPDFContextCreate(consumer, mediaBox, auxiliaryInfo);
    CGDataConsumerRelease(consumer);
    return context;
}

static void Open(CFURLRef url)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    LSOpenCFURLRef(url, NULL);
#pragma clang diagnostic pop
}

void CGEPDFDocumentShow(CGPDFDocumentRef document)
{
    if (!document)
        return;
    CFURLRef url = CFEURLCreateTemporaryFileURLForObject(kUTTypePDF, CFSTR("CGPDFDocumentRef"), document);
    if (!url)
        return;
    CGContextRef context = CGPDFContextCreateWithURL(url, NULL, NULL);
    if (context) {
        size_t count = CGPDFDocumentGetNumberOfPages(document);
        for (size_t i = 1; i <= count; i++) {
            CGPDFPageRef page = CGPDFDocumentGetPage(document, i);
            if (!page)
                continue;
            CGRect box = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            CGContextBeginPage(context, &box);
            CGContextDrawPDFPage(context, page);
            CGContextEndPage(context);
        }
        CGContextRelease(context);
        Open(url);
    }
    CFRelease(url);
}

void CGEPDFPageShow(CGPDFPageRef page)
{
    if (!page)
        return;
    CFURLRef url = CFEURLCreateTemporaryFileURLForObject(kUTTypePDF, CFSTR("CGPDFPageRef"), page);
    if (!url)
        return;
    CGRect box = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    CGContextRef context = CGPDFContextCreateWithURL(url, &box, NULL);
    if (context) {
        CGContextBeginPage(context, &box);
        CGContextDrawPDFPage(context, page);
        CGContextEndPage(context);
        CGContextRelease(context);
        Open(url);
    }
    CFRelease(url);
}
