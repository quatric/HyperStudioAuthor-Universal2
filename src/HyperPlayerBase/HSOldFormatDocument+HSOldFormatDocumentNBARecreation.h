#import "HyperPlayerBasePrefix.h"
#import "HSOldFormatDocumentValidation.h"
#import "SMKSpeechVoice.h"


@interface HSOldFormatDocument (HSOldFormatDocumentNBARecreation)
- (id)processButtonListerNBAWithData:(id)aData button:(id)aButton;
- (id)processButtonStepperNBAWithData:(id)aData button:(id)aButton;
- (id)processButtonScannerNBAWithData:(id)aData button:(id)aButton;
- (id)processExpPageNBAWithData:(id)aData button:(id)aButton;
- (id)processKeyMapperNBAWithData:(id)aData button:(id)aButton;
- (id)processStarFieldNBAWithData:(id)aData button:(id)aButton;
- (id)processSpeechRecognitionNBAWithData:(id)aData button:(id)aButton;
- (id)processHideShow2NBAWithData:(id)aData button:(id)aButton;
- (id)processMultipleHideShowNBAWithData:(id)aData button:(id)aButton;
- (id)processAutoTypeNBAWithData:(id)aData button:(id)aButton;
- (id)processAutoRecordNBAWithData:(id)aData button:(id)aButton;
- (id)processMovieControllerNBAWithData:(id)aData button:(id)aButton;
- (id)processPictureShowNBAWithData:(id)aData button:(id)aButton;
- (id)processButtonRunnerNBAWithData:(id)aData button:(id)aButton;
- (id)processSlideShowNBAWithData:(id)aData button:(id)aButton;
- (id)processSetVolumeNBAWithData:(id)aData button:(id)aButton;
- (id)processTextMoveNBAWithData:(id)aData button:(id)aButton;
- (id)processRunApplescriptNBAWithData:(id)aData button:(id)aButton;
- (id)processSetCursorPositionNBAWithData:(id)aData button:(id)aButton;
- (id)processPrintCardNBAWithData:(id)aData button:(id)aButton;
- (id)processShowMessageNBAWithData:(id)aData button:(id)aButton;
- (id)processHideCursorNBAWithData:(id)aData button:(id)aButton;
- (id)processObscureCursorNBAWithData:(id)aData button:(id)aButton;
- (id)processQuitAnotherNBAWithData:(id)aData button:(id)aButton;
- (id)processHomeStackNBAWithData:(id)aData button:(id)aButton;
- (id)processCreditsScrollNBAWithData:(id)aData button:(id)aButton;
- (id)processBlabberMouthNBAWithData:(id)aData button:(id)aButton;
- (id)processPauseNBAWithData:(id)aData button:(id)aButton;
- (id)processClearChangeFlagNBAWithData:(id)aData button:(id)aButton;
- (id)processQuitNBAWithData:(id)aData button:(id)aButton;
- (id)processRunCommandNBAWithData:(id)aData button:(id)aButton;
@end

@interface SMKSpeechVoice (HSOldFormatDocumentNBARecreationAdditionalPrivate)
- (id)description;
@end

