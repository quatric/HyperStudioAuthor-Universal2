// Path helpers for the selection tools.

// A copy of the path scaled and moved so that its bounds fill the rect; the
// rect itself when the path is empty.
CGMutablePathRef BTCGPathCreateMutableCopyInscribedInRect(CGPathRef path, CGRect rect);
// A copy of a path traced along pixel edges with every staircase corner cut
// by half a pixel, so that the outline follows diagonals.
CGMutablePathRef BTCGPathCreateMutableCopyWithSmoothedCorners(CGPathRef path);
CGPathRef BTCGPathCreateCopyWithSmoothedCorners(CGPathRef path);
