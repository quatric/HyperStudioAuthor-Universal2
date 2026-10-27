#import "HyperStudioPrefix.h"


@interface HSMovie (SoundConversionForIPadExport)
- (id)convertedSoundtrackPath;
- (id)convertedForIPadExportSoundPath;
- (id)convertSound:(struct MovieType **)aSound isMIDI:(BOOL)aMIDI;
- (BOOL)isIPadExportableFileType;
- (id)iPadExportableFileTypes;
@end

