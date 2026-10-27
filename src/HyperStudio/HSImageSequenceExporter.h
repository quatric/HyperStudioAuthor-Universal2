#import "HyperStudioPrefix.h"
#import "HSExporter2.h"


@interface HSImageSequenceExporter : HSExporter2
{
    unsigned int _isExportOnlySelectedCards:1;
}
- (BOOL)isActiveStoryboardMode;
- (void)performExportDocument:(id)aDocument ofType:(id)aType;
- (id)progressSheetDescription;
- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType;
- (void)setExportOnlySelectedCards:(BOOL)aCards;
- (BOOL)isExportOnlySelectedCards;
- (BOOL)isExportOnlyOneCard;
- (NSUInteger)countExportedCards;
- (void)setDataSource:(id)aSource;
@end

