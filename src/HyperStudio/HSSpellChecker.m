#import "HSSpellChecker.h"

@implementation HSSpellChecker

- (void)correct:(id)aCorrect
{
    NSRange range = [[self textFinderDataSource] selectedRangeForCurrentItem];
    NSString *correction = [[aCorrect object] stringValue];
    if (correction == nil)
        return;
    if ([[[[self textFinderDataSource] hyperTextForCurrentItem] substringWithRange:range] isEqualToString:correction])
        return;
    [[self textFinderDataSource] hyperReplaceTextForCurrentItem:correction inRanges:[NSArray arrayWithObject:[NSValue valueWithRange:range]]];
    [[self textFinderDataSource] selectCurrentItemStringWithRange:NSMakeRange(range.location, 0)];
}

- (void)ignoreWord:(id)aWord
{
    NSString *word = [[aWord object] stringValue];
    if (word != nil)
        [[NSSpellChecker sharedSpellChecker] ignoreWord:word inSpellDocumentWithTag:[[self textFinderDataSource] hyperSpellDocumentTag]];
}

- (void)findNext:(id)aNext
{
    [self performCheckSpelling:aNext];
}

- (void)setTextFinderDataSource:(id)aSource
{
    _textFinderDataSource = aSource;
}

- (id)textFinderDataSource
{
    return _textFinderDataSource;
}

- (void)performShowGuessPanel:(id)aPanel
{
    [[[NSSpellChecker sharedSpellChecker] spellingPanel] orderFront:aPanel];
    [self performCheckSpelling:aPanel];
}

- (void)performCheckSpelling:(id)aSpelling
{
    [(id<HSTextObjectDataSource>)[self textFinderDataSource] setDirection:1];
    [[self textFinderDataSource] setWrapsAround:YES];
    NSString *text = [[self textFinderDataSource] hyperTextForCurrentItem];
    NSRange selection = [[self textFinderDataSource] selectedRangeForCurrentItem];
    if (text == nil)
        return;
    NSRange found = [[NSSpellChecker sharedSpellChecker] checkSpellingOfString:text startingAt:NSMaxRange(selection) language:nil wrap:NO inSpellDocumentWithTag:[[self textFinderDataSource] hyperSpellDocumentTag] wordCount:NULL];
    if (found.location == NSNotFound) {
        [[self textFinderDataSource] startEnumeration];
        do {
            BOOL moved = [[self textFinderDataSource] moveToNext];
            [[self textFinderDataSource] selectCurrentItemStringWithRange:NSMakeRange(0, 0)];
            text = [[self textFinderDataSource] hyperTextForCurrentItem];
            selection = [[self textFinderDataSource] selectedRangeForCurrentItem];
            found = [[NSSpellChecker sharedSpellChecker] checkSpellingOfString:text startingAt:NSMaxRange(selection) language:nil wrap:NO inSpellDocumentWithTag:[[self textFinderDataSource] hyperSpellDocumentTag] wordCount:NULL];
            if (!moved)
                break;
        } while (found.location == NSNotFound);
        if (found.location == NSNotFound) {
            [[NSSpellChecker sharedSpellChecker] updateSpellingPanelWithMisspelledWord:@""];
            return;
        }
    }
    [[self textFinderDataSource] activateCurrentItem];
    [[NSSpellChecker sharedSpellChecker] updateSpellingPanelWithMisspelledWord:[text substringWithRange:found]];
    [[self textFinderDataSource] selectCurrentItemStringWithRange:found];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findNext:) name:HSFindNextMisspelledWordNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ignoreWord:) name:HSIgnoreMisspelledWordNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(correct:) name:HSCorrectMisspelledWordNotification object:nil];
    }
    return self;
}

@end
