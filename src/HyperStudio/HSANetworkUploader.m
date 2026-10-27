#import "HSANetworkUploader.h"

@implementation HSANetworkUploader

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithConnection:(id)aConnection
{
    if (aConnection == nil) {
        [self release];
        return nil;
    }
    self = [super init];
    if (self != nil) {
        _connection = [aConnection retain];
        [_connection setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_connection setDelegate:nil];
    [_connection release];
    [super dealloc];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (BOOL)isUploading
{
    return _isUploading;
}

- (BOOL)uploadFileAtURL:(id)aURL removeIfExist:(BOOL)aRemove error:(id *)aError
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (void)uploadFolderAtURL:(id)aURL removeIfExist:(BOOL)aRemove
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)cancel
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
