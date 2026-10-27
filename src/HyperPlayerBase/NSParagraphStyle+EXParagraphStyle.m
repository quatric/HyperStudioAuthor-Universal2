#import "NSParagraphStyle+EXParagraphStyle.h"
@implementation NSParagraphStyle (EXParagraphStyle)
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}
// Every attribute by name. (The original wrote zero header level,
// hyphenation and text blocks/lists and 0.05 tightening before 10.4;
// the AppKit version check is gone.)
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        NSStringFromClass([NSParagraphStyle class]), EXClassNameKey,
        [NSNumber numberWithInt:(int)[self alignment]], @"alignment",
        [NSNumber numberWithInt:(int)[self baseWritingDirection]], @"baseWritingDirection",
        [NSNumber numberWithFloat:[self defaultTabInterval]], @"defaultTabInterval",
        [NSNumber numberWithFloat:[self firstLineHeadIndent]], @"firstLineHeadIndent",
        [NSNumber numberWithInt:(int)[self headerLevel]], @"headerLevel",
        [NSNumber numberWithFloat:[self headIndent]], @"headIndent",
        [NSNumber numberWithFloat:[self hyphenationFactor]], @"hyphenationFactor",
        [NSNumber numberWithInt:(int)[self lineBreakMode]], @"lineBreakMode",
        [NSNumber numberWithFloat:[self lineHeightMultiple]], @"lineHeightMultiple",
        [NSNumber numberWithFloat:[self lineSpacing]], @"lineSpacing",
        [NSNumber numberWithFloat:[self maximumLineHeight]], @"maximumLineHeight",
        [NSNumber numberWithFloat:[self minimumLineHeight]], @"minimumLineHeight",
        [NSNumber numberWithFloat:[self paragraphSpacing]], @"paragraphSpacing",
        [NSNumber numberWithFloat:[self paragraphSpacingBefore]], @"paragraphSpacingBefore",
        [NSNumber numberWithFloat:[self tailIndent]], @"tailIndent",
        [NSNumber numberWithFloat:[self tighteningFactorForTruncation]], @"tighteningFactorForTruncation",
        [self hyperDictionaryRepresentationsFromArray:[self tabStops]], @"tabStops",
        [self hyperDictionaryRepresentationsFromArray:[self textBlocks]], @"textBlocks",
        [self hyperDictionaryRepresentationsFromArray:[self textLists]], @"textLists",
        nil];
}
// Returns an immutable copy of the stored style in place of the receiver.
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:[[aDictionary objectForKey:@"alignment"] intValue]];
    [style setBaseWritingDirection:[[aDictionary objectForKey:@"baseWritingDirection"] intValue]];
    [style setDefaultTabInterval:[[aDictionary objectForKey:@"defaultTabInterval"] floatValue]];
    [style setFirstLineHeadIndent:[[aDictionary objectForKey:@"firstLineHeadIndent"] floatValue]];
    [style setHeadIndent:[[aDictionary objectForKey:@"headIndent"] floatValue]];
    [style setLineBreakMode:[[aDictionary objectForKey:@"lineBreakMode"] intValue]];
    [style setLineHeightMultiple:[[aDictionary objectForKey:@"lineHeightMultiple"] floatValue]];
    [style setLineSpacing:[[aDictionary objectForKey:@"lineSpacing"] floatValue]];
    [style setMaximumLineHeight:[[aDictionary objectForKey:@"maximumLineHeight"] floatValue]];
    [style setMinimumLineHeight:[[aDictionary objectForKey:@"minimumLineHeight"] floatValue]];
    [style setParagraphSpacing:[[aDictionary objectForKey:@"paragraphSpacing"] floatValue]];
    [style setParagraphSpacingBefore:[[aDictionary objectForKey:@"paragraphSpacingBefore"] floatValue]];
    [style setTailIndent:[[aDictionary objectForKey:@"tailIndent"] floatValue]];
    [style setTabStops:[self hyperArrayFromDictionaryRepresentations:[aDictionary objectForKey:@"tabStops"]]];
    [style setHeaderLevel:[[aDictionary objectForKey:@"headerLevel"] intValue]];
    [style setHyphenationFactor:[[aDictionary objectForKey:@"hyphenationFactor"] floatValue]];
    [style setTighteningFactorForTruncation:[[aDictionary objectForKey:@"tighteningFactorForTruncation"] floatValue]];
    [style setTextBlocks:[self hyperArrayFromDictionaryRepresentations:[aDictionary objectForKey:@"textBlocks"]]];
    [style setTextLists:[self hyperArrayFromDictionaryRepresentations:[aDictionary objectForKey:@"textLists"]]];
    id copy = [style copy];
    [style release];
    [self release];
    return copy;
}
- (BOOL)canBeExtraPostLoaded
{
    return NO;
}
// The objects of the dictionaries that decode (nil when none do).
- (id)hyperArrayFromDictionaryRepresentations:(id)aRepresentations
{
    NSMutableArray *objects = nil;
    for (id representation in aRepresentations) {
        if (![representation isKindOfClass:[NSDictionary class]])
            continue;
        id object = [NSObject objectWithExtraDictionary:representation];
        if (object == nil)
            continue;
        if (objects == nil)
            objects = [NSMutableArray array];
        [objects addObject:object];
    }
    return [[objects copy] autorelease];
}
- (id)hyperDictionaryRepresentationsFromArray:(id)aArray
{
    NSMutableArray *representations = [NSMutableArray array];
    for (id object in aArray) {
        id representation = [object extraDictionaryRepresentation];
        if (representation != nil)
            [representations addObject:representation];
    }
    return [[representations copy] autorelease];
}
@end
