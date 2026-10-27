#import "KeynoteShape.h"

@implementation KeynoteShape

- (NSUInteger)verticalAlignment
{
    return [[self keynoteObjectForXMLPath:@"./text/text-storage/text-body"] verticalAlignment];
}

- (id)textBackgroundColor
{
    return [[[self style] keynoteObjectForXMLPath:@"./property-map/fill/color"] color];
}

- (id)text
{
    if (!_text) {
        id textBody = [self keynoteObjectForXMLPath:@"./text/text-storage/text-body"];
        [textBody setStylesheet:[self slideStylesheet]];
        _text = [[textBody attributedText] retain];
    }
    return _text;
}

// (The original only collects links when the body holds several paragraphs;
// a single paragraph yields no links.)
- (id)allLinks
{
    if (!_links) {
        _links = [NSMutableArray new];
        id paragraphs = [self keynoteObjectForXMLPath:@"./text/text-storage/text-body/p"];
        if (paragraphs && ![paragraphs isKindOfClass:[KeynoteParagraph class]]) {
            NSEnumerator *enumerator = [paragraphs objectEnumerator];
            id paragraph;
            while ((paragraph = [enumerator nextObject])) {
                if ([paragraph keynoteObjectForXMLPath:@"./link"])
                    [_links addObject:[[[paragraph keynoteObjectForXMLPath:@"./link"] nodeAttributes] objectForKey:@"href"]];
            }
            return [NSArray arrayWithArray:_links];
        }
        return [NSArray array];
    }
    return [NSArray arrayWithArray:_links];
}

- (BOOL)exportsText
{
    return [[self text] length] != 0;
}

// Builds the path from the shape's bezier, point-path (arrows, stars) or
// scalar-path (polygons, rounded rectangles) element, flipping it for a
// horizontally flipped shape.
- (id)bezierPath
{
    id node = [self keynoteBezier];
    id path = nil;
    if (node) {
        path = [NSBezierPath hyperBezierPathWithString:[[node nodeAttributes] objectForKey:@"path"]];
        if (![self isLine])
            [path closePath];
    } else if ((node = [self keynoteObjectForXMLPath:@"./path/point-path"])) {
        NSString *type = [[node nodeAttributes] objectForKey:@"type"];
        NSSize size = [(KeynoteSize *)[node keynoteObjectForXMLPath:@"./size"] size];
        NSPoint point = [KeynoteTools pointWithAttributesDictionary:[[node keynoteObjectForXMLPath:@"./point"] nodeAttributes]];
        if ([type isEqualToString:@"right"] || [type isEqualToString:@"double"]) {
            CGFloat controlPointX = point.x;
            if (controlPointX <= 1.0f && controlPointX > 0)
                controlPointX *= size.width;
            if ([type isEqualToString:@"right"])
                path = [KeynoteBezierPathsBuilder rightArrowPathWithFlippedControlPointX:controlPointX controlPointVerticalOffsetToPathHeightRatio:point.y size:size];
            else
                path = [KeynoteBezierPathsBuilder doubleArrowPathWithFlippedControlPointX:controlPointX controlPointVerticalOffsetToPathHeightRatio:point.y size:size];
        } else if ([type isEqualToString:@"star"]) {
            path = [KeynoteBezierPathsBuilder starPathWithNumberOfCorners:(NSInteger)point.x inscribedToCircumscribedCirclesRatio:point.y size:size];
        } else {
            return [self defaultBezierPath];
        }
    } else if ((node = [self keynoteObjectForXMLPath:@"./path/scalar-path"])) {
        NSInteger type = [[[node nodeAttributes] objectForKey:@"type"] intValue];
        NSSize size = [(KeynoteSize *)[node keynoteObjectForXMLPath:@"./size"] size];
        float scalar = [[[node nodeAttributes] objectForKey:@"scalar"] floatValue];
        if (type == 1)
            path = [KeynoteBezierPathsBuilder polygonPathWithNumberOfCorners:(NSInteger)scalar size:size];
        else if (type == 0)
            path = [KeynoteBezierPathsBuilder roundedRectPathWithScalar:(NSInteger)scalar size:size];
        else
            return [self defaultBezierPath];
    } else {
        return [self defaultBezierPath];
    }
    if (!path)
        return [self defaultBezierPath];
    if ([KeynoteTools horizontalFlipWithAttributesDictionary:[node nodeAttributes]])
        [path transformUsingAffineTransform:[NSAffineTransform hyperXFlipInRect:[path bounds]]];
    return path;
}

- (id)keynoteBezier
{
    id bezier = [self keynoteObjectForXMLPath:@"./path/bezier-path/bezier"];
    if (!bezier)
        bezier = [self keynoteObjectForXMLPath:@"./path/editable-bezier-path/bezier"];
    return bezier;
}

- (id)defaultBezierPath
{
    return [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, 100, 100)];
}

// (The head and tail line ends are swapped in the original.)
- (id)tailLineEnd
{
    return [super headLineEnd];
}

- (id)headLineEnd
{
    return [super tailLineEnd];
}

// An open path without fill or texture whose end point differs from its start.
- (BOOL)isLine
{
    NSString *path = [[[self keynoteBezier] nodeAttributes] objectForKey:@"path"];
    if ([path rangeOfString:@"Z"].location != NSNotFound)
        return NO;
    id style = [self style];
    if ([style fillColor] || [style texturedFill])
        return NO;
    NSArray *parts = [path componentsSeparatedByString:@" "];
    NSInteger count = [parts count];
    if (count < 7)
        return YES;
    float startY = [[parts objectAtIndex:2] floatValue];
    float startX = [[parts objectAtIndex:1] floatValue];
    float endY = [[parts objectAtIndex:count - 1] floatValue];
    float endX = [[parts objectAtIndex:count - 2] floatValue];
    float magnitudeStartX = startX != 0 ? fabsf(startX) : 1;
    float magnitudeEndX = endX != 0 ? fabsf(endX) : 1;
    if (fabsf(startX - endX) > MAX(magnitudeStartX, magnitudeEndX) * 0.0005f)
        return YES;
    float magnitudeStartY = startY != 0 ? fabsf(startY) : 1;
    float magnitudeEndY = endY != 0 ? fabsf(endY) : 1;
    return MAX(magnitudeStartY, magnitudeEndY) * 0.0005f < fabsf(startY - endY);
}

- (BOOL)exportsBezierPath
{
    return ![[[self style] nodeParentIdent] isEqualToString:@"textboxStyleID"];
}

- (void)didDetail
{
    [super didDetail];
    [self verifyLinks];
}

// Links of the form "keynote:<path>" must point at a readable file; otherwise
// an importing problem (code 0x4e2c) is recorded.
- (void)verifyLinks
{
    NSEnumerator *enumerator = [[self allLinks] objectEnumerator];
    NSString *link;
    while ((link = [enumerator nextObject])) {
        if ([link hasPrefix:@"keynote:"]) {
            NSString *path = [link substringFromIndex:[@"keynote:" length]];
            if (![[NSFileManager defaultManager] hyperIsFileReadableAtPath:path])
                [[self importManager] addImportingProblemForCode:0x4e2c point:@"005" info:path];
        }
    }
}

- (void)dealloc
{
    [_text release];
    [_links release];
    [super dealloc];
}

@end
