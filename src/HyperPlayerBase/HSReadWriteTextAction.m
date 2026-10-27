#import "HSReadWriteTextAction.h"
#import "HSActionExecutionContext.h"
#import "HSAlert.h"
#import "HSExecutableResourceProvider.h"
#import "HSNavigationController.h"
#import "NSString+NSStringLinkRecognitionHSExtensions.h"

static id HSReadWriteTextActionLocalizedString(NSString *aKey)
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:aKey value:@"" table:@"Alerts"];
}

static id HSReadWriteTextActionCannotPerformAlert(NSString *aInformativeTextKey)
{
    return [HSAlert alertWithMessageText:HSReadWriteTextActionLocalizedString(@"HSCannotPerformActionAlertMessageText") defaultButton:nil alternateButton:nil otherButton:nil informativeText:HSReadWriteTextActionLocalizedString(aInformativeTextKey)];
}

// The attributes of an existing file, mutable.
static NSMutableDictionary *HSReadWriteTextActionFileAttributes(NSFileManager *aManager, NSString *aPath)
{
    if (![aManager fileExistsAtPath:aPath])
        return nil;
    return [[[aManager attributesOfItemAtPath:aPath error:NULL] mutableCopy] autorelease];
}

// Reads a text file into a text object (appending to or replacing its
// text), or writes the text object's text to a file (appending to or
// replacing the file's contents). The file may be relative to the stack.
@implementation HSReadWriteTextAction

