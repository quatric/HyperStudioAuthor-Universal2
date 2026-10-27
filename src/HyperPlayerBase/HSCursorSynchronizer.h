#import "HyperPlayerBasePrefix.h"


@interface HSCursorSynchronizer : NSObject
{
    HSCursor *_currentCursor;
}
+ (id)sharedInstance;
- (void)clearCursor;
- (void)resetCursor;
- (void)setCursor:(id)aCursor;
- (void)dealloc;
- (id)init;
@end

@interface HSCursor : NSObject
{
    NSCursor *_cursor;
    NSString *_name;
    HSNewMedia *_imageMedia;
}
+ (id)cursorNamed:(id)aNamed;
+ (id)loadedCursorWithName:(id)aName;
+ (id)cursorsDescription;
+ (id)registeredCursorsByName;
+ (id)microphoneCursor;
+ (id)disappearingCursor;
+ (id)draggingCursor;
+ (id)draggableCursor;
+ (id)actionCursor;
+ (id)textCursor;
+ (id)defaultPlayerCursor;
+ (id)defaultCursor;
+ (id)cursorWithFrames:(id)aFrames changeDelays:(id)aDelays hotSpot:(NSPoint)aSpot;
+ (BOOL)isHidden;
+ (void)unhideCursorIfNeeded;
+ (void)hideCursorIfNeeded;
+ (void)clearCursor;
+ (void)resetCursor;
- (void)setCursor:(id)aCursor;
- (id)cursor;
- (void)setImageMedia:(id)aMedia;
- (id)imageMedia;
- (void)setName:(id)aName;
- (id)name;
- (void)set;
- (NSPoint)hotSpot;
- (id)image;
- (void)setImage:(id)aImage hotSpot:(NSPoint)aSpot;
- (BOOL)isEqual:(id)aEqual;
- (void)dealloc;
- (id)initWithCursor:(id)aCursor;
- (id)initWithImage:(id)aImage hotSpot:(NSPoint)aSpot;
- (id)imageMediaForHTML5Export;
@end

