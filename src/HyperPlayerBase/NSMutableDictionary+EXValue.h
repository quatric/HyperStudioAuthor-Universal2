#import "HyperPlayerBasePrefix.h"


@interface NSMutableDictionary (EXValue)
- (id)setExtraFloat:(CGFloat)aFloat forKey:(id)aKey;
- (id)setExtraDouble:(double)aDouble forKey:(id)aKey;
- (id)setExtraBool:(BOOL)aBool forKey:(id)aKey;
- (id)setExtraInt:(NSInteger)aInt forKey:(id)aKey;
- (id)setExtraLongLong:(long long)aLong forKey:(id)aKey;
- (id)setExtraRange:(NSRange)aRange forKey:(id)aKey;
- (id)setExtraRect:(NSRect)aRect forKey:(id)aKey;
- (id)setExtraSize:(NSSize)aSize forKey:(id)aKey;
- (id)setExtraPoint:(NSPoint)aPoint forKey:(id)aKey;
@end

@interface NSDictionary (EXValue)
+ (id)extraDictionaryWithRect:(NSRect)aRect;
+ (id)extraDictionaryWithSize:(NSSize)aSize;
+ (id)extraDictionaryWithPoint:(NSPoint)aPoint;
@end

@interface NSArray (EXValue)
- (NSRange)extraRangeValue;
- (NSRect)extraRectValue;
- (NSSize)extraSizeValue;
- (NSPoint)extraPointValue;
@end

@interface NSObject (EXValue)
- (CGFloat)extraFloatForKey:(id)aKey;
- (double)extraDoubleForKey:(id)aKey;
- (BOOL)extraBoolForKey:(id)aKey;
- (NSInteger)extraIntForKey:(id)aKey;
- (long long)extraLongLongForKey:(id)aKey;
- (NSRange)extraRangeForKey:(id)aKey;
- (NSRect)extraRectForKey:(id)aKey;
- (NSSize)extraSizeForKey:(id)aKey;
- (NSPoint)extraPointForKey:(id)aKey;
- (NSRange)extraRangeValue;
- (NSRect)extraRectValue;
- (NSSize)extraSizeValue;
- (NSPoint)extraPointValue;
@end

@interface NSValue (EXValue)
- (NSRange)extraRangeValue;
- (NSRect)extraRectValue;
- (NSSize)extraSizeValue;
- (NSPoint)extraPointValue;
@end

@interface NSObject (HSValueProtected)
- (id)safeExtraValueForKey:(id)aKey;
@end

