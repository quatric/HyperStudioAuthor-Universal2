#import "HyperStudioPrefix.h"
#import "HSPublisher.h"


@interface HSITunesPublisher : HSPublisher
{
    NSFileWrapper *_publishWrapper;
}
+ (id)applicationBundleForBundleID:(id)aID creator:(NSUInteger)aCreator;
+ (BOOL)iTunesApplicationVersionSupported;
+ (CGFloat)iTunesApplicationVersion;
- (void)iTunesLibraryMissingAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)iTunesUnaccessableAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)publish:(id)aPublish;
- (void)transferDataToITunesLibraryFromPath:(id)aPath;
- (id)progressSheetDescription;
- (void)dealloc;
@end

