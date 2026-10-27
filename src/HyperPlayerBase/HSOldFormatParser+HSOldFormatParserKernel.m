#import "HSOldFormatParser+HSOldFormatParserKernel.h"

// The parsing engine. A type is a dictionary from the types tree (or the
// values buffer), or a name parsed by parseType_<name>:atDefinedTree:parent:
// atOffset:; names without a method are forwarded to the types tree. Complex
// types (a "type" array) parse their parts in turn, each at its own offset or
// after the previous part.
@implementation HSOldFormatParser (HSOldFormatParserKernel)

// Every parseType_ selector has the signature of parseType_dummy; any other
// selector has none, so it is not recognized.
- (id)methodSignatureForSelector:(SEL)aSelector
{
    if ([NSStringFromSelector(aSelector) rangeOfString:@"parseType_"].location == NSNotFound)
        return nil;
    return [super methodSignatureForSelector:@selector(parseType_dummy:atDefinedTree:parent:atOffset:)];
}

// parseType_<name>: for a name in the types tree reads the type from the tree.
- (void)forwardInvocation:(id)aInvocation
{
    NSString *selector = NSStringFromSelector([aInvocation selector]);
    NSUInteger colon = [selector rangeOfString:@":"].location;
    NSString *name = [selector substringWithRange:NSMakeRange(10, colon - 10)];
    if ([[self typesTreeAllKeys] containsObject:name]) {
        [aInvocation setSelector:@selector(parseType_ReadFromDictionary__:atDefinedTree:parent:atOffset:)];
        [aInvocation invoke];
    } else {
        [self doesNotRecognizeSelector:[aInvocation selector]];
    }
}

// "<type>.size" for every type with a fixed size.
- (void)createSizeKeys
{
    NSArray *keys = [[self typesTree] allKeys];
    NSInteger count = [keys count];
    for (NSInteger i = 0; i < count; i++) {
        NSString *key = [keys objectAtIndex:i];
        NSDictionary *type = [[self typesTree] objectForKey:key];
        if ([[type allKeys] containsObject:@"size"])
            [self setValuesBufferObject:[type objectForKey:@"size"] forKey:[key stringByAppendingString:@".size"]];
    }
}

// A number, or a values buffer key naming one; -1 otherwise.
- (NSInteger)longEvaluate:(id)aEvaluate
{
    if (aEvaluate) {
        if ([aEvaluate isKindOfClass:[NSString class]])
            aEvaluate = [self valuesBufferObjectForKey:aEvaluate];
        if ([aEvaluate isKindOfClass:[NSNumber class]])
            return (int)[aEvaluate longValue];
    }
    return -1;
}

- (NSInteger)intEvaluate:(id)aEvaluate
{
    if (aEvaluate) {
        if ([aEvaluate isKindOfClass:[NSString class]])
            aEvaluate = [self valuesBufferObjectForKey:aEvaluate];
        if ([aEvaluate isKindOfClass:[NSNumber class]])
            return [aEvaluate intValue];
    }
    return -1;
}

- (id)setType:(id)aType name:(id)aName size:(id)aSize offset:(id)aOffset count:(id)aCount value:(id)aValue forBase:(id)aBase
{
    if (!aBase)
        aBase = [NSMutableArray array];
    NSMutableDictionary *part = [NSMutableDictionary dictionary];
    if (aType)
        [part setObject:aType forKey:@"type"];
    if (aName)
        [part setObject:aName forKey:@"name"];
    if (aSize)
        [part setObject:aSize forKey:@"size"];
    if (aCount)
        [part setObject:aCount forKey:@"count"];
    if (aOffset)
        [part setObject:aOffset forKey:@"offset"];
    if (aValue)
        [part setObject:aValue forKey:@"value"];
    [aBase addObject:part];
    return aBase;
}

- (void)setAtValueTree:(id)aTree withParent:(id)aParent withName:(id)aName
{
    NSMutableDictionary *values = [NSMutableDictionary dictionaryWithDictionary:[[self typesTree] objectForKey:@"__values"]];
    if (!values)
        values = [NSMutableDictionary dictionary];
    [values setObject:aTree forKey:[aParent stringByAppendingFormat:@".type.%@", aName]];
    [[self typesTree] setObject:values forKey:@"__values"];
}

