// PDF helpers (SMKApplicationKit's CGEPDF functions).
#import <ApplicationServices/ApplicationServices.h>

// A PDF context writing into data.
CGContextRef CGEPDFContextCreateWithCFData(CFMutableDataRef data, const CGRect *mediaBox, CFDictionaryRef auxiliaryInfo);

// Debugging: saves a document or page as a PDF file in the temporary folder
// and opens it.
void CGEPDFDocumentShow(CGPDFDocumentRef document);
void CGEPDFPageShow(CGPDFPageRef page);
