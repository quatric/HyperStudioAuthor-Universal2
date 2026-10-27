#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSPictureShowAction : HSNBAAction <HSPictureShowActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSLoopPictureShowAttribute, HSLeavesLastPictureOnExitAttribute, HSShowsFilenameOnPictureAttribute, HSTimeDelayAttribute, HSURLAttribute>
{
    BOOL _loopPictureShow;
    BOOL _leavesLastPictureOnExit;
    BOOL _showsFilenameOnPicture;
    double _timeDelay;
    NSURL *_URL;
    NSMutableArray *_URLs;
    HSActionExecutionContext *_context;
    BOOL _isMissingFolder;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (BOOL)isAbleToStartInInvalidState;
- (BOOL)isValid;
- (NSRect)slideshowFrame;
- (NSUInteger)slideshowAutoresizingMask;
- (id)slideshowView;
- (id)slideshowItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSlideshowItems;
- (void)invalidateURLs;
- (id)URLs;
- (void)setURL:(id)aURL;
- (id)URL;
- (void)setTimeDelay:(double)aDelay;
- (double)timeDelay;
- (void)setShowsFilenameOnPicture:(BOOL)aPicture;
- (BOOL)showsFilenameOnPicture;
- (void)setLeavesLastPictureOnExit:(BOOL)aExit;
- (BOOL)leavesLastPictureOnExit;
- (void)setLoopPictureShow:(BOOL)aShow;
- (BOOL)loopPictureShow;
- (void)openPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (id)missingFolderAlert;
- (id)pictureShowActionAttributes;
- (void)startInContext:(id)aContext;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)slideshowDidStop:(id)aStop;
- (void)notifyDidFinish;
- (BOOL)canChangeSynchronousFlag;
- (BOOL)isSynchronous;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

