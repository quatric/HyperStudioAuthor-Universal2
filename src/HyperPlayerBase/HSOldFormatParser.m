#import "HSOldFormatParser.h"

// Parses a HyperStudio 4 file through a types tree: each type names its parts
// (type, name, size, offset, count, value), and the parsed values are kept in
// a values buffer keyed "<parent>.type.<name>" for later sizes and offsets.
@implementation HSOldFormatParser

- (id)parametersDictionaryWithValue:(id)aValue name:(id)aName type:(id)aType size:(id)aSize
{
    if (aName)
        return [NSDictionary dictionaryWithObjectsAndKeys:aValue, @"value", aType, @"type", aSize, @"size", aName, @"name", nil];
    return [NSDictionary dictionaryWithObjectsAndKeys:aValue, @"value", aType, @"type", aSize, @"size", nil];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)setSlave:(BOOL)aSlave
{
    _isSlave = aSlave;
}

- (BOOL)isSlave
{
    return _isSlave;
}

- (void)setIsCollectParserValues:(BOOL)aValues
{
    _isCollectParserValues = aValues;
}

- (BOOL)isCollectParserValues
{
    return _isCollectParserValues;
}

- (void)setSaveOldToValuesBuffer:(BOOL)aBuffer
{
    _isSaveOldToValuesBuffer = aBuffer;
}

- (BOOL)isSaveOldToValuesBuffer
{
    return _isSaveOldToValuesBuffer;
}

- (void)setDataSavedToValuesBuffer:(BOOL)aBuffer
{
    _isDataSavedToValuesBuffer = aBuffer;
}

- (BOOL)isDataSavedToValuesBuffer
{
    return _isDataSavedToValuesBuffer;
}

- (void)setKernelError:(BOOL)aError
{
    _hasKernelError = aError;
}

- (BOOL)hasKernelError
{
    return _hasKernelError;
}

- (void)setKernelErrors:(id)aErrors
{
    if (_kernelErrors != aErrors) {
        [_kernelErrors release];
        _kernelErrors = [aErrors retain];
    }
}

- (id)kernelErrors
{
    return _kernelErrors;
}

- (BOOL)hasKernelBreak
{
    return _hasKernelBreak;
}

- (void)setKernelBreak:(BOOL)aBreak
{
    _hasKernelBreak = aBreak;
}

- (void)setParsingType:(id)aType
{
    if (_parsingType != aType) {
        [_parsingType release];
        _parsingType = [aType retain];
    }
}

- (id)parsingType
{
    return _parsingType;
}

- (void)setTypesTreeAllKeys:(id)aKeys
{
    if (_typesTreeAllKeys != aKeys) {
        [_typesTreeAllKeys release];
        _typesTreeAllKeys = [aKeys retain];
    }
}

- (id)typesTreeAllKeys
{
    if (!_typesTreeAllKeys)
        [self setTypesTreeAllKeys:[_typesTree allKeys]];
    return _typesTreeAllKeys;
}

- (void)setTypesTree:(id)aTree
{
    if (_typesTree != aTree) {
        [_typesTree release];
        [self setTypesTreeAllKeys:nil];
        _typesTree = [aTree retain];
    }
}

- (id)typesTree
{
    return _typesTree;
}

- (void)setValuesBuffer:(id)aBuffer
{
    if (_valuesBuffer != aBuffer) {
        [_valuesBuffer release];
        _valuesBuffer = [aBuffer retain];
    }
}

- (id)valuesBuffer
{
    return _valuesBuffer;
}

// The buffer without saved older values (keys with '~') and without images
// and colours.
- (id)valuesBufferForSave
{
    NSMutableDictionary *buffer = [_valuesBuffer mutableCopy];
    NSArray *keys = [buffer allKeys];
    NSInteger count = [keys count];
    for (NSInteger i = 0; i < count; i++) {
        id key = [keys objectAtIndex:i];
        id value = [buffer objectForKey:key];
        if ([key rangeOfString:@"~"].location != NSNotFound || [value isKindOfClass:[NSImage class]] || [value isKindOfClass:[NSColor class]])
            [buffer removeObjectForKey:key];
    }
    return [buffer autorelease];
}

