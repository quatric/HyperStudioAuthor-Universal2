#import "HSVectorGraphicsObject+KeynoteImporting.h"

@implementation HSVectorGraphicsObject (KeynoteImporting)

+ (BOOL)shouldImportFromKeynoteObject:(id)aObject
{
    if (![aObject conformsToProtocol:@protocol(KeynoteBezierPathContainer)])
        return NO;
    return [aObject exportsBezierPath];
}

- (id)registredLineEndingInfoObjectFromKeynoteLineEnd:(id)aEnd
{
    HSVectorGraphicsLineEndingInfoObject *info;
    NSAffineTransform *transform;
    NSPoint endPoint;
    NSBezierPath *path;

    if (aEnd == nil)
        return nil;
    info = [[HSVectorGraphicsLineEndingInfoObject new] autorelease];
    [info setIsFilled:[aEnd isFilled]];
    transform = [NSAffineTransform transform];
    endPoint = [aEnd endPoint];
    [transform rotateByRadians:-1.5707964f];
    [transform translateXBy:-endPoint.x yBy:-endPoint.y];
    path = [aEnd bezierPath];
    [path transformUsingAffineTransform:transform];
    [info setPath:path];
    return [[HSVectorGraphicsLineEndingInfoObjectProvider sharedProvider] registeredInfoObject:info];
}

- (void)importKeynoteStroke:(id)aStroke
{
    float width;
    id attributes;

    if (aStroke == nil)
        return;
    width = ceilf([(KeynoteStroke *)aStroke width]);
    attributes = [self queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];
    if (attributes != nil) {
        if ([[aStroke patternType] isEqualToString:@""]) {
            if ([attributes isHyperShape])
                [attributes setHyperLineWidth:0.0];
            else {
                [attributes setHyperStrokeColor:[aStroke color]];
                [attributes setHyperLineWidth:1.0];
            }
        }
        else {
            NSArray *patterns;

            [attributes setHyperStrokeColor:[aStroke color]];
            [attributes setHyperLineWidth:width];
            patterns = [aStroke patterns];
            if (patterns != nil) {
                NSInteger count = [patterns count], i;
                float *pattern = malloc(count * sizeof(float));
                float phase = [(KeynoteStroke *)aStroke patternPhase];

                for (i = 0; i < count; i++)
                    pattern[i] = [[patterns objectAtIndex:i] floatValue];
                [self setLineDashInfo:[[[HSVectorGraphicsLineDashInfoObject alloc] initWithLineDashString:[NSBezierPath extraStringRepresentationOfLineDashStyleRepresentationOfPattern:pattern count:count phase:phase]] autorelease]];
                // Fix: the pattern buffer was leaked.
                free(pattern);
            }
        }
    }
    [[[self hyperHeadEnding] queryHyperInterface:@protocol(HSMutableVectorGraphicsLineEndingAttributes)] setHyperScale:(NSInteger)width];
    [[[self hyperTailEnding] queryHyperInterface:@protocol(HSMutableVectorGraphicsLineEndingAttributes)] setHyperScale:(NSInteger)width];
}

- (void)applyKeynoteGeometry:(id)aGeometry
{
    [super applyKeynoteGeometry:aGeometry];
    [[[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveFrameBoundingRectOriginTo:[(KeynoteGeometry *)aGeometry origin] withLayoutGuidingContext:nil];
}

- (void)importFromKeynoteObject:(id)aObject
{
    id attributes = [self queryHyperInterface:@protocol(HSMutableVectorGraphicsAttributes)];

    [attributes setHyperBezierPath:[aObject bezierPath]];
    if ([aObject conformsToProtocol:@protocol(KeynoteLineEndContainer)]) {
        id lineEnd = [aObject headLineEnd];
        if (lineEnd != nil)
            [[[self hyperHeadEnding] queryHyperInterface:@protocol(HSMutableVectorGraphicsLineEndingAttributes)] setHyperInfoObject:[self registredLineEndingInfoObjectFromKeynoteLineEnd:lineEnd]];
        lineEnd = [aObject tailLineEnd];
        if (lineEnd != nil)
            [[[self hyperTailEnding] queryHyperInterface:@protocol(HSMutableVectorGraphicsLineEndingAttributes)] setHyperInfoObject:[self registredLineEndingInfoObjectFromKeynoteLineEnd:lineEnd]];
    }
    [attributes setHyperLineCapStyle:NSLineCapStyleRound];
    [attributes setHyperLineJoinStyle:NSLineJoinStyleRound];
    [super importFromKeynoteObject:aObject];
}

@end
