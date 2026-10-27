#import "HyperPlayerBasePrefix.h"
#import "HSDocument.h"
#import "HSZipDirectoryWrapper.h"


@interface HSDocumentStoring : HSDocument
{
    HSZipDirectoryWrapper *_contentsWrapper;
    HSZipDirectoryWrapper *_projectAttributesWrapper;
    NSFileWrapper *_stackWrapper;
    NSString *_preferredFilename;
    NSMutableDictionary *_filenamesMapping;
    unsigned int _currentSaveOperationType;
    BOOL _isAutosavingDisabled;
    BOOL _isWritingDisabled;
    BOOL _shouldStorePreviewImages;
    BOOL _wasImportedAndNotAutosaved;
}
- (id)previewImageToStoreForCard:(id)aCard;
- (id)thumbnailImageToStoreForCard:(id)aCard;
- (id)filenamesMapping;
- (void)addFilenameMaping:(id)aMaping newFileName:(id)aName;
- (void)zipWrapper:(id)aWrapper didChangeFileNameFrom:(id)aFrom toName:(id)aName;
- (NSUInteger)compressLevelForFileWrapper:(id)aWrapper zipWrapper:(id)aWrapper2;
- (void)close;
- (BOOL)loadProjectAttributesWrapper:(id)aWrapper error:(id *)aError;
- (BOOL)loadContentsWrapper:(id)aWrapper error:(id *)aError;
- (BOOL)readFromData:(id)aData ofType:(id)aType error:(id *)aError;
- (BOOL)readFromFileWrapper:(id)aWrapper ofType:(id)aType error:(id *)aError;
- (id)fileWrapperOfType:(id)aType error:(id *)aError;
- (id)dataOfType:(id)aType error:(id *)aError;
- (id)hyperFileWrapperOfType:(id)aType error:(id *)aError;
- (BOOL)readFromURL:(id)aURL ofType:(id)aType error:(id *)aError;
- (BOOL)writeToURL:(id)aURL ofType:(id)aType error:(id *)aError;
- (void)saveToURL:(id)aURL ofType:(id)aType forSaveOperation:(NSUInteger)aOperation delegate:(id)aDelegate didSaveSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (BOOL)saveToURL:(id)aURL ofType:(id)aType forSaveOperation:(NSUInteger)aOperation error:(id *)aError;
- (NSUInteger)currentSaveOperationType;
- (BOOL)isWritingDisabled;
- (id)writableTypesForSaveOperation:(NSUInteger)aOperation;
- (BOOL)writeSafelyToURL:(id)aURL ofType:(id)aType forSaveOperation:(NSUInteger)aOperation error:(id *)aError;
- (BOOL)hyperExportWithBackupToFile:(id)aFile ofType:(id)aType error:(id *)aError;
- (id)autosavingFileType;
- (void)checkAndSetAutosavedContentsFilePath;
- (BOOL)hyperReadFromWorkcopy:(id)aWorkcopy ofType:(id)aType error:(id *)aError;
- (BOOL)hyperWriteToWorkcopy:(id)aWorkcopy ofType:(id)aType error:(id *)aError;
- (void)setPreferredFilename:(id)aFilename;
- (id)preferredFilename;
- (void)setProjectAttributesWrapper:(id)aWrapper;
- (void)setContentsWrapper:(id)aWrapper;
- (void)clearCaches;
- (void)setShouldStoreCardPreviewImages:(BOOL)aImages;
- (BOOL)shouldStoreCardPreviewImages;
- (id)cardPreviewImagesWrapper;
- (id)stackWrapper;
- (void)setResourcesWrapper:(id)aWrapper;
- (id)resourcesWrapper;
- (id)projectAttributesWrapper;
- (id)versionPlistWrapper;
- (id)contentsWithoutResourcesWrapper;
- (id)contentsWrapper;
- (void)dealloc;
- (id)init;
- (BOOL)hasUnautosavedChanges;
- (BOOL)isDocumentEdited;
- (void)invalidateCardsPreview;
@end

@interface HSCardPreviewsFileWrapper : HSZipDirectoryWrapper
{
    HSDocumentStoring *_documentStoring;
}
- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames;
- (id)fileWrappers;
- (void)dealloc;
- (id)initWithDocumentStoring:(id)aStoring;
@end

@interface NSFileWrapper (HSDocumentStoring)
- (BOOL)hyperWriteToURL:(id)aURL atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames error:(id *)aError;
@end

