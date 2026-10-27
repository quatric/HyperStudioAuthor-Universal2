#import "HyperStudioPrefix.h"
#import "KeynoteGraphicStyle.h"


@interface KeynoteSlideStyle : KeynoteGraphicStyle
{
}
- (BOOL)visibilityOfPlaceholderWithPath:(id)aPath;
- (BOOL)isSlideNumberPlaceholderVisible;
- (BOOL)isObjectPlaceholderVisible;
- (BOOL)isBodyPlaceholderVisible;
- (BOOL)isTitlePlaceholderVisible;
- (id)transition;
@end

