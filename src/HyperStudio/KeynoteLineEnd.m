#import "KeynoteLineEnd.h"

@implementation KeynoteLineEnd

- (void)setEndPoint:(NSPoint)aPoint
{
    _endPoint = aPoint;
}

- (NSPoint)endPoint
{
    [self calculate];
    return _endPoint;
}

- (void)setBezierPath:(id)aPath
{
    if (_bezierPath != aPath) {
        [_bezierPath release];
        _bezierPath = [aPath retain];
    }
}

- (id)bezierPath
{
    [self calculate];
    return _bezierPath;
}

- (void)setIsFilled:(BOOL)aFilled
{
    _isFilled = aFilled;
}

- (BOOL)isFilled
{
    [self calculate];
    return _isFilled;
}

- (void)dealloc
{
    [_bezierPath release];
    [super dealloc];
}

- (void)calculate
{
    if (_isCalculated)
        return;
    [self setIsFilled:[[[self nodeAttributes] objectForKey:@"filled"] isEqualToString:@"true"]];
    id endPointObject = [self firstKeynoteObjectForXMLPath:@"./end-point"];
    [self setEndPoint:endPointObject != nil ? [KeynoteTools pointWithAttributesDictionary:[endPointObject nodeAttributes]] : NSZeroPoint];
    NSString *pathString = [[[self firstKeynoteObjectForXMLPath:@"./path"] nodeAttributes] objectForKey:@"path"];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 3.0, 3.0)];
    if (pathString != nil)
        path = [NSBezierPath hyperBezierPathWithString:pathString];
    [self setBezierPath:path];
    _isCalculated = YES;
}

@end
