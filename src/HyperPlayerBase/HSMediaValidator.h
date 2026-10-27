#import "HyperPlayerBasePrefix.h"


@interface HSMediaValidator : NSObject
{
    HSDocument *_document;
    BOOL _isUndoGroupOpened;
}
+ (id)mediaValidatorForDocument:(id)aDocument;
- (void)removeActionFromParent:(id)aParent;
- (id)soundItemFromMedia:(id)aMedia;
- (id)findNewMediaForOldMedia:(id)aMedia;
- (void)addMedia:(id)aMedia forObject:(id)aObject inMediaToObjectMapIfCannotStore:(id)aStore;
- (BOOL)canStoreMedia:(id)aMedia;
- (void)closeUndoGroupIfNeeded;
- (void)openUndoGroupIfNeeded;
- (void)validateMedia;
- (void)validateMediaWithError:(id *)aError;
- (void)validatePlayMovieObjects:(id)aObjects error:(id *)aError;
- (void)invalidMovieMediaWithoutActionAlertDidEndWithReturnCode:(NSInteger)aCode media:(id)aMedia objects:(id)aObjects error:(id *)aError;
- (id)createInvalidMediaToPlayMovieObjectsMapFor:(id)aFor;
- (void)validatePlayMovieActions:(id)aActions error:(id *)aError;
- (void)invalidMovieMediaAlertDidEndWithReturnCode:(NSInteger)aCode media:(id)aMedia actions:(id)aActions error:(id *)aError;
- (id)createInvalidMediaToPlayMovieActionsMapFor:(id)aFor;
- (void)validatePlaySoundActions:(id)aActions error:(id *)aError;
- (void)invalidSoundMediaAlertDidEndWithReturnCode:(NSInteger)aCode media:(id)aMedia actions:(id)aActions error:(id *)aError;
- (id)createInvalidMediaToPlaySoundActionsMapFor:(id)aFor;
- (id)initWithDocument:(id)aDocument;
@end

