#import "HyperStudioPrefix.h"


@interface HSEditorCardViewDragHelper : NSObject
{
    NSView<HSEditorCardViewDragHost> *_dragHost;
    unsigned int _canRecieveDrag:1;
    HSPasteboardDataProvider *_draggingPasteboardDataProvider;
    HSPasteboardDataProvider *_copyPasteboardDataProvider;
    NSPoint _offsetOfAddedObject;
    id<HSAddActionHandlerDelegate> _delegate;
    NSMutableDictionary *_mediaDictionary;
    NSData *_cashedImageDataFromRTFDPasteboard;
}
+ (id)iTunesSpecificFilenamesFromPasteboard:(id)aPasteboard;
+ (id)URLFromPasteboard:(id)aPasteboard;
+ (id)commentsForDroppedObjectWithURL:(id)aURL;
+ (id)commentsForArrayOfURLs:(id)aLs withAutofillType:(NSInteger)aType;
- (id)decodeDataObjectFromData:(id)aData offset:(unsigned int *)aOffset;
- (void)decodeValueOfObjCType:(char *)aType at:(void *)aAt fromData:(id)aData offset:(unsigned int *)aOffset;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)presentDropErrorInWindow:(id)aWindow dropOnCard:(BOOL)aCard;
- (NSUInteger)importToObject:(id)aObject dataFromFiles:(id)aFiles;
- (NSUInteger)importToCardDataFromFiles:(id)aFiles;
- (id)defaultAcceptingObject;
- (void)invalidateMediaDictionary;
- (id)mediaDictionary;
- (id)mediaWithPath:(id)aPath;
- (void)setupPasteUndoActionNameIfNeeded:(BOOL)aNeeded;
- (BOOL)readSelectionFromPasteboard:(id)aPasteboard useDragPreferences:(BOOL)aPreferences didAddNewObject:(BOOL *)aObject;
- (void)scaleTextObject:(id)aObject toSize:(NSSize)aSize needCenter:(BOOL)aCenter;
- (BOOL)canRecieveDataWhileDraggingFromPasteboard:(id)aPasteboard;
- (BOOL)canRecieveDataFromPath:(id)aPath acceptingObject:(id)aObject dataName:(id *)aName;
- (BOOL)canRecieveDataFromPath:(id)aPath acceptingObject:(id)aObject dataName:(id *)aName canConnect:(BOOL *)aConnect;
- (BOOL)canRecieveDataFromPath:(id)aPath acceptingObject:(id)aObject;
- (BOOL)isLockedObject:(id)aObject;
- (id)actionClassesForMediaType:(id)aType;
- (BOOL)canAddAction:(id)aAction intoObject:(id)aObject;
- (BOOL)canAddActionOfClass:(Class)aClass intoObject:(id)aObject;
- (BOOL)addObjectsInArray:(id)aArray intoObject:(id)aObject center:(BOOL)aCenter fitCanvas:(BOOL)aCanvas needOpenHelpPane:(BOOL)aPane isPasting:(BOOL)aPasting useDragPreferences:(BOOL)aPreferences pastingNotHSObject:(BOOL)aObject2;
- (BOOL)addObjectsInArray:(id)aArray intoObject:(id)aObject center:(BOOL)aCenter fitCanvas:(BOOL)aCanvas isPasting:(BOOL)aPasting useDragPreferences:(BOOL)aPreferences pastingNotHSObject:(BOOL)aObject2;
- (BOOL)addObject:(id)aObject intoObject:(id)aObject2 center:(BOOL)aCenter fitCanvas:(BOOL)aCanvas isHyperObject:(BOOL *)aObject3 needOpenHelpPane:(BOOL)aPane isPasting:(BOOL)aPasting useDragPreferences:(BOOL)aPreferences pastingNotHSObject:(BOOL)aObject4;
- (void)prepareAction:(id)aAction forAddingIntoObject:(id)aObject;
- (void)prepareGroupObjectIfNeeded:(id)aNeeded;
- (void)addAction:(id)aAction intoObject:(id)aObject useDragPreferences:(BOOL)aPreferences;
- (BOOL)changeMedia:(id)aMedia forObject:(id)aObject;
- (BOOL)addObjectsInArray:(id)aArray center:(BOOL)aCenter needOpenHelpPane:(BOOL)aPane useDragPreferences:(BOOL)aPreferences;
- (BOOL)addObjectsInArray:(id)aArray center:(BOOL)aCenter useDragPreferences:(BOOL)aPreferences;
- (BOOL)addObjectsInArray:(id)aArray center:(BOOL)aCenter fitCanvas:(BOOL)aCanvas isPasting:(BOOL)aPasting useDragPreferences:(BOOL)aPreferences pastingNotHSObject:(BOOL)aObject;
- (void)addObjectToCenterOfCard:(id)aCard;
- (void)addObjectToCenter:(id)aCenter;
- (id)actionEventForAction:(id)aAction addedIntoObject:(id)aObject useDragPreferences:(BOOL)aPreferences;
- (BOOL)readFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject createdObjects:(id *)aObjects runAnimationMode:(BOOL *)aMode dragOperation:(NSUInteger)aOperation useDragPreferences:(BOOL)aPreferences pastingNotHSObject:(BOOL *)aObject2;
- (id)archivedImageRegionNodeFromPasteboard:(id)aPasteboard;
- (id)objectFromFile:(id)aFile shouldImport:(BOOL)aImport intoAcceptingObject:(id)aObject runAnimationMode:(BOOL *)aMode error:(id *)aError dragOperation:(NSUInteger)aOperation useDragPreferences:(BOOL)aPreferences;
- (id)objectsFromPDFFile:(id)aFile firstPageOnly:(BOOL)aOnly;
- (id)objectsFromPDFFile:(id)aFile firstPageOnly:(BOOL)aOnly error:(id *)aError;
- (BOOL)isAnimatedGifMovieAtPath:(id)aPath;
- (BOOL)canRecieveDataFromFiles:(id)aFiles acceptingObject:(id)aObject dataName:(id *)aName;
- (BOOL)canRecieveDataFromFiles:(id)aFiles acceptingObject:(id)aObject dataName:(id *)aName canConnect:(BOOL *)aConnect;
- (BOOL)canRecieveDataFromFiles:(id)aFiles acceptingObject:(id)aObject;
- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject dataName:(id *)aName dragOperation:(NSUInteger)aOperation;
- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject dataName:(id *)aName dragOperation:(NSUInteger)aOperation canConnectToObject:(BOOL *)aObject2;
- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject canConnectToObject:(BOOL *)aObject2;
- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject dragOperation:(NSUInteger)aOperation;
- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard dataName:(id *)aName;
- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard;
- (BOOL)stringIsURL:(id)aURL;
- (id)stringFromPasteboard:(id)aPasteboard;
- (id)cashedImageDataFromRTFDPasteboard:(id)aPasteboard;
- (id)imageDataFromRTFDPasteboard:(id)aPasteboard;
- (BOOL)startDragWithNodes:(id)aNodes event:(id)aEvent;
- (void)duplicateObjectsInEnumerator:(id)aEnumerator duplicatedObjects:(id *)aObjects;
- (void)writeObjectsInEnumeratorToPasteboard:(id)aPasteboard;
- (void)draggedImage:(id)aImage endedAt:(NSPoint)aAt operation:(NSUInteger)aOperation;
- (void)adjustLocationOfObjects:(id)aObjects toRect:(NSRect)aRect offsets:(id)aOffsets shift:(CGFloat)aShift;
- (BOOL)tryToReadFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject alignCenter:(BOOL)aCenter orAdjustLocation:(BOOL)aLocation toRect:(NSRect)aRect runAnimationMode:(BOOL *)aMode didAddNewObject:(BOOL *)aObject2 isPasting:(BOOL)aPasting dragOperation:(NSUInteger)aOperation useDragPreferences:(BOOL)aPreferences;
- (BOOL)performDragOperation:(id)aOperation acceptingObject:(id)aObject runAnimationMode:(BOOL *)aMode didAddNewObject:(BOOL *)aObject2;
- (BOOL)performDragOperation:(id)aOperation acceptingObject:(id)aObject;
- (void)concludeDragOperation:(id)aOperation;
- (void)draggingExited:(id)aExited;
- (NSUInteger)draggingUpdated:(id)aUpdated;
- (NSUInteger)draggingEntered:(id)aEntered;
- (id)pasteboardTypes;
- (id)editorDocument;
- (void)dealloc;
- (void)invalidateDragHost;
- (id)initWithDragHost:(id)aHost;
@end

@interface NSArray (HSNodeSelectionSupport)
- (id)objectsByRemovingLinkedObjects;
@end

