#import "NSWorkspace+NSEWorkspace.h"

@implementation NSWorkspace (NSEWorkspace)

// Launches the application at a path, or with a name. Before Snow Leopard
// (AppKit 1038) this went through LSOpenApplication; that path is gone.
- (BOOL)NSE_launchApplication:(id)aApplication options:(NSUInteger)aOptions configuration:(id)aConfiguration error:(id *)aError
{
    NSString *path = aApplication;
    if (![path isAbsolutePath])
        path = [self fullPathForApplication:path];
    NSURL *url = path ? [NSURL fileURLWithPath:path] : nil;
    if (!url) {
        if (aError)
            *aError = nil;
        return NO;
    }
    return [self launchApplicationAtURL:url options:aOptions configuration:aConfiguration error:aError] != nil;
}

@end

