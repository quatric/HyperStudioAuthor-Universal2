#import "HSScriptErrorInfo.h"

@implementation HSScriptErrorInfo

+ (NSUInteger)alertStyleForErrorLevel:(NSInteger)aLevel
{
    if (aLevel == 4)
        return NSAlertStyleCritical;
    if ((NSUInteger)(aLevel - 1) < 3)
        return NSAlertStyleWarning;
    return NSAlertStyleInformational;
}

+ (NSInteger)compositeErrorsLevelWithErrors:(id)aErrors
{
    return [aErrors hyperMaxScriptErrorLevel];
}

+ (id)errorInfoWithMessage:(id)aMessage
{
    return [[[self alloc] initWithMessage:aMessage] autorelease];
}

+ (id)errorInfo
{
    return [[[self alloc] init] autorelease];
}

- (NSUInteger)alertStyle
{
    return [[self class] alertStyleForErrorLevel:[self level]];
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSScriptErrorInfo *copy = [[HSScriptErrorInfo allocWithZone:aZone] initWithMessage:[self message]];
    [copy setLevel:[self level]];
    [copy setId:[self id]];
    [copy setRange:[self range]];
    [copy setBisonRange:[self bisonRange]];
    [copy setMessage:[self message]];
    [copy setShortMessage:[self shortMessage]];
    [copy setSourceCode:[self sourceCode]];
    return copy;
}

- (id)levelString
{
    NSString *key;
    switch (_level) {
    case 0:
        key = @"Info";
        break;
    case 1:
        key = @"Warning";
        break;
    case 2:
    case 3:
        key = @"Possible Runtime Error";
        break;
    case 4:
        key = @"Error";
        break;
    default:
        return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"Level<%d>" value:@"" table:@"ScriptStudio"], _level];
    }
    return [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:@"ScriptStudio"];
}

- (void)setLevel:(NSInteger)aLevel
{
    _level = (unsigned int)aLevel;
}

- (NSInteger)level
{
    return _level;
}

- (void)setId:(NSUInteger)aId
{
    _id = (unsigned int)aId;
}

- (NSUInteger)id
{
    return _id;
}

- (void)setBisonRange:(struct HSScriptBisonRange)aRange
{
    _bisonRange = aRange;
}

- (struct HSScriptBisonRange)bisonRange
{
    return _bisonRange;
}

- (void)setRange:(NSRange)aRange
{
    _range = aRange;
}

- (NSRange)range
{
    return _range;
}

- (void)setMessage:(id)aMessage
{
    if (_message != aMessage) {
        [_message release];
        _message = [aMessage copy];
    }
}

- (id)message
{
    return [[_message retain] autorelease];
}

- (void)setShortMessage:(id)aMessage
{
    if (_shortMessage != aMessage) {
        [_shortMessage release];
        _shortMessage = [aMessage copy];
    }
}

- (id)shortMessage
{
    return _shortMessage;
}

- (void)setSourceCode:(id)aCode
{
    if (_sourceCode != aCode) {
        [_sourceCode release];
        _sourceCode = [aCode copy];
    }
}

- (id)sourceCode
{
    return _sourceCode;
}

- (void)setLine:(NSUInteger)aLine
{
    _bisonRange.first_line = (int)aLine;
}

- (NSUInteger)line
{
    return _bisonRange.first_line + 1;
}

- (void)dealloc
{
    [_message release];
    [_sourceCode release];
    [_shortMessage release];
    [super dealloc];
}

- (id)initWithMessage:(id)aMessage andRange:(NSRange)aRange
{
    self = [self initWithMessage:aMessage];
    if (self != nil)
        [self setRange:aRange];
    return self;
}

- (id)initWithMessage:(id)aMessage
{
    self = [self init];
    if (self != nil)
        [self setMessage:aMessage];
    return self;
}

- (id)init
{
    // The original's defaults (_id = 0, _level = 4) sit behind an inverted
    // nil check and never run, so new infos start at level 0.
    return [super init];
}

@end

@implementation NSArray (HSScriptErrorInfosArray)

- (NSInteger)hyperMaxScriptErrorLevel
{
    NSUInteger maxLevel = 0;
    NSEnumerator *enumerator = [self objectEnumerator];
    id info;
    while ((info = [enumerator nextObject]) != nil) {
        if (maxLevel < (NSUInteger)[(HSScriptErrorInfo *)info level])
            maxLevel = [(HSScriptErrorInfo *)info level];
    }
    return maxLevel;
}

@end
