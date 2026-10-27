#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatDocumentValidation.h"


@interface HSOldFormatDocument (HSResourceRecreation)
- (void)processBy_blobBody_cursor_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_blobBody_icon_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_oneFont_ID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_blobBody_midi_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_blobBody_buttonItemSoundData_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_blobHeader_id_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
- (void)processBy_blobHeader_typeLong_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters;
@end

