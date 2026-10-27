#import "HyperPlayerBasePrefix.h"


@interface HSNavigationOperation : NSObject
{
    NSURL *_sourceStackURL;
    BOOL _shouldReopenDocumentIfSoureIsDestination;
    NSURL *_destinationStackURL;
    HSUID *_destinationCardUID;
    unsigned int _destinationCardIndex;
    int _destinationCardIdOldFileFormat;
    HSCard *_destinationCard;
    HSStack *_destinationStack;
    BOOL _shouldOpenUntitledDocument;
    BOOL _shouldOpenInSeparateWindow;
    id<HSTransitionAttributes> _transition;
    int _stage;
    BOOL _ignoresSlideshow;
    NSDictionary *_userInfo;
    HSCard *_sourceCard;
    HSDocument *_sourceDocument;
    CGAffineTransform _sourceCardUserSpaceToViewSpaceTransform;
    CGAffineTransform _sourceCardViewTransform;
}
- (void)setStage:(NSInteger)aStage;
- (void)setStage:(NSInteger)aStage postNotification:(BOOL)aNotification;
- (void)didChangeStage;
- (void)willChangeStage;
- (NSInteger)stage;
- (void)setUserInfo:(id)aInfo;
- (id)userInfo;
- (void)setIgnoresSlideshow:(BOOL)aSlideshow;
- (BOOL)ignoresSlideshow;
- (id)transition;
- (void)setShouldOpenUntitledDocument:(BOOL)aDocument;
- (BOOL)shouldOpenUntitledDocument;
- (void)setDestinationCard:(id)aCard;
- (id)destinationCard;
- (void)setDestinationStack:(id)aStack;
- (id)destinationStack;
- (id)destinationCardUID;
- (id)destinationStackURL;
- (NSInteger)destinationCardIdOldFileFormat;
- (NSUInteger)destinationCardIndex;
- (BOOL)shouldReopenDocumentIfSoureIsDestination;
- (void)setShouldReopenDocumentIfSoureIsDestination:(BOOL)aDestination;
- (void)setSourceCardViewTransform:(CGAffineTransform)aTransform;
- (CGAffineTransform)sourceCardViewTransform;
- (void)setSourceCardUserSpaceToViewSpaceTransform:(CGAffineTransform)aTransform;
- (CGAffineTransform)sourceCardUserSpaceToViewSpaceTransform;
- (void)setSourceCard:(id)aCard;
- (id)sourceCard;
- (void)setSourceDocument:(id)aDocument;
- (id)sourceDocument;
- (void)setSourceStackURL:(id)aURL;
- (id)sourceStackURL;
- (void)dealloc;
- (id)initWithDestinationStackURL:(id)aURL destinationCardIdOldFileFormat:(NSUInteger)aFormat transition:(id)aTransition;
- (id)initWithDestinationStackURL:(id)aURL destinationCardIndex:(NSUInteger)aIndex transition:(id)aTransition;
- (id)initWithDestinationStackURL:(id)aURL destinationCardUID:(id)aUID transition:(id)aTransition;
- (void)setShouldOpenInSeparateWindow:(BOOL)aOpen;
- (BOOL)shouldOpenInSeparateWindow;
- (void)setTransition:(id)aTransition;
@end

