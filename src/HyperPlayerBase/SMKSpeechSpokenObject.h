#import "HyperPlayerBasePrefix.h"


@interface SMKSpeechSpokenObject : NSObject
{
    id _requestor;
    union HyperPlayerBase_anon23 _text;
    struct HyperPlayerBase_anon24 _soFlags;
}
- (void)setHasBeenSpoken;
- (void)setHasBeenProcessed;
- (void)prepareForSpeaking;
- (BOOL)isBeingSpoken;
- (BOOL)isBeingProcessedBySpeaker;
- (id)dataToSpeak;
- (id)textToSpeak;
- (void)clearRequestor;
- (id)requestor;
- (void)setChooseVoiceBeforeProcessing:(BOOL)aProcessing;
- (BOOL)chooseVoiceBeforeProcessing;
- (BOOL)isHighPriority;
- (BOOL)needsParsing;
- (BOOL)shouldBeDropped;
- (void)markAsShouldBeDropped;
- (void)setDataToSpeak:(id)aSpeak;
- (void)dealloc;
- (id)initWithData:(id)aData requestor:(id)aRequestor highPriority:(BOOL)aPriority;
- (id)initWithTextToSpeak:(id)aSpeak requestor:(id)aRequestor parsed:(BOOL)aParsed highPriority:(BOOL)aPriority;
- (void)_setRequestor:(id)aRequestor;
@end

