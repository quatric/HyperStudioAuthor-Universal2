#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSScrollCardAction : HSNBAAction <HSScrollCardActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSScrollCardActionAttribute, HSPositionAttributes, HSPositionAttribute>
{
    NSPoint _scrollPoint;
}
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (BOOL)supportedInIPad;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (void)setPosition:(NSPoint)aPosition;
- (NSPoint)position;
- (void)setScrollPoint:(NSPoint)aPoint;
- (NSPoint)scrollPoint;
- (void)animationDidEnd:(id)aEnd;
- (void)animationDidStop:(id)aStop;
- (void)startInContext:(id)aContext;
- (void)setScrollPointRepresentation:(id)aRepresentation;
- (id)scrollPointRepresentation;
- (BOOL)canChangeSynchronousFlag;
- (BOOL)isSynchronous;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

