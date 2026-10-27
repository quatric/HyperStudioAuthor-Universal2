#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSReadWriteTextAction : HSNBAAction <HSReadWriteTextActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSReadWriteTextActionTargetObjectAttribute, HSReadWriteTextActionFileURLAttribute, HSReadWriteTextActionModeAttribute, HSReadWriteTextActionOperationAttribute>
{
    HSUID *_targetObjectUID;
    NSURL *_fileURL;
    int _mode;
    int _operation;
    NSMutableAttributedString *_textToWrite;
    unsigned int _isFileURLRelativeToStack:1;
}
- (id)provideDOSStyleLineEndingForString:(id)aString;
- (void)startInContext:(id)aContext;
- (void)panelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)lockedFileAlertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)askUserToSaveAsInContext:(id)aContext;
- (void)askUserToLocateTheFileInContext:(id)aContext;
- (id)fileLockedAlert;
- (id)fileForWritingNotFoundAlert;
- (id)fileNotFoundAlert;
- (id)textViewIsReadOnlyAlert;
- (id)cannotReadFromFileAlert;
- (id)cannotWriteToFileAlert;
- (id)fileIsNotReadableAlert;
- (id)missingObjectAlert;
- (BOOL)writeAttributedString:(id)aString toURL:(id)aURL attributes:(id)aAttributes;
- (BOOL)isAbleToStartInInvalidState;
- (BOOL)isValid;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (void)setModeAsString:(id)aString;
- (id)modeAsString;
- (void)setOperationAsString:(id)aString;
- (id)operationAsString;
- (void)setMode:(NSInteger)aMode;
- (NSInteger)mode;
- (void)setOperation:(NSInteger)aOperation;
- (NSInteger)operation;
- (id)absoluteFileURL;
- (id)filePath;
- (void)setRelativeFileURL:(id)aURL;
- (id)relativeFileURL;
- (void)setFileURL:(id)aURL;
- (void)setFileURL:(id)aURL relativeToStack:(BOOL)aStack;
- (BOOL)isFileURLRelativeToStack;
- (id)fileURL;
- (void)setTargetObjectUID:(id)aUID;
- (id)targetObjectUID;
- (void)HSReadWriteTextAction_notifyUndoOrRedoChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

