#import <ApplicationServices/ApplicationServices.h>

// Text drawn with the context's attachments rather than its text state: the
// font (kCGEContextFontAttachmentKey, a CGFont or CTFont, outlined at one
// unit to the em, so the text matrix carries the size), the drawing mode
// (kCGEContextTextDrawingModeAttachmentKey, a CGTextDrawingMode), fill and
// stroke colors (a CGColor or a one-CGEColor array, gradients drawn in the
// ...ColorBounds rects), the line style and the stroking mode
// (kCGEContextTextStrokingModeAttachmentKey: 0 centered, 1 inside the glyphs,
// 2 outside them). Advances are in user space; the text position moves past
// the glyphs.
void CGEContextShowGlyphsWithAdvances(CGContextRef context, const CGGlyph *glyphs, const CGSize *advances,
                                      size_t count);
// Adds the glyphs' outlines to the context's path (the text position stays).
void CGEContextAddGlyphs(CGContextRef context, const CGGlyph *glyphs, const CGSize *advances, size_t count);

bool CGEFontGetGlyphBBoxes(CGFontRef font, const CGGlyph *glyphs, size_t count, CGRect *bboxes);
