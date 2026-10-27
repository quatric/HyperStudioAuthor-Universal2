#import "PTransaction+PTransactionPrivate.h"
#import <objc/message.h>

@implementation PTransaction (PTransactionPrivate)

- (void)setState:(NSInteger)aState
{
    [_transactionLock lock];
    _state = (int)aState;
    [_transactionLock unlock];
}

- (void)abortTransaction
{
    [self setState:4];
    if ([self respondsToSelector:@selector(performSelectorOnMainThread:withObject:waitUntilDone:)])
        [self performSelectorOnMainThread:@selector(abortTransactionThread:) withObject:nil waitUntilDone:NO];
    else
        [self abortTransactionThread:nil];
}

- (void)abortTransactionThread:(id)aThread
{
    if ([_delegate respondsToSelector:@selector(transactionAborted:)])
        ((void (*)(id, SEL, id))objc_msgSend)(_delegate, @selector(transactionAborted:), self);
}

// The delegate hears about the result only when the transaction finished
// on another thread (aThread is then NSNull).
- (void)finishTransactionThread:(id)aThread
{
    [_startThread release];
    _startThread = nil;
    if (_error == 0) {
        [self setState:3];
        if (aThread != nil && [_delegate respondsToSelector:@selector(transactionSuccessful:)])
            ((void (*)(id, SEL, id))objc_msgSend)(_delegate, @selector(transactionSuccessful:), self);
    } else {
        [self setState:5];
        if (aThread != nil && [_delegate respondsToSelector:@selector(transactionHadError:)])
            ((void (*)(id, SEL, id))objc_msgSend)(_delegate, @selector(transactionHadError:), self);
    }
}

- (void)setError:(NSInteger)aError
{
    [_transactionLock lock];
    _error = (int)aError;
    [_transactionLock unlock];
}

// For values known up front: finishes now, or on the next run loop pass.
- (void)quickTransaction:(BOOL)aTransaction
{
    [self setState:2];
    if (aTransaction)
        [self finishTransactionThread:nil];
    else
        [self performSelector:@selector(finishTransactionThread:) withObject:[NSNull null] afterDelay:0.0];
}

- (void)startTransaction:(BOOL)aTransaction
{
    [self setState:2];
    _startThread = [[NSThread currentThread] retain];
    if (aTransaction)
        [self transactionThread:nil];
    else
        [[PTransactionManager sharedTransactionManager] addTransaction:self];
}

- (void)transactionThreadFunction
{
}

- (void)transactionThread:(id)aThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self transactionThreadFunction];
    if ([self state] == 4) {
        [_transactionLock lock];
        [_value release];
        _value = nil;
        [_objectValue release];
        _objectValue = nil;
        [_transactionLock unlock];
    } else if (![[NSThread currentThread] isEqual:_startThread]
               && [self respondsToSelector:@selector(performSelectorOnMainThread:withObject:waitUntilDone:)]) {
        [self performSelectorOnMainThread:@selector(finishTransactionThread:) withObject:[NSNull null] waitUntilDone:NO];
    } else {
        [self finishTransactionThread:nil];
    }
    [pool release];
}

@end
