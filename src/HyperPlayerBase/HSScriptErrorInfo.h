#import "HyperPlayerBasePrefix.h"


@interface HSScriptErrorInfo : NSObject <NSCopying>
{
    unsigned int _id;
    unsigned int _level;
    NSString *_sourceCode;
    NSString *_shortMessage;
    NSString *_message;
    NSRange _range;
    struct HSScriptBisonRange _bisonRange;
}
+ (NSUInteger)alertStyleForErrorLevel:(NSInteger)aLevel;
+ (NSInteger)compositeErrorsLevelWithErrors:(id)aErrors;
+ (id)errorInfoWithMessage:(id)aMessage;
+ (id)errorInfo;
- (NSUInteger)alertStyle;
- (id)copyWithZone:(NSZone *)aZone;
- (id)levelString;
- (void)setLevel:(NSInteger)aLevel;
- (NSInteger)level;
- (void)setId:(NSUInteger)aId;
- (NSUInteger)id;
- (void)setBisonRange:(struct HSScriptBisonRange)aRange;
- (struct HSScriptBisonRange)bisonRange;
- (void)setRange:(NSRange)aRange;
- (NSRange)range;
- (void)setMessage:(id)aMessage;
- (id)message;
- (void)setShortMessage:(id)aMessage;
- (id)shortMessage;
- (void)setSourceCode:(id)aCode;
- (id)sourceCode;
- (void)setLine:(NSUInteger)aLine;
- (NSUInteger)line;
- (void)dealloc;
- (id)initWithMessage:(id)aMessage andRange:(NSRange)aRange;
- (id)initWithMessage:(id)aMessage;
- (id)init;
@end

@interface NSArray (HSScriptErrorInfosArray)
- (NSInteger)hyperMaxScriptErrorLevel;
@end

