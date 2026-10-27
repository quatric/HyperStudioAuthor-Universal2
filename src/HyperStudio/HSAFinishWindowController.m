#import "HSAFinishWindowController.h"

@implementation HSAFinishWindowController

- (id)initWithStorePath:(id)aPath
{
    self = [super initWithWindow:nil];
    if (self != nil) {
        _storePath = [aPath copy];
    }
    return self;
}

// The window comes from the nib; the controller is only made with a store path.
- (id)initWithWindow:(id)aWindow
{
    [self release];
    return nil;
}

- (void)dealloc
{
    [_embeddedCode release];
    [_storePath release];
    [super dealloc];
}

- (id)windowNibName
{
    return @"HSDiskPublisherFinishWindow";
}

- (void)windowDidLoad
{
    if ([_storePath length] != 0) {
        [_storePathTextField setStringValue:_storePath];
    }
}

- (IBAction)onOK:(id)aSender
{
    [NSApp endSheet:[self window] returnCode:1];
    [[self window] close];
}

- (IBAction)onPreviewSiteNow:(id)aSender
{
    [NSApp endSheet:[self window] returnCode:0];
    [[NSWorkspace sharedWorkspace] openFile:[_storePath stringByAppendingPathComponent:@"index.html"] withApplication:@"Safari"];
    [[self window] close];
}

// Puts the embed code of the published page on the pasteboard.
- (IBAction)onEmbedCode:(id)aSender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (_embeddedCode == nil) {
        id page = [[[[NSDocumentController sharedDocumentController] currentDocument] exportManager] performSelector:@selector(embeddedCode:) withObject:self];
        if (page != nil) {
            id iframe = [page elementNamed:@"iframe"];
            NSString *text = [[NSString alloc] initWithData:[page data] encoding:NSUTF8StringEncoding];
            NSString *code = text;
            if (iframe == nil) {
                [text autorelease];
                NSRange start = [text rangeOfString:@"<!-- Start of Embed Code -->"];
                NSRange end = [text rangeOfString:@"<!-- End of Embed Code -->"];
                if (start.length != 0 && end.length != 0) {
                    NSString *snippet = [text substringWithRange:NSMakeRange(start.location, end.location + end.length - start.location)];
                    if (snippet != nil) {
                        code = [snippet retain];
                    }
                }
                if (code == text) {
                    code = [text retain];
                }
            }
            _embeddedCode = code;
        }
    }
    if (_embeddedCode != nil) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
        [pasteboard setString:_embeddedCode forType:NSStringPboardType];
    }
    [pool drain];
}

@end
