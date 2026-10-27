#import "HyperStudioPrefix.h"
#import "KeynoteStyle.h"


@interface KeynoteListstyle : KeynoteStyle
{
    NSDictionary *_topicsInfo;
}
- (id)detailedListLabelTypes;
- (void)applyTo:(id)aTo withStringAttributes:(id)aAttributes listLevel:(NSInteger)aLevel;
- (void)setTopicsInfo:(id)aInfo;
- (id)topicsInfo;
@end

