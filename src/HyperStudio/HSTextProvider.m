#import "HSTextProvider.h"
static id sDAT_003428d0;

static id sDAT_003428d0;

static id sDAT_003428d0;


@implementation HSTextProvider

/* i386 ivar offsets: _textFinder=0x4, _spellChecker=0x8 */

+ (id)sharedInstance
{
    if (sDAT_003428d0 == nil) {
        sDAT_003428d0 = [[self alloc] init];
    }
    return sDAT_003428d0;
}

- (void)deactivateCurrentItem
{
    [[self currentTextProvider] deactivateCurrentItem];
}

- (BOOL)hyperReplaceTextForCurrentItem:(id)aItem inRanges:(id)aRanges
{
    return (BOOL)[[self currentTextProvider] hyperReplaceTextForCurrentItem:aItem inRanges:aRanges];
}

- (BOOL)setHyperNameForCurrentItem:(id)aItem
{
    return (BOOL)[[self currentTextProvider] setHyperNameForCurrentItem:aItem];
}

- (void)setHyperTextForCurrentItem:(id)aItem
{
    [[self currentTextProvider] setHyperTextForCurrentItem:aItem];
}

- (void)selectCurrentItemNameWithRange:(NSRange)aRange
{
    [[self currentTextProvider] selectCurrentItemNameWithRange:aRange];
}

- (void)selectCurrentItemStringWithRange:(NSRange)aRange
{
    [[self currentTextProvider] selectCurrentItemStringWithRange:aRange];
}

- (void)activateInspectorOfCurrentItem
{
    [[self currentTextProvider] activateInspectorOfCurrentItem];
}

- (void)activateCurrentItem
{
    [[self currentTextProvider] activateCurrentItem];
}

- (NSInteger)hyperSpellDocumentTag
{
    return (int)[[self currentTextProvider] hyperSpellDocumentTag];
}

- (NSRange)selectedRangeForCurrentItemName
{
    return [[self currentTextProvider] selectedRangeForCurrentItemName];
}

- (NSRange)selectedRangeForCurrentItem
{
    return [[self currentTextProvider] selectedRangeForCurrentItem];
}

- (id)hyperNameForCurrentItem
{
    return [[self currentTextProvider] hyperNameForCurrentItem];
}

- (id)hyperTextForCurrentItem
{
    return [[self currentTextProvider] hyperTextForCurrentItem];
}

- (BOOL)moveToNext
{
    return (BOOL)[[self currentTextProvider] moveToNext];
}

- (BOOL)shouldEnableIncludeObjectNamesButton
{
    return (BOOL)[[self currentTextProvider] shouldEnableIncludeObjectNamesButton];
}

- (void)setIncludeObjectNames:(BOOL)aNames
{
    [[self currentTextProvider] setIncludeObjectNames:aNames];
}

- (void)setWrapsAround:(BOOL)aAround
{
    [[self currentTextProvider] setWrapsAround:aAround];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c3acb @ 000c3acb, 65 bytes * /

void FUN_000c3acb(HSTextProvider *self,SEL _cmd,int setDirection)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_currentTextProvider);
  _objc_msgSend(self_00,sel_setDirection_,setDirection);
  return;
}

*/
- (void)setDirection:(NSInteger)aDirection
{
    [[self currentTextProvider] setDirection:aDirection];
}

- (void)startEnumeration
{
    [[self currentTextProvider] startEnumeration];
}

- (void)performCheckSpelling:(id)aSpelling
{
    [[self spellChecker] performCheckSpelling:aSpelling];
}

- (void)performShowGuessPanel:(id)aPanel
{
    [[self spellChecker] performShowGuessPanel:aPanel];
}

- (void)performFindAction:(id)aAction
{
    [[self textFinder] runFindPanel:aAction];
}

- (id)currentTextProvider
{
    id pvVar2_4;

    if (![[[NSApp mainWindow] windowController] respondsToSelector:@selector(stackTextProvider)]) {
        pvVar2_4 = nil;
    }
    else {
        pvVar2_4 = [[[NSApp mainWindow] windowController] stackTextProvider];
    }
    return pvVar2_4;
}

- (id)spellChecker
{
    HSSpellChecker *pHVar1;
    HSSpellChecker *pHVar1_2;

    pHVar1 = _spellChecker;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSSpellChecker alloc] init];
        _spellChecker = pHVar1_2;
        [pHVar1_2 setTextFinderDataSource:self];
        pHVar1 = _spellChecker;
    }
    return pHVar1;
}

- (id)textFinder
{
    HSTextFinder *pHVar1;
    HSTextFinder *pHVar1_2;

    pHVar1 = _textFinder;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSTextFinder alloc] init];
        _textFinder = pHVar1_2;
        [pHVar1_2 setTextFinderDataSource:self];
        pHVar1 = _textFinder;
    }
    return pHVar1;
}

- (void)dealloc
{
    if (sDAT_003428d0 == self) {
        sDAT_003428d0 = nil;
    }
    [_textFinder setTextFinderDataSource:nil];
    [_textFinder release];
    [_spellChecker setTextFinderDataSource:nil];
    [_spellChecker release];
    [super dealloc];
}

- (id)init
{
    if (sDAT_003428d0 == nil) {
        self = [super init];
        if (self != nil) {
            sDAT_003428d0 = self;
        }
    }
    else {
        [self release];
        self = [sDAT_003428d0 retain];
    }
    return self;
}

@end

