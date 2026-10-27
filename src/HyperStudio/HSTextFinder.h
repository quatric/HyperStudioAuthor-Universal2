#import "HyperStudioPrefix.h"


@interface HSTextFinder : NSObject <NSWindowDelegate, NSObject>
{
    NSTextField *_findTextField;
    NSTextField *_replaceTextField;
    NSTextField *_statusField;
    NSButton *_ignoreCaseButton;
    NSButton *_wrapAroundButton;
    NSButton *_findNextButton;
    NSButton *_includeObjectNamesButton;
    NSPanel *_findPanel;
    NSString *_findString;
    BOOL _findStringChangedSinceLastPasteboardUpdate;
    BOOL _lastFindWasSuccessful;
    id<HSTextObjectDataSource> _textFinderDataSource;
}
- (void)loadFindStringToPasteboard;
- (void)loadFindStringFromPasteboard;
- (void)windowDidUpdate:(id)aUpdate;
- (void)appWillDeactivate:(id)aDeactivate;
- (void)appDidActivate:(id)aActivate;
- (void)orderFrontFindPanel:(id)aPanel;
- (NSRange)rangeOfFindStringInHyperText:(id)aText searchOptions:(NSUInteger)aOptions startFromSelectedRange:(NSRange)aRange;
- (void)checkCurrentItemWithOptions:(NSUInteger)aOptions ignoreSelectedRange:(BOOL)aRange;
- (BOOL)find:(NSInteger)aFind;
- (id)findPanel;
- (void)findPanelActionSetFindString:(id)aString;
- (void)setIncludeObjectNames:(BOOL)aNames;
- (BOOL)includeObjectNames;
- (void)setIgnoreCaseSearch:(BOOL)aSearch;
- (BOOL)ignoreCaseSearch;
- (void)setWrapsAround:(BOOL)aAround;
- (BOOL)wrapsAround;
- (void)setFindString:(id)aString;
- (id)findString;
- (void)setTextFinderDataSource:(id)aSource;
- (id)textFinderDataSource;
- (void)runFindPanel:(id)aPanel;
- (void)includeObjectNamesChanged:(id)aChanged;
- (void)replaceAll:(id)aAll;
- (void)replaceAndFind:(id)aFind;
- (void)replace:(id)aReplace;
- (void)findPrevious:(id)aPrevious;
- (void)findNext:(id)aNext;
- (void)findNextAndOrderFindPanelOut:(id)aOut;
- (void)dealloc;
- (id)init;
@end

