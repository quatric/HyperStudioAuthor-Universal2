#import "HyperStudioPrefix.h"


@interface HSButtonObjectAssistantPaneState : NSObject
{
    NSString *_backgroundStyle;
    NSString *_buttonType;
    BOOL _titleVisible;
    BOOL _highlight;
}
- (void)setHighlight:(BOOL)aHighlight;
- (BOOL)highlight;
- (void)setTitleVisible:(BOOL)aVisible;
- (BOOL)titleVisible;
- (void)setBackgrounStyle:(id)aStyle withButtonType:(id)aType;
- (void)setButtonType:(id)aType;
- (id)buttonType;
- (void)setBackgroundStyle:(id)aStyle;
- (id)backgroundStyle;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
@end

