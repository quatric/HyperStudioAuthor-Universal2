#import "NSTextTableBlock+EXTextTableBlock.h"
@implementation NSTextTableBlock (EXTextTableBlock)
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        NSStringFromClass([NSTextTableBlock class]), EXClassNameKey,
        [[self table] extraDictionaryRepresentation], @"table",
        [NSNumber numberWithInt:(int)[self startingRow]], @"startingRow",
        [NSNumber numberWithInt:(int)[self rowSpan]], @"rowSpan",
        [NSNumber numberWithInt:(int)[self startingColumn]], @"startingColumn",
        [NSNumber numberWithInt:(int)[self columnSpan]], @"columnSpan",
        nil];
}
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    // Without a table the allocated instance is returned uninitialized, as in
    // the original.
    NSTextTable *table = [NSObject objectWithExtraDictionary:[aDictionary objectForKey:@"table"]];
    int startingRow = [[aDictionary objectForKey:@"startingRow"] intValue];
    int rowSpan = [[aDictionary objectForKey:@"rowSpan"] intValue];
    int startingColumn = [[aDictionary objectForKey:@"startingColumn"] intValue];
    int columnSpan = [[aDictionary objectForKey:@"columnSpan"] intValue];
    if (table != nil) {
        [self release];
        self = [[NSTextTableBlock alloc] initWithTable:table startingRow:startingRow rowSpan:rowSpan
                                        startingColumn:startingColumn columnSpan:columnSpan];
    }
    return self;
}
- (BOOL)canBeExtraPostLoaded
{
    return NO;
}
@end
