#import "PRDOLocalTransaction.h"

// A transaction against a published server (a Distributed Objects proxy).

@implementation PRDOLocalTransaction

// Sets the connection's timeouts; subclasses then make their call.
- (void)transactionThreadFunction
{
    @try {
        NSConnection *connection = [(NSDistantObject *)_serverProtocol connectionForProxy];
        if (_timeout <= 0.0) {
            [connection setRequestTimeout:60.0];
            [connection setReplyTimeout:60.0];
        } else {
            [connection setRequestTimeout:_timeout];
            [connection setReplyTimeout:_timeout];
        }
    } @catch (NSException *exception) {
        [_client unexpectedDisconnect];
    }
}

- (void)dealloc
{
    [_serverItem release];
    [_client release];
    [(id<PRDOServerProtocol>)_serverProtocol release];
    [_password release];
    [super dealloc];
}

- (id)initWithServer:(id)aServer client:(id)aClient item:(id)aItem delegate:(id)aDelegate password:(id)aPassword timeout:(double)aTimeout
{
    self = [super init];
    if (self != nil) {
        _serverProtocol = [aServer retain];
        _client = [aClient retain];
        _serverItem = [aItem retain];
        _password = [aPassword copy];
        _timeout = aTimeout;
        [self setDelegate:aDelegate];
    }
    return self;
}

@end
