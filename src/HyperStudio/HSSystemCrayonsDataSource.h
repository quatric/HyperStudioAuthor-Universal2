#import "HyperStudioPrefix.h"


@interface HSSystemCrayonsDataSource : NSObject
{
    NSArray *_systemColorPreset;
}
- (id)colorAtIndex:(NSInteger)aIndex;
- (id)systemColorPreset;
- (BOOL)managesRowsAndColumnsCountForCrayonsView:(id)aView;
- (id)crayonsView:(id)aView colorForRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (NSInteger)numberOfColumnsInCrayonsView:(id)aView;
- (NSInteger)numberOfRowsInCrayonsView:(id)aView;
- (void)dealloc;
@end

