#import "HSDocumentStoring.h"
#import "HSApplicationController.h"
#import "HSDataArchiver.h"
#import "HSError.h"
#import "HSErrorManager.h"
#import "HSMediaSaver.h"
#import "HSMediaValidator.h"
#import "HSPathsProvider.h"
#import "HSStack.h"
#import "HSZipArchiver.h"
#import "HSZipWrapper.h"
#import "NSFileManager+HSExtensions.h"
#import "NSFileWrapper+HSExtensions.h"

// The document layer that stores a stack as a zipped package: Contents
// (stack, resources and Quick Look previews), Contents.plist (project
// attributes) and Version.plist.
@implementation HSDocumentStoring

- (id)previewImageToStoreForCard:(id)aCard
{
    return [self previewImageForCard:aCard];
}

- (id)thumbnailImageToStoreForCard:(id)aCard
{
    return [self thumbnailImageForCard:aCard];
}

- (id)filenamesMapping
{
    return [NSDictionary dictionaryWithDictionary:_filenamesMapping];
}

- (void)addFilenameMaping:(id)aMaping newFileName:(id)aName
{
    if (_filenamesMapping == nil)
        _filenamesMapping = [NSMutableDictionary new];
    [_filenamesMapping setObject:aName forKey:aMaping];
}

- (void)zipWrapper:(id)aWrapper didChangeFileNameFrom:(id)aFrom toName:(id)aName
{
    [self addFilenameMaping:aFrom newFileName:aName];
}

// The model files compress well; media is stored as is.
- (NSUInteger)compressLevelForFileWrapper:(id)aWrapper zipWrapper:(id)aWrapper2
{
    static NSArray *compressedExtensions = nil;
    if (compressedExtensions == nil)
        compressedExtensions = [[NSArray arrayWithObjects:@"plist", @"hsobject", @"hsstack", @"hscard", nil] retain];
    NSString *extension = [[aWrapper filename] pathExtension];
    if (extension == nil)
        extension = [[aWrapper preferredFilename] pathExtension];
    return [compressedExtensions containsObject:extension] ? 1 : 0;
}

- (void)close
{
    [super close];
}

- (BOOL)loadProjectAttributesWrapper:(id)aWrapper error:(id *)aError
{
    BOOL result = [super loadProjectAttributesWrapper:aWrapper error:aError];
    if (result)
        [self setProjectAttributesWrapper:aWrapper];
    return result;
}

- (BOOL)loadContentsWrapper:(id)aWrapper error:(id *)aError
{
    BOOL result = [super loadContentsWrapper:aWrapper error:aError];
    if (result)
        [self setContentsWrapper:aWrapper];
    return result;
}

