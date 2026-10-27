#import "HSPatternColorMatrixDataProvider.h"

@implementation HSPatternColorMatrixDataProvider

+ (id)sharedDataProvider
{
    static id sharedProvider = nil;
    if (sharedProvider == nil)
        sharedProvider = [self new];
    return sharedProvider;
}

- (id)defaultColorAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    static NSArray *patterns = nil;
    if (patterns == nil)
        patterns = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ColorMatrixPatterns" ofType:@"plist"]] retain];
    id name = [[patterns objectAtIndex:aColumn + aRow * [self numberOfColumns]] objectForKey:@"patternName"];
    return [NSColor colorWithPatternImage:[[HSPatternsSharedProvider sharedPatternsProvider] hyperPatternForName:name]];
}

- (id)init
{
    return [super initWithNumberOfRows:4 columns:4 colorSwatchImageSize:NSMakeSize(32, 24) outline:NSMakeSize(1, 1) storeInDefaults:NO];
}

@end
