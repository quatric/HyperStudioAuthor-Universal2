#import "HyperEditorBasePrefix.h"


@interface HSAttributeCheckBox : NSButton
{
    BOOL _hasMultipleValues;
}
- (BOOL)sendAction:(SEL)aAction to:(id)aTo;
- (void)setState:(NSInteger)aState;
- (void)setHasMultipleValues:(BOOL)aValues;
- (BOOL)hasMultipleValues;
@end

