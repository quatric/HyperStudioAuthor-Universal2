#import "HSSystemCrayonsDataSource.h"

@implementation HSSystemCrayonsDataSource

- (id)colorAtIndex:(NSInteger)aIndex
{
    return [[[NSColor alloc] initWithExtraDictionary:[[self systemColorPreset] extraObjectAtIndex:aIndex]] autorelease];
}

- (id)systemColorPreset
{
    if (_systemColorPreset == nil)
        _systemColorPreset = [[NSArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"SystemColorCrayonsPreset" ofType:@"plist"]];
    return _systemColorPreset;
}

- (BOOL)managesRowsAndColumnsCountForCrayonsView:(id)aView
{
    return YES;
}

- (id)crayonsView:(id)aView colorForRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    return [self colorAtIndex:aRow * 8 + aColumn];
}

- (NSInteger)numberOfColumnsInCrayonsView:(id)aView
{
    return 8;
}

- (NSInteger)numberOfRowsInCrayonsView:(id)aView
{
    return 6;
}

- (void)dealloc
{
    [_systemColorPreset release];
    [super dealloc];
}

@end
