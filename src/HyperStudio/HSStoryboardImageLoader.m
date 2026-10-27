#import "HSStoryboardImageLoader.h"

@implementation HSStoryboardImageLoader

- (void)cancelAllRequests
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _running = NO;
}

- (void)validateInvalidItems
{
    if (_running)
        return;
    _running = YES;
    [self performSelector:@selector(loadQueuedImages:) withObject:nil afterDelay:0.0 inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, nil]];
}

// Renders one invalid card thumbnail per run-loop pass until the delegate has none left.
- (void)loadQueuedImages:(id)aImages
{
    if ([_delegate respondsToSelector:@selector(nextInvalidItemForImageLoader:)]) {
        NSDictionary *request = [_delegate nextInvalidItemForImageLoader:self];

        if (request != nil) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            id card = [request objectForKey:@"card"];

            if (card != nil) {
                NSSize size = NSSizeFromString([request objectForKey:@"size"]);
                NSImage *image = [[[NSImage alloc] initWithSize:size] autorelease];

                [image setFlipped:YES];
                [image lockFocus];
                NSSize cardSize = [[[card queryHyperInterface:@protocol(HSUserObjectSupport)] stack] hyperCardSize];
                [[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformMakeScale(size.width / cardSize.width, size.height / cardSize.height)] concat];
                [[[card queryHyperInterface:@protocol(HSVisualization)] queryRenderer] drawRegion:[HSRegion regionWithRect:NSMakeRect(0, 0, cardSize.width, cardSize.height)] withDelegate:nil];
                [image unlockFocus];
                if ([_delegate respondsToSelector:@selector(imageLoader:loadedImage:)])
                    [_delegate imageLoader:self loadedImage:[NSDictionary dictionaryWithObjectsAndKeys:image, @"image", request, @"request", nil]];
            }
            // Fix: the pool was only drained when the request had a card.
            [pool release];
            [self performSelector:_cmd withObject:nil afterDelay:0.0 inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, nil]];
            return;
        }
    }
    _running = NO;
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)initWithDelegate:(id)aDelegate
{
    self = [super init];
    if (self != nil)
        _delegate = aDelegate;
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super dealloc];
}

@end
