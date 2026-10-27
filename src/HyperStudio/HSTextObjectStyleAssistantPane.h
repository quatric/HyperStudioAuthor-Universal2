#import "HyperStudioPrefix.h"
#import "HSTextStyleAssistantPane.h"


@interface HSTextObjectStyleAssistantPane : HSTextStyleAssistantPane
{
    id<HSTextObjectAttributes> _observedTextObjectAttributes;
    id<HSTextLayoutAttributes> _observedTextLayoutAttributes;
    id<HSMutableShadowAttributes> _observedTextShadowAttributes;
}
+ (BOOL)canEditObject:(id)aObject;
- (void)validateCharacterSpacingControls;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)setShadow:(id)aShadow;
- (void)showShadowPane;
- (void)setOutline:(id)aOutline;
- (void)showOutlinePane;
- (void)enableSpaceCharactersControls:(BOOL)aControls;
- (void)characterSpacingValueChanged:(id)aChanged;
- (void)characterSpacingEnabled:(id)aEnabled;
- (void)setVerticalAlignment:(id)aAlignment;
- (void)setAlign:(id)aAlign;
- (void)setUnderline:(id)aUnderline;
- (void)setItalic:(id)aItalic;
- (void)setBold:(id)aBold;
- (void)textColorChanged:(id)aChanged;
- (void)readjustCharacterSpacingValue;
- (void)viewDidLoad;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setObservedTextShadowAttributes:(id)aAttributes;
- (void)setObservedTextLayoutAttributes:(id)aAttributes;
- (void)setObservedTextObjectAttributes:(id)aAttributes;
- (void)dealloc;
- (id)init;
@end