// Data is buffered only when asked for. When older values are kept, the value
// already under the key moves to "<key>@1", which moves on to "@2", and so on.
- (void)setValuesBufferObject:(id)aObject forKey:(id)aKey
{
    if (![self isDataSavedToValuesBuffer] && [aObject isKindOfClass:[NSData class]])
        return;
    if ([self isSaveOldToValuesBuffer] && [[[self valuesBuffer] allKeys] containsObject:aKey]) {
        id old = [self valuesBufferObjectForKey:aKey];
        NSUInteger at = [aKey rangeOfString:@"@"].location;
        NSString *oldKey;
        if (at == NSNotFound)
            oldKey = [aKey stringByAppendingString:@"@1"];
        else
            oldKey = [[aKey substringToIndex:at] stringByAppendingFormat:@"@%d", [[aKey substringFromIndex:at + 1] intValue] + 1];
        [self setValuesBufferObject:old forKey:oldKey];
    }
    if ([self delegate] && [_delegate respondsToSelector:@selector(oldFormatParser:didWriteInBufferValue:forKey:)])
        [_delegate oldFormatParser:self didWriteInBufferValue:aObject forKey:aKey];
    [[self valuesBuffer] setValue:aObject forKey:aKey];
}

- (id)valuesBufferObjectForKey:(id)aKey
{
    return [[self valuesBuffer] objectForKey:aKey];
}

// Records what is wrong (no type, no tree, offset or size past the data) and
// returns whether the parser has a kernel error, from this or an earlier
// check.
- (BOOL)parametersValidationForType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    if (!aType) {
        [_kernelErrors setObject:@"type parameter is nil." forKey:@"type_error"];
        [self setKernelError:YES];
    }
    if (!aTree) {
        [_kernelErrors setObject:@"definedTree parameter is nil." forKey:@"definedTree_error"];
        [self setKernelError:YES];
    }
    if ([self dataLength] - 1 < aOffset) {
        [_kernelErrors setObject:@"offset parameter greatest then data length." forKey:@"offset_error"];
        [self setKernelError:YES];
    }
    id size = [aType isKindOfClass:[NSDictionary class]] ? [aType objectForKey:@"size"] : nil;
    if ([self dataLength] - 1 < [self intEvaluate:size]) {
        [_kernelErrors setObject:@"type size greatest then data length." forKey:@"type_size_error"];
        [self setKernelError:YES];
    }
    return [self hasKernelError];
}

- (id)kernelErrorForType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    if (aType)
        [_kernelErrors setObject:aType forKey:@"type parameter"];
    if (aTree)
        [_kernelErrors setObject:aTree forKey:@"definedTree parameter"];
    if (aParent)
        [_kernelErrors setObject:aParent forKey:@"parent parameter"];
    [_kernelErrors setObject:[NSNumber numberWithInt:(int)aOffset] forKey:@"offset parameter"];
    [_kernelErrors setObject:[NSNumber numberWithInt:(int)[self dataLength]] forKey:@"data length"];
    NSMutableDictionary *error = [NSMutableDictionary new];
    [error setObject:@"kernelError" forKey:@"name"];
    [error setObject:@"kernelError" forKey:@"type"];
    [error setObject:_kernelErrors forKey:@"value"];
    [error setObject:[NSNumber numberWithLong:0] forKey:@"size"];
    return [error autorelease];
}

- (id)parseType_ReadFromDictionary__:(id)aDictionary atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    id type = [[self typesTree] objectForKey:aDictionary];
    if (!type)
        type = [self valuesBufferObjectForKey:aDictionary];
    return type;
}

- (id)parseType_subType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    return aTree;
}

- (id)parseType_dummy:(id)aDummy atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    return nil;
}

// A parsed value that is not an array or dictionary is buffered under
// "<parent name>.type.<name>" and reported to the delegate.
- (id)valueSimpleForValue:(id)aValue forComplexType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSString *name = [aTree objectForKey:@"name"];
    NSString *parentName = [aParent objectForKey:@"name"];
    id value = [aValue objectForKey:@"value"];
    if (!name)
        name = @"";
    if (!parentName)
        parentName = @"";
    if (![value isKindOfClass:[NSArray class]] && ![value isKindOfClass:[NSDictionary class]]) {
        NSString *key = [parentName stringByAppendingFormat:@".type.%@", name];
        [self setValuesBufferObject:value forKey:key];
        if ([self delegate] && [_delegate respondsToSelector:@selector(oldFormatParser:didDeriveSimpleValue:forName:parentName:parameters:)]) {
            NSNumber *offset = [NSNumber numberWithInt:(int)aOffset];
            NSDictionary *parameters;
            if (_isCollectParserValues)
                parameters = [NSDictionary dictionaryWithObjectsAndKeys:aValue, @"valueParameter", aType, @"complexTypeParameter", aTree, @"definedTreeParameter", aParent, @"parentParameter", offset, @"offsetParameter", nil];
            else
                parameters = [NSDictionary dictionaryWithObjectsAndKeys:aType, @"complexTypeParameter", aTree, @"definedTreeParameter", aParent, @"parentParameter", offset, @"offsetParameter", nil];
            [_delegate oldFormatParser:self didDeriveSimpleValue:value forName:name parentName:parentName parameters:parameters];
        }
    }
    return aValue;
}

