#import "HyperStudioPrefix.h"


@interface HSViewEmbedder : NSObject <HSRunTimeEditorEmbedder, HyperInterface, NSObject>
{
    id<HSRunTimeEditorEmbedderObserver> _observer;
}
- (id)observer;
- (void)setObserver:(id)aObserver;
- (BOOL)isMountedInHostView;
- (void)unmountFromHostView:(id)aView;
- (BOOL)makeEmbeddedViewFirstResponder;
- (void)mountInHostView:(id)aView;
- (void)sizeToFitWithObjectBounds:(NSRect)aBounds;
- (NSSize)preferredSize;
- (void)setFrame:(NSRect)aFrame;
- (NSRect)frame;
- (id)embeddedView;
@end

