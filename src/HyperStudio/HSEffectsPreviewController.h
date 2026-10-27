#import "HyperStudioPrefix.h"


@interface HSEffectsPreviewController : NSObject
{
    id<HSEffectsPreviewControllerDataSource> _dataSource;
    id _delegate;
    HSImagePreviewView *_originalPreview;
    HSImagePreviewView *_effectPreview;
    NSView *_containerView;
}
- (void)mouseDownAtPoint:(NSPoint)aPoint atColor:(id)aColor inView:(id)aView;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (id)dataSource;
- (void)setDataSource:(id)aSource;
- (void)update;
- (id)containerView;
- (void)loadNibIfNeeded;
@end

