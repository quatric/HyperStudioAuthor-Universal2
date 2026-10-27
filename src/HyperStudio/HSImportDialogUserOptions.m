#import "HSImportDialogUserOptions.h"

@implementation HSImportDialogUserOptions

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"optionsDictionary", nil];
}

- (id)optionsDictionary
{
    return _optionsDictionary;
}

- (void)setOptionsDictionary:(id)aDictionary
{
    if (![aDictionary isEqualToDictionary:_optionsDictionary]) {
        [_optionsDictionary release];
        _optionsDictionary = [aDictionary mutableCopy];
    }
}

- (void)setValue:(id)aValue forUndefinedKey:(id)aKey
{
    if (aValue == nil || aKey == nil)
        return;
    if (_optionsDictionary == nil)
        _optionsDictionary = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
    [_optionsDictionary setObject:aValue forKey:aKey];
}

- (id)valueForUndefinedKey:(id)aKey
{
    if (aKey == nil)
        return nil;
    return [_optionsDictionary objectForKey:aKey];
}

- (id)copy
{
    return [[[self class] alloc] initWithExtraDictionary:[self extraDictionaryRepresentation]];
}

- (void)dealloc
{
    [_optionsDictionary release];
    [super dealloc];
}

@end
