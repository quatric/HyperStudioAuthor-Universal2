// Pixel lookups shared by the BTImage classes.

BOOL BTIsImagePoint(id image, CGPoint point);
// ARGB 8-bit images (format -1) without a profile only; NULL otherwise.
CGColorRef BTCopyColorFromRawImage(id image, CGPoint point);
CGColorRef BTCopyColorFromCGImage(id image, CGPoint point);