// Data is either a zip archive or an old compressed serialized file wrapper.
// It is unpacked to a temporary folder that becomes the file name source.
- (BOOL)readFromData:(id)aData ofType:(id)aType error:(id *)aError
{
    NSFileWrapper *wrapper = [HSZipArchiver fileWrapperForDataZip:aData];
    if (wrapper == nil) {
        HSDataArchiver *archiver = [HSDataArchiver new];
        NSData *data = [archiver uncompressData:aData];
        [archiver release];
        wrapper = [[[NSFileWrapper alloc] initWithSerializedRepresentation:data] autorelease];
    }
    NSString *path = [[[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[NSString hyperUIDString]] stringByAppendingFormat:@"-%@-%@", @"Stack", @"stack"];
    [wrapper writeToFile:path atomically:NO updateFilenames:YES];
    [self setFileNameSource:path];
    return [self hyperReadFromFileWrapper:wrapper ofType:aType error:aError];
}

- (BOOL)readFromFileWrapper:(id)aWrapper ofType:(id)aType error:(id *)aError
{
    if ([aWrapper isDirectory])
        return [self hyperReadFromFileWrapper:aWrapper ofType:aType error:aError];
    return [super readFromFileWrapper:aWrapper ofType:aType error:aError];
}

- (id)fileWrapperOfType:(id)aType error:(id *)aError
{
    if ([aType isEqualToString:@"HSDocumentType"] || [aType isEqualToString:@"HSWebDocumentType"]) {
        NSFileWrapper *directory = [self hyperFileWrapperOfType:aType error:aError];
        HSZipWrapper *zipWrapper = [[HSZipWrapper alloc] initDirectoryWithFileWrappers:[directory fileWrappers]];
        if (zipWrapper != nil) {
            [zipWrapper setDelegate:self];
            return [zipWrapper autorelease];
        }
    }
    return [super fileWrapperOfType:aType error:aError];
}

- (id)dataOfType:(id)aType error:(id *)aError
{
    _isWritingDisabled = YES;
    NSData *data = [HSZipArchiver dataZipForFileWrapper:[self hyperFileWrapperOfType:aType error:aError]];
    if (data == nil && aError != NULL && *aError == nil)
        *aError = [HSError errorWithHSCode:0x280];
    _isWritingDisabled = NO;
    return data;
}

- (id)hyperFileWrapperOfType:(id)aType error:(id *)aError
{
    NSMutableDictionary *wrappers = [NSMutableDictionary dictionary];
    if ([aType isEqualToString:@"HSDocumentType"] || [aType isEqualToString:@"HSWebDocumentType"])
        [wrappers setObject:[self contentsWrapper] forKey:@"Contents"];
    else if ([aType isEqualToString:@"HSDocumentWithoutResourcesType"])
        [wrappers setObject:[self contentsWithoutResourcesWrapper] forKey:@"Contents"];
    [wrappers setObject:[self projectAttributesWrapper] forKey:@"Contents.plist"];
    [wrappers setObject:[self versionPlistWrapper] forKey:@"Version.plist"];
    HSZipDirectoryWrapper *wrapper = [[[HSZipDirectoryWrapper alloc] initDirectoryWithFileWrappers:wrappers] autorelease];
    [wrapper setFilename:[[[[self fileURL] path] stringByDeletingPathExtension] stringByAppendingPathExtension:@"stack"]];
    return wrapper;
}

- (BOOL)readFromURL:(id)aURL ofType:(id)aType error:(id *)aError
{
    BOOL result = NO;
    if ([aURL isFileURL]) {
        NSString *path = [aURL path];
        if ([[NSFileManager defaultManager] hyperIsFileAbleToReadFromPath:path document:self error:aError]
            && [[NSFileManager defaultManager] hyperIsReadableFileAtPath:path showAlert:YES error:nil]) {
            if ([aType isEqualToString:@"HSNativeDocumentType"])
                result = [super readFromURL:aURL ofType:aType error:aError];
            else
                result = [self hyperReadFromWorkcopy:path ofType:aType error:aError];
        }
    }
    [self clearCaches];
    return result;
}

// A failed write removes the partially written file.
- (BOOL)writeToURL:(id)aURL ofType:(id)aType error:(id *)aError
{
    BOOL result = NO;
    if ([aURL isFileURL]) {
        NSFileWrapper *wrapper = [self fileWrapperOfType:aType error:aError];
        if (wrapper != nil) {
            result = [wrapper hyperWriteToURL:aURL atomically:NO updateFilenames:YES error:aError];
            if (!result) {
                NSString *path = [aURL path];
                if (path != nil)
                    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            }
        }
    }
    [self clearCaches];
    return result;
}

- (void)saveToURL:(id)aURL ofType:(id)aType forSaveOperation:(NSUInteger)aOperation delegate:(id)aDelegate didSaveSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    _currentSaveOperationType = (unsigned int)aOperation;
    [super saveToURL:aURL ofType:aType forSaveOperation:aOperation delegate:aDelegate didSaveSelector:aSelector contextInfo:aInfo];
    _currentSaveOperationType = 0xffffffff;
}

// A save the user cancelled counts as a success.
- (NSUInteger)currentSaveOperationType
{
    return _currentSaveOperationType;
}

- (BOOL)isWritingDisabled
{
    return _isWritingDisabled;
}

// Autosaving writes native stacks; export offers the types the editor
// document types list as exportable.
- (id)writableTypesForSaveOperation:(NSUInteger)aOperation
{
    NSEnumerator *documentTypes = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDocumentTypes"] objectEnumerator];
    NSMutableArray *types = [NSMutableArray array];
    if (aOperation == NSAutosaveOperation) {
        [types addObject:@"HSDocumentType"];
    } else if (aOperation == NSSaveToOperation) {
        NSDictionary *documentType;
        while ((documentType = [documentTypes nextObject]) != nil) {
            if ([[documentType objectForKey:@"CFBundleTypeRole"] isEqual:@"Editor"])
                [types addObjectsFromArray:[documentType objectForKey:@"NSExportableAs"]];
        }
    } else {
        types = [NSMutableArray arrayWithArray:[super writableTypesForSaveOperation:aOperation]];
    }
    return types;
}

