#import "HSPrintCardAction.h"

@implementation HSPrintCardAction
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:(_showPageSetupDialog ? @"1" : @"0") forKey:@"showPageSetupDialog"];
    [dictionary setObject:(_showPrintDialog ? @"1" : @"0") forKey:@"showPrintDialog"];
    [dictionary setObject:(_centerPrintout ? @"1" : @"0") forKey:@"centerPrintout"];
    return dictionary;
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return NO;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [self setShowPageSetupDialog:[[[aRepresentation attributeForName:@"showPageSetupDialog"] stringValue] hyperBoolValue]];
    [self setShowPrintDialog:[[[aRepresentation attributeForName:@"showPrintDialog"] stringValue] hyperBoolValue]];
    [self setCenterPrintout:[[[aRepresentation attributeForName:@"centerPrintout"] stringValue] hyperBoolValue]];
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"showPageSetupDialog" stringValue:[self showPageSetupDialog] ? HSXMLStoring1String : HSXMLStoring0String]];
    [element addAttribute:[NSXMLNode attributeWithName:@"showPrintDialog" stringValue:[self showPrintDialog] ? HSXMLStoring1String : HSXMLStoring0String]];
    [element addAttribute:[NSXMLNode attributeWithName:@"centerPrintout" stringValue:[self centerPrintout] ? HSXMLStoring1String : HSXMLStoring0String]];
    return element;
}
- (id)XMLElementName
{
    return @"actPrintCard";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)supportedInIPad
{
    return YES;
}
// Without a usable current printer the print dialog is always shown.
- (void)printCurrentCard
{
    PMPrintSession session = NULL;
    PMPrintSettings settings = NULL;
    PMPrinter printer = NULL;
    CFStringRef model = NULL;
    BOOL noPrinter = YES;
    if (PMCreateSession(&session) == noErr && PMCreatePrintSettings(&settings) == noErr
        && PMSessionDefaultPrintSettings(session, settings) == noErr
        && PMSessionGetCurrentPrinter(session, &printer) == noErr) {
        PMPrinterGetMakeAndModelName(printer, &model);
        if (model)
            noPrinter = NO;
    }
    if (settings)
        PMRelease(settings);
    if (session)
        PMRelease(session);
    BOOL center = [self centerPrintout];
    [_context printCurrentCardWithDelegate:self showPrintDialog:(noPrinter ? YES : [self showPrintDialog]) centerPrintout:center];
}
- (void)setCenterPrintout:(BOOL)aValue
{
    if ((_centerPrintout ? YES : NO) == (aValue ? YES : NO))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Center Printout" value:@"" table:@"UndoManager"]];
    [(HSPrintCardAction *)[[self undoManager] prepareWithInvocationTarget:self] setCenterPrintout:[self centerPrintout]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPrintCardCenterPrintoutAttribute) ofObject:self withUserInfo:nil];
    _centerPrintout = aValue;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPrintCardCenterPrintoutAttribute) ofObject:self withUserInfo:nil];
}
- (BOOL)centerPrintout
{
    return _centerPrintout;
}
- (void)setShowPrintDialog:(BOOL)aValue
{
    if ((_showPrintDialog ? YES : NO) == (aValue ? YES : NO))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Show Print Dialog" value:@"" table:@"UndoManager"]];
    [(HSPrintCardAction *)[[self undoManager] prepareWithInvocationTarget:self] setShowPrintDialog:[self showPrintDialog]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPrintCardShowPrintDialogAttribute) ofObject:self withUserInfo:nil];
    _showPrintDialog = aValue;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPrintCardShowPrintDialogAttribute) ofObject:self withUserInfo:nil];
}
- (BOOL)showPrintDialog
{
    return _showPrintDialog;
}
- (void)setShowPageSetupDialog:(BOOL)aValue
{
    if ((_showPageSetupDialog ? YES : NO) == (aValue ? YES : NO))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Show Page Setup Dialog" value:@"" table:@"UndoManager"]];
    [(HSPrintCardAction *)[[self undoManager] prepareWithInvocationTarget:self] setShowPageSetupDialog:[self showPageSetupDialog]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPrintCardShowPageSetupAttribute) ofObject:self withUserInfo:nil];
    _showPageSetupDialog = aValue;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPrintCardShowPageSetupAttribute) ofObject:self withUserInfo:nil];
}
- (BOOL)showPageSetupDialog
{
    return _showPageSetupDialog;
}
- (void)documentDidEndPrinting
{
    [self notifyDidFinish];
}
- (void)documentDidCancelPrinting
{
    [self notifyDidFinish];
}
- (void)documentDidEndPageSetupDialog
{
    [self printCurrentCard];
}
// The context is not retained.
- (void)startInContext:(id)aContext
{
    if ([HSRestrictionsManager restrictionState:HSPrintCardsAndTextDisabled]) {
        [self notifyDidFinish];
        return;
    }
    _context = aContext;
    if ([self showPageSetupDialog])
        [(HSActionExecutionContext *)aContext displayPageSetupDialogWithDelegate:self];
    else
        [self printCurrentCard];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"showPageSetupDialog", @"showPrintDialog", @"centerPrintout", nil]];
}
@end