- (id)provideDOSStyleLineEndingForString:(id)aString
{
    NSMutableString *string = [NSMutableString stringWithString:aString];
    [string replaceOccurrencesOfString:@"\n" withString:@"\r\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [string length])];
    return string;
}

- (void)startInContext:(id)aContext
{
    id textView = [[[self stack] childInTreeWithUID:[self targetObjectUID]] queryHyperInterface:@protocol(HSSystemTextViewAttribute)];
    id text = [textView hyperText];
    if (textView == nil) {
        [aContext displayAlert:[self missingObjectAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        return;
    }
    if (_operation == 1) {
        if (_isFileURLRelativeToStack) {
            [[self undoManager] disableUndoRegistration];
            [self setFileURL:[self absoluteFileURL] relativeToStack:NO];
            [[self undoManager] enableUndoRegistration];
        }
        NSString *path = [_fileURL path];
        NSFileManager *manager = [NSFileManager defaultManager];
        // A missing folder on the way to the file.
        if (_fileURL != nil && ![manager fileExistsAtPath:path]) {
            NSInteger count = [path pathComponentsCount];
            for (NSInteger i = 1; i < count; i++) {
                if (![manager fileExistsAtPath:[path pathWithFirstComponents:i]]) {
                    [aContext displayAlert:[self fileForWritingNotFoundAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:aContext];
                    return;
                }
            }
        }
        NSMutableDictionary *attributes = HSReadWriteTextActionFileAttributes(manager, path);
        [attributes removeObjectForKey:NSFileModificationDate];
        [attributes setObject:[NSNumber numberWithBool:NO] forKey:NSFileImmutable];
        _textToWrite = nil;
        if (_mode == 0)
            _textToWrite = [[NSMutableAttributedString alloc] initWithURL:_fileURL options:@{} documentAttributes:NULL error:NULL];
        else
            _textToWrite = [NSMutableAttributedString new];
        if (_textToWrite == nil) {
            if ([manager fileExistsAtPath:path]) {
                id alert = [manager isWritableFileAtPath:path] ? [self cannotReadFromFileAlert] : [self cannotWriteToFileAlert];
                [aContext displayAlert:alert modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
                [_textToWrite release];
                _textToWrite = nil;
                return;
            }
            _textToWrite = [NSMutableAttributedString new];
        }
        [_textToWrite appendAttributedString:text];
        if ([attributes fileIsImmutable] || ([manager fileExistsAtPath:path] && ![manager isWritableFileAtPath:path])) {
            [aContext displayAlert:[self fileLockedAlert] modalDelegate:self didEndSelector:@selector(lockedFileAlertDidEnd:returnCode:contextInfo:) contextInfo:aContext];
            return;
        }
        BOOL isWritten = [self writeAttributedString:_textToWrite toURL:_fileURL attributes:attributes];
        [_textToWrite release];
        _textToWrite = nil;
        if (!isWritten) {
            [aContext displayAlert:[self cannotWriteToFileAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
            return;
        }
        [self notifyDidFinish];
        return;
    }
    if (_operation != 0) {
        [self notifyDidFinish];
        return;
    }
    if (![textView isEditable]) {
        [aContext displayAlert:[self textViewIsReadOnlyAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        return;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *URL = nil;
    if (_isFileURLRelativeToStack) {
        URL = [self absoluteFileURL];
        if (URL != nil && ![manager fileExistsAtPath:[URL path]])
            URL = nil;
    } else if ([manager fileExistsAtPath:[_fileURL path]]) {
        URL = _fileURL;
    } else {
        URL = [HSNavigationController findURLUsingActionURL:_fileURL baseURL:[[[self document] fileURL] URLByDeletingLastPathComponent]];
        if ([_fileURL isEqual:URL])
            URL = nil;
    }
    if (URL == nil) {
        [aContext displayAlert:[self fileNotFoundAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:aContext];
        return;
    }
    if (URL != _fileURL) {
        [[self undoManager] disableUndoRegistration];
        [self setFileURL:URL relativeToStack:NO];
        [[self undoManager] enableUndoRegistration];
    }
    NSDictionary *documentAttributes = nil;
    NSAttributedString *readText = [[[NSAttributedString alloc] initWithURL:_fileURL options:@{} documentAttributes:&documentAttributes error:NULL] autorelease];
    // Plain text takes the text object's attributes.
    if ([[documentAttributes objectForKey:NSDocumentTypeDocumentAttribute] isEqualToString:NSPlainTextDocumentType])
        readText = [[[NSAttributedString alloc] initWithString:[readText string] attributes:[textView hyperTextAttributes]] autorelease];
    if (readText == nil) {
        [aContext displayAlert:[self fileIsNotReadableAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        return;
    }
    NSMutableAttributedString *newText = [NSMutableAttributedString new];
    if (newText == nil)
        return;
    if (_mode == 0)
        [newText appendAttributedString:text];
    [newText appendAttributedString:readText];
    [textView setHyperText:newText];
    [newText release];
    [self notifyDidFinish];
}

- (void)panelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode != NSModalResponseOK) {
        [self notifyDidFinish];
        return;
    }
    [[self undoManager] disableUndoRegistration];
    [self setFileURL:[aEnd URL] relativeToStack:NO];
    [[self undoManager] enableUndoRegistration];
    [self startInContext:(id)aInfo];
}

// Unlock and write, cancel, or save elsewhere.
- (void)lockedFileAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aInfo == NULL)
        return;
    if (aCode == NSAlertThirdButtonReturn) {
        NSString *path = [_fileURL path];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSMutableDictionary *attributes = HSReadWriteTextActionFileAttributes(manager, path);
        if ([attributes fileIsImmutable])
            [manager setAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:NSFileImmutable] ofItemAtPath:[_fileURL path] error:NULL];
        [attributes removeObjectForKey:NSFileModificationDate];
        BOOL isWritten = [self writeAttributedString:_textToWrite toURL:_fileURL attributes:attributes];
        [_textToWrite release];
        _textToWrite = nil;
        if (!isWritten)
            [(id)aInfo displayAlert:[self cannotWriteToFileAlert] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        [self notifyDidFinish];
    } else if (aCode == NSAlertSecondButtonReturn) {
        [_textToWrite release];
        _textToWrite = nil;
        [self notifyDidFinish];
    } else if (aCode == NSAlertFirstButtonReturn) {
        [_textToWrite release];
        _textToWrite = nil;
        [self askUserToSaveAsInContext:(id)aInfo];
    }
}

// The missing-file alerts offer to locate the file.
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aInfo != NULL && aCode == NSAlertFirstButtonReturn)
        [self askUserToLocateTheFileInContext:(id)aInfo];
    else
        [self notifyDidFinish];
}

- (void)askUserToSaveAsInContext:(id)aContext
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setCanCreateDirectories:YES];
    [panel setAllowsOtherFileTypes:YES];
    [aContext showSavePanel:panel sheetForDirectory:nil file:nil modalDelegate:self didEndSelector:@selector(panelDidEnd:returnCode:contextInfo:) contextInfo:aContext];
}

- (void)askUserToLocateTheFileInContext:(id)aContext
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    NSArray *types = [NSArray arrayWithObjects:@"rtf", @"txt", @"doc", @"rtfd", nil];
    [aContext showOpenPanel:panel sheetForDirectory:nil file:nil types:types modalDelegate:self didEndSelector:@selector(panelDidEnd:returnCode:contextInfo:) contextInfo:aContext];
}

- (id)fileLockedAlert
{
    HSAlert *alert = [[HSAlert new] autorelease];
    [alert setMessageText:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileMissingAlertMessage")];
    [alert setInformativeText:[NSString stringWithFormat:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileLockedAlertInformativeText"), [_fileURL lastPathComponent]]];
    [alert addButtonWithTitle:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileLockedAlertFirstButtonTitle")];
    [alert addButtonWithTitle:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileLockedAlertSecondButtonTitle")];
    [alert addButtonWithTitle:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileLockedAlertThirdButtonTitle")];
    [alert setAlertStyle:5];
    return alert;
}

- (id)fileForWritingNotFoundAlert
{
    HSAlert *alert = [[HSAlert new] autorelease];
    [alert setMessageText:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileMissingAlertMessage")];
    [alert setInformativeText:[NSString stringWithFormat:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileForWritingMissingAlertInformativeText"), [_fileURL lastPathComponent]]];
    [alert addButtonWithTitle:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileForWritingMissingAlertFirstButtonTitle")];
    [alert addButtonWithTitle:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileForWritingMissingAlertSecondButtonTitle")];
    [alert setAlertStyle:5];
    return alert;
}

- (id)fileNotFoundAlert
{
    HSAlert *alert = [[HSAlert new] autorelease];
    [alert setMessageText:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileMissingAlertMessage")];
    [alert setInformativeText:[NSString stringWithFormat:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileMissingAlertInformativeText"), [_fileURL lastPathComponent]]];
    [alert addButtonWithTitle:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileMissingAlertFirstButtonTitle")];
    [alert addButtonWithTitle:HSReadWriteTextActionLocalizedString(@"ReadWriteTextFileMissingAlertSecondButtonTitle")];
    [alert setAlertStyle:5];
    return alert;
}

- (id)textViewIsReadOnlyAlert
{
    return HSReadWriteTextActionCannotPerformAlert(@"HSTextViewIsReadOnlyAlertAlertInformativeText");
}

- (id)cannotReadFromFileAlert
{
    return HSReadWriteTextActionCannotPerformAlert(@"HSCannotReadFromFileAlertInformativeText");
}

- (id)cannotWriteToFileAlert
{
    return HSReadWriteTextActionCannotPerformAlert(@"HSCannotWriteToFileAlertInformativeText");
}

- (id)fileIsNotReadableAlert
{
    return HSReadWriteTextActionCannotPerformAlert(@"HSFileIsNotReadableAlertInformativeText");
}

- (id)missingObjectAlert
{
    return HSReadWriteTextActionCannotPerformAlert(@"HSObjectIsMissingAlertInformativeText");
}

// The format follows the extension; anything else is UTF-8 text with DOS
// line endings.
- (BOOL)writeAttributedString:(id)aString toURL:(id)aURL attributes:(id)aAttributes
{
    NSString *extension = [aURL pathExtension];
    NSRange range = NSMakeRange(0, [aString length]);
    BOOL isWritten;
    if ([extension isEqual:@"rtf"]) {
        isWritten = [[aString RTFFromRange:range documentAttributes:@{}] writeToURL:aURL options:0 error:NULL];
    } else if ([extension isEqual:@"rtfd"]) {
        NSFileWrapper *wrapper = [aString RTFDFileWrapperFromRange:range documentAttributes:@{}];
        isWritten = [wrapper writeToURL:aURL options:NSFileWrapperWritingAtomic | NSFileWrapperWritingWithNameUpdating originalContentsURL:nil error:NULL];
    } else if ([extension isEqual:@"doc"]) {
        isWritten = [[aString docFormatFromRange:range documentAttributes:@{}] writeToURL:aURL atomically:YES];
    } else {
        isWritten = [[self provideDOSStyleLineEndingForString:[aString string]] writeToURL:aURL atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
    if (isWritten && aAttributes != nil)
        [[NSFileManager defaultManager] setAttributes:aAttributes ofItemAtPath:[aURL path] error:NULL];
    return isWritten;
}

- (BOOL)isAbleToStartInInvalidState
{
    return YES;
}

- (BOOL)isValid
{
    if (_targetObjectUID == nil)
        return NO;
    return [[self stack] childInTreeWithUID:_targetObjectUID] != nil;
}

// Nothing is left without the target.
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    if ([aDs containsObject:[self targetObjectUID]])
        return nil;
    return [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
}

- (void)setModeAsString:(id)aString
{
    if ([aString isEqualToString:@"append"])
        _mode = 0;
    else if ([aString isEqualToString:@"replace"])
        _mode = 1;
}

- (id)modeAsString
{
    return _mode == 1 ? @"replace" : @"append";
}

- (void)setOperationAsString:(id)aString
{
    if ([aString isEqualToString:@"read"])
        _operation = 0;
    else if ([aString isEqualToString:@"write"])
        _operation = 1;
}

- (id)operationAsString
{
    return _operation == 1 ? @"write" : @"read";
}

- (void)setMode:(NSInteger)aMode
{
    if (_mode == aMode)
        return;
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [[undoManager prepareWithInvocationTarget:self] HSReadWriteTextAction_notifyUndoOrRedoChange:0x200 ofAttribute:@protocol(HSReadWriteTextActionModeAttribute) withUserInfo:nil];
        [[undoManager prepareWithInvocationTarget:self] setMode:_mode];
        [[undoManager prepareWithInvocationTarget:self] HSReadWriteTextAction_notifyUndoOrRedoChange:0x100 ofAttribute:@protocol(HSReadWriteTextActionModeAttribute) withUserInfo:nil];
    }
    id center = [self attributeNotificationCenter];
    [center notifyChange:1 ofAttribute:@protocol(HSReadWriteTextActionModeAttribute) ofObject:self withUserInfo:nil];
    _mode = (int)aMode;
    [center notifyChange:2 ofAttribute:@protocol(HSReadWriteTextActionModeAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)mode
{
    return _mode;
}

- (void)setOperation:(NSInteger)aOperation
{
    if (_operation == aOperation)
        return;
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [[undoManager prepareWithInvocationTarget:self] HSReadWriteTextAction_notifyUndoOrRedoChange:0x200 ofAttribute:@protocol(HSReadWriteTextActionOperationAttribute) withUserInfo:nil];
        [[undoManager prepareWithInvocationTarget:self] setOperation:_operation];
        [[undoManager prepareWithInvocationTarget:self] HSReadWriteTextAction_notifyUndoOrRedoChange:0x100 ofAttribute:@protocol(HSReadWriteTextActionOperationAttribute) withUserInfo:nil];
    }
    id center = [self attributeNotificationCenter];
    [center notifyChange:1 ofAttribute:@protocol(HSReadWriteTextActionOperationAttribute) ofObject:self withUserInfo:nil];
    _operation = (int)aOperation;
    [center notifyChange:2 ofAttribute:@protocol(HSReadWriteTextActionOperationAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)operation
{
    return _operation;
}

// A relative URL is resolved against the stack's folder.
- (id)absoluteFileURL
{
    NSURL *URL = [_fileURL absoluteURL];
    if (URL == nil || !_isFileURLRelativeToStack)
        return URL;
    NSURL *folderURL = [[[self document] fileURL] URLByDeletingLastPathComponent];
    if (folderURL == nil)
        return nil;
    Boolean isAbsolute;
    CFStringRef path = CFURLCopyStrictPath((CFURLRef)URL, &isAbsolute);
    if (path == NULL)
        return nil;
    NSURL *absoluteURL = [[NSURL URLWithString:(NSString *)path relativeToURL:folderURL] absoluteURL];
    CFRelease(path);
    return absoluteURL;
}

// The relative path as is for a relative URL.
- (id)filePath
{
    NSURL *URL = [_fileURL absoluteURL];
    if (URL == nil)
        return nil;
    if (!_isFileURLRelativeToStack)
        return [URL path];
    Boolean isAbsolute;
    CFStringRef path = CFURLCopyStrictPath((CFURLRef)URL, &isAbsolute);
    if (path == NULL)
        return nil;
    NSString *filePath = [(NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, path, CFSTR(""), kCFStringEncodingUTF8) autorelease];
    CFRelease(path);
    return filePath;
}

- (void)setRelativeFileURL:(id)aURL
{
    if (_fileURL != aURL) {
        id URL = [aURL copy];
        [_fileURL release];
        _fileURL = URL;
    }
    _isFileURLRelativeToStack = 1;
}

- (id)relativeFileURL
{
    return _fileURL;
}

- (void)setFileURL:(id)aURL
{
    if (_fileURL != aURL) {
        id URL = [aURL copy];
        [_fileURL release];
        _fileURL = URL;
    }
    _isFileURLRelativeToStack = 0;
}

- (void)setFileURL:(id)aURL relativeToStack:(BOOL)aStack
{
    if ((aStack != 0) == (_isFileURLRelativeToStack != 0) && [aURL isEqual:_fileURL])
        return;
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [[undoManager prepareWithInvocationTarget:self] HSReadWriteTextAction_notifyUndoOrRedoChange:0x200 ofAttribute:@protocol(HSReadWriteTextActionFileURLAttribute) withUserInfo:nil];
        [[undoManager prepareWithInvocationTarget:self] setFileURL:_fileURL relativeToStack:_isFileURLRelativeToStack ? YES : NO];
        [[undoManager prepareWithInvocationTarget:self] HSReadWriteTextAction_notifyUndoOrRedoChange:0x100 ofAttribute:@protocol(HSReadWriteTextActionFileURLAttribute) withUserInfo:nil];
    }
    id center = [self attributeNotificationCenter];
    [center notifyChange:1 ofAttribute:@protocol(HSReadWriteTextActionFileURLAttribute) ofObject:self withUserInfo:nil];
    id URL = [aURL copy];
    [_fileURL release];
    _fileURL = URL;
    _isFileURLRelativeToStack = aStack & 1;
    [center notifyChange:2 ofAttribute:@protocol(HSReadWriteTextActionFileURLAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)isFileURLRelativeToStack
{
    return _isFileURLRelativeToStack ? YES : NO;
}

- (id)fileURL
{
    return _fileURL;
}

- (void)setTargetObjectUID:(id)aUID
{
    if ([aUID isEqual:_targetObjectUID])
        return;
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [[undoManager prepareWithInvocationTarget:self] HSReadWriteTextAction_notifyUndoOrRedoChange:0x200 ofAttribute:@protocol(HSReadWriteTextActionTargetObjectAttribute) withUserInfo:nil];
        [[undoManager prepareWithInvocationTarget:self] setTargetObjectUID:_targetObjectUID];
        [[undoManager prepareWithInvocationTarget:self] HSReadWriteTextAction_notifyUndoOrRedoChange:0x100 ofAttribute:@protocol(HSReadWriteTextActionTargetObjectAttribute) withUserInfo:nil];
    }
    id center = [self attributeNotificationCenter];
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSActionValidationStatusAttribute), @protocol(HSReadWriteTextActionTargetObjectAttribute), nil];
    [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
    [_targetObjectUID release];
    _targetObjectUID = [aUID retain];
    [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
}

- (id)targetObjectUID
{
    return _targetObjectUID;
}

- (void)HSReadWriteTextAction_notifyUndoOrRedoChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo
{
    [[self attributeNotificationCenter] notifyChange:aChange ofAttribute:aAttribute ofObject:self withUserInfo:aInfo];
}

// Quirk kept: the loading key is the opposite of the storing one (a new
// action loads "relativeFileURL").
- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [[super keysForExtraLoadingWithCodingContext:aContext] arrayByAddingObject:_isFileURLRelativeToStack ? @"fileURL" : @"relativeFileURL"];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:@"targetObjectUID", _isFileURLRelativeToStack ? @"relativeFileURL" : @"fileURL", @"operationAsString", @"modeAsString", nil];
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}

- (void)dealloc
{
    [_targetObjectUID release];
    [_fileURL release];
    // Fixed: the text being written leaked.
    [_textToWrite release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _operation = 1;
    return self;
}

@end