// Validates and saves the document media into the resources wrapper before
// the actual write, and maps write failures to HyperStudio errors. A failed
// autosave offers to turn autosaving off.
- (BOOL)writeSafelyToURL:(id)aURL ofType:(id)aType forSaveOperation:(NSUInteger)aOperation error:(id *)aError
{
    NSString *path;
    NSString *filename;
    if (![aURL isFileURL] || (path = [aURL path]) == nil || (filename = [path lastPathComponent]) == nil)
        return NO;

    BOOL result = NO;
    [self setPreferredFilename:filename];
    [self setResourcesWrapper:nil];
    if (aOperation != NSAutosaveOperation)
        [[HSMediaValidator mediaValidatorForDocument:self] validateMediaWithError:aError];
    if (aError == NULL || *aError == nil) {
        NSFileWrapper *resources = [self resourcesWrapper];
        if (resources == nil)
            return NO;
        if ([HSMediaSaver saveMediaForDocument:self resourcesWrapper:resources]) {
            [self reloadDocumentMedia];
            if (aOperation != NSAutosaveOperation) {
                id controller = [HSApplicationController sharedDocumentController];
                if ([controller respondsToSelector:@selector(isStackToGoController)] && [controller isStackToGoController])
                    path = [[NSBundle mainBundle] bundlePath];
                NSString *folder = [path stringByDeletingLastPathComponent];
                if (folder == nil)
                    return NO;
                [[HSPathsProvider sharedPathsProvider] setHyperStudioDocumentsFolder:folder];
            }
            NSUndoManager *undoManager = [self undoManager];
            _isAutosavingDisabled = NO;
            [undoManager disableUndoRegistration];
            result = [super writeSafelyToURL:aURL ofType:aType forSaveOperation:aOperation error:aError];
            [undoManager enableUndoRegistration];
            if (result) {
                [self clearCaches];
                return YES;
            }
        }
    }

    if (aOperation == NSAutosaveOperation) {
        if (_isAutosavingDisabled) {
            result = YES;
        } else if (aError != NULL && *aError != nil && ([(NSError *)*aError code] == 0x280 || [(NSError *)*aError code] == 0x4e36)) {
            NSArray *options = [NSArray arrayWithObjects:@"Turn Backup Off", @"Cancel", nil];
            if (options != nil) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:options forKey:NSLocalizedRecoveryOptionsErrorKey];
                NSError *error = [HSError errorWithDomain:HSSpecificErrorDomain code:0x4e37 userInfo:userInfo];
                HSErrorManager *errorManager;
                if (error != nil && (errorManager = [HSErrorManager sharedErrorManager]) != nil) {
                    [errorManager presentError:error];
                    if ([errorManager lastResult] == NSAlertFirstButtonReturn)
                        _isAutosavingDisabled = YES;
                    result = YES;
                }
            }
        }
    } else if (aError != NULL && *aError != nil) {
        NSInteger code = [(NSError *)*aError code];
        NSInteger hsCode = 0;
        if (code == 0x280)
            hsCode = 0x502f;
        else if (code == 0x201)
            hsCode = 0x502e;
        else if (code == 0x200)
            hsCode = 0x5030;
        if (hsCode != 0)
            *aError = [HSError fileErrorWithHSCode:hsCode filePath:[self displayName]];
    }
    [self clearCaches];
    return result;
}

- (BOOL)hyperExportWithBackupToFile:(id)aFile ofType:(id)aType error:(id *)aError
{
    return NO;
}

- (id)autosavingFileType
{
    [self checkAndSetAutosavedContentsFilePath];
    return @"HSDocumentType";
}