- (void)setParsed:(BOOL)aParsed
{
    _parsed = aParsed;
}

- (BOOL)isParsed
{
    return _parsed;
}

- (void)setResultStatus:(id)aStatus
{
    if (_resultStatus != aStatus) {
        [_resultStatus release];
        _resultStatus = [aStatus retain];
    }
}

- (id)resultStatus
{
    return _resultStatus;
}

- (void)setResultDictionary:(id)aDictionary
{
    if (_resultDictionary != aDictionary) {
        [_resultDictionary release];
        _resultDictionary = [aDictionary retain];
    }
}

- (id)resultDictionary
{
    if (![self isParsed])
        [self parse];
    return _resultDictionary;
}

- (void)setDataLength:(NSInteger)aLength
{
    _dataLength = (int)aLength;
}

- (NSInteger)dataLength
{
    return _dataLength;
}

- (void)setData:(id)aData
{
    if (_data != aData) {
        [_data release];
        _data = [aData retain];
        [self setDataLength:[_data length]];
    }
}

- (id)data
{
    return _data;
}

- (void)setPath:(id)aPath
{
    if (_path != aPath) {
        [_path release];
        _path = [aPath retain];
    }
}

- (id)path
{
    return _path;
}

- (void)dealloc
{
    _delegate = nil;
    [_path release];
    [_data release];
    [_resultDictionary release];
    [_resultStatus release];
    [_valuesBuffer release];
    [_typesTree release];
    [_typesTreeAllKeys release];
    [_parsingType release];
    [_kernelErrors release];
    [super dealloc];
}

- (id)initWithData:(id)aData
{
    self = [super init];
    if (self) {
        _path = nil;
        [self setData:aData];
        _parsed = NO;
        _resultDictionary = [NSMutableDictionary new];
        _resultStatus = [NSMutableDictionary new];
        _valuesBuffer = [NSMutableDictionary new];
        _typesTree = [NSMutableDictionary new];
        _kernelErrors = [NSMutableDictionary new];
        _isDataSavedToValuesBuffer = NO;
        _isSaveOldToValuesBuffer = NO;
        _isCollectParserValues = NO;
        _hasKernelBreak = NO;
    }
    return self;
}

- (id)initWithFileAtPath:(id)aPath
{
    self = [super init];
    if (self) {
        _path = [aPath copy];
        _data = nil;
        _parsed = NO;
        _resultDictionary = [NSMutableDictionary new];
        _resultStatus = [NSMutableDictionary new];
        _valuesBuffer = [NSMutableDictionary new];
        _typesTree = [NSMutableDictionary new];
        _kernelErrors = [NSMutableDictionary new];
        _isDataSavedToValuesBuffer = NO;
        _isSaveOldToValuesBuffer = NO;
        _isCollectParserValues = NO;
        _hasKernelBreak = NO;
    }
    return self;
}

// The types tree is set later, by the subclass or the owner.
- (id)init
{
    self = [super init];
    if (self) {
        _path = nil;
        _data = nil;
        _parsed = NO;
        _resultDictionary = [NSMutableDictionary new];
        _resultStatus = [NSMutableDictionary new];
        _valuesBuffer = [NSMutableDictionary new];
        _typesTree = nil;
        _kernelErrors = [NSMutableDictionary new];
        _isDataSavedToValuesBuffer = NO;
        _isSaveOldToValuesBuffer = NO;
        _isCollectParserValues = NO;
        _hasKernelBreak = NO;
    }
    return self;
}

@end

@implementation HSOldFormatParser (HSOldFormatParserPrivate)

- (void)loadDataFromFile
{
    [self setData:[NSData dataWithContentsOfFile:_path]];
}

- (void)parse
{
    if (!_data && _path)
        [self loadDataFromFile];
    if (_data) {
        [self setResultDictionary:[self parsedValue]];
        [self setParsed:YES];
    }
}

@end
