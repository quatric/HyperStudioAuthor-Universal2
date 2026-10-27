#import "HyperPlayerBasePrefix.h"


@interface HSOldFormatParser : NSObject
{
    NSString *_path;
    NSData *_data;
    int _dataLength;
    NSMutableDictionary *_resultDictionary;
    NSMutableDictionary *_resultStatus;
    BOOL _parsed;
    NSMutableDictionary *_valuesBuffer;
    NSMutableDictionary *_typesTree;
    NSArray *_typesTreeAllKeys;
    NSString *_parsingType;
    NSMutableDictionary *_kernelErrors;
    BOOL _hasKernelError;
    BOOL _hasKernelBreak;
    BOOL _isDataSavedToValuesBuffer;
    BOOL _isSaveOldToValuesBuffer;
    BOOL _isCollectParserValues;
    BOOL _isSlave;
    id _delegate;
}
- (id)parametersDictionaryWithValue:(id)aValue name:(id)aName type:(id)aType size:(id)aSize;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setSlave:(BOOL)aSlave;
- (BOOL)isSlave;
- (void)setIsCollectParserValues:(BOOL)aValues;
- (BOOL)isCollectParserValues;
- (void)setSaveOldToValuesBuffer:(BOOL)aBuffer;
- (BOOL)isSaveOldToValuesBuffer;
- (void)setDataSavedToValuesBuffer:(BOOL)aBuffer;
- (BOOL)isDataSavedToValuesBuffer;
- (void)setKernelError:(BOOL)aError;
- (BOOL)hasKernelError;
- (void)setKernelErrors:(id)aErrors;
- (id)kernelErrors;
- (BOOL)hasKernelBreak;
- (void)setKernelBreak:(BOOL)aBreak;
- (void)setParsingType:(id)aType;
- (id)parsingType;
- (void)setTypesTreeAllKeys:(id)aKeys;
- (id)typesTreeAllKeys;
- (void)setTypesTree:(id)aTree;
- (id)typesTree;
- (void)setValuesBuffer:(id)aBuffer;
- (id)valuesBuffer;
- (id)valuesBufferForSave;
- (void)setParsed:(BOOL)aParsed;
- (BOOL)isParsed;
- (void)setResultStatus:(id)aStatus;
- (id)resultStatus;
- (void)setResultDictionary:(id)aDictionary;
- (id)resultDictionary;
- (void)setDataLength:(NSInteger)aLength;
- (NSInteger)dataLength;
- (void)setData:(id)aData;
- (id)data;
- (void)setPath:(id)aPath;
- (id)path;
- (void)dealloc;
- (id)initWithData:(id)aData;
- (id)initWithFileAtPath:(id)aPath;
- (id)init;
@end

@interface HSOldFormatParser (HSOldFormatParserPrivate)
- (void)loadDataFromFile;
- (void)parse;
@end

