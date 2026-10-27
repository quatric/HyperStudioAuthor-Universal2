#import "HyperPlayerBasePrefix.h"


@interface HSOpenPanelProvider : NSObject <NSOpenSavePanelDelegate, NSObject>
{
    NSMutableDictionary *_fileTypeToFolderMap;
    id _modalDelegate;
    SEL _didEndSelector;
    void *_contextInfo;
}
+ (id)sharedOpenPanelProvider;
- (void)setTypeToFolderMapValue:(id)aValue forKey:(id)aKey;
- (id)fileTypeToFolderMap;
- (SEL)setterSelectorForFileType:(id)aType;
- (id)supportedTypesForFileType:(id)aType;
- (void)sheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)beginSheetForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector fileType:(id)aType accessoryView:(id)aView contextInfo:(void *)aInfo;
- (id)chooseFileOfType:(id)aType;
- (void)dealloc;
@end

