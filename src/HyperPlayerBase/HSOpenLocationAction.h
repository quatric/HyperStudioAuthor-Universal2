#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSOpenLocationAction : HSToDoAction <HSOpenLocationActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSURLAttribute, HSOpenLocationQuitAfterLaunchAttribute, HSOpenLocationApplicationNameAttribute, HSOpenLocationOpensDocumentAttribute, HSOpenLocationOpensApplicationAttribute, HSOpenLocationLaunchInForegroundAttribute>
{
    NSString *_applicationName;
    NSString *_applicationPath;
    BOOL _opensDocument;
    BOOL _opensApplication;
    BOOL _quitAfterLaunch;
    BOOL _launchInForeground;
    NSURL *_URL;
}
+ (id)auxiliaryApplicationNamesDictionary;
+ (id)actionWithPathToFile:(id)aFile;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)isAbleToStartInInvalidState;
- (BOOL)isValid;
- (id)pathToApplication;
- (id)pathToApplicationWithName:(id)aName;
- (id)auxiliaryApplicationName;
- (void)setOpensApplication:(BOOL)aApplication;
- (BOOL)opensApplication;
- (void)setOpensDocument:(BOOL)aDocument;
- (BOOL)opensDocument;
- (void)setApplicationName:(id)aName;
- (id)applicationName;
- (void)setLaunchInForeground:(BOOL)aForeground;
- (BOOL)launchInForeground;
- (void)setQuitAfterLaunch:(BOOL)aLaunch;
- (BOOL)quitAfterLaunch;
- (void)startInContext:(id)aContext;
- (void)setURL:(id)aURL;
- (id)URL;
- (void)openPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (BOOL)findFileAtPath:(id)aPath isApplication:(BOOL)aApplication context:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

