#import "HyperPlayerBasePrefix.h"


@interface HSMouseTracker : NSObject <HSAutoscrollingTrackingLoopClient, HSTrackingLoopClient, NSObject>
{
    id<HSLayoutGuidingContext> _layoutGuidingContext;
}
- (void)handleFlagsChanged:(id)aChanged inTrackingLoop:(id)aLoop;
- (void)handleMouseUp:(id)aUp inTrackingLoop:(id)aLoop;
- (void)handleMouseDragged:(id)aDragged inTrackingLoop:(id)aLoop;
- (void)handleMouseDown:(id)aDown inTrackingLoop:(id)aLoop;
- (void)flagsChanged:(id)aChanged inView:(id)aView;
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)postprocessMouseDragged:(id)aDragged inView:(id)aView;
- (void)processMouseDragged:(id)aDragged inView:(id)aView;
- (void)preprocessMouseDragged:(id)aDragged inView:(id)aView;
- (void)mouseDragged:(id)aDragged inView:(id)aView;
- (void)postprocessMouseDown:(id)aDown inView:(id)aView;
- (void)processMouseDown:(id)aDown inView:(id)aView;
- (void)preprocessMouseDown:(id)aDown inView:(id)aView;
- (void)mouseDown:(id)aDown inView:(id)aView;
- (void)setLayoutGuidingContext:(id)aContext;
- (id)layoutGuidingContext;
- (void)dealloc;
@end

