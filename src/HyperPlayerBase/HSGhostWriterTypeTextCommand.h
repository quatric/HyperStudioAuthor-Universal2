#import "HyperPlayerBasePrefix.h"
#import "HSGhostWriterCommand.h"


@interface HSGhostWriterTypeTextCommand : HSGhostWriterCommand <HSGhostWriterTypeTextCommandInterface, HyperInterface, NSObject, NSCoding>
{
    NSString *_stringToType;
    NSAttributedString *_textToType;
}
- (id)stringRepresentation;
- (id)descriprtion;
- (BOOL)shouldRunWithoutDelayAfterCommand:(id)aCommand;
- (id)initWithCoder:(id)aCoder;
- (void)encodeWithCoder:(id)aCoder;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)executeWithActionPerformer:(id)aPerformer;
- (id)copyWithZone:(NSZone *)aZone;
- (BOOL)isEqual:(id)aEqual;
- (void)setStringToType:(id)aType;
- (void)setTextToType:(id)aType;
- (id)stringToType;
- (id)initWithStringToType:(id)aType;
- (void)dealloc;
@end

