#import "HyperStudioPrefix.h"
#import "HSANetworkConnection.h"


@interface HSAFTPConnection : HSANetworkConnection <NSStreamDelegate>
{
    unsigned int _isActive:1;
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    NSTimer *_timeoutTimer;
    NSMutableData *_readData;
    NSMutableSet *_URLs;
    int _currentIndex;
    NSMutableArray *_directories;
    SEL _didEndSelector;
}
+ (NSUInteger)defaultPort;
+ (id)schemes;
+ (id)anonymousUser;
+ (id)localizedErrorForError:(id)aError;
- (id)initWithURL:(id)aURL delegate:(id)aDelegate;
- (BOOL)isActive;
- (void)setIsActive:(BOOL)aIsActive;
- (id)outputStream;
- (BOOL)open;
- (void)close;
- (void)checkConnection;
- (void)checkReachability;
- (void)removeDirectory;
- (void)resourceExistsAtPath:(id)aPath;
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)aEvent;
- (void)dealloc;
@end
