#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSTextViewProcessingAction : HSNBAAction <HSTextViewProcessingActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTextViewUIDsAttribute, HSTextViewNamesAttribute>
{
    NSArray *_textViewUIDs;
    NSArray *_textViewNames;
}
- (id)textViewWithTitle:(id)aTitle;
- (id)textViewWithUID:(id)aUID;
- (void)setTextViewNames:(id)aNames;
- (id)textViewNames;
- (void)setTextViewUIDs:(id)aDs;
- (id)textViewUIDs;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