// Parts without a size take the size their value reports. The values are kept
// only when collecting; the size is the full size when given.
- (id)valueForComplexType:(id)aType atDefinedTree:(id)aTree type:(id)aType2 atOffset:(NSInteger)aOffset fullSize:(id)aSize
{
    NSMutableArray *values = [NSMutableArray new];
    NSInteger count = [aType count], next = aOffset;
    for (NSInteger i = 0; i < count && !_hasKernelError && !_hasKernelBreak; i++) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSDictionary *part = [aType objectAtIndex:i];
        id partType = [part objectForKey:@"type"];
        BOOL isArray = [partType isKindOfClass:[NSArray class]];
        NSInteger partOffset = [self intEvaluate:[part objectForKey:@"offset"]];
        NSInteger partSize = [self intEvaluate:[part objectForKey:@"size"]];
        if (isArray)
            partType = @"subType";
        NSInteger at = partOffset >= 0 ? partOffset + aOffset : next;
        id value = [self valueForType:partType atDefinedTree:part parent:aTree atOffset:at];
        if (partSize < 0)
            partSize = [self intEvaluate:[value objectForKey:@"size"]];
        if (_isCollectParserValues)
            [values addObject:value];
        next = partSize + at;
        [pool release];
    }
    NSInteger fullSize = [self intEvaluate:aSize];
    NSNumber *size = [NSNumber numberWithLong:fullSize > 0 ? fullSize : next - aOffset];
    return [NSDictionary dictionaryWithObjectsAndKeys:[values autorelease], @"value", aType2, @"type", size, @"size", nil];
}

// Parts with a count of 2 or more are repeated that many times (without
// their offset).
- (id)workTreeFrom:(id)aFrom
{
    NSMutableDictionary *tree = [aFrom mutableCopy];
    id types = [tree objectForKey:@"type"];
    if ([types isKindOfClass:[NSArray class]]) {
        NSMutableArray *parts = [NSMutableArray array];
        NSInteger count = [types count];
        for (NSInteger i = 0; i < count && !_hasKernelError && !_hasKernelBreak; i++) {
            NSMutableDictionary *part = [NSMutableDictionary dictionaryWithDictionary:[types objectAtIndex:i]];
            NSInteger repeat = [self intEvaluate:[part objectForKey:@"count"]];
            if (repeat < 2) {
                [part removeObjectForKey:@"count"];
                [parts addObject:part];
            } else {
                [part removeObjectForKey:@"offset"];
                [part removeObjectForKey:@"count"];
                id name = [part objectForKey:@"name"];
                for (NSInteger j = 1; j <= repeat; j++) {
                    [part setObject:name forKey:@"name"];
                    [parts addObject:[[part copy] autorelease]];
                }
            }
        }
        [tree setObject:parts forKey:@"type"];
    }
    return [tree autorelease];
}

// Calls parseType_<name> (spaces in the name become underscores).
- (id)invokeCustomParserForType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    id type = aType, tree = aTree, parent = aParent, result = nil;
    NSInteger offset = aOffset;
    if ([self parametersValidationForType:aType atDefinedTree:aTree parent:aParent atOffset:aOffset])
        return [self kernelErrorForType:aType atDefinedTree:aTree parent:aParent atOffset:aOffset];
    NSMutableString *name = [NSMutableString stringWithString:aType];
    [name replaceOccurrencesOfString:@" " withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [name length])];
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"parseType_%@:atDefinedTree:parent:atOffset:", name]);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    [invocation setArgument:&type atIndex:2];
    [invocation setArgument:&tree atIndex:3];
    [invocation setArgument:&parent atIndex:4];
    [invocation setArgument:&offset atIndex:5];
    [invocation invoke];
    [invocation getReturnValue:&result];
    return result;
}

