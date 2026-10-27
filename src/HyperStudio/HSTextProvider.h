#import "HyperStudioPrefix.h"


@interface HSTextProvider : NSObject <HSTextObjectDataSource>
{
    HSTextFinder *_textFinder;
    HSSpellChecker *_spellChecker;
}
+ (id)sharedInstance;
- (void)deactivateCurrentItem;
- (BOOL)hyperReplaceTextForCurrentItem:(id)aItem inRanges:(id)aRanges;
- (BOOL)setHyperNameForCurrentItem:(id)aItem;
- (void)setHyperTextForCurrentItem:(id)aItem;
- (void)selectCurrentItemNameWithRange:(NSRange)aRange;
- (void)selectCurrentItemStringWithRange:(NSRange)aRange;
- (void)activateInspectorOfCurrentItem;
- (void)activateCurrentItem;
- (NSInteger)hyperSpellDocumentTag;
- (NSRange)selectedRangeForCurrentItemName;
- (NSRange)selectedRangeForCurrentItem;
- (id)hyperNameForCurrentItem;
- (id)hyperTextForCurrentItem;
- (BOOL)moveToNext;
- (BOOL)shouldEnableIncludeObjectNamesButton;
- (void)setIncludeObjectNames:(BOOL)aNames;
- (void)setWrapsAround:(BOOL)aAround;
- (void)setDirection:(NSInteger)aDirection;
- (void)startEnumeration;
- (void)performCheckSpelling:(id)aSpelling;
- (void)performShowGuessPanel:(id)aPanel;
- (void)performFindAction:(id)aAction;
- (id)currentTextProvider;
- (id)spellChecker;
- (id)textFinder;
- (void)dealloc;
- (id)init;
@end

