#import "HSScrollCardAction.h"

@implementation HSScrollCardAction
- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [element addAttribute:[NSXMLNode attributeWithName:@"scrollPoint_X" stringValue:[NSString stringWithFormat:@"%.2f", (double)_scrollPoint.x]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"scrollPoint_Y" stringValue:[NSString stringWithFormat:@"%.2f", (double)_scrollPoint.y]]];
    [pool release];
    return element;
}
- (id)XMLElementName
{
    return @"actScrollCard";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return ![aType isEqualToString:@"HSiBooksAuthorDocumentType"];
}
- (BOOL)supportedInIPad
{
    return YES;
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    NSPoint point = [self scrollPoint];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)point.x] forKey:@"xCoord"];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)point.y] forKey:@"yCoord"];
    return dictionary;
}
- (void)setPosition:(NSPoint)aPosition
{
    [self setScrollPoint:aPosition];
}
- (NSPoint)position
{
    return [self scrollPoint];
}
- (void)setScrollPoint:(NSPoint)aPoint
{
    if (NSEqualPoints(aPoint, _scrollPoint))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"HSScrollCardAction" value:@"" table:@"UndoManager"]];
    [(HSScrollCardAction *)[[self undoManager] prepareWithInvocationTarget:self] setScrollPoint:[self scrollPoint]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSScrollCardActionAttribute) ofObject:self withUserInfo:nil];
    _scrollPoint = aPoint;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSScrollCardActionAttribute) ofObject:self withUserInfo:nil];
}
- (NSPoint)scrollPoint
{
    return _scrollPoint;
}
- (void)animationDidEnd:(id)aEnd
{
    [self notifyDidFinish];
}
- (void)animationDidStop:(id)aStop
{
    [self notifyDidFinish];
}
- (void)startInContext:(id)aContext
{
    [(HSActionExecutionContext *)aContext scrollCardToPoint:[self scrollPoint] withAnimationDelegate:self];
}
- (void)setScrollPointRepresentation:(id)aRepresentation
{
    [self setScrollPoint:NSPointFromString(aRepresentation)];
}
- (id)scrollPointRepresentation
{
    return NSStringFromPoint([self scrollPoint]);
}
- (BOOL)canChangeSynchronousFlag
{
    return NO;
}
- (BOOL)isSynchronous
{
    return YES;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"scrollPointRepresentation"];
}
@end