// Parses the parsing type from the start of the data.
- (id)parsedValue
{
    [self setKernelError:NO];
    [self setSaveOldToValuesBuffer:NO];
    [self createSizeKeys];
    if ([self delegate] && [_delegate respondsToSelector:@selector(oldFormatParser:didStartParsingWithTypesTree:parsingType:)])
        [_delegate oldFormatParser:self didStartParsingWithTypesTree:[self typesTree] parsingType:[self parsingType]];
    NSDictionary *tree = [[self typesTree] objectForKey:[self parsingType]];
    id value = [[self valueForType:[self parsingType] atDefinedTree:tree parent:nil atOffset:0] retain];
    if ([self delegate] && [_delegate respondsToSelector:@selector(oldFormatParser:didFinishParsingWithTypesTree:parsingType:)])
        [_delegate oldFormatParser:self didFinishParsingWithTypesTree:[self typesTree] parsingType:[self parsingType]];
    return [value autorelease];
}

// A type name goes through its parser over the work tree; the dictionary it
// gives is a complex type (parts), a simple value, or another type to parse
// with that dictionary as the tree. A break gives the none value; an error
// the kernel error.
- (id)valueForTypeInternal:(id)aInternal atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self parametersValidationForType:aInternal atDefinedTree:aTree parent:aParent atOffset:aOffset];
    if ([self delegate] && [_delegate respondsToSelector:@selector(oldFormatParser:willParseWithParameters:)])
        [_delegate oldFormatParser:self willParseWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:aInternal, @"typeParameter", aTree, @"definedTreeParameter", aParent, @"parentParameter", [NSNumber numberWithInt:(int)aOffset], @"offsetParameter", nil]];
    id result = nil;
    if (!_hasKernelError && !_hasKernelBreak) {
        result = aInternal;
        if ([aInternal isKindOfClass:[NSString class]]) {
            id tree = [[self workTreeFrom:aTree] retain];
            result = [self invokeCustomParserForType:aInternal atDefinedTree:tree parent:aParent atOffset:aOffset];
            [tree release];
        }
        if ([result isKindOfClass:[NSDictionary class]]) {
            id type = [result objectForKey:@"type"];
            [self parametersValidationForType:result atDefinedTree:aTree parent:aParent atOffset:aOffset];
            if (!_hasKernelError && !_hasKernelBreak) {
                id size = [result objectForKey:@"size"];
                if ([type isKindOfClass:[NSArray class]]) {
                    id name = [result objectForKey:@"name"];
                    if (name)
                        [self setValuesBufferObject:[NSNumber numberWithInt:(int)aOffset] forKey:[name stringByAppendingString:@".offset"]];
                    result = [self valueForComplexType:type atDefinedTree:aTree type:aInternal atOffset:aOffset fullSize:size];
                } else if ([type isKindOfClass:[NSString class]]) {
                    if (![result objectForKey:@"value"])
                        result = [self valueForType:type atDefinedTree:result parent:aTree atOffset:aOffset];
                    else
                        result = [self valueSimpleForValue:result forComplexType:type atDefinedTree:aTree parent:aParent atOffset:aOffset];
                }
            }
        }
    }
    if ([self hasKernelBreak])
        result = [self parseType_none:@"none" atDefinedTree:aTree parent:aParent atOffset:aOffset];
    if ([self hasKernelError])
        result = [self kernelErrorForType:aInternal atDefinedTree:aTree parent:aParent atOffset:aOffset];
    if ([self delegate] && [_delegate respondsToSelector:@selector(oldFormatParser:didDeriveValue:parameters:)])
        [_delegate oldFormatParser:self didDeriveValue:result parameters:[NSDictionary dictionaryWithObjectsAndKeys:aInternal, @"typeParameter", aTree, @"definedTreeParameter", aParent, @"parentParameter", [NSNumber numberWithInt:(int)aOffset], @"offsetParameter", nil]];
    [result retain];
    [pool release];
    return [result autorelease];
}

// At the end of the data every type is none.
- (id)valueForType:(id)aType atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    if ([self dataLength] == aOffset)
        return [self parametersDictionaryWithValue:@"none" name:@"none" type:aType size:nil];
    return [self valueForTypeInternal:aType atDefinedTree:aTree parent:aParent atOffset:aOffset];
}

@end