// Autosaves go next to the document as "<name> (Autosaved).stack", or to
// ~/Library/Autosave Information when that place is not writable.
- (void)checkAndSetAutosavedContentsFilePath
{
    NSString *path = [[self fileURL] path];
    if (path == nil)
        return;
    NSString *autosaved = [[NSBundle mainBundle] localizedStringForKey:@"(Autosaved)" value:@"" table:nil];
    NSString *folder = [@"~/Library/Autosave Information" stringByExpandingTildeInPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL];
    NSString *fallback = [folder stringByAppendingPathComponent:[path lastPathComponent]];
    NSString *autosavePath = [NSString stringWithFormat:@"%@ %@", [path stringByDeletingPathExtension], autosaved];
    if (![[NSFileManager defaultManager] hyperIsFileWritableAtPath:autosavePath])
        autosavePath = [NSString stringWithFormat:@"%@ %@", [fallback stringByDeletingPathExtension], autosaved];
    [super setAutosavedContentsFileURL:[NSURL fileURLWithPath:[autosavePath stringByAppendingPathExtension:@"stack"]]];
}

- (BOOL)hyperReadFromWorkcopy:(id)aWorkcopy ofType:(id)aType error:(id *)aError
{
    if ([aType isEqualToString:@"HSDocumentType"] || [aType isEqualToString:@"HSWebDocumentType"]) {
        HSZipWrapper *wrapper = [[HSZipWrapper alloc] initWithPath:aWorkcopy withDelegate:self];
        if (wrapper != nil) {
            BOOL result = [self hyperReadFromFileWrapper:wrapper ofType:aType error:aError];
            [wrapper release];
            return result;
        }
    }
    return [super readFromURL:[NSURL fileURLWithPath:aWorkcopy] ofType:aType error:aError];
}

- (BOOL)hyperWriteToWorkcopy:(id)aWorkcopy ofType:(id)aType error:(id *)aError
{
    BOOL result = [super writeToURL:[NSURL fileURLWithPath:aWorkcopy] ofType:aType error:aError];
    [self clearCaches];
    return result;
}

- (void)setPreferredFilename:(id)aFilename
{
    if (_preferredFilename != aFilename) {
        [_preferredFilename release];
        _preferredFilename = [aFilename retain];
    }
}

- (id)preferredFilename
{
    if (_preferredFilename == nil)
        [self setPreferredFilename:[self displayName]];
    return _preferredFilename;
}

- (void)setProjectAttributesWrapper:(id)aWrapper
{
    if (_projectAttributesWrapper != aWrapper) {
        [_projectAttributesWrapper release];
        _projectAttributesWrapper = [aWrapper retain];
    }
}

- (void)setContentsWrapper:(id)aWrapper
{
    if (_contentsWrapper != aWrapper) {
        [_contentsWrapper release];
        _contentsWrapper = [aWrapper retain];
    }
}

- (void)clearCaches
{
    [_stackWrapper release];
    _stackWrapper = nil;
}

- (void)setShouldStoreCardPreviewImages:(BOOL)aImages
{
    _shouldStorePreviewImages = aImages;
}

- (BOOL)shouldStoreCardPreviewImages
{
    return _shouldStorePreviewImages;
}

- (id)cardPreviewImagesWrapper
{
    HSCardPreviewsFileWrapper *wrapper = [[[HSCardPreviewsFileWrapper alloc] initWithDocumentStoring:self] autorelease];
    [wrapper setPreferredFilename:@"quicklook"];
    return wrapper;
}

- (id)stackWrapper
{
    if (_stackWrapper == nil)
        _stackWrapper = [[[self stack] fileWrapperRepresentation] retain];
    return _stackWrapper;
}

- (void)setResourcesWrapper:(id)aWrapper
{
    if (_resourcesWrapper != nil)
        [_contentsWrapper removeFileWrapper:_resourcesWrapper];
    [super setResourcesWrapper:aWrapper];
}

- (id)resourcesWrapper
{
    if (_resourcesWrapper == nil) {
        HSZipDirectoryWrapper *mediaAccessor = [[[HSZipDirectoryWrapper allocWithZone:[self zone]] initDirectoryWithFileWrappers:[NSDictionary dictionary]] autorelease];
        _resourcesWrapper = [[HSZipDirectoryWrapper allocWithZone:[self zone]] initDirectoryWithFileWrappers:[NSDictionary dictionaryWithObjectsAndKeys:mediaAccessor, @"MediaAccessor", nil]];
        [_resourcesWrapper setPreferredFilename:@"Resources"];
    }
    return _resourcesWrapper;
}

