#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatParser.h"


@interface HSOldFormatParser (HSOldFormatParserKernel)
- (id)methodSignatureForSelector:(SEL)aSelector;
- (void)forwardInvocation:(id)aInvocation;
- (void)createSizeKeys;
- (NSInteger)longEvaluate:(id)aEvaluate;
- (NSInteger)intEvaluate:(id)aEvaluate;
- (id)setType:(id)aType name:(id)aName size:(id)aSize offset:(id)aOffset count:(id)aCount value:(id)aValue forBase:(id)aBase;
- (void)setAtValueTree:(id)aTree withParent:(id)aParent withName:(id)aName;
- (void)setValuesBufferObject:(id)aObject forKey:(id)aKey;
- (id)valuesBufferObjectForKey:(id)aKey;
- (BOOL)parametersValidationForType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)kernelErrorForType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_ReadFromDictionary__:(id)aDictionary atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_subType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parseType_dummy:(id)aDummy atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)valueSimpleForValue:(id)aValue forComplexType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)valueForComplexType:(id)aType atDefinedTree:(id)aTree type:(id)aType2 atOffset:(NSInteger)aOffset fullSize:(id)aSize;
- (id)workTreeFrom:(id)aFrom;
- (id)invokeCustomParserForType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)parsedValue;
- (id)valueForTypeInternal:(id)aInternal atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
- (id)valueForType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset;
@end

