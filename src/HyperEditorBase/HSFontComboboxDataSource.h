#import "HyperEditorBasePrefix.h"


@interface HSFontComboboxDataSource : NSObject <NSComboBoxDataSource, NSObject>
{
    NSMutableDictionary *_fonts;
    NSArray *_sortedFontNames;
    NSMapTable *_fontSamplesTable;
}
+ (id)sharedDrawingLayoutManager;
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedFontDataSource;
- (id)fontNameKeyForItem:(id)aItem;
- (id)keyValueForItemAtIndex:(NSInteger)aIndex;
- (id)comboBox:(id)aBox completedString:(id)aString;
- (NSUInteger)comboBox:(id)aBox indexOfItemWithStringValue:(id)aValue;
- (id)comboBox:(id)aBox objectValueForItemAtIndex:(NSInteger)aIndex;
- (NSInteger)numberOfItemsInComboBox:(id)aBox;
- (void)prerareImageForFontName:(id)aName;
- (id)fontSamplesTable;
- (id)fonts;
- (id)sortedFontNames;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