- (id)projectAttributesWrapper
{
    NSMutableDictionary *attributes = [[self attributes] mutableCopy];
    [attributes setObject:[[self class] currentDocumentVersion] forKey:@"HSDocumentVersion"];
    [attributes setObject:[[self class] currentDocumentCompatibilityVersion] forKey:@"HSDocumentCompatibilityVersion"];
    [attributes setObject:[HSApplicationController buildVersionString] forKey:@"HSDocumentCreatorVersion"];
    if ([self printInfo] != nil)
        [attributes setObject:[NSArchiver archivedDataWithRootObject:[self printInfo]] forKey:HSDocumentPrintInfoDictionaryAttributeKey];
    NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithHyperDictionary:attributes];
    [attributes release];
    return [wrapper autorelease];
}

- (id)versionPlistWrapper
{
    static NSFileWrapper *versionWrapper = nil;
    if (versionWrapper == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[@"Version.plist" stringByDeletingPathExtension] ofType:@"plist"];
        versionWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[NSData dataWithContentsOfFile:path]];
    }
    return versionWrapper;
}

- (id)contentsWithoutResourcesWrapper
{
    NSDictionary *existing = [_contentsWrapper fileWrappers];
    NSMutableDictionary *wrappers = existing != nil ? [NSMutableDictionary dictionaryWithDictionary:existing] : [NSMutableDictionary dictionary];
    NSFileWrapper *stackWrapper = [self stackWrapper];
    [wrappers setObject:stackWrapper forKey:[stackWrapper preferredFilename]];
    [wrappers removeObjectForKey:@"Resources"];
    [self setContentsWrapper:[[[HSZipDirectoryWrapper alloc] initDirectoryWithFileWrappers:wrappers] autorelease]];
    return _contentsWrapper;
}

// The iPad copy of the stack is dropped from the saved package.
- (id)contentsWrapper
{
    NSDictionary *existing = [_contentsWrapper fileWrappers];
    NSMutableDictionary *wrappers = existing != nil ? [NSMutableDictionary dictionaryWithDictionary:existing] : [NSMutableDictionary dictionary];
    if ([wrappers objectForKey:@"Resources"] == nil)
        [wrappers setObject:[self resourcesWrapper] forKey:@"Resources"];
    NSFileWrapper *stackWrapper = [self stackWrapper];
    [wrappers setObject:stackWrapper forKey:[stackWrapper preferredFilename]];
    NSFileWrapper *previews = [self cardPreviewImagesWrapper];
    if (previews != nil)
        [wrappers setObject:previews forKey:@"quicklook"];
    if ([wrappers objectForKey:@"iPadStack"] != nil)
        [wrappers removeObjectForKey:@"iPadStack"];
    [self setContentsWrapper:[[[HSZipDirectoryWrapper alloc] initDirectoryWithFileWrappers:wrappers] autorelease]];
    return _contentsWrapper;
}

- (void)dealloc
{
    [self destoryModelIfNeeded];
    [_contentsWrapper release];
    [_projectAttributesWrapper release];
    [_preferredFilename release];
    [_stackWrapper release];
    [_filenamesMapping release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _isAutosavingDisabled = NO;
        _isWritingDisabled = NO;
        _shouldStorePreviewImages = YES;
        _currentSaveOperationType = 0xffffffff;
    }
    return self;
}

@end

// The Quick Look folder of a saved stack: card thumbnails and previews as
// JPEG files plus an Info.plist describing them. The contents are built once,
// the first time the wrappers are asked for.
@implementation HSCardPreviewsFileWrapper

- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames
{
    [self fileWrappers];
    return [super writeToFile:aFile atomically:aAtomically updateFilenames:aFilenames];
}

