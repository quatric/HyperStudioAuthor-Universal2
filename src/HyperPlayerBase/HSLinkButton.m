#import "HSLinkButton.h"
// A borderless button shown as a link: the pointing hand over its title.
@implementation HSLinkButton
- (void)resetCursorRects
{
    NSRect rect = [[self cell] drawingRectForBounds:[self bounds]];
    [self addCursorRect:rect cursor:[NSCursor pointingHandCursor]];
}
@end
// The About box (nib "AboutBox"): name, version, copyright, the authors and
// credits RTFs from the main bundle, and the web site link button.
@implementation HSAboutBoxController
+ (id)sharedInstance
{
    static HSAboutBoxController *sharedInstance = nil;
    if (sharedInstance == nil)
        sharedInstance = [[self alloc] init];
    return sharedInstance;
}
- (id)copyright
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"];
}
- (id)versionString
{
    NSBundle *bundle = [NSBundle mainBundle];
    id build = [bundle HS_buildVersion];
    id version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *format = [bundle localizedStringForKey:@"Version%@%@" value:@"" table:@"Localizable"];
    return [NSString stringWithFormat:format, version, build];
}
// The application name (plus the release-specific name) in bold 14, with a
// raised "®" after its first word, centred.
- (id)applicationNameRegistered
{
    unichar registered = 0xae;
    NSString *symbol = [NSString stringWithCharacters:&registered length:1];
    NSDictionary *symbolAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSFont boldSystemFontOfSize:11], NSFontAttributeName,
        [NSNumber numberWithFloat:5], NSBaselineOffsetAttributeName, nil];
    NSAttributedString *mark = [[[NSAttributedString alloc]
        initWithString:[NSString stringWithFormat:@"%@ ", symbol] attributes:symbolAttributes] autorelease];
    NSString *name = [self appName];
    NSMutableAttributedString *result = nil;
    if (name != nil) {
        NSString *releaseName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"HSReleaseSpecificVersionName"];
        if ([releaseName length] != 0)
            name = [name stringByAppendingFormat:@" %@", releaseName];
        NSDictionary *nameAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont boldSystemFontOfSize:14], NSFontAttributeName, nil];
        result = [[[NSMutableAttributedString alloc] initWithString:name attributes:nameAttributes] autorelease];
    }
    NSRange space = name != nil ? [name rangeOfString:@" "] : NSMakeRange(0, 0);
    if (space.length != 0)
        [result replaceCharactersInRange:space withAttributedString:mark];
    else
        [result appendAttributedString:mark];
    [result setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [result length])];
    return result;
}
- (id)appName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}
- (id)windowTitle
{
    return @"";
}
- (id)creditsRTF
{
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtf" inDirectory:@""]];
}
- (id)authorsRTF
{
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Authors" ofType:@"rtf" inDirectory:@""]];
}
- (void)linkButtonPressed:(id)aPressed
{
    NSString *url = [NSString stringWithFormat:@"http://%@", [_linkButton title]];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}
- (void)windowDidLoad
{
    id title = [self windowTitle];
    if (title != nil)
        [[self window] setTitle:title];
    id rtf = [self authorsRTF];
    if (rtf != nil)
        [_authors replaceCharactersInRange:NSMakeRange(0, [[_authors string] length]) withRTF:rtf];
    rtf = [self creditsRTF];
    if (rtf != nil)
        [_credits replaceCharactersInRange:NSMakeRange(0, [[_credits string] length]) withRTF:rtf];
    id name = [self applicationNameRegistered];
    if (name != nil) {
        [_aboutApplicationName setAttributedStringValue:name];
        [_macVersionApplicationName setAttributedStringValue:name];
        [_creditsApplicationName setAttributedStringValue:name];
    }
    id version = [self versionString];
    if (version != nil) {
        [_macVersionBuildVersion setStringValue:version];
        [_aboutBuildVersion setStringValue:version];
        [_creditsBuildVersion setStringValue:version];
    }
    id copyright = [self copyright];
    if (copyright != nil)
        [_copyRight setStringValue:copyright];

    // Blue underlined title, brown when pressed; both centred.
    NSMutableAttributedString *link = [[[NSMutableAttributedString alloc]
        initWithAttributedString:[_linkButton attributedTitle]] autorelease];
    [link addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
                            [NSColor blueColor], NSForegroundColorAttributeName, nil]
                  range:NSMakeRange(0, [link length])];
    [link setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [link length])];
    [_linkButton setAttributedTitle:link];
    NSMutableAttributedString *pressed = [[[NSMutableAttributedString alloc]
        initWithAttributedString:[_linkButton attributedTitle]] autorelease];
    [pressed addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
                               [NSColor brownColor], NSForegroundColorAttributeName, nil]
                     range:NSMakeRange(0, [link length])];
    [pressed setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, [link length])];
    [_linkButton setAttributedAlternateTitle:pressed];
    [_linkButton setFocusRingType:NSFocusRingTypeNone];
    [[self window] center];
}
- (id)init
{
    return [super initWithWindowNibName:@"AboutBox"];
}
@end
