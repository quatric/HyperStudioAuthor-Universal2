#import "HSNavigationOperation.h"

@implementation HSNavigationOperation

- (void)setStage:(NSInteger)aStage
{
    [self setStage:aStage postNotification:YES];
}

- (void)setStage:(NSInteger)aStage postNotification:(BOOL)aNotification
{
    if (!aNotification) {
        _stage = (int)aStage;
    } else {
        [self willChangeStage];
        _stage = (int)aStage;
        [self didChangeStage];
    }
}

- (void)didChangeStage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSNavigationOperationStageDidChangeNotification" object:self];
}

- (void)willChangeStage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSNavigationOperationStageWillChangeNotification" object:self];
}

- (NSInteger)stage
{
    return _stage;
}

- (void)setUserInfo:(id)aInfo
{
    if (![_userInfo isEqualToDictionary:aInfo]) {
        [_userInfo release];
        _userInfo = [aInfo retain];
    }
}

- (id)userInfo
{
    return _userInfo;
}

- (void)setIgnoresSlideshow:(BOOL)aSlideshow
{
    _ignoresSlideshow = aSlideshow;
}

- (BOOL)ignoresSlideshow
{
    return _ignoresSlideshow;
}

- (id)transition
{
    return _transition;
}

- (void)setShouldOpenUntitledDocument:(BOOL)aDocument
{
    _shouldOpenUntitledDocument = aDocument;
}

- (BOOL)shouldOpenUntitledDocument
{
    return _shouldOpenUntitledDocument;
}

- (void)setDestinationCard:(id)aCard
{
    if (_destinationCard != aCard) {
        [_destinationCard release];
        _destinationCard = [aCard retain];
    }
}

- (id)destinationCard
{
    return _destinationCard;
}

- (void)setDestinationStack:(id)aStack
{
    if (_destinationStack != aStack) {
        [_destinationStack release];
        _destinationStack = [aStack retain];
    }
}

- (id)destinationStack
{
    return _destinationStack;
}

- (id)destinationCardUID
{
    return _destinationCardUID;
}

- (id)destinationStackURL
{
    return _destinationStackURL;
}

// Unset index/id are 0x7fffffff (the i386 NSNotFound); callers compare against that value.
- (NSInteger)destinationCardIdOldFileFormat
{
    return _destinationCardIdOldFileFormat;
}

- (NSUInteger)destinationCardIndex
{
    return _destinationCardIndex;
}

- (BOOL)shouldReopenDocumentIfSoureIsDestination
{
    return _shouldReopenDocumentIfSoureIsDestination;
}

- (void)setShouldReopenDocumentIfSoureIsDestination:(BOOL)aDestination
{
    _shouldReopenDocumentIfSoureIsDestination = aDestination;
}

- (void)setSourceCardViewTransform:(CGAffineTransform)aTransform
{
    _sourceCardViewTransform = aTransform;
}

- (CGAffineTransform)sourceCardViewTransform
{
    return _sourceCardViewTransform;
}

- (void)setSourceCardUserSpaceToViewSpaceTransform:(CGAffineTransform)aTransform
{
    _sourceCardUserSpaceToViewSpaceTransform = aTransform;
}

- (CGAffineTransform)sourceCardUserSpaceToViewSpaceTransform
{
    return _sourceCardUserSpaceToViewSpaceTransform;
}

- (void)setSourceCard:(id)aCard
{
    if (_sourceCard != aCard) {
        [aCard retain];
        [_sourceCard release];
        _sourceCard = aCard;
    }
}

- (id)sourceCard
{
    return _sourceCard;
}

- (void)setSourceDocument:(id)aDocument
{
    if (_sourceDocument != aDocument) {
        [_sourceDocument release];
        _sourceDocument = [aDocument retain];
    }
}

- (id)sourceDocument
{
    return _sourceDocument;
}

- (void)setSourceStackURL:(id)aURL
{
    if (![_sourceStackURL isEqual:aURL]) {
        [_sourceStackURL release];
        _sourceStackURL = [aURL retain];
    }
}

- (id)sourceStackURL
{
    return _sourceStackURL;
}

- (void)dealloc
{
    [_sourceStackURL release];
    [_sourceCard release];
    [_sourceDocument release];
    [_destinationCardUID release];
    [_destinationStackURL release];
    [_destinationCard release];
    [_destinationStack release];
    [(id)_transition release];
    [_userInfo release];
    [super dealloc];
}

- (id)initWithDestinationStackURL:(id)aURL destinationCardIdOldFileFormat:(NSUInteger)aFormat transition:(id)aTransition
{
    self = [super init];
    if (self != nil) {
        _destinationStackURL = [aURL retain];
        _destinationCardIdOldFileFormat = (int)aFormat;
        _transition = [aTransition retain];
        _destinationCardIndex = 0x7fffffff;
    }
    return self;
}

- (id)initWithDestinationStackURL:(id)aURL destinationCardIndex:(NSUInteger)aIndex transition:(id)aTransition
{
    self = [super init];
    if (self != nil) {
        _destinationStackURL = [aURL retain];
        _destinationCardIndex = (unsigned int)aIndex;
        _transition = [aTransition retain];
        _destinationCardIdOldFileFormat = 0x7fffffff;
    }
    return self;
}

- (id)initWithDestinationStackURL:(id)aURL destinationCardUID:(id)aUID transition:(id)aTransition
{
    self = [super init];
    if (self != nil) {
        _destinationStackURL = [aURL retain];
        _destinationCardUID = [aUID retain];
        _transition = [aTransition retain];
        _destinationCardIndex = 0x7fffffff;
        _destinationCardIdOldFileFormat = 0x7fffffff;
    }
    return self;
}

@end
