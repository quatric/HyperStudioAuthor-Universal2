#import "__NSEFileManagerPathHandler.h"

// These implement NSFileManager's URL and delegate methods on Foundation
// before 10.6 (NSFoundationVersionNumber < 833), where the +loads add them;
// macOS 11 has them all, so nothing installs these classes any more.

// The handlers turn the old handler callback (fileManager:
// shouldProceedAfterError: with a dictionary) into the delegate's error
// methods.
enum {
    kHandlerCopying = 1,
    kHandlerMoving = 2,
    kHandlerLinking = 3,
    kHandlerRemoving = 4,
};

static NSError *NewHandlerError(NSInteger code, NSDictionary *errorInfo)
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        [errorInfo objectForKey:@"Error"], NSLocalizedDescriptionKey,
        [errorInfo objectForKey:@"Path"], NSFilePathErrorKey,
        [errorInfo objectForKey:@"ToPath"], @"NSDestinationFilePath", nil];
    return [[NSError alloc] initWithDomain:@"NSEFileManagerErrorDomain" code:code userInfo:userInfo];
}

@implementation __NSEFileManagerPathHandler

- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError
{
    [_error release];
    _error = NewHandlerError(_errorCode, aError);
    SEL selector;
    switch (_errorCode) {
    case kHandlerCopying:
        selector = @selector(fileManager:shouldProceedAfterError:copyingItemAtPath:toPath:);
        break;
    case kHandlerMoving:
        selector = @selector(fileManager:shouldProceedAfterError:movingItemAtPath:toPath:);
        break;
    case kHandlerLinking:
        selector = @selector(fileManager:shouldProceedAfterError:linkingItemAtPath:toPath:);
        break;
    case kHandlerRemoving:
        if ([_delegate respondsToSelector:@selector(fileManager:shouldProceedAfterError:removingItemAtPath:)])
            return [_delegate fileManager:aManager shouldProceedAfterError:_error removingItemAtPath:_sourcePath];
        return NO;
    default:
        return NO;
    }
    if (![_delegate respondsToSelector:selector])
        return NO;
    return ((BOOL (*)(id, SEL, id, id, id, id))objc_msgSend)(_delegate, selector, aManager, _error, _sourcePath,
                                                            _destinationPath);
}

- (id)error
{
    return _error;
}

- (void)dealloc
{
    [_error release];
    [_sourcePath release];
    [_destinationPath release];
    [super dealloc];
}

