#import "SMKBitmapToolsPrefix.h"


@interface BTMutableCGImageUndoer : NSObject <BTImageUndoing, NSObject>
{
    id<BTCGImage, BTCGMutableImage> _image;
    id<BTImageUndoingDelegate> _delegate;
    id<BTCGImage> _originalImageCopy;
    CGRect _changedRect;
    unsigned int _isGrouping:1;
}
- (void)endUndoGrouping;
- (void)beginUndoGrouping;
- (void)registerUndoInRect:(CGRect)aRect;
- (void)BTMutableCGImageUndoer_registerUndoInRect:(CGRect)aRect withOriginalImage:(id)aImage;
- (void)BTMutableCGImageUndoer_replaceRect:(CGRect)aRect withImage:(id)aImage;
- (id)BTMutableCGImageUndoer_copyRect:(CGRect)aRect fromImage:(id)aImage;
- (id)delegate;
- (id)image;
- (void)dealloc;
- (id)initWithImage:(id)aImage delegate:(id)aDelegate;
- (id)init;
@end

