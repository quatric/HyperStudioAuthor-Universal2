#import "KeynoteSlideStyle.h"

@implementation KeynoteSlideStyle

- (BOOL)visibilityOfPlaceholderWithPath:(id)aPath
{
    id number = [[[[self deepStyleChildForXMLPath:aPath] keynoteObjectForXMLPath:@"./number"] nodeAttributes] objectForKey:@"number"];

    if (number == nil)
        return NO;
    return [number intValue] != 0;
}

- (BOOL)isSlideNumberPlaceholderVisible
{
    return [self visibilityOfPlaceholderWithPath:@"./property-map/slideNumberPlaceholderVisibility"];
}

- (BOOL)isObjectPlaceholderVisible
{
    return [self visibilityOfPlaceholderWithPath:@"./property-map/objectPlaceholderVisibility"];
}

- (BOOL)isBodyPlaceholderVisible
{
    return [self visibilityOfPlaceholderWithPath:@"./property-map/bodyPlaceholderVisibility"];
}

- (BOOL)isTitlePlaceholderVisible
{
    return [self visibilityOfPlaceholderWithPath:@"./property-map/titlePlaceholderVisibility"];
}

- (id)transition
{
    return [self deepStyleChildForXMLPath:@"./property-map/transition"];
}

@end
