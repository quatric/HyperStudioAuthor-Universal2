#import "HyperStudioPrefix.h"


@interface HSSpellChecker : NSObject
{
    id<HSTextObjectDataSource> _textFinderDataSource;
}
- (void)correct:(id)aCorrect;
- (void)ignoreWord:(id)aWord;
- (void)findNext:(id)aNext;
- (void)setTextFinderDataSource:(id)aSource;
- (id)textFinderDataSource;
- (void)performShowGuessPanel:(id)aPanel;
- (void)performCheckSpelling:(id)aSpelling;
- (void)dealloc;
- (id)init;
@end