- (id)fileWrappers
{
    HSDocumentStoring *document = _documentStoring;
    if (document != nil) {
        _documentStoring = nil;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        HSStack *stack;
        NSString *cardSize;
        NSDictionary *stackInfo;
        NSMutableArray *cards;
        if (info != nil && (stack = [document stack]) != nil
            && (cardSize = NSStringFromSize([stack hyperCardSize])) != nil
            && (stackInfo = [NSDictionary dictionaryWithObject:cardSize forKey:@"cardsize"]) != nil) {
            [info setObject:stackInfo forKey:@"stack"];
            if ((cards = [NSMutableArray array]) != nil) {
                NSString *thumbnailSize = nil;
                NSString *previewSize = nil;
                NSEnumerator *enumerator = [[stack hyperChildren] objectEnumerator];
                id child;
                // Any failure stops collecting cards; what was collected is still written.
                while ((child = [enumerator nextObject]) != nil) {
                    id<HSCardAttributes> card = [child queryHyperInterface:@protocol(HSCardAttributes)];
                    NSMutableDictionary *cardInfo;
                    NSString *title;
                    if (card == nil || (cardInfo = [NSMutableDictionary dictionary]) == nil || (title = [card hyperTitle]) == nil)
                        break;
                    NSString *uid = [[card hyperUID] stringValue];
                    if (uid == nil)
                        break;
                    [cardInfo setObject:title forKey:@"name"];
                    [cardInfo setObject:uid forKey:@"uid"];

                    NSImage *image = [document thumbnailImageToStoreForCard:card];
                    if (image != nil) {
                        if (thumbnailSize == nil && (thumbnailSize = NSStringFromSize([image size])) == nil)
                            break;
                        NSString *filename = [[NSString stringWithFormat:@"%@%@", @"thumb_", uid] stringByAppendingPathExtension:@"jpg"];
                        if (filename == nil)
                            break;
                        NSData *data = [image hyperRepresentationUsingType:NSJPEGFileType properties:nil];
                        if (data == nil)
                            break;
                        NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
                        if (wrapper == nil)
                            break;
                        [wrapper setPreferredFilename:filename];
                        [self addFileWrapper:wrapper];
                        [wrapper release];
                        [cardInfo setObject:filename forKey:@"thumbnail"];
                    }

                    if ([document shouldStoreCardPreviewImages] && (image = [document previewImageToStoreForCard:card]) != nil) {
                        if (previewSize == nil && (previewSize = NSStringFromSize([image size])) == nil)
                            break;
                        NSString *filename = [[NSString stringWithFormat:@"%@%@", @"preview_", uid] stringByAppendingPathExtension:@"jpg"];
                        if (filename == nil)
                            break;
                        NSData *data = [image hyperRepresentationUsingType:NSJPEGFileType properties:nil];
                        if (data == nil)
                            break;
                        NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
                        if (wrapper == nil)
                            break;
                        [wrapper setPreferredFilename:filename];
                        [self addFileWrapper:wrapper];
                        [wrapper release];
                        [cardInfo setObject:filename forKey:@"preview"];
                    }
                    [cards addObject:cardInfo];
                }
                if (thumbnailSize != nil)
                    [info setObject:thumbnailSize forKey:@"thumbnailSize"];
                if (previewSize != nil)
                    [info setObject:previewSize forKey:@"previewSize"];
                if ([cards count] != 0)
                    [info setObject:cards forKey:@"cards"];
                NSFileWrapper *infoWrapper = [[NSFileWrapper alloc] initWithHyperDictionary:info];
                if (infoWrapper != nil) {
                    [infoWrapper setPreferredFilename:@"Info.plist"];
                    [self addFileWrapper:infoWrapper];
                    [infoWrapper release];
                    [document release];
                    document = nil;
                }
            }
        }
        // Kept for another try when the Info.plist could not be built.
        _documentStoring = document;
    }
    return [super fileWrappers];
}

- (void)dealloc
{
    [_documentStoring release];
    [super dealloc];
}

- (id)initWithDocumentStoring:(id)aStoring
{
    self = [super initDirectoryWithFileWrappers:[NSDictionary dictionary]];
    if (self != nil)
        _documentStoring = [aStoring retain];
    return self;
}

@end

@implementation NSFileWrapper (HSDocumentStoring)

// The original wrote with writeToFile:atomically:updateFilenames: before
// AppKit 10.6; every supported system has the URL based method.
- (BOOL)hyperWriteToURL:(id)aURL atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames error:(id *)aError
{
    NSFileWrapperWritingOptions options = 0;
    if (aAtomically)
        options |= NSFileWrapperWritingAtomic;
    if (aFilenames)
        options |= NSFileWrapperWritingWithNameUpdating;
    return [self writeToURL:aURL options:options originalContentsURL:nil error:aError];
}

@end
