#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteListLabelTypeinfo : KeynoteObject
{
    NSDictionary *_topicsInfo;
}
+ (id)romanStringComponentsDictionary;
+ (id)numberingPrefixTypes;
- (id)lowerRomanStringFromInt:(NSInteger)aInt;
- (id)lowerAlphaStringFromInt:(NSInteger)aInt;
- (id)stringOfType:(id)aType fromInt:(NSInteger)aInt;
- (id)prefixOfType:(id)aType withFormat:(id)aFormat stringAttributes:(id)aAttributes listLevel:(NSInteger)aLevel shouldModify:(BOOL)aModify;
- (id)defaultPrefix;
- (id)attributedPrefixFromPrefix:(id)aPrefix withStringAttributes:(id)aAttributes;
- (id)prefixWithStringAttributes:(id)aAttributes listLevel:(NSInteger)aLevel;
- (void)setTopicsInfo:(id)aInfo;
- (id)topicsInfo;
- (void)didInitFromParser;
@end

