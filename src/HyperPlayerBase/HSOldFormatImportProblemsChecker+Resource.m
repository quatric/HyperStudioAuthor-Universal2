#import "HSOldFormatImportProblemsChecker+Resource.h"
@implementation HSOldFormatImportProblemsChecker (Resource)
- (void)processBy_oneFont_ID_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id fontName = [aParser valuesBufferObjectForKey:@"oneFont.type.fontName"];
    [aParser setValuesBufferObject:fontName forKey:[NSString stringWithFormat:@"~fontByID_%d", [aValue unsignedIntValue]]];
}
- (void)processBy_blobBody_buttonItemSoundData_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    [aValue length];
    if ([aParser intEvaluate:@"buttonSoundHeader1.type.modInit"] & 0x700)
        [self addImportingProblemForCode:0x4e2b point:@"001" info:@"(wrong sound type - MACE3(6))"];
}
- (void)processBy_blobHeader_id_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    id offset;
    NSString *key;
    if ([[[self parser] valuesBufferObjectForKey:@"blobHeader.type.typeLong"] intValue] == 'Actn') {
        offset = [[self parser] valuesBufferObjectForKey:@"~ActionOffset"];
        key = [NSString stringWithFormat:@"~actionOffsetByID_%d", [aValue intValue]];
    } else if ([[[self parser] valuesBufferObjectForKey:@"blobHeader.type.typeLong"] intValue] == 'Hlnk') {
        offset = [[self parser] valuesBufferObjectForKey:@"~HyperlinkOffset"];
        key = [NSString stringWithFormat:@"~hyperlinkOffsetByID_%d", [aValue intValue]];
    } else
        return;
    [[self parser] setValuesBufferObject:offset forKey:key];
}
- (void)processBy_blobHeader_typeLong_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    if ([aValue intValue] == 'Actn') {
        [[self parser] setValuesBufferObject:[aParameters objectForKey:@"offsetParameter"] forKey:@"~ActionOffset"];
    } else if ([aValue intValue] == 'Hlnk') {
        int offset = [[aParameters objectForKey:@"offsetParameter"] intValue];
        if (offset < 1)
            return;
        [[self parser] setValuesBufferObject:@"YES" forKey:@"ButtonItems"];
        id hyperlinkType = [[[self parser] typesTree] objectForKey:@"Blob_BT_HYPERLINK"];
        [[self parser] valueForType:@"Blob_BT_HYPERLINK" atDefinedTree:hyperlinkType parent:nil atOffset:offset + 0x44];
    }
}
@end
