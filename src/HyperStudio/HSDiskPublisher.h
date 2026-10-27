#import "HyperStudioPrefix.h"
#import "HSPublisher.h"


@interface HSDiskPublisher : HSPublisher
{
    NSString *_storePath;
    NSString *_embeddedCode;
    NSTextField *_filePathTextField;
    NSButton *_embedCodeButton;
    NSButton *_previewSiteNowButton;
    NSWindow *_finishWindow;
}
- (void)embedCode:(id)aCode;
- (void)finish:(id)aFinish;
- (void)previewSiteNow:(id)aNow;
- (void)finishSheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)publish:(id)aPublish;
- (void)showFinishWindow;
- (id)finishWindow;
- (id)progressSheetDescription;
- (void)dealloc;
@end

