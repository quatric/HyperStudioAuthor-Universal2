#import "HyperPlayerBasePrefix.h"


@interface HSOldFormatDocumentValidation : NSObject
{
    HSOldFormatParser *_parser;
    NSMutableDictionary *_validationErrors;
    BOOL _isValid;
}
- (BOOL)isOldFileFormatValidForData:(id)aData;
- (void)setValidationErrors:(id)aErrors;
- (id)validationErrors;
- (void)setParser:(id)aParser;
- (id)parser;
- (void)dealloc;
- (id)init;
@end

@interface HSOldFormatDocument : NSObject
{
    NSData *_fileContents;
    HSOldFormatParser *_parser;
    HSOldFormatGraphicsImport *_graphicsImport;
    NSMutableArray *_importingWarnings;
    NSMutableArray *_filesForWarnings1;
    NSMutableArray *_filesForWarnings2;
    NSString *_fileName;
    HSStack *_stack;
    HSDocument *_document;
    HSError *_error;
    NSDictionary *_oldCursorHotSpot;
    NSDictionary *_nbaById;
    NSMutableArray *_cards;
    NSMutableDictionary *_cardsById;
    NSMutableArray *_firstGroupCards;
    NSDictionary *_oldFileFormatStructures;
    NSDictionary *_keyMapDictionary;
    BOOL _debugFlag;
    BOOL _isSharedItem;
    BOOL _isHiddenItem;
    BOOL _isLocked;
    BOOL _isMasterCardIdExists;
    BOOL _isHyperLogoWarning;
    BOOL _isFontWarning;
    BOOL _isAlertForMissingExternalsDisplayed;
    BOOL _isCanceledByUser;
    BOOL _isLegacyPlayerDetected;
    int _currentCardIndex;
    int _uniqueImportedIndex;
    unsigned int _offsetToBlobs;
    HSImportProgressDialog *_progressDialog;
    int _presMode;
    int _presColor;
    int _presFlags;
    BOOL _isPresModeSet;
    HSOldFormatPreViewer *_oldFormatPreViewer;
    NSMapTable *_pngRepresentationsToMediaMap;
    NSMutableArray *_transitionsProcessedAsFromMac;
}
- (id)mediaForImage:(id)aImage;
- (id)pngRepresentationsToMediaMap;
- (void)cancelImport;
- (id)progressDialog;
- (id)uniqueImportedIndexString;
- (id)oldFileFormatStructures;
- (id)firstGroupCards;
- (id)cardsById;
- (id)cards;
- (id)keyMappings;
- (void)setNbaById:(id)aId;
- (id)nbaById;
- (void)setOldCursorHotSpot:(id)aSpot;
- (id)oldCursorHotSpot;
- (void)showImportingWarnings;
- (void)addImportingWarning:(id)aWarning;
- (void)setImportingWarnings:(id)aWarnings;
- (id)importingWarnings;
- (void)addFilesForWarnings2:(id)aWarnings2;
- (void)setFilesForWarnings2:(id)aWarnings2;
- (id)filesForWarnings2;
- (void)addFilesForWarnings1:(id)aWarnings1;
- (void)setFilesForWarnings1:(id)aWarnings1;
- (id)filesForWarnings1;
- (BOOL)oldFormatDocument;
- (BOOL)isFontWarning;
- (void)setFontWarning:(BOOL)aWarning;
- (BOOL)isHyperLogoWarning;
- (void)setHyperLogoWarning:(BOOL)aWarning;
- (BOOL)isLegacyPlayerDetected;
- (BOOL)isCanceledByUser;
- (void)setDebugFlag:(BOOL)aFlag;
- (BOOL)debugFlag;
- (void)setDocument:(id)aDocument;
- (id)document;
- (void)setStack:(id)aStack;
- (id)stack;
- (void)setFileName:(id)aName;
- (id)fileName;
- (void)setGraphicsImport:(id)aImport;
- (id)graphicsImport;
- (void)setParser:(id)aParser;
- (id)parser;
- (void)setFileContents:(id)aContents;
- (id)fileContents;
- (BOOL)createContents;
- (BOOL)readFromFile:(id)aFile ofType:(id)aType error:(id *)aError;
- (void)oldFormatParser:(id)aParser progressForParseOperationDidChange:(double)aChange;
- (void)oldFormatParserFinishParseOperation;
- (void)oldFormatParser:(id)aParser startParseOperationMinValue:(double)aValue maxValue:(double)aValue2;
- (void)dealloc;
- (id)init;
@end