- (id)initWithErrorCode:(NSInteger)aCode delegate:(id)aDelegate sourcePath:(id)aPath destinationPath:(id)aPath2
{
    self = [super init];
    if (!self)
        return nil;
    _errorCode = (int)aCode;
    _delegate = aDelegate;
    _sourcePath = [aPath retain];
    _destinationPath = [aPath2 retain];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

@implementation __NSEFileManagerURLHandler

- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError
{
    [_error release];
    _error = NewHandlerError(_errorCode, aError);
    SEL selector;
    switch (_errorCode) {
    case kHandlerCopying:
        selector = @selector(fileManager:shouldProceedAfterError:copyingItemAtURL:toURL:);
        break;
    case kHandlerMoving:
        selector = @selector(fileManager:shouldProceedAfterError:movingItemAtURL:toURL:);
        break;
    case kHandlerLinking:
        selector = @selector(fileManager:shouldProceedAfterError:linkingItemAtURL:toURL:);
        break;
    case kHandlerRemoving:
        if ([_delegate respondsToSelector:@selector(fileManager:shouldProceedAfterError:removingItemAtURL:)])
            return [_delegate fileManager:aManager shouldProceedAfterError:_error removingItemAtURL:_sourceURL];
        return NO;
    default:
        return NO;
    }
    if (![_delegate respondsToSelector:selector])
        return NO;
    return ((BOOL (*)(id, SEL, id, id, id, id))objc_msgSend)(_delegate, selector, aManager, _error, _sourceURL,
                                                            _destinationURL);
}

- (id)error
{
    return _error;
}

- (void)dealloc
{
    [_error release];
    [_sourceURL release];
    [_destinationURL release];
    [super dealloc];
}

- (id)initWithErrorCode:(NSInteger)aCode delegate:(id)aDelegate sourceURL:(id)aURL destinationURL:(id)aURL2
{
    self = [super init];
    if (!self)
        return nil;
    _errorCode = (int)aCode;
    _delegate = aDelegate;
    _sourceURL = [aURL retain];
    _destinationURL = [aURL2 retain];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

// Stands in as the file manager's delegate during a path operation, turning
// its path callbacks into the real delegate's URL ones. The real delegate is
// the file manager's own while it's called (and may change it).
@implementation __NSEFileManagerPathDelegate

// Calls the delegate with the file manager's delegate set to it, and takes
// the file manager's delegate back as the delegate afterwards.
static BOOL CallDelegate(__NSEFileManagerPathDelegate *self, id *delegate, NSFileManager *manager, SEL selector,
                         BOOL otherwise, id error, NSURL *url, NSURL *url2)
{
    if (![*delegate respondsToSelector:selector])
        return otherwise;
    [manager setDelegate:*delegate];
    BOOL result;
    if (error && url2)
        result = ((BOOL (*)(id, SEL, id, id, id, id))objc_msgSend)(*delegate, selector, manager, error, url, url2);
    else if (error)
        result = ((BOOL (*)(id, SEL, id, id, id))objc_msgSend)(*delegate, selector, manager, error, url);
    else if (url2)
        result = ((BOOL (*)(id, SEL, id, id, id))objc_msgSend)(*delegate, selector, manager, url, url2);
    else
        result = ((BOOL (*)(id, SEL, id, id))objc_msgSend)(*delegate, selector, manager, url);
    *delegate = [manager delegate];
    [manager setDelegate:(id)self];
    return result;
}

- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError removingItemAtPath:(id)aPath
{
    return CallDelegate(self, &_delegate, aManager, @selector(fileManager:shouldProceedAfterError:removingItemAtURL:),
                        NO, aError, _sourceURL, nil);
}

- (BOOL)fileManager:(id)aManager shouldRemoveItemAtPath:(id)aPath
{
    return CallDelegate(self, &_delegate, aManager, @selector(fileManager:shouldRemoveItemAtURL:), YES, nil,
                        _sourceURL, nil);
}

- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError linkingItemAtPath:(id)aPath toPath:(id)aPath2
{
    return CallDelegate(self, &_delegate, aManager,
                        @selector(fileManager:shouldProceedAfterError:linkingItemAtURL:toURL:), NO, aError,
                        _sourceURL, _destinationURL);
}

- (BOOL)fileManager:(id)aManager shouldLinkItemAtPath:(id)aPath toPath:(id)aPath2
{
    return CallDelegate(self, &_delegate, aManager, @selector(fileManager:shouldLinkItemAtURL:toURL:), YES, nil,
                        _sourceURL, _destinationURL);
}

- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError movingItemAtPath:(id)aPath toPath:(id)aPath2
{
    return CallDelegate(self, &_delegate, aManager,
                        @selector(fileManager:shouldProceedAfterError:movingItemAtURL:toURL:), NO, aError,
                        _sourceURL, _destinationURL);
}

- (BOOL)fileManager:(id)aManager shouldMoveItemAtPath:(id)aPath toPath:(id)aPath2
{
    return CallDelegate(self, &_delegate, aManager, @selector(fileManager:shouldMoveItemAtURL:toURL:), YES, nil,
                        _sourceURL, _destinationURL);
}

- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError copyingItemAtPath:(id)aPath toPath:(id)aPath2
{
    return CallDelegate(self, &_delegate, aManager,
                        @selector(fileManager:shouldProceedAfterError:copyingItemAtURL:toURL:), NO, aError,
                        _sourceURL, _destinationURL);
}

- (BOOL)fileManager:(id)aManager shouldCopyItemAtPath:(id)aPath toPath:(id)aPath2
{
    return CallDelegate(self, &_delegate, aManager, @selector(fileManager:shouldCopyItemAtURL:toURL:), YES, nil,
                        _sourceURL, _destinationURL);
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_sourceURL release];
    [_destinationURL release];
    [super dealloc];
}

- (id)initWithDelegate:(id)aDelegate sourceURL:(id)aURL destinationURL:(id)aURL2
{
    self = [super init];
    if (!self)
        return nil;
    _delegate = aDelegate;
    _sourceURL = [aURL retain];
    _destinationURL = [aURL2 retain];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

// Stands in as the delegate while linking (10.5's linkItemAtURL: didn't ask the
// delegate about URLs it links).
@implementation __NSEFileManagerURLDelegate

- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError linkingItemAtURL:(id)aURL toURL:(id)aURL2
{
    if (![_delegate respondsToSelector:@selector(fileManager:shouldProceedAfterError:linkingItemAtURL:toURL:)])
        return NO;
    [aManager setDelegate:_delegate];
    BOOL result = [_delegate fileManager:aManager shouldProceedAfterError:aError linkingItemAtURL:aURL toURL:aURL2];
    _delegate = [aManager delegate];
    [aManager setDelegate:(id)self];
    return result;
}

- (BOOL)fileManager:(id)aManager shouldLinkItemAtURL:(id)aURL toURL:(id)aURL2
{
    if (![_delegate respondsToSelector:@selector(fileManager:shouldLinkItemAtURL:toURL:)])
        return YES;
    [aManager setDelegate:_delegate];
    BOOL result = [_delegate fileManager:aManager shouldLinkItemAtURL:aURL toURL:aURL2];
    _delegate = [aManager delegate];
    [aManager setDelegate:(id)self];
    return result;
}

// Copying errors are asked about as linking ones.
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError copyingItemAtURL:(id)aURL toURL:(id)aURL2
{
    return [self fileManager:aManager shouldProceedAfterError:aError linkingItemAtURL:aURL toURL:aURL2];
}

- (id)delegate
{
    return _delegate;
}

- (id)initWithDelegate:(id)aDelegate
{
    self = [super init];
    if (self)
        _delegate = aDelegate;
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

@implementation NSDirectoryEnumerator (NSEDirectoryEnumeratorLoading)

// Added skipDescendants (Foundation before 10.6); macOS 11 has it.
+ (void)load
{
}

@end

@implementation NSFileManager (NSEFileManagerLoading)

// Added the URL and delegate methods (Foundation before 10.6); macOS 11 has
// them.
+ (void)load
{
}

@end
