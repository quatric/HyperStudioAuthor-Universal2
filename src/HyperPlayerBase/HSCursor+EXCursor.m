#import "HSCursor+EXCursor.h"
@implementation HSCursor (EXCursor)
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"cursor", nil];
}
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        NSStringFromClass([HSCursor class]), EXClassNameKey,
        [[self image] TIFFRepresentation], @"imageData",
        NSStringFromPoint([self hotSpot]), @"hotSpot",
        nil];
    if ([self imageMedia] != nil)
        [dictionary setObject:[[[self imageMedia] mediaUID] extraDictionaryRepresentationWithCodingContext:aContext]
                       forKey:@"imageUID"];
    return [[dictionary copy] autorelease];
}
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    [self release];
    NSImage *image = [[[NSImage alloc] initWithData:[aDictionary objectForKey:@"imageData"]] autorelease];
    NSPoint hotSpot = NSPointFromString([aDictionary objectForKey:@"hotSpot"]);
    HSCursor *cursor = [[HSCursor alloc] initWithImage:image hotSpot:hotSpot];
    id uidDictionary = [aDictionary objectForKey:@"imageUID"];
    if (uidDictionary != nil) {
        id uid = [HSUID objectWithExtraDictionary:uidDictionary];
        if (uid != nil)
            [cursor setImageMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid]];
    }
    return cursor;
}
- (BOOL)canBeExtraPostLoaded
{
    return NO;
}
@end
