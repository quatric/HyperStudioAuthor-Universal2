#import "HSRecorder.h"
#define GL_SILENCE_DEPRECATION 1
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

// The frames queue is a doubly linked list of captured frames (f0 the oldest, f1 the newest) with a list
// of spare items (f2) for reuse; an item without a buffer ends the recording.
struct HSFramesQueueItem {
    CVPixelBufferRef buffer;
    struct HyperStudio_anon7 duration;
    struct HSFramesQueueItem *previous;
    struct HSFramesQueueItem *next;
};

// FUN_00267c9e: puts the audio compression options on the sound connections of a movie file output.
static void HSRecorderSetSoundCompression(QTCaptureMovieFileOutput *aOutput, NSString *aIdentifier)
{
    QTCompressionOptions *options = [QTCompressionOptions compressionOptionsWithIdentifier:aIdentifier];
    if (options != nil) {
        for (QTCaptureConnection *connection in [aOutput connections]) {
            if ([[connection mediaType] isEqualToString:QTMediaTypeSound]) {
                [aOutput setCompressionOptions:options forConnection:connection];
            }
        }
    }
}

static QTTime HSRecorderQTTimeFromDuration(struct HyperStudio_anon7 aDuration)
{
    QTTime time = QTMakeTime(aDuration.f0, aDuration.f1);
    time.flags = aDuration.f2;
    return time;
}

static struct HSFramesQueueItem *HSRecorderFramesQueueAppendItem(struct HSFramesQueue *aQueue)
{
    struct HSFramesQueueItem *item = aQueue->f2;
    if (item == NULL) {
        item = malloc(sizeof(struct HSFramesQueueItem));
    } else {
        aQueue->f2 = item->next;
    }
    if (item != NULL) {
        memset(item, 0, sizeof(struct HSFramesQueueItem));
        if (aQueue->f0 == NULL) {
            aQueue->f0 = item;
        } else {
            aQueue->f1->next = item;
            item->previous = aQueue->f1;
        }
        aQueue->f1 = item;
        aQueue->f3++;
    }
    return item;
}

@implementation HSRecorder

/* i386 ivar offsets: _delegateMutex=0x4, _delegate=0x30, _dataSource=0x34, _currentThreadContext=0x38, _capturingStartTime=0x3c, _capturingPreviousTimeMutex=0x44, _capturingPreviousTime=0x70, _voiceCaptureSession=0x78, _voiceCaptureFileOutput=0x7c, _audioOutToInCaptureSession=0x80, _audioOutToInCaptureFileOutput=0x84, _voiceCaptureDeviceInput=0x88, _voiceCaptureDevice=0x8c, _audioOutToInCaptureDeviceInput=0x90, _audioOutToInCaptureDevice=0x94, _audioDeviceSwapper=0x98, _currentFrameBuffer=0x9c, _framesPerSecondLimit=0xa0, _framesCounter=0xa8, _framesQueueLimit=0xac, _roundedCornersForMovie=0xb0, _movieSize=0xb4, _voiceRecorder=0xbc, _audioOutToInRecorder=0xc0, _movieLogger=0xc4, _useAudioRecordWorkAround=0xc8, _error=0xcc, _lazyMovieCreation=0xd0, _processedInAnotherThreadMovies=0xd4 */

- (id)playbackThread
{
    return [NSThread mainThread];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00265641 @ 00265641, 205 bytes * /

void FUN_00265641(HSRecorder *self,SEL _cmd,id HSThreadContextDelegate_threadContext,
                 id didFinishFlatteningToFile,id dueToError)

{
  id pvVar1;
  HSRecorder *pHVar2;
  
  if (self->_currentThreadContext == HSThreadContextDelegate_threadContext) {
    _objc_msgSend(self->_currentThreadContext,sel_release);
    self->_currentThreadContext = (HSThreadContext *)0x0;
    _pthread_mutex_lock((pthread_mutex_t *)&self->_delegateMutex);
    pHVar2 = (HSRecorder *)sel_recorder_didFinishRecordingToOutputFileAtPath_dueToError_;
    pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                           sel_recorder_didFinishRecordingToOutputFileAtPath_dueToError_);
    if ((char)pvVar1 != '\0') {
      if (self->_error != (id)0x0) {
        dueToError = self->_error;
      }
      pHVar2 = self;
      _objc_msgSend(self->_delegate,sel_recorder_didFinishRecordingToOutputFileAtPath_dueToError_,
                    self,didFinishFlatteningToFile,dueToError);
    }
    _pthread_mutex_unlock((pthread_mutex_t *)&self->_delegateMutex);
    _objc_msgSend(self->_error,sel_autorelease,pHVar2);
    self->_error = (id)0x0;
  }
  return;
}

*/
- (void)HSThreadContextDelegate_threadContext:(id)aContext didFinishFlatteningToFile:(id)aFile dueToError:(id)aError
{
    if (_currentThreadContext == aContext) {
        [_currentThreadContext release];
        _currentThreadContext = nil;
        pthread_mutex_lock(&_delegateMutex);
        if ([_delegate respondsToSelector:@selector(recorder:didFinishRecordingToOutputFileAtPath:dueToError:)]) {
            [_delegate recorder:self didFinishRecordingToOutputFileAtPath:aFile dueToError:(_error != nil) ? _error : aError];
        }
        pthread_mutex_unlock(&_delegateMutex);
        [_error autorelease];
        _error = nil;
    }
}

- (void)audioRecorder:(id)aRecorder didFinishRecordingToFileAtURL:(id)aURL dueToError:(id)aError
{
    [self performSelectorOnMainThread:@selector(HSRecorder_loadSoundMovieWithAttributes:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:aURL, @"outputFileURL", aRecorder, @"captureOutput", nil] waitUntilDone:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026578e @ 0026578e, 445 bytes * /

void FUN_0026578e(HSRecorder *self,SEL _cmd,id captureOutput,id didFinishRecordingToOutputFileAtURL,
                 id forConnections,id dueToError)

{
  id pvVar1;
  HSRecorder *self_00;
  SEL op;
  undefined4 uVar2;
  undefined *puVar3;
  
  if (dueToError != (id)0x0) {
    pvVar1 = _objc_msgSend(dueToError,sel_domain);
    uVar2 = *(undefined4 *)PTR_003368a0;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,uVar2);
    if (((char)pvVar1 != '\0') &&
       (pvVar1 = _objc_msgSend(dueToError,sel_code,uVar2), pvVar1 != (id)0x4b0)) {
      _objc_msgSend(self->_error,sel_release,uVar2);
      pvVar1 = _objc_msgSend(dueToError,sel_retain);
      self->_error = pvVar1;
      _objc_msgSend(self,sel_cancelRecording);
      puVar3 = sel_recorder_didFinishRecordingToOutputFileAtPath_dueToError_;
      pvVar1 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                             sel_recorder_didFinishRecordingToOutputFileAtPath_dueToError_);
      if ((char)pvVar1 == '\0') {
        return;
      }
      self_00 = self->_delegate;
      pvVar1 = _objc_msgSend(self->_currentThreadContext,sel_outputMovieFilePath,puVar3);
      op = sel_recorder_didFinishRecordingToOutputFileAtPath_dueToError_;
      goto LAB_002658a1;
    }
  }
  _objc_msgSend(self->_error,sel_release);
  pvVar1 = _objc_msgSend(dueToError,sel_retain);
  self->_error = pvVar1;
  pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,
                         didFinishRecordingToOutputFileAtURL,&cfstr_outputFileURL,captureOutput,
                         &cfstr_captureOutput,0);
  dueToError = (id)0x0;
  self_00 = self;
  op = sel_performSelectorOnMainThread_withObject_waitUntilDone_;
  self = (HSRecorder *)sel_HSRecorder_loadSoundMovieWithAttributes_;
LAB_002658a1:
  _objc_msgSend(self_00,op,self,pvVar1,dueToError);
  return;
}

*/
- (void)captureOutput:(id)aOutput didFinishRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections dueToError:(id)aError
{
    if (aError != nil && [[aError domain] isEqualToString:QTKitErrorDomain] && [aError code] != 0x4b0) {
        [_error release];
        _error = [aError retain];
        [self cancelRecording];
        if ([_delegate respondsToSelector:@selector(recorder:didFinishRecordingToOutputFileAtPath:dueToError:)]) {
            [_delegate recorder:self didFinishRecordingToOutputFileAtPath:[_currentThreadContext outputMovieFilePath] dueToError:aError];
        }
        return;
    }
    [_error release];
    _error = [aError retain];
    [self performSelectorOnMainThread:@selector(HSRecorder_loadSoundMovieWithAttributes:)
                           withObject:[NSDictionary dictionaryWithObjectsAndKeys:aURL, @"outputFileURL", aOutput, @"captureOutput", nil]
                        waitUntilDone:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026594b @ 0026594b, 1903 bytes * /

void FUN_0026594b(HSRecorder *self,SEL _cmd,id HSRecorder_loadSoundMovieWithAttributes)

{
  int iVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  HSThreadContext *self_01;
  id pvVar5;
  double dVar6;
  double dVar7;
  SEL op;
  undefined8 in_stack_ffffff3c;
  longlong lVar8;
  uint uVar11;
  undefined8 uVar9;
  undefined *puVar12;
  ulonglong uVar10;
  undefined4 uVar13;
  id local_9c;
  id local_80;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  lVar8 = CONCAT44((int)((ulonglong)in_stack_ffffff3c >> 0x20),&cfstr_outputFileURL);
  pvVar2 = _objc_msgSend(HSRecorder_loadSoundMovieWithAttributes,sel_objectForKey_,
                         &cfstr_outputFileURL);
  pvVar2 = _objc_msgSend(pvVar2,sel_path);
  if (pvVar2 == (id)0x0) {
LAB_00265c61:
    if (self->_currentThreadContext != (HSThreadContext *)0x0) {
      uVar9 = CONCAT44((int)((ulonglong)lVar8 >> 0x20),&cfstr_outputFileURL);
      pvVar2 = _objc_msgSend(HSRecorder_loadSoundMovieWithAttributes,sel_objectForKey_,
                             &cfstr_outputFileURL);
      if (pvVar2 == (id)0x0) {
        if (self->_movieLogger != (id)0x0) {
          pvVar2 = _objc_msgSend(self->_movieLogger,sel_log,uVar9);
          local_74 = 0;
          local_70 = 0;
          local_6c = (int *)0x0;
          local_68 = 0;
          local_64 = 0;
          local_60 = 0;
          local_5c = 0;
          local_58 = 0;
          uVar9 = CONCAT44(local_50,&local_74);
          uVar13 = 0x10;
          local_9c = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,
                                   local_50,0x10);
          if (local_9c != (id)0x0) {
            iVar1 = *local_6c;
            do {
              local_80 = (id)0x0;
              do {
                if (iVar1 != *local_6c) {
                  _objc_enumerationMutation(pvVar2);
                }
                pvVar3 = *(id *)(local_70 + (int)local_80 * 4);
                dVar7 = _objc_msgSend_fpret(pvVar3,sel_startTime);
                dVar7 = dVar7 - self->_capturingStartTime;
                pvVar4 = _objc_msgSend(pvVar3,sel_movie);
                pvVar4 = _objc_msgSend(pvVar4,sel_QTMovie);
                pvVar4 = _objc_msgSend(pvVar4,sel_copyWithZone_,0);
                pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
                pvVar5 = _objc_msgSend(pvVar4,sel_detachFromCurrentThread);
                self_00 = cls_NSDictionary;
                puVar12 = PTR_cfstr_HSRecorderPlaybackAttributesKey_003426c8;
                if ((char)pvVar5 != '\0') {
                  dVar6 = 0.0;
                  if (0.0 <= dVar7) {
                    dVar6 = dVar7;
                  }
                  pvVar3 = _objc_msgSend(pvVar3,sel_copyWithStartTime_,dVar6);
                  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
                  pvVar3 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar4,
                                         PTR_cfstr_HSRecorderQTMovieKey_003426c4,pvVar3,puVar12,0);
                  pvVar4 = _objc_msgSend(self,sel_processedInAnotherThreadMovies);
                  _objc_msgSend(pvVar4,sel_addObject_,pvVar3);
                  _objc_msgSend(self->_currentThreadContext,sel_addSoundMovieWithAttributes_,pvVar3)
                  ;
                }
                local_80 = (id)((int)local_80 + 1);
              } while (local_80 < local_9c);
              uVar9 = CONCAT44(local_50,&local_74);
              uVar13 = 0x10;
              local_9c = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,
                                       &local_74,local_50,0x10);
            } while (local_9c != (id)0x0);
          }
          _objc_msgSend(self->_movieLogger,sel_release,uVar9,uVar13);
          self->_movieLogger = (id)0x0;
        }
LAB_0026602f:
        puVar12 = (undefined *)((ulonglong)uVar9 >> 0x20);
        pvVar2 = (id)0x0;
      }
      else {
        uVar9 = 0;
        pvVar2 = _objc_msgSend(cls_QTMovie,sel_movieWithURL_error_,pvVar2,0);
        if (pvVar2 == (id)0x0) goto LAB_0026602f;
        pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,0,(int)((ulonglong)uVar9 >> 0x20));
        _objc_msgSend(pvVar2,sel_setAttribute_forKey_,pvVar3,*(undefined4 *)PTR_00336950);
        pvVar4 = _objc_msgSend(pvVar2,sel_detachFromCurrentThread);
        pvVar3 = (id)0x0;
        if ((char)pvVar4 != '\0') {
          pvVar3 = pvVar2;
        }
        puVar12 = PTR_cfstr_HSRecorderQTMovieKey_003426c4;
        pvVar2 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,pvVar3,
                               PTR_cfstr_HSRecorderQTMovieKey_003426c4);
      }
      _objc_msgSend(self->_currentThreadContext,sel_addSoundMovieWithAttributes_,pvVar2);
      if (self->_useAudioRecordWorkAround == '\0') {
        if (self->_audioOutToInCaptureFileOutput != (id)0x0) {
          return;
        }
        pvVar2 = self->_voiceCaptureFileOutput;
      }
      else {
        if (self->_voiceRecorder != (id)0x0) {
          return;
        }
        pvVar2 = self->_audioOutToInRecorder;
      }
      if (pvVar2 != (id)0x0) {
        return;
      }
      if (self->_movieLogger != (id)0x0) {
        return;
      }
      self_01 = self->_currentThreadContext;
      uVar10 = CONCAT44(puVar12,1);
      op = sel_setAudioCaptirungDidFinish_;
      goto LAB_00265a2a;
    }
    self_01 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,lVar8);
  }
  else {
    uVar13 = (undefined4)((ulonglong)lVar8 >> 0x20);
    pvVar3 = _objc_msgSend(pvVar2,sel_hasSuffix_,&cfstr_voice_aiff);
    lVar8 = CONCAT44(uVar13,&cfstr_captureOutput);
    pvVar4 = _objc_msgSend(HSRecorder_loadSoundMovieWithAttributes,sel_objectForKey_,
                           &cfstr_captureOutput);
    if ((char)pvVar3 == '\0') {
      if ((pvVar4 == self->_audioOutToInRecorder) ||
         (pvVar4 == self->_audioOutToInCaptureFileOutput)) {
        if (self->_useAudioRecordWorkAround == '\0') {
          _objc_msgSend(self->_audioOutToInCaptureSession,sel_stopRunning,lVar8);
          uVar11 = (uint)((ulonglong)lVar8 >> 0x20);
          pvVar3 = _objc_msgSend(self->_audioOutToInCaptureDeviceInput,sel_device);
          pvVar3 = _objc_msgSend(pvVar3,sel_isOpen);
          if ((char)pvVar3 != '\0') {
            pvVar3 = _objc_msgSend(self->_audioOutToInCaptureDeviceInput,sel_device);
            _objc_msgSend(pvVar3,sel_close);
          }
          _objc_msgSend(self->_audioOutToInCaptureSession,sel_removeOutput_,
                        self->_voiceCaptureFileOutput);
          lVar8 = (ulonglong)uVar11 << 0x20;
          _objc_msgSend(self->_audioOutToInCaptureFileOutput,sel_setDelegate_,0);
          _objc_msgSend(self->_audioOutToInCaptureFileOutput,sel_release);
          self->_audioOutToInCaptureFileOutput = (id)0x0;
        }
        else {
          _objc_msgSend(self->_audioOutToInRecorder,sel_release,lVar8);
          self->_audioOutToInRecorder = (id)0x0;
        }
        goto LAB_00265c61;
      }
    }
    else if ((pvVar4 == self->_voiceRecorder) || (pvVar4 == self->_voiceCaptureFileOutput)) {
      if (self->_useAudioRecordWorkAround == '\0') {
        _objc_msgSend(self->_voiceCaptureSession,sel_stopRunning,lVar8);
        uVar11 = (uint)((ulonglong)lVar8 >> 0x20);
        pvVar3 = _objc_msgSend(self->_voiceCaptureDeviceInput,sel_device);
        pvVar3 = _objc_msgSend(pvVar3,sel_isOpen);
        if ((char)pvVar3 != '\0') {
          pvVar3 = _objc_msgSend(self->_voiceCaptureDeviceInput,sel_device);
          _objc_msgSend(pvVar3,sel_close);
        }
        _objc_msgSend(self->_voiceCaptureSession,sel_removeOutput_,self->_voiceCaptureFileOutput);
        lVar8 = (ulonglong)uVar11 << 0x20;
        _objc_msgSend(self->_voiceCaptureFileOutput,sel_setDelegate_,0);
        _objc_msgSend(self->_voiceCaptureFileOutput,sel_release);
        self->_voiceCaptureFileOutput = (id)0x0;
      }
      else {
        _objc_msgSend(self->_voiceRecorder,sel_release,lVar8);
        self->_voiceRecorder = (id)0x0;
      }
      goto LAB_00265c61;
    }
    self_01 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,lVar8);
  }
  uVar10 = ZEXT48(pvVar2);
  op = sel_removeFileAtPath_handler_;
LAB_00265a2a:
  _objc_msgSend(self_01,op,uVar10);
  return;
}

*/
- (void)HSRecorder_loadSoundMovieWithAttributes:(id)aAttributes
{
    NSString *path = [[aAttributes objectForKey:@"outputFileURL"] path];
    if (path != nil) {
        // A captured audio file finished recording: its recorder is torn down and the file is deleted.
        BOOL isVoice = [path hasSuffix:@"voice.aiff"];
        id output = [aAttributes objectForKey:@"captureOutput"];
        if (!isVoice) {
            if (output == _audioOutToInRecorder || output == _audioOutToInCaptureFileOutput) {
                if (!_useAudioRecordWorkAround) {
                    [_audioOutToInCaptureSession stopRunning];
                    if ([[_audioOutToInCaptureDeviceInput device] isOpen]) {
                        [[_audioOutToInCaptureDeviceInput device] close];
                    }
                    [_audioOutToInCaptureSession removeOutput:_voiceCaptureFileOutput];
                    [_audioOutToInCaptureFileOutput setDelegate:nil];
                    [_audioOutToInCaptureFileOutput release];
                    _audioOutToInCaptureFileOutput = nil;
                } else {
                    [_audioOutToInRecorder release];
                    _audioOutToInRecorder = nil;
                }
            }
        } else if (output == _voiceRecorder || output == _voiceCaptureFileOutput) {
            if (!_useAudioRecordWorkAround) {
                [_voiceCaptureSession stopRunning];
                if ([[_voiceCaptureDeviceInput device] isOpen]) {
                    [[_voiceCaptureDeviceInput device] close];
                }
                [_voiceCaptureSession removeOutput:_voiceCaptureFileOutput];
                [_voiceCaptureFileOutput setDelegate:nil];
                [_voiceCaptureFileOutput release];
                _voiceCaptureFileOutput = nil;
            } else {
                [_voiceRecorder release];
                _voiceRecorder = nil;
            }
        }
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        return;
    }
    if (_currentThreadContext == nil) {
        return;
    }
    id soundURL = [aAttributes objectForKey:@"outputFileURL"];
    NSDictionary *movieAttributes = nil;
    if (soundURL == nil) {
        if (_movieLogger != nil) {
            for (HSMoviePlaybackLogItem *item in [_movieLogger log]) {
                double startTime = [item startTime] - _capturingStartTime;
                QTMovie *movie = [[[[item movie] QTMovie] copyWithZone:NULL] autorelease];
                if ([movie detachFromCurrentThread]) {
                    id playbackItem = [[item copyWithStartTime:MAX(0.0, startTime)] autorelease];
                    NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:movie, @"HSRecorderQTMovieKey", playbackItem, @"HSRecorderPlaybackAttributesKey", nil];
                    [[self processedInAnotherThreadMovies] addObject:entry];
                    [_currentThreadContext addSoundMovieWithAttributes:entry];
                }
            }
            [_movieLogger release];
            _movieLogger = nil;
        }
    } else {
        QTMovie *movie = [QTMovie movieWithURL:soundURL error:NULL];
        if (movie != nil) {
            [movie setAttribute:[NSNumber numberWithBool:NO] forKey:QTMovieIsActiveAttribute];
            movieAttributes = [NSDictionary dictionaryWithObject:([movie detachFromCurrentThread] ? movie : [NSNull null]) forKey:@"HSRecorderQTMovieKey"];
        }
    }
    [_currentThreadContext addSoundMovieWithAttributes:movieAttributes];
    id otherRecorder;
    if (!_useAudioRecordWorkAround) {
        if (_audioOutToInCaptureFileOutput != nil) {
            return;
        }
        otherRecorder = _voiceCaptureFileOutput;
    } else {
        if (_voiceRecorder != nil) {
            return;
        }
        otherRecorder = _audioOutToInRecorder;
    }
    if (otherRecorder != nil || _movieLogger != nil) {
        return;
    }
    [_currentThreadContext setAudioCaptirungDidFinish:YES];
}

- (id)processedInAnotherThreadMovies
{
    id pvVar1;

    pvVar1 = _processedInAnotherThreadMovies;
    if (pvVar1 == nil) {
        pvVar1 = [[NSMutableArray alloc] init];
        _processedInAnotherThreadMovies = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026610c @ 0026610c, 89 bytes * /

void FUN_0026610c(HSRecorder *self,SEL _cmd,id audioRecorder,id willStartRecordingToFileAtURL)

{
  double dVar1;
  
  _pthread_mutex_lock((pthread_mutex_t *)&self->_capturingPreviousTimeMutex);
  if ((self->_capturingPreviousTime == -1.0) && (!NAN(self->_capturingPreviousTime))) {
    dVar1 = _objc_msgSend_fpret(cls_NSDate,sel_timeIntervalSinceReferenceDate);
    self->_capturingPreviousTime = dVar1;
  }
  _pthread_mutex_unlock((pthread_mutex_t *)&self->_capturingPreviousTimeMutex);
  return;
}

*/
- (void)audioRecorder:(id)aRecorder willStartRecordingToFileAtURL:(id)aURL
{
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    if (_capturingPreviousTime == -1.0) {
        _capturingPreviousTime = [NSDate timeIntervalSinceReferenceDate];
    }
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00266165 @ 00266165, 89 bytes * /

void FUN_00266165(HSRecorder *self,SEL _cmd,id captureOutput,id willStartRecordingToOutputFileAtURL,
                 id forConnections)

{
  double dVar1;
  
  _pthread_mutex_lock((pthread_mutex_t *)&self->_capturingPreviousTimeMutex);
  if ((self->_capturingPreviousTime == -1.0) && (!NAN(self->_capturingPreviousTime))) {
    dVar1 = _objc_msgSend_fpret(cls_NSDate,sel_timeIntervalSinceReferenceDate);
    self->_capturingPreviousTime = dVar1;
  }
  _pthread_mutex_unlock((pthread_mutex_t *)&self->_capturingPreviousTimeMutex);
  return;
}

*/
- (void)captureOutput:(id)aOutput willStartRecordingToOutputFileAtURL:(id)aURL forConnections:(id)aConnections
{
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    if (_capturingPreviousTime == -1.0) {
        _capturingPreviousTime = [NSDate timeIntervalSinceReferenceDate];
    }
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002661be @ 002661be, 545 bytes * /

void FUN_002661be(HSRecorder *self,SEL _cmd,id capturingDataSource,CVBuffer *didOutputFrame,
                 double atTime)

{
  opaque_pthread_mutex_t *poVar1;
  double dVar2;
  HSThreadContext *self_00;
  undefined4 *puVar3;
  
  puVar3 = (undefined4 *)&stack0xffffffa4;
  if (didOutputFrame == (CVBuffer *)0x0) {
    return;
  }
  _CVPixelBufferRetain();
  if ((self->_capturingStartTime == -1.0) && (!NAN(self->_capturingStartTime))) {
    self->_capturingStartTime = atTime;
    self->_currentFrameBuffer = didOutputFrame;
    self->_framesCounter = 0;
    if (self->_voiceCaptureFileOutput != (id)0x0) {
      return;
    }
    self->_capturingPreviousTime = atTime;
    return;
  }
  poVar1 = &self->_capturingPreviousTimeMutex;
  _pthread_mutex_lock((pthread_mutex_t *)poVar1);
  dVar2 = self->_capturingPreviousTime;
  _pthread_mutex_unlock((pthread_mutex_t *)poVar1);
  if ((dVar2 == -1.0) && (!NAN(dVar2))) {
    _CVPixelBufferRelease();
    self->_currentFrameBuffer = didOutputFrame;
    return;
  }
  if ((atTime - self->_capturingStartTime) * self->_framesPerSecondLimit <=
      (double)((ulonglong)(self->_framesCounter + 2) | 0x4330000000000000) - 4503599627370496.0) {
    if (atTime - dVar2 < 1.0 / self->_framesPerSecondLimit) goto LAB_002663c0;
    _objc_msgSend(self->_currentThreadContext,
                  sel_removeFrameItemWithSmallestDuration_removedLastFrameDuration_);
  }
  self_00 = self->_currentThreadContext;
  _llroundf();
  _QTMakeTime();
  puVar3 = (undefined4 *)&stack0xffffffa0;
  _objc_msgSend(self_00,sel_addNewItemWithFrameBuffer_duration_isLastFrame_);
  _pthread_mutex_lock((pthread_mutex_t *)poVar1);
  self->_capturingPreviousTime = atTime;
  _pthread_mutex_unlock((pthread_mutex_t *)poVar1);
  self->_framesCounter = self->_framesCounter + 1;
LAB_002663c0:
  *puVar3 = self->_currentFrameBuffer;
  puVar3[-1] = 0x2663ce;
  _CVPixelBufferRelease();
  self->_currentFrameBuffer = didOutputFrame;
  return;
}

*/
- (void)capturingDataSource:(id)aSource didOutputFrame:(struct __CVBuffer *)aFrame atTime:(double)aTime
{
    if (aFrame == NULL) {
        return;
    }
    CVPixelBufferRetain(aFrame);
    if (_capturingStartTime == -1.0) {
        _capturingStartTime = aTime;
        _currentFrameBuffer = aFrame;
        _framesCounter = 0;
        if (_voiceCaptureFileOutput == nil) {
            _capturingPreviousTime = aTime;
        }
        return;
    }
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    double previousTime = _capturingPreviousTime;
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
    if (previousTime == -1.0) {
        CVPixelBufferRelease(_currentFrameBuffer);
        _currentFrameBuffer = aFrame;
        return;
    }
    BOOL addFrame = YES;
    if ((aTime - _capturingStartTime) * _framesPerSecondLimit <= (double)(_framesCounter + 2)) {
        // Frames come in faster than the limit allows: drop the shortest queued frame to make room.
        if (aTime - previousTime < 1.0 / _framesPerSecondLimit) {
            addFrame = NO;
        } else {
            double removedLastFrameDuration = 0.0;
            if ([_currentThreadContext removeFrameItemWithSmallestDuration:1.0 / _framesPerSecondLimit removedLastFrameDuration:&removedLastFrameDuration]) {
                previousTime -= removedLastFrameDuration;
            }
        }
    }
    if (addFrame) {
        struct HyperStudio_anon7 duration = { llroundf((float)((aTime - previousTime) * 600.0)), 600, 0 };
        [_currentThreadContext addNewItemWithFrameBuffer:_currentFrameBuffer duration:duration isLastFrame:NO];
        pthread_mutex_lock(&_capturingPreviousTimeMutex);
        _capturingPreviousTime = aTime;
        pthread_mutex_unlock(&_capturingPreviousTimeMutex);
        _framesCounter++;
    }
    CVPixelBufferRelease(_currentFrameBuffer);
    _currentFrameBuffer = aFrame;
}

- (void)setLazyMovieCreation:(BOOL)aCreation
{
    _lazyMovieCreation = aCreation;
}

- (BOOL)isLazyMovieCreation
{
    return _lazyMovieCreation;
}

- (void)setAudioOutToInCaptureDevice:(id)aDevice
{
    if (_audioOutToInCaptureDevice != aDevice) {
        [_audioOutToInCaptureDevice release];
        _audioOutToInCaptureDevice = [aDevice retain];
    }
}

- (id)audioOutToInCaptureDevice:(id)aDevice
{
    return [_audioOutToInCaptureDeviceInput device];
}

- (void)setAudioVoiceCaptureDevice:(id)aDevice
{
    if (_voiceCaptureDevice != aDevice) {
        [_voiceCaptureDevice release];
        _voiceCaptureDevice = [aDevice retain];
    }
}

- (id)audioVoiceCaptureDevice
{
    return [_voiceCaptureDeviceInput device];
}

- (void)setMovieSize:(NSSize)aSize
{
    (_movieSize).width = aSize.width;
    (_movieSize).height = aSize.height;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00264eb0 @ 00264eb0, 20 bytes * /

ulonglong FUN_00264eb0(HSRecorder *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_movieSize).width;
  uVar1._4_4_ = (self->_movieSize).height;
  return uVar1;
}

*/
- (NSSize)movieSize
{
    return _movieSize;
}

- (void)setRoundedCornersForMovie:(BOOL)aMovie
{
    _roundedCornersForMovie = aMovie;
}

- (BOOL)roundedCornersForMovie
{
    return _roundedCornersForMovie;
}

- (void)cancelRecording
{
    if (_currentThreadContext != nil) {
        [self HSRecorder_cancelRecording];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00266505 @ 00266505, 747 bytes * /

void FUN_00266505(HSRecorder *self,SEL _cmd)

{
  double dVar1;
  HSThreadContext *pHVar2;
  id pvVar3;
  id pvVar4;
  double *pdVar5;
  undefined4 *puVar6;
  SEL op;
  
  puVar6 = (undefined4 *)&stack0xffffffa4;
  _objc_msgSend(self->_dataSource,sel_stopCapturingForConsumer_);
  _objc_msgSend_fpret(cls_NSDate,sel_timeIntervalSinceReferenceDate);
  if (self->_useAudioRecordWorkAround == '\0') {
    if (self->_voiceCaptureFileOutput != (id)0x0) {
      _objc_msgSend(self->_voiceCaptureFileOutput,sel_recordToOutputFileURL_bufferDestination_);
    }
    pvVar3 = self->_audioOutToInCaptureFileOutput;
    op = sel_recordToOutputFileURL_bufferDestination_;
    if (pvVar3 == (id)0x0) goto LAB_0026662d;
  }
  else {
    pvVar3 = _objc_msgSend(self->_voiceRecorder,sel_isRecording);
    if ((char)pvVar3 != '\0') {
      _objc_msgSend(self->_voiceRecorder,sel_stopRecording);
    }
    pvVar3 = _objc_msgSend(self->_audioOutToInRecorder,sel_isRecording);
    if ((char)pvVar3 == '\0') goto LAB_0026662d;
    pvVar3 = self->_audioOutToInRecorder;
    op = sel_stopRecording;
  }
  _objc_msgSend(pvVar3,op);
LAB_0026662d:
  if (self->_movieLogger != (id)0x0) {
    _objc_msgSend(self->_movieLogger,sel_stopLogging);
    _objc_msgSend(self,sel_HSRecorder_loadSoundMovieWithAttributes_);
  }
  _pthread_mutex_lock((pthread_mutex_t *)&self->_capturingPreviousTimeMutex);
  pdVar5 = &self->_capturingPreviousTime;
  if (self->_capturingPreviousTime == -1.0) {
    pdVar5 = &self->_capturingStartTime;
  }
  dVar1 = *pdVar5;
  *(undefined4 *)((int)&self->_capturingPreviousTime + 4) = 0xbff00000;
  *(undefined4 *)&self->_capturingPreviousTime = 0;
  _pthread_mutex_unlock((pthread_mutex_t *)&self->_capturingPreviousTimeMutex);
  if (dVar1 != -1.0) {
    pHVar2 = self->_currentThreadContext;
    _llroundf();
    _QTMakeTime();
    puVar6 = (undefined4 *)&stack0xffffffa0;
    _objc_msgSend(pHVar2,sel_addNewItemWithFrameBuffer_duration_isLastFrame_);
    _CVPixelBufferRelease();
    self->_currentFrameBuffer = (CVBuffer *)0x0;
  }
  pvVar3 = self->_delegate;
  puVar6[2] = sel_recorder_willFinishRecordingToOutputFileAtPath_dueToError_;
  puVar6[1] = sel_respondsToSelector_;
  *puVar6 = pvVar3;
  puVar6[-1] = 0x2667a7;
  pvVar3 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  if ((char)pvVar3 != '\0') {
    pvVar3 = self->_delegate;
    pHVar2 = self->_currentThreadContext;
    puVar6[1] = sel_outputMovieFilePath;
    *puVar6 = pHVar2;
    puVar6[-1] = 0x2667c6;
    pvVar4 = _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
    puVar6[3] = pvVar4;
    puVar6[2] = self;
    puVar6[1] = sel_recorder_willFinishRecordingToOutputFileAtPath_dueToError_;
    *puVar6 = pvVar3;
    puVar6[4] = 0;
    puVar6[-1] = 0x2667e8;
    _objc_msgSend((id)*puVar6,(SEL)puVar6[1]);
  }
  return;
}

*/
- (void)stopRecording
{
    [_dataSource stopCapturingForConsumer:self];
    double now = [NSDate timeIntervalSinceReferenceDate];
    if (!_useAudioRecordWorkAround) {
        if (_voiceCaptureFileOutput != nil) {
            [_voiceCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
        }
        if (_audioOutToInCaptureFileOutput != nil) {
            [_audioOutToInCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
        }
    } else {
        if ([_voiceRecorder isRecording]) {
            [_voiceRecorder stopRecording];
        }
        if ([_audioOutToInRecorder isRecording]) {
            [_audioOutToInRecorder stopRecording];
        }
    }
    if (_movieLogger != nil) {
        [_movieLogger stopLogging];
        [self HSRecorder_loadSoundMovieWithAttributes:nil];
    }
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    double lastFrameTime = (_capturingPreviousTime == -1.0) ? _capturingStartTime : _capturingPreviousTime;
    _capturingPreviousTime = -1.0;
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
    if (lastFrameTime != -1.0) {
        struct HyperStudio_anon7 duration = { llroundf((float)((now - lastFrameTime) * 600.0)), 600, 0 };
        [_currentThreadContext addNewItemWithFrameBuffer:_currentFrameBuffer duration:duration isLastFrame:YES];
        CVPixelBufferRelease(_currentFrameBuffer);
        _currentFrameBuffer = NULL;
    }
    if ([_delegate respondsToSelector:@selector(recorder:willFinishRecordingToOutputFileAtPath:dueToError:)]) {
        [_delegate recorder:self willFinishRecordingToOutputFileAtPath:[_currentThreadContext outputMovieFilePath] dueToError:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002667f0 @ 002667f0, 908 bytes * /

BOOL FUN_002667f0(HSRecorder *self,SEL _cmd)

{
  BOOL BVar1;
  id pvVar2;
  id self_00;
  id self_01;
  id pvVar3;
  HSRecorder *pHVar4;
  undefined4 uVar5;
  
  pHVar4 = self;
  _objc_msgSend(self->_dataSource,sel_stopCapturingForConsumer_,self);
  if (self->_useAudioRecordWorkAround == '\0') {
    if (self->_voiceCaptureFileOutput != (id)0x0) {
      _objc_msgSend(self->_voiceCaptureFileOutput,sel_recordToOutputFileURL_bufferDestination_,0,2);
      _objc_msgSend(self->_voiceCaptureSession,sel_removeOutput_,self->_voiceCaptureFileOutput);
      pHVar4 = (HSRecorder *)0x0;
      _objc_msgSend(self->_voiceCaptureFileOutput,sel_setDelegate_,0);
      _objc_msgSend(self->_voiceCaptureFileOutput,sel_release);
      self->_voiceCaptureFileOutput = (id)0x0;
    }
    if (self->_audioOutToInCaptureFileOutput != (id)0x0) {
      _objc_msgSend(self->_audioOutToInCaptureFileOutput,
                    sel_recordToOutputFileURL_bufferDestination_,0,2);
      _objc_msgSend(self->_audioOutToInCaptureSession,sel_removeOutput_,
                    self->_audioOutToInCaptureFileOutput);
      pHVar4 = (HSRecorder *)0x0;
      _objc_msgSend(self->_audioOutToInCaptureFileOutput,sel_setDelegate_,0);
      _objc_msgSend(self->_audioOutToInCaptureFileOutput,sel_release);
      self->_audioOutToInCaptureFileOutput = (id)0x0;
    }
  }
  else {
    if (self->_voiceRecorder != (id)0x0) {
      _objc_msgSend(self->_voiceRecorder,sel_stopRecording,pHVar4);
      pHVar4 = (HSRecorder *)0x0;
      _objc_msgSend(self->_voiceRecorder,sel_setDelegate_,0);
      _objc_msgSend(self->_voiceRecorder,sel_release);
      self->_voiceRecorder = (id)0x0;
    }
    if (self->_audioOutToInRecorder != (id)0x0) {
      _objc_msgSend(self->_audioOutToInRecorder,sel_stopRecording,pHVar4);
      pHVar4 = (HSRecorder *)0x0;
      _objc_msgSend(self->_audioOutToInRecorder,sel_setDelegate_,0);
      _objc_msgSend(self->_audioOutToInRecorder,sel_release);
      self->_audioOutToInRecorder = (id)0x0;
    }
  }
  if (self->_movieLogger != (id)0x0) {
    _objc_msgSend(self->_movieLogger,sel_stopLogging,pHVar4);
    _objc_msgSend(self->_movieLogger,sel_release);
    self->_movieLogger = (id)0x0;
  }
  _objc_msgSend(self->_currentThreadContext,sel_cancelProcessing,pHVar4);
  pvVar2 = _objc_msgSend(self->_currentThreadContext,sel_outputMovieFilePath);
  self_00 = _objc_msgSend(pvVar2,sel_retain);
  pvVar2 = _objc_msgSend(self->_currentThreadContext,sel_videoFramesAttributes);
  self_01 = _objc_msgSend(pvVar2,sel_retain);
  _objc_msgSend(self->_currentThreadContext,sel_release);
  self->_currentThreadContext = (HSThreadContext *)0x0;
  _pthread_mutex_lock((pthread_mutex_t *)&self->_capturingPreviousTimeMutex);
  *(undefined4 *)((int)&self->_capturingPreviousTime + 4) = 0xbff00000;
  *(undefined4 *)&self->_capturingPreviousTime = 0;
  _pthread_mutex_unlock((pthread_mutex_t *)&self->_capturingPreviousTimeMutex);
  _CVPixelBufferRelease(self->_currentFrameBuffer);
  self->_currentFrameBuffer = (CVBuffer *)0x0;
  *(undefined4 *)((int)&self->_capturingStartTime + 4) = 0xbff00000;
  *(undefined4 *)&self->_capturingStartTime = 0;
  uVar5 = 0;
  pvVar2 = self_01;
  pvVar3 = _objc_msgSend(self,sel_HSRecorder_prepareForRecordingWithAttributes_openAudioDevice_,
                         self_01,0);
  BVar1 = '\0';
  if ((char)pvVar3 != '\0') {
    pvVar2 = self_00;
    pvVar3 = _objc_msgSend(self,sel_startRecordingToOutputFilePath_,self_00,uVar5);
    BVar1 = (BOOL)pvVar3;
  }
  _objc_msgSend(self_00,sel_release,pvVar2,uVar5);
  _objc_msgSend(self_01,sel_release);
  return BVar1;
}

*/
- (BOOL)restartRecording
{
    [_dataSource stopCapturingForConsumer:self];
    if (!_useAudioRecordWorkAround) {
        if (_voiceCaptureFileOutput != nil) {
            [_voiceCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
            [_voiceCaptureSession removeOutput:_voiceCaptureFileOutput];
            [_voiceCaptureFileOutput setDelegate:nil];
            [_voiceCaptureFileOutput release];
            _voiceCaptureFileOutput = nil;
        }
        if (_audioOutToInCaptureFileOutput != nil) {
            [_audioOutToInCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
            [_audioOutToInCaptureSession removeOutput:_audioOutToInCaptureFileOutput];
            [_audioOutToInCaptureFileOutput setDelegate:nil];
            [_audioOutToInCaptureFileOutput release];
            _audioOutToInCaptureFileOutput = nil;
        }
    } else {
        if (_voiceRecorder != nil) {
            [_voiceRecorder stopRecording];
            [_voiceRecorder setDelegate:nil];
            [_voiceRecorder release];
            _voiceRecorder = nil;
        }
        if (_audioOutToInRecorder != nil) {
            [_audioOutToInRecorder stopRecording];
            [_audioOutToInRecorder setDelegate:nil];
            [_audioOutToInRecorder release];
            _audioOutToInRecorder = nil;
        }
    }
    if (_movieLogger != nil) {
        [_movieLogger stopLogging];
        [_movieLogger release];
        _movieLogger = nil;
    }
    [_currentThreadContext cancelProcessing];
    NSString *outputPath = [[_currentThreadContext outputMovieFilePath] retain];
    NSDictionary *attributes = [[_currentThreadContext videoFramesAttributes] retain];
    [_currentThreadContext release];
    _currentThreadContext = nil;
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    _capturingPreviousTime = -1.0;
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
    CVPixelBufferRelease(_currentFrameBuffer);
    _currentFrameBuffer = NULL;
    _capturingStartTime = -1.0;
    BOOL restarted = NO;
    if ([self HSRecorder_prepareForRecordingWithAttributes:attributes openAudioDevice:NO]) {
        restarted = [self startRecordingToOutputFilePath:outputPath];
    }
    [outputPath release];
    [attributes release];
    return restarted;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00266b7c @ 00266b7c, 541 bytes * /

BOOL FUN_00266b7c(HSRecorder *self,SEL _cmd,id startRecordingToOutputFilePath)

{
  HSThreadContext *self_00;
  undefined *puVar1;
  id pvVar2;
  HSRecorder *pHVar3;
  HSRecorder *pHVar4;
  SEL pcVar5;
  undefined4 extraout_EDX;
  byte bVar6;
  byte local_14;
  
  if ((startRecordingToOutputFilePath == (id)0x0) || (pvVar2 = self->_dataSource, pvVar2 == (id)0x0)
     ) {
    return '\0';
  }
  *(undefined4 *)((int)&self->_capturingStartTime + 4) = 0xbff00000;
  *(undefined4 *)&self->_capturingStartTime = 0;
  *(undefined4 *)((int)&self->_capturingPreviousTime + 4) = 0xbff00000;
  *(undefined4 *)&self->_capturingPreviousTime = 0;
  pHVar3 = self;
  _objc_msgSend(pvVar2,sel_startCapturingForConsumer_,self);
  puVar1 = cls_NSURL;
  if ((self->_voiceRecorder == (id)0x0) && (self->_voiceCaptureFileOutput == (id)0x0)) {
LAB_00266be4:
    pHVar4 = pHVar3;
    local_14 = 0;
  }
  else {
    pvVar2 = _objc_msgSend(self->_currentThreadContext,sel_workFolderPath,pHVar3);
    pHVar3 = _objc_msgSend(pvVar2,sel_stringByAppendingPathComponent_,&cfstr_voice_aiff);
    pHVar4 = _objc_msgSend(puVar1,sel_fileURLWithPath_,pHVar3);
    if (pHVar4 == (HSRecorder *)0x0) goto LAB_00266be4;
    if (self->_useAudioRecordWorkAround == '\0') {
      pvVar2 = self->_voiceCaptureFileOutput;
      pcVar5 = sel_recordToOutputFileURL_;
    }
    else {
      pvVar2 = self->_voiceRecorder;
      pcVar5 = sel_startRecordingToFileAtURL_;
    }
    _objc_msgSend(pvVar2,pcVar5,pHVar4);
    local_14 = 1;
  }
  puVar1 = cls_NSURL;
  if ((self->_audioOutToInRecorder == (id)0x0) && (self->_audioOutToInCaptureFileOutput == (id)0x0))
  {
    pvVar2 = self->_movieLogger;
    pcVar5 = sel_startLogging;
    pHVar3 = pHVar4;
    if (pvVar2 == (id)0x0) {
LAB_00266ce5:
      pHVar4 = pHVar3;
      bVar6 = 0;
      goto LAB_00266d37;
    }
  }
  else {
    pvVar2 = _objc_msgSend(self->_currentThreadContext,sel_workFolderPath,pHVar4);
    pHVar3 = _objc_msgSend(pvVar2,sel_stringByAppendingPathComponent_,&cfstr_audioOutToIn_aiff);
    pHVar4 = _objc_msgSend(puVar1,sel_fileURLWithPath_,pHVar3);
    if (pHVar4 == (HSRecorder *)0x0) goto LAB_00266ce5;
    if (self->_useAudioRecordWorkAround == '\0') {
      pvVar2 = self->_audioOutToInCaptureFileOutput;
      pcVar5 = sel_recordToOutputFileURL_;
    }
    else {
      pvVar2 = self->_audioOutToInRecorder;
      pcVar5 = sel_startRecordingToFileAtURL_;
    }
  }
  _objc_msgSend(pvVar2,pcVar5,pHVar4);
  bVar6 = 1;
LAB_00266d37:
  self_00 = self->_currentThreadContext;
  pvVar2 = _objc_msgSend(self,sel_movieSize,pHVar4);
  _objc_msgSend(self_00,
                sel_capturingDidStartForOutputFilePath_isAudioCapturingUsed_isRoundedCorners_movieSize_
                ,startRecordingToOutputFilePath,(int)(char)(bVar6 | local_14),
                (int)self->_roundedCornersForMovie,pvVar2,extraout_EDX);
  return '\x01';
}

*/
- (BOOL)startRecordingToOutputFilePath:(id)aPath
{
    if (aPath == nil || _dataSource == nil) {
        return NO;
    }
    _capturingStartTime = -1.0;
    _capturingPreviousTime = -1.0;
    [_dataSource startCapturingForConsumer:self];
    BOOL voiceUsed = NO;
    if (_voiceRecorder != nil || _voiceCaptureFileOutput != nil) {
        NSURL *url = [NSURL fileURLWithPath:[[_currentThreadContext workFolderPath] stringByAppendingPathComponent:@"voice.aiff"]];
        if (url != nil) {
            if (_useAudioRecordWorkAround) {
                [_voiceRecorder startRecordingToFileAtURL:url];
            } else {
                [_voiceCaptureFileOutput recordToOutputFileURL:url];
            }
            voiceUsed = YES;
        }
    }
    BOOL audioOutToInUsed = NO;
    if (_audioOutToInRecorder != nil || _audioOutToInCaptureFileOutput != nil) {
        NSURL *url = [NSURL fileURLWithPath:[[_currentThreadContext workFolderPath] stringByAppendingPathComponent:@"audioOutToIn.aiff"]];
        if (url != nil) {
            if (_useAudioRecordWorkAround) {
                [_audioOutToInRecorder startRecordingToFileAtURL:url];
            } else {
                [_audioOutToInCaptureFileOutput recordToOutputFileURL:url];
            }
            audioOutToInUsed = YES;
        }
    } else if (_movieLogger != nil) {
        [_movieLogger startLogging];
        audioOutToInUsed = YES;
    }
    [_currentThreadContext capturingDidStartForOutputFilePath:aPath isAudioCapturingUsed:(voiceUsed || audioOutToInUsed) isRoundedCorners:_roundedCornersForMovie movieSize:[self movieSize]];
    return YES;
}

- (BOOL)prepareToRecordWithAttributes:(id)aAttributes
{
    id pvVar1;

    if ((_currentThreadContext != nil) && (pvVar1 = [_currentThreadContext outputMovieFilePath], pvVar1 == nil )) {
        [_currentThreadContext setVideoFramesQueueLimit:_framesQueueLimit]
        ;
        return YES;
    }
    return (BOOL)[self HSRecorder_prepareForRecordingWithAttributes:aAttributes openAudioDevice:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00266e18 @ 00266e18, 1618 bytes * /

BOOL FUN_00266e18(HSRecorder *self,SEL _cmd,id HSRecorder_prepareForRecordingWithAttributes,
                 BOOL openAudioDevice)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  HSThreadContext *self_00;
  HSRecorder *pHVar5;
  HSRecorder *self_01;
  SEL pcVar6;
  HSRecorder *pHVar7;
  undefined *puVar8;
  HSThreadContext *pHVar9;
  int iVar10;
  undefined4 uVar11;
  undefined4 uVar12;
  
  pvVar1 = _objc_msgSend(HSRecorder_prepareForRecordingWithAttributes,sel_objectForKey_,
                         &cfstr_HSVideoCodecTypeAttribute);
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_class);
  pvVar3 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
  if (((char)pvVar3 == '\0') ||
     (pvVar3 = _objc_msgSend(pvVar1,sel_unsignedIntValue,pvVar2), puVar8 = cls_NSString,
     pvVar3 == (id)0x0)) {
    pcVar4 = &cfstr_mp4v;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_unsignedIntValue,pvVar2);
    pcVar4 = _objc_msgSend(puVar8,sel_extraStringWithFourCharCode_,pvVar1);
  }
  pvVar1 = _objc_msgSend(HSRecorder_prepareForRecordingWithAttributes,sel_objectForKey_,
                         &cfstr_HSVideoCodecQualityAttribute);
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_class);
  pvVar3 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
  if (((char)pvVar3 == '\0') ||
     (pvVar2 = _objc_msgSend(pvVar1,sel_unsignedIntValue,pvVar2), pvVar2 == (id)0x0)) {
    pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedInt_,0x300);
  }
  uVar11 = *(undefined4 *)PTR_00336904;
  uVar12 = 0;
  pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,pcVar4,
                         *(undefined4 *)PTR_00336908,pvVar1,uVar11,0);
  pvVar2 = _objc_msgSend(cls_HSThreadContext,sel_alloc);
  self_00 = _objc_msgSend(pvVar2,sel_initWithVideoFramesAttributes_delegate_,pvVar1,self);
  if (self_00 == (HSThreadContext *)0x0) {
    return '\0';
  }
  iVar10 = 0;
  puVar8 = sel_processingThreadRoutine_;
  pHVar9 = self_00;
  _objc_msgSend(cls_NSThread,sel_detachNewThreadSelector_toTarget_withObject_,
                sel_processingThreadRoutine_,self_00,0,uVar11,uVar12);
  pvVar1 = _objc_msgSend(self_00,sel_isProcessingThreadRoutineStarted);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self_00,sel_release,puVar8,pHVar9,iVar10);
    return '\0';
  }
  self->_currentThreadContext = self_00;
  _objc_msgSend(self_00,sel_setVideoFramesQueueLimit_,self->_framesQueueLimit,pHVar9,iVar10);
  pHVar7 = (HSRecorder *)(int)self->_lazyMovieCreation;
  _objc_msgSend(self->_currentThreadContext,sel_setLazyMovieCreation_,pHVar7);
  if (self->_useAudioRecordWorkAround == '\0') {
    pvVar1 = _objc_msgSend(HSRecorder_prepareForRecordingWithAttributes,sel_objectForKey_,
                           &cfstr_HSAudioCompressionTypeAttribute,pHVar9,iVar10);
    pHVar7 = _objc_msgSend(cls_NSString,sel_class);
    pvVar2 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pHVar7);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(pvVar1,sel_length,pHVar7);
    }
    pHVar5 = self->_voiceCaptureSession;
    if (pHVar5 == (HSRecorder *)0x0) {
      pHVar5 = _objc_msgSend(cls_QTCaptureSession,sel_new,pHVar7);
      self->_voiceCaptureSession = pHVar5;
    }
    if (pHVar5 != (HSRecorder *)0x0) {
      pHVar9 = self->_voiceCaptureDevice;
      iVar10 = (int)openAudioDevice;
      pvVar1 = _objc_msgSend(self,sel_HSRecorder_setupAudioDeviceInputForSession_device_openDevice_,
                             pHVar5,pHVar9,iVar10);
      pHVar7 = pHVar5;
      if (((char)pvVar1 != '\0') &&
         (self_01 = _objc_msgSend(cls_QTCaptureMovieFileOutput,sel_new,pHVar5,pHVar9,iVar10),
         pHVar7 = pHVar5, self_01 != (HSRecorder *)0x0)) {
        pHVar9 = (HSThreadContext *)0x0;
        pHVar7 = self_01;
        pvVar1 = _objc_msgSend(self->_voiceCaptureSession,sel_addOutput_error_,self_01,0,iVar10);
        pcVar6 = sel_release;
        if ((char)pvVar1 != '\0') {
          FUN_00267c9e();
          self->_voiceCaptureFileOutput = self_01;
          pHVar7 = self;
          _objc_msgSend(self_01,sel_setDelegate_,self,pHVar9,iVar10);
          self_01 = self->_voiceCaptureSession;
          pcVar6 = sel_startRunning;
        }
        _objc_msgSend(self_01,pcVar6,pHVar7,pHVar9,iVar10);
      }
    }
    pvVar1 = _objc_msgSend(self,sel_audioDeviceSwapper,pHVar7,pHVar9,iVar10);
    pvVar1 = _objc_msgSend(pvVar1,sel_status);
    if (pvVar1 != (id)0x1) goto LAB_00267415;
    pvVar1 = self->_audioOutToInCaptureSession;
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_QTCaptureSession,sel_new,pHVar7,pHVar9,iVar10);
      self->_audioOutToInCaptureSession = pvVar1;
    }
    if (pvVar1 == (id)0x0) {
      return '\0';
    }
    pvVar2 = self->_audioOutToInCaptureDevice;
    iVar10 = (int)openAudioDevice;
    pvVar3 = _objc_msgSend(self,sel_HSRecorder_setupAudioDeviceInputForSession_device_openDevice_,
                           pvVar1,pvVar2,iVar10);
    if ((char)pvVar3 == '\0') {
      return '\0';
    }
    pHVar5 = _objc_msgSend(cls_QTCaptureMovieFileOutput,sel_new,pvVar1,pvVar2,iVar10);
    if (pHVar5 == (HSRecorder *)0x0) {
      return '\0';
    }
    pHVar9 = (HSThreadContext *)0x0;
    pHVar7 = pHVar5;
    pvVar1 = _objc_msgSend(self->_audioOutToInCaptureSession,sel_addOutput_error_,pHVar5,0,iVar10);
    pcVar6 = sel_release;
    if ((char)pvVar1 != '\0') {
      FUN_00267c9e();
      self->_audioOutToInCaptureFileOutput = pHVar5;
      pHVar7 = self;
      _objc_msgSend(pHVar5,sel_setDelegate_,self,pHVar9,iVar10);
      pHVar5 = self->_audioOutToInCaptureSession;
      pcVar6 = sel_startRunning;
    }
  }
  else {
    if (self->_voiceCaptureDevice != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_HSAudioRecorder,sel_alloc,pHVar7,pHVar9,iVar10);
      pvVar2 = _objc_msgSend(self->_voiceCaptureDevice,sel_uniqueID);
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithAudioDeviceUID_,pvVar2);
      self->_voiceRecorder = pvVar1;
      if (pvVar1 == (id)0x0) {
        return '\x01';
      }
      pHVar7 = self;
      _objc_msgSend(pvVar1,sel_setDelegate_,self);
    }
    if (self->_audioOutToInCaptureDevice == (id)0x0) goto LAB_00267415;
    pvVar1 = _objc_msgSend(cls_HSAudioRecorder,sel_alloc,pHVar7);
    pvVar2 = _objc_msgSend(self->_audioOutToInCaptureDevice,sel_uniqueID);
    pHVar5 = _objc_msgSend(pvVar1,sel_initWithAudioDeviceUID_,pvVar2);
    self->_audioOutToInRecorder = pHVar5;
    pcVar6 = sel_setDelegate_;
    pHVar7 = self;
    if (pHVar5 == (HSRecorder *)0x0) {
      return '\x01';
    }
  }
  _objc_msgSend(pHVar5,pcVar6,pHVar7,pHVar9);
LAB_00267415:
  if (self->_audioOutToInCaptureDevice != (id)0x0) {
    return '\x01';
  }
  _objc_msgSend(self->_movieLogger,sel_release,pHVar7);
  pvVar1 = _objc_msgSend(cls_HSMoviePlaybackLogger,sel_new);
  self->_movieLogger = pvVar1;
  return '\x01';
}

*/
- (BOOL)HSRecorder_prepareForRecordingWithAttributes:(id)aAttributes openAudioDevice:(BOOL)aDevice
{
    id codecType = [aAttributes objectForKey:@"HSVideoCodecTypeAttribute"];
    NSString *codec = @"mp4v";
    if ([codecType isKindOfClass:[NSNumber class]] && [codecType unsignedIntValue] != 0) {
        codec = [NSString extraStringWithFourCharCode:[codecType unsignedIntValue]];
    }
    id codecQuality = [aAttributes objectForKey:@"HSVideoCodecQualityAttribute"];
    if (![codecQuality isKindOfClass:[NSNumber class]] || [codecQuality unsignedIntValue] == 0) {
        codecQuality = [NSNumber numberWithUnsignedInt:0x300];
    }
    NSDictionary *videoAttributes = [NSDictionary dictionaryWithObjectsAndKeys:codec, QTAddImageCodecType, codecQuality, QTAddImageCodecQuality, nil];
    HSThreadContext *context = [[HSThreadContext alloc] initWithVideoFramesAttributes:videoAttributes delegate:self];
    if (context == nil) {
        return NO;
    }
    [NSThread detachNewThreadSelector:@selector(processingThreadRoutine:) toTarget:context withObject:nil];
    if (![context isProcessingThreadRoutineStarted]) {
        [context release];
        return NO;
    }
    _currentThreadContext = context;
    [_currentThreadContext setVideoFramesQueueLimit:_framesQueueLimit];
    [_currentThreadContext setLazyMovieCreation:_lazyMovieCreation];
    if (!_useAudioRecordWorkAround) {
        NSString *audioCompression = [aAttributes objectForKey:@"HSAudioCompressionTypeAttribute"];
        if (![audioCompression isKindOfClass:[NSString class]] || [audioCompression length] == 0) {
            audioCompression = @"QTCompressionOptionsHighQualityAACAudio";
        }
        QTCaptureSession *voiceSession = _voiceCaptureSession;
        if (voiceSession == nil) {
            voiceSession = _voiceCaptureSession = [QTCaptureSession new];
        }
        if (voiceSession != nil && [self HSRecorder_setupAudioDeviceInputForSession:voiceSession device:_voiceCaptureDevice openDevice:aDevice]) {
            QTCaptureMovieFileOutput *output = [QTCaptureMovieFileOutput new];
            if (output != nil) {
                if ([voiceSession addOutput:output error:NULL]) {
                    HSRecorderSetSoundCompression(output, audioCompression);
                    _voiceCaptureFileOutput = output;
                    [output setDelegate:self];
                    [voiceSession startRunning];
                } else {
                    [output release];
                }
            }
        }
        if ([[self audioDeviceSwapper] status] == 1) {
            QTCaptureSession *outToInSession = _audioOutToInCaptureSession;
            if (outToInSession == nil) {
                outToInSession = _audioOutToInCaptureSession = [QTCaptureSession new];
            }
            if (outToInSession == nil) {
                return NO;
            }
            if (![self HSRecorder_setupAudioDeviceInputForSession:outToInSession device:_audioOutToInCaptureDevice openDevice:aDevice]) {
                return NO;
            }
            QTCaptureMovieFileOutput *output = [QTCaptureMovieFileOutput new];
            if (output == nil) {
                return NO;
            }
            if ([outToInSession addOutput:output error:NULL]) {
                HSRecorderSetSoundCompression(output, audioCompression);
                _audioOutToInCaptureFileOutput = output;
                [output setDelegate:self];
                [outToInSession startRunning];
            } else {
                [output release];
            }
        }
    } else {
        if (_voiceCaptureDevice != nil) {
            _voiceRecorder = [[HSAudioRecorder alloc] initWithAudioDeviceUID:[_voiceCaptureDevice uniqueID]];
            if (_voiceRecorder == nil) {
                return YES;
            }
            [_voiceRecorder setDelegate:self];
        }
        if (_audioOutToInCaptureDevice != nil) {
            _audioOutToInRecorder = [[HSAudioRecorder alloc] initWithAudioDeviceUID:[_audioOutToInCaptureDevice uniqueID]];
            if (_audioOutToInRecorder == nil) {
                return YES;
            }
            [_audioOutToInRecorder setDelegate:self];
        }
    }
    if (_audioOutToInCaptureDevice == nil) {
        [_movieLogger release];
        _movieLogger = [HSMoviePlaybackLogger new];
    }
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026746a @ 0026746a, 370 bytes * /

BOOL FUN_0026746a(HSRecorder *self,SEL _cmd,id HSRecorder_setupAudioDeviceInputForSession,id device,
                 BOOL openDevice)

{
  id *ppvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 *puVar5;
  BOOL local_15;
  undefined4 local_14;
  
  if ((HSRecorder_setupAudioDeviceInputForSession == (id)0x0) || (device == (id)0x0)) {
LAB_00267485:
    local_15 = '\0';
  }
  else {
    local_14 = 0;
    if (self->_voiceCaptureDevice == device) {
      ppvVar1 = &self->_voiceCaptureDeviceInput;
    }
    else {
      if (self->_audioOutToInCaptureDevice != device) goto LAB_00267485;
      ppvVar1 = &self->_audioOutToInCaptureDeviceInput;
    }
    pvVar4 = *ppvVar1;
    if (pvVar4 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar4,sel_device);
      if (openDevice == '\0') {
        pvVar2 = _objc_msgSend(pvVar3,sel_isConnected);
        if (((char)pvVar2 != '\0') &&
           (pvVar3 = _objc_msgSend(pvVar3,sel_QTE_isInUseByAnotherApplication), (char)pvVar3 == '\0'
           )) goto LAB_00267485;
      }
      else {
        pvVar3 = _objc_msgSend(pvVar3,sel_open_,&local_14);
        if ((char)pvVar3 != '\0') {
          return (char)pvVar3;
        }
      }
      _objc_msgSend(pvVar4,sel_release);
    }
    local_15 = '\0';
    pvVar4 = (id)0x0;
    if (device != (id)0x0) {
      puVar5 = &local_14;
      pvVar3 = _objc_msgSend(device,sel_open_,puVar5);
      if ((char)pvVar3 != '\0') {
        pvVar4 = _objc_msgSend(cls_QTCaptureDeviceInput,sel_alloc,puVar5);
        pvVar4 = _objc_msgSend(pvVar4,sel_initWithDevice_,device);
      }
    }
    if (pvVar4 != (id)0x0) {
      pvVar4 = _objc_msgSend(HSRecorder_setupAudioDeviceInputForSession,sel_addInput_error_,pvVar4,
                             &local_14);
      local_15 = (BOOL)pvVar4;
    }
  }
  return local_15;
}

*/
- (BOOL)HSRecorder_setupAudioDeviceInputForSession:(id)aSession device:(id)aDevice openDevice:(BOOL)aDevice2
{
    if (aSession == nil || aDevice == nil) {
        return NO;
    }
    NSError *error = nil;
    QTCaptureDeviceInput **inputPointer;
    if (_voiceCaptureDevice == aDevice) {
        inputPointer = &_voiceCaptureDeviceInput;
    } else if (_audioOutToInCaptureDevice == aDevice) {
        inputPointer = &_audioOutToInCaptureDeviceInput;
    } else {
        return NO;
    }
    QTCaptureDeviceInput *input = *inputPointer;
    if (input != nil) {
        QTCaptureDevice *device = [input device];
        if (!aDevice2) {
            if (![device isConnected] || ![device QTE_isInUseByAnotherApplication]) {
                return NO;
            }
        } else if ([device open:&error]) {
            return YES;
        }
        [input release];
        *inputPointer = nil;
    }
    input = nil;
    if ([aDevice open:&error]) {
        input = [[QTCaptureDeviceInput alloc] initWithDevice:aDevice];
    }
    if (input == nil) {
        return NO;
    }
    // The original left the new input out of the ivar, leaving it dangling after the release above.
    *inputPointer = input;
    return [aSession addInput:input error:&error];
}

- (NSUInteger)framesQueueLimit
{
    return _framesQueueLimit;
}

- (void)setFramesQueueLimit:(NSUInteger)aLimit
{
    _framesQueueLimit = aLimit;
}

- (double)framesPerSecondLimit
{
    return _framesPerSecondLimit;
}

- (void)setFramesPerSecondLimit:(double)aLimit
{
    _framesPerSecondLimit = aLimit;
}

- (id)dataSource
{
    return _dataSource;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002675dc @ 002675dc, 171 bytes * /

void FUN_002675dc(HSRecorder *self,SEL _cmd,id setDataSource)

{
  id pvVar1;
  HSRecorder *self_00;
  SEL op;
  
  if (self->_dataSource != setDataSource) {
    pvVar1 = _objc_msgSend(self->_currentThreadContext,sel_outputMovieFilePath);
    if (pvVar1 != (id)0x0) {
      self_00 = self;
      op = sel_HSRecorder_cancelRecording;
      if (setDataSource != (id)0x0) {
        _objc_msgSend(self->_dataSource,sel_stopCapturingForConsumer_,self);
        self_00 = setDataSource;
        op = sel_startCapturingForConsumer_;
      }
      _objc_msgSend(self_00,op);
    }
    _objc_msgSend(self->_dataSource,sel_release);
    pvVar1 = _objc_msgSend(setDataSource,sel_retain);
    self->_dataSource = pvVar1;
  }
  return;
}

*/
- (void)setDataSource:(id)aSource
{
    if (_dataSource != aSource) {
        if ([_currentThreadContext outputMovieFilePath] != nil) {
            if (aSource != nil) {
                [_dataSource stopCapturingForConsumer:self];
                [aSource startCapturingForConsumer:self];
            } else {
                [self HSRecorder_cancelRecording];
            }
        }
        [_dataSource release];
        _dataSource = [aSource retain];
    }
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    pthread_mutex_lock((pthread_mutex_t *)&_delegateMutex);
    _delegate = aDelegate;
    pthread_mutex_unlock((pthread_mutex_t *)&_delegateMutex);
}

- (void)release
{
    if (([self retainCount] == 0x1) && (_currentThreadContext != nil)) {
        [self HSRecorder_cancelRecording];
    }
    [super release];
}

- (void)dealloc
{
    [_voiceCaptureFileOutput setDelegate:0];
    [_voiceCaptureFileOutput release];
    [_voiceCaptureSession release];
    [_voiceCaptureDeviceInput release];
    [_voiceCaptureDevice release];
    [_audioOutToInCaptureFileOutput setDelegate:0];
    [_audioOutToInCaptureFileOutput release];
    [_audioOutToInCaptureSession release];
    [_audioOutToInCaptureDeviceInput release];
    [_audioOutToInCaptureDevice release];
    [_audioDeviceSwapper release];
    [_voiceRecorder release];
    [_audioOutToInRecorder release];
    [_movieLogger release];
    [_processedInAnotherThreadMovies release];
    [_error release];
    CVPixelBufferRelease(_currentFrameBuffer);
    pthread_mutex_destroy((pthread_mutex_t *)&_capturingPreviousTimeMutex);
    pthread_mutex_destroy((pthread_mutex_t *)&_delegateMutex);
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00267896 @ 00267896, 341 bytes * /

id FUN_00267896(HSRecorder *self,SEL _cmd)

{
  HSRecorder *pHVar1;
  int iVar2;
  id pvVar3;
  pthread_mutexattr_t local_2c;
  HSRecorder *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSObject_00356150;
  pHVar1 = _objc_msgSendSuper(&local_1c,sel_init);
  if (pHVar1 != (HSRecorder *)0x0) {
    iVar2 = _pthread_mutex_init((pthread_mutex_t *)&pHVar1->_capturingPreviousTimeMutex,
                                (pthread_mutexattr_t *)0x0);
    if (iVar2 == 0) {
      iVar2 = _pthread_mutexattr_init(&local_2c);
      if (iVar2 == 0) {
        iVar2 = _pthread_mutexattr_settype(&local_2c,2);
        if ((iVar2 == 0) &&
           (iVar2 = _pthread_mutex_init((pthread_mutex_t *)&pHVar1->_delegateMutex,&local_2c),
           iVar2 == 0)) {
          _pthread_mutexattr_destroy(&local_2c);
          *(undefined4 *)((int)&pHVar1->_framesPerSecondLimit + 4) = 0x40390000;
          *(undefined4 *)&pHVar1->_framesPerSecondLimit = 0;
          pHVar1->_framesQueueLimit = 0x32;
          *(undefined4 *)((int)&pHVar1->_capturingPreviousTime + 4) = 0xbff00000;
          *(undefined4 *)&pHVar1->_capturingPreviousTime = 0;
          *(undefined4 *)((int)&pHVar1->_capturingStartTime + 4) = 0xbff00000;
          *(undefined4 *)&pHVar1->_capturingStartTime = 0;
          pvVar3 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
          pvVar3 = _objc_msgSend(pvVar3,sel_quickTimeVersion);
          if ((int)pvVar3 < 0x7210001) {
            pHVar1->_useAudioRecordWorkAround = '\x01';
            return pHVar1;
          }
          return pHVar1;
        }
        _pthread_mutexattr_destroy(&local_2c);
      }
    }
    local_18 = PTR_s_NSObject_00356150;
    local_1c = pHVar1;
    _objc_msgSendSuper(&local_1c,sel_release);
  }
  return (id)0x0;
}

*/
- (id)init
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    pthread_mutexattr_t attributes;
    if (pthread_mutex_init(&_capturingPreviousTimeMutex, NULL) == 0 && pthread_mutexattr_init(&attributes) == 0) {
        // The delegate mutex is recursive: delegate callbacks may call back into the recorder.
        if (pthread_mutexattr_settype(&attributes, PTHREAD_MUTEX_RECURSIVE) == 0 && pthread_mutex_init(&_delegateMutex, &attributes) == 0) {
            pthread_mutexattr_destroy(&attributes);
            _framesPerSecondLimit = 25.0;
            _framesQueueLimit = 50;
            _capturingPreviousTime = -1.0;
            _capturingStartTime = -1.0;
            if ([[HSSystem sharedSystem] quickTimeVersion] < 0x07210001) {
                _useAudioRecordWorkAround = YES;
            }
            return self;
        }
        pthread_mutexattr_destroy(&attributes);
    }
    [super release];
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002679eb @ 002679eb, 691 bytes * /

void FUN_002679eb(HSRecorder *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self->_currentThreadContext,sel_outputMovieFilePath);
  if (pvVar1 == (id)0x0) goto LAB_00267c2c;
  _objc_msgSend(self->_dataSource,sel_stopCapturingForConsumer_,self);
  uVar2 = 1;
  _objc_msgSend(self->_currentThreadContext,sel_setAudioCaptirungDidFinish_,1);
  _objc_msgSend(self->_currentThreadContext,sel_cancelProcessing);
  if (self->_useAudioRecordWorkAround == '\0') {
    if (self->_voiceCaptureFileOutput != (id)0x0) {
      uVar3 = 2;
      uVar2 = 0;
      _objc_msgSend(self->_voiceCaptureFileOutput,sel_recordToOutputFileURL_bufferDestination_,0,2);
      _objc_msgSend(self->_voiceCaptureSession,sel_stopRunning);
      pvVar1 = _objc_msgSend(self->_voiceCaptureDeviceInput,sel_device);
      pvVar1 = _objc_msgSend(pvVar1,sel_isOpen);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(self->_voiceCaptureDeviceInput,sel_device,uVar2,uVar3);
        _objc_msgSend(pvVar1,sel_close);
      }
    }
    if (self->_audioOutToInCaptureFileOutput != (id)0x0) {
      uVar3 = 2;
      uVar2 = 0;
      _objc_msgSend(self->_audioOutToInCaptureFileOutput,
                    sel_recordToOutputFileURL_bufferDestination_,0,2);
      _objc_msgSend(self->_audioOutToInCaptureSession,sel_stopRunning);
      pvVar1 = _objc_msgSend(self->_audioOutToInCaptureDeviceInput,sel_device);
      pvVar1 = _objc_msgSend(pvVar1,sel_isOpen);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(self->_audioOutToInCaptureDeviceInput,sel_device,uVar2,uVar3);
        op = sel_close;
        goto LAB_00267bce;
      }
    }
  }
  else {
    if (self->_voiceRecorder != (id)0x0) {
      _objc_msgSend(self->_voiceRecorder,sel_stopRecording,uVar2);
    }
    pvVar1 = self->_audioOutToInRecorder;
    op = sel_stopRecording;
    if (pvVar1 != (id)0x0) {
LAB_00267bce:
      _objc_msgSend(pvVar1,op,uVar2);
    }
  }
  if (self->_movieLogger != (id)0x0) {
    _objc_msgSend(self->_movieLogger,sel_stopLogging,uVar2);
    uVar2 = 0;
    _objc_msgSend(self,sel_HSRecorder_loadSoundMovieWithAttributes_,0);
  }
  _objc_msgSend(self->_dataSource,sel_release,uVar2);
  self->_dataSource = (id)0x0;
LAB_00267c2c:
  _objc_msgSend(self->_currentThreadContext,sel_removeAllSoundMovies);
  _pthread_mutex_lock((pthread_mutex_t *)&self->_capturingPreviousTimeMutex);
  *(undefined4 *)((int)&self->_capturingPreviousTime + 4) = 0xbff00000;
  *(undefined4 *)&self->_capturingPreviousTime = 0;
  _pthread_mutex_unlock((pthread_mutex_t *)&self->_capturingPreviousTimeMutex);
  _CVPixelBufferRelease(self->_currentFrameBuffer);
  self->_currentFrameBuffer = (CVBuffer *)0x0;
  _objc_msgSend(self->_currentThreadContext,sel_release);
  self->_currentThreadContext = (HSThreadContext *)0x0;
  return;
}

*/
- (void)HSRecorder_cancelRecording
{
    if ([_currentThreadContext outputMovieFilePath] != nil) {
        [_dataSource stopCapturingForConsumer:self];
        [_currentThreadContext setAudioCaptirungDidFinish:YES];
        [_currentThreadContext cancelProcessing];
        if (!_useAudioRecordWorkAround) {
            if (_voiceCaptureFileOutput != nil) {
                [_voiceCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
                [_voiceCaptureSession stopRunning];
                if ([[_voiceCaptureDeviceInput device] isOpen]) {
                    [[_voiceCaptureDeviceInput device] close];
                }
            }
            if (_audioOutToInCaptureFileOutput != nil) {
                [_audioOutToInCaptureFileOutput recordToOutputFileURL:nil bufferDestination:QTCaptureFileOutputBufferDestinationOldFile];
                [_audioOutToInCaptureSession stopRunning];
                if ([[_audioOutToInCaptureDeviceInput device] isOpen]) {
                    [[_audioOutToInCaptureDeviceInput device] close];
                }
            }
        } else {
            if (_voiceRecorder != nil) {
                [_voiceRecorder stopRecording];
            }
            if (_audioOutToInRecorder != nil) {
                [_audioOutToInRecorder stopRecording];
            }
        }
        if (_movieLogger != nil) {
            [_movieLogger stopLogging];
            [self HSRecorder_loadSoundMovieWithAttributes:nil];
        }
        [_dataSource release];
        _dataSource = nil;
    }
    [_currentThreadContext removeAllSoundMovies];
    pthread_mutex_lock(&_capturingPreviousTimeMutex);
    _capturingPreviousTime = -1.0;
    pthread_mutex_unlock(&_capturingPreviousTimeMutex);
    CVPixelBufferRelease(_currentFrameBuffer);
    _currentFrameBuffer = NULL;
    [_currentThreadContext release];
    _currentThreadContext = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002653dc @ 002653dc, 468 bytes * /

int FUN_002653dc(HSRecorder *self,SEL _cmd,id informUserAboutError,BOOL showCancelButton)

{
  id pvVar1;
  id self_00;
  cfstringStruct *pcVar2;
  cfstringStruct *pcVar3;
  id local_14;
  
  pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr____Description,
                         informUserAboutError);
  self_00 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pcVar2 = &cfstr_Alerts;
  pcVar3 = &cfstr_empty;
  local_14 = _objc_msgSend(self_00,sel_localizedStringForKey_value_table_,pvVar1,&cfstr_empty,
                           &cfstr_Alerts);
  if (local_14 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar1,pcVar3,pcVar2)
    ;
    local_14 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                             &cfstr_kHSInternalHyperCastingError_Description,&cfstr_empty,
                             &cfstr_Alerts);
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pcVar2 = &cfstr_kHSInternalHyperCastingError_RecoverySuggestion;
  }
  else {
    pcVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr____RecoverySuggestion,
                           informUserAboutError,pcVar2);
    pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar2,&cfstr_empty,
                         &cfstr_Alerts);
  pcVar2 = &cfstr_Cancel;
  if (showCancelButton == '\0') {
    pcVar2 = (cfstringStruct *)0x0;
  }
  pcVar3 = &cfstr_Continue;
  if (showCancelButton == '\0') {
    pcVar3 = &cfstr_OK;
  }
  pvVar1 = _objc_msgSend(cls_NSAlert,
                         sel_alertWithMessageText_defaultButton_alternateButton_otherButton_informativeTextWithFormat_
                         ,local_14,pcVar3,pcVar2,0,pvVar1);
  pvVar1 = _objc_msgSend(pvVar1,sel_runModal);
  return (int)pvVar1;
}

*/
- (NSInteger)informUserAboutError:(id)aError showCancelButton:(BOOL)aButton
{
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:[NSString stringWithFormat:@"%@-Description", aError] value:@"" table:@"Alerts"];
    NSString *suggestion;
    if (message == nil) {
        message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"kHSInternalHyperCastingError-Description" value:@"" table:@"Alerts"];
        suggestion = @"kHSInternalHyperCastingError-RecoverySuggestion";
    } else {
        suggestion = [NSString stringWithFormat:@"%@-RecoverySuggestion", aError];
    }
    NSString *informative = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:suggestion value:@"" table:@"Alerts"];
    // The original passed the suggestion as the format string; it is used as plain text here.
    NSAlert *alert = [NSAlert alertWithMessageText:message
                                     defaultButton:aButton ? @"Continue" : @"OK"
                                   alternateButton:aButton ? @"Cancel" : nil
                                       otherButton:nil
                         informativeTextWithFormat:@"%@", informative];
    return [alert runModal];
}

- (id)audioDeviceSwapper
{
    return nil;
}

@end

@implementation HSThreadContext

/* i386 ivar offsets: _workFolderPath=0x4, _movie=0x8, _movieStorage=0xc, _soundMovies=0x10, _scheduledProcessing=0x14, _outputMovieFilePath=0x18, _videoFramesAttributes=0x1c, _delegateMutex=0x20, _delegate=0x4c, _videoFramesQueue=0x50, _videoFramesQueueLimit=0x54, _processingThreadMutex=0x58, _processingThreadCondition=0x84, _cornersClipPath=0xa0, _openGLContext=0xa4, _offscreenWindow=0xa8, _packedPixelsBufferSize=0xac, _packedPixelsBuffer=0xb0, _lazyMovieCreation=0xb4, _roundedCornersForMovie=0xb4, _isWaitingForActivation=0xb4, _isThreadRoutineStarted=0xb4, _isProcessingCanceled=0xb4, _isAudioCapturingUsed=0xb4, _isWaitingForAudio=0xb4, _isWaitingForVideo=0xb4, _isAudioCaptirungDidFinish=0xb5, _movieSize=0xb8 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00265280 @ 00265280, 348 bytes * /

id FUN_00265280(id self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  char *pcVar5;
  char local_11;
  
  pvVar1 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_temporaryFolder);
  pvVar2 = _objc_msgSend(pvVar1,sel_stringByAppendingPathComponent_,&cfstr_Hypercast);
  self_00 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  local_11 = '\0';
  pcVar5 = &local_11;
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(self_00,sel_fileExistsAtPath_isDirectory_,pvVar2,pcVar5);
  if (((char)pvVar3 == '\0') || (local_11 == '\0')) {
    pcVar5 = (char *)0x0;
    pvVar1 = pvVar2;
    _objc_msgSend(self_00,sel_createDirectoryAtPath_attributes_,pvVar2,0);
  }
  do {
    pvVar1 = _objc_msgSend(cls_HSUID,sel_UID,pvVar1,pcVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_stringValue);
    pvVar3 = _objc_msgSend(pvVar2,sel_stringByAppendingPathComponent_,pvVar1);
    pcVar5 = &local_11;
    pvVar1 = pvVar3;
    pvVar4 = _objc_msgSend(self_00,sel_fileExistsAtPath_isDirectory_);
    if ((char)pvVar4 == '\0') break;
  } while (local_11 != '\0');
  pvVar2 = _objc_msgSend(self_00,sel_createDirectoryAtPath_attributes_,pvVar3,0);
  pvVar1 = (id)0x0;
  if ((char)pvVar2 != '\0') {
    pvVar1 = pvVar3;
  }
  return pvVar1;
}

*/
+ (id)HSThreadContext_createWorkFolder
{
    NSString *basePath = [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:@"Hypercast"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:basePath isDirectory:&isDirectory] || !isDirectory) {
        [fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *path;
    do {
        path = [basePath stringByAppendingPathComponent:[[HSUID UID] stringValue]];
        if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
            break;
        }
    } while (isDirectory);
    return [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL] ? path : nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026818b @ 0026818b, 6124 bytes * /

void FUN_0026818b(HSThreadContext *self,SEL _cmd,id processingThreadRoutine)

{
  opaque_pthread_mutex_t *poVar1;
  opaque_pthread_cond_t *poVar2;
  HSFramesQueue *pHVar3;
  uint uVar4;
  undefined1 *self_00;
  uint uVar5;
  size_t sVar6;
  float fVar7;
  float fVar8;
  bool bVar9;
  undefined *puVar10;
  undefined *puVar11;
  char cVar12;
  short sVar13;
  id self_01;
  id pvVar14;
  int iVar15;
  uint uVar16;
  uint uVar17;
  id pvVar18;
  int iVar19;
  undefined4 uVar20;
  undefined *self_02;
  void *pvVar21;
  undefined4 uVar22;
  int *piVar23;
  undefined4 uVar24;
  uint uVar25;
  id pvVar26;
  id self_03;
  id self_04;
  id pvVar27;
  undefined4 uVar28;
  id pvVar29;
  undefined1 *puVar30;
  void **ppvVar31;
  longdouble lVar32;
  longdouble lVar33;
  double dVar34;
  double dVar35;
  double dVar36;
  float fVar37;
  float fVar38;
  double dVar39;
  undefined *self_05;
  SEL pcVar40;
  float fVar41;
  undefined4 *puVar42;
  void *pvVar43;
  float fVar44;
  void *pvVar45;
  int iVar46;
  void *pvVar47;
  int *piVar48;
  id local_148;
  id local_140;
  short local_134;
  uint local_12c;
  id local_124;
  id local_104;
  id local_100;
  undefined1 local_ec [60];
  undefined4 local_b0;
  float local_ac;
  float fStack_a8;
  float local_a4;
  float fStack_a0;
  float local_9c;
  float fStack_98;
  float local_94;
  float fStack_90;
  int local_8c;
  undefined4 local_88;
  undefined4 local_84;
  undefined4 local_80;
  undefined4 local_7c;
  undefined4 local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  self_01 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  _objc_msgSend(cls_QTMovie,sel_enterQTKitOnThread);
  pvVar14 = _objc_msgSend(self->_movie,sel_attachToCurrentThread);
  uVar16._0_1_ = self->_lazyMovieCreation[0];
  uVar16._1_1_ = self->_roundedCornersForMovie[0];
  uVar16._2_1_ = self->_isWaitingForActivation[0];
  uVar16._3_1_ = self->_isThreadRoutineStarted[0];
  *(uint *)self->_lazyMovieCreation = (uint)((byte)pvVar14 & 1) * 8 + (uVar16 & 0xfffffff7);
  poVar1 = &self->_processingThreadMutex;
  local_ec._0_4_ = poVar1;
  _pthread_mutex_lock((pthread_mutex_t *)poVar1);
  self->_lazyMovieCreation[0] = self->_lazyMovieCreation[0] | 4;
  poVar2 = &self->_processingThreadCondition;
  _pthread_cond_signal((pthread_cond_t *)poVar2);
  uVar17._0_1_ = self->_lazyMovieCreation[0];
  uVar17._1_1_ = self->_roundedCornersForMovie[0];
  uVar17._2_1_ = self->_isWaitingForActivation[0];
  uVar17._3_1_ = self->_isThreadRoutineStarted[0];
  if ((uVar17 & 8) == 0) {
    _pthread_mutex_unlock((pthread_mutex_t *)poVar1);
  }
  else {
    while (((uVar17 & 0x10) == 0 && (self->_outputMovieFilePath == (id)0x0))) {
      _pthread_cond_wait((pthread_cond_t *)poVar2,(pthread_mutex_t *)poVar1);
      uVar17._0_1_ = self->_lazyMovieCreation[0];
      uVar17._1_1_ = self->_roundedCornersForMovie[0];
      uVar17._2_1_ = self->_isWaitingForActivation[0];
      uVar17._3_1_ = self->_isThreadRoutineStarted[0];
    }
    _pthread_mutex_unlock((pthread_mutex_t *)poVar1);
    puVar11 = PTR_0033607c;
    puVar10 = PTR_00336074;
    if (((self->_lazyMovieCreation[0] & 0x10) == 0) && (self->_outputMovieFilePath != (id)0x0)) {
      uVar24 = *(undefined4 *)PTR_0033615c;
      bVar9 = false;
      local_12c = 0;
      while( true ) {
        _pthread_mutex_lock((pthread_mutex_t *)poVar1);
        ppvVar31 = (void **)0x0;
        while (((self->_lazyMovieCreation[0] & 0x10) == 0 &&
               (ppvVar31 = self->_videoFramesQueue->f0, ppvVar31 == (void **)0x0))) {
          _pthread_cond_wait((pthread_cond_t *)poVar2,(pthread_mutex_t *)poVar1);
        }
        _pthread_mutex_unlock((pthread_mutex_t *)poVar1);
        if (((self->_lazyMovieCreation[0] & 0x10) != 0) || (*ppvVar31 == (void *)0x0)) break;
        pvVar14 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
        iVar15 = _CVPixelBufferRetain(*ppvVar31);
        pvVar43 = ppvVar31[1];
        pvVar45 = ppvVar31[2];
        pvVar21 = ppvVar31[4];
        pvVar47 = ppvVar31[3];
        _pthread_mutex_lock((pthread_mutex_t *)poVar1);
        pHVar3 = self->_videoFramesQueue;
        ppvVar31 = pHVar3->f0;
        if (ppvVar31 != (void **)0x0) {
          pHVar3->f0 = ppvVar31[6];
          if (ppvVar31[6] != (void *)0x0) {
            *(undefined4 *)((int)ppvVar31[6] + 0x14) = 0;
          }
          ppvVar31[6] = pHVar3->f2;
          if (pHVar3->f2 != (void **)0x0) {
            pHVar3->f2[5] = ppvVar31;
          }
          pHVar3->f2 = ppvVar31;
          if (pHVar3->f1 == ppvVar31) {
            pHVar3->f1 = (void **)0x0;
          }
          _CVPixelBufferRelease(*ppvVar31);
          pHVar3->f3 = pHVar3->f3 - 1;
        }
        if (((self->_lazyMovieCreation[0] & 0x80) != 0) &&
           (self->_videoFramesQueue->f3 < self->_videoFramesQueueLimit)) {
          _pthread_cond_signal((pthread_cond_t *)poVar2);
        }
        _pthread_mutex_unlock((pthread_mutex_t *)poVar1);
        uVar4._0_1_ = self->_lazyMovieCreation[0];
        uVar4._1_1_ = self->_roundedCornersForMovie[0];
        uVar4._2_1_ = self->_isWaitingForActivation[0];
        uVar4._3_1_ = self->_isThreadRoutineStarted[0];
        if (((uVar4 & 1) != 0) && (!bVar9)) {
          uVar16 = _CVPixelBufferGetHeight(iVar15);
          uVar17 = _CVPixelBufferGetWidth(iVar15);
          bVar9 = true;
          pvVar18 = _objc_msgSend(self,sel_prepareOpenGLContextWithTextureSize_,
                                  (float)((double)((ulonglong)uVar17 | 0x4330000000000000) -
                                         4503599627370496.0),
                                  (float)((double)((ulonglong)uVar16 | 0x4330000000000000) -
                                         4503599627370496.0));
          local_12c = (uint)pvVar18 & 0xff;
        }
        if ((char)local_12c == '\0') {
          if (iVar15 == 0) break;
          iVar19 = _CVBufferGetAttachment(iVar15,&cfstr_HSPixelBufferCGImage,0);
          if (iVar19 == 0) {
            iVar19 = _CGEImageCreateWithPixelBuffer(iVar15,1,0,0,1,0);
          }
          else {
            iVar19 = _CGImageRetain(iVar19);
          }
          if (iVar19 == 0) break;
          uVar16 = _CGImageGetHeight(iVar19);
          uVar17 = _CGImageGetWidth(iVar19);
          uVar22._0_1_ = self->_isProcessingCanceled[0];
          uVar22._1_1_ = self->_isAudioCapturingUsed[0];
          uVar22._2_1_ = self->_isWaitingForAudio[0];
          uVar22._3_1_ = self->_isWaitingForVideo[0];
          fVar37 = (float)((double)((ulonglong)uVar16 | 0x4330000000000000) - 4503599627370496.0);
          fVar38 = (float)((double)((ulonglong)uVar17 | 0x4330000000000000) - 4503599627370496.0);
          cVar12 = _NSEqualSizes(uVar22,*(undefined4 *)self->_isAudioCaptirungDidFinish,
                                 *(undefined4 *)puVar11,*(undefined4 *)(puVar11 + 4));
          fVar8 = fVar37;
          local_100 = (id)fVar38;
          if (cVar12 == '\0') {
            fVar8 = *(float *)self->_isAudioCaptirungDidFinish;
            local_100 = (id)*(float *)self->_isProcessingCanceled;
          }
          local_9c = *(float *)puVar10;
          fStack_98 = *(float *)(puVar10 + 4);
          local_94 = fVar38;
          fStack_90 = fVar37;
          pvVar18 = _objc_msgSend(cls_NSImage,sel_alloc);
          pvVar18 = _objc_msgSend(pvVar18,sel_initWithSize_,local_100,fVar8);
          fVar41 = fVar38;
          fVar44 = fVar37;
          cVar12 = _NSEqualSizes(local_100,fVar8,fVar38,fVar37);
          if (cVar12 == '\0') {
            fVar7 = fVar37 / fVar8;
            if (fVar37 / fVar8 <= fVar38 / (float)local_100) {
              fVar7 = fVar38 / (float)local_100;
            }
            lVar32 = (longdouble)_floorf(fVar38 / fVar7);
            local_94 = (float)lVar32;
            lVar33 = (longdouble)_floorf(fVar37 / fVar7);
            fStack_90 = (float)lVar33;
            local_9c = ((float)local_100 - (float)lVar32) * 0.5;
            fStack_98 = (fVar8 - fStack_90) * 0.5;
          }
          _objc_msgSend(pvVar18,sel_lockFocus);
          if ((self->_lazyMovieCreation[0] & 2) != 0) {
            if (self->_cornersClipPath == (id)0x0) {
              fVar41 = local_9c;
              fVar44 = fStack_98;
              pvVar26 = _objc_msgSend(cls_NSBezierPath,
                                      sel_smkRoundedBorderPathWithRect_cornerRadius_,local_9c,
                                      fStack_98,local_94,fStack_90,0x41800000);
              pvVar26 = _objc_msgSend(pvVar26,sel_retain);
              self->_cornersClipPath = pvVar26;
            }
            pvVar26 = _objc_msgSend(cls_NSColor,sel_blackColor,fVar41,fVar44);
            _objc_msgSend(pvVar26,sel_set);
            _NSRectFill(local_9c,fStack_98,local_94,fStack_90);
            _objc_msgSend(self->_cornersClipPath,sel_setClip);
          }
          local_ac = local_9c;
          fStack_a8 = fStack_98;
          local_a4 = local_94;
          fStack_a0 = fStack_90;
          pvVar26 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
          pvVar26 = _objc_msgSend(pvVar26,sel_graphicsPort);
          _CGContextDrawImage(pvVar26,local_ac,fStack_a8,local_a4,fStack_a0,iVar19);
          _objc_msgSend(pvVar18,sel_unlockFocus);
          _CGImageRelease(iVar19);
          if (pvVar18 == (id)0x0) break;
          piVar48 = self->_videoFramesAttributes;
          pvVar26 = pvVar18;
          _objc_msgSend(self->_movie,sel_addImage_forDuration_withAttributes_,pvVar18,pvVar43,
                        pvVar45,pvVar47,pvVar21,piVar48);
          _objc_msgSend(pvVar18,sel_release);
        }
        else {
          uVar16 = _CVPixelBufferGetWidth(iVar15);
          uVar17 = _CVPixelBufferGetHeight(iVar15);
          if (self->_openGLContext == (id)0x0) break;
          local_78 = 0;
          local_7c = 0;
          local_80 = 0;
          local_84 = 0;
          local_88 = 0;
          cVar12 = _CVEPixelBufferIsOpenGLCompatible
                             (iVar15,&local_78,&local_7c,&local_80,&local_84,&local_88);
          if ((cVar12 == '\0') || (iVar19 = _CVPixelBufferLockBaseAddress(iVar15,1,0), iVar19 != 0))
          break;
          uVar20 = _CVPixelBufferGetBaseAddress(iVar15);
          pvVar18 = _objc_msgSend(cls_NSOpenGLContext,sel_currentContext);
          self_02 = _objc_msgSend(pvVar18,sel_retain);
          _objc_msgSend(self->_openGLContext,sel_makeCurrentContext);
          pvVar18 = _objc_msgSend(self->_openGLContext,sel_CGLContextObj);
          iVar19 = _CGLLockContext(pvVar18);
          uVar22 = local_88;
          if (iVar19 == 0) {
            _glPixelStorei(0xcf2,local_84);
            _glPixelStorei(0xcf5,uVar22);
            _glPixelStorei(0x85b2,1);
            cVar12 = _glIsEnabled(0x84f5);
            if (cVar12 == '\0') {
              _glEnable(0x84f5);
            }
            local_8c = 0;
            _glGenTextures(1,&local_8c);
            if (local_8c != 0) {
              _glBindTexture(0x84f5,local_8c);
              _glTexParameteri(0x84f5,0x85bc,0x85bf);
              _glTexParameteri(0x84f5,&DAT_00002801,&DAT_00002600);
              _glTexParameteri(0x84f5,&DAT_00002800,&DAT_00002600);
              _glTexImage2D(0x84f5,0,local_78,uVar16,uVar17,0,local_7c,local_80,uVar20);
              _glBegin(7);
              _glTexCoord2d(0,0,0,0);
              dVar34 = (double)((ulonglong)uVar17 | 0x4330000000000000) - 4503599627370496.0;
              _glVertex2d(0,0xbff00000,0,0xbff00000);
              _glTexCoord2d(0,0,dVar34);
              _glVertex2d(0,0xbff00000,0,0x3ff00000);
              dVar35 = (double)((ulonglong)uVar16 | 0x4330000000000000) - 4503599627370496.0;
              _glTexCoord2d(dVar35,dVar34);
              _glVertex2d(0,0x3ff00000,0,0x3ff00000);
              _glTexCoord2d(dVar35,0,0);
              _glVertex2d(0,0x3ff00000,0,0xbff00000);
              _glEnd();
              _glFlush();
              _glDeleteTextures(1,&local_8c);
              if (self->_packedPixelsBuffer == (void *)0x0) {
                sVar6 = uVar16 * uVar17 * 2;
                self->_packedPixelsBufferSize = sVar6;
                pvVar21 = _malloc(sVar6);
                self->_packedPixelsBuffer = pvVar21;
                if (pvVar21 == (void *)0x0) goto LAB_002689d0;
              }
              local_80 = 0x85ba;
              _glReadBuffer(0x404);
              _glReadPixels(0,0,uVar16,uVar17,0x85b9,local_80,self->_packedPixelsBuffer);
            }
LAB_002689d0:
            pvVar18 = _objc_msgSend(self->_openGLContext,sel_CGLContextObj);
            _CGLUnlockContext(pvVar18);
          }
          self_05 = cls_NSOpenGLContext;
          pcVar40 = sel_clearCurrentContext;
          if (self_02 != (undefined *)0x0) {
            _objc_msgSend(self_02,sel_makeCurrentContext);
            self_05 = self_02;
            pcVar40 = sel_release;
          }
          _objc_msgSend(self_05,pcVar40);
          _CVPixelBufferUnlockBaseAddress(iVar15,1,0);
          uVar22 = uVar24;
          pvVar18 = _objc_msgSend(self->_movie,sel_tracksOfMediaType_,uVar24);
          pvVar18 = _objc_msgSend(pvVar18,sel_count);
          if (pvVar18 == (id)0x0) {
            pvVar18 = _objc_msgSend(self->_movie,sel_quickTimeMovie,uVar22);
            uVar22 = _NewMovieTrack(pvVar18,uVar16 << 0x10,uVar17 << 0x10,0);
            _NewTrackMedia(uVar22,0x76696465,600,0,0);
          }
          pvVar18 = _objc_msgSend(self->_movie,sel_tracksOfMediaType_,uVar24);
          pvVar18 = _objc_msgSend(pvVar18,sel_objectAtIndex_,0);
          pvVar18 = _objc_msgSend(pvVar18,sel_quickTimeTrack);
          uVar22 = _GetTrackMedia(pvVar18);
          piVar23 = (int *)_NewHandleClear(0x56);
          *(undefined4 *)(*piVar23 + 4) = 0x32767579;
          *(short *)(*piVar23 + 0x20) = (short)uVar16;
          *(short *)(*piVar23 + 0x22) = (short)uVar17;
          _BeginMediaEdits(uVar22);
          pvVar26 = (id)self->_packedPixelsBufferSize;
          pvVar21 = (void *)0x0;
          pvVar47 = (void *)0x0;
          piVar48 = piVar23;
          _AddMediaSample2(uVar22,self->_packedPixelsBuffer,pvVar26,pvVar43,pvVar45,0,0,piVar23,1,0,
                           0);
          _EndMediaEdits(uVar22);
          _DisposeHandle(piVar23);
        }
        _CVPixelBufferRelease(iVar15);
        _objc_msgSend(pvVar14,sel_release,pvVar26,pvVar43,pvVar45,pvVar47,pvVar21,piVar48);
      }
      _pthread_mutex_lock((pthread_mutex_t *)poVar1);
      self->_lazyMovieCreation[0] = self->_lazyMovieCreation[0] | 0x40;
      if ((char)local_12c != '\0') {
        if (self->_packedPixelsBuffer != (void *)0x0) {
          _free(self->_packedPixelsBuffer);
          self->_packedPixelsBuffer = (void *)0x0;
        }
        _objc_msgSend(self,sel_destroyOpenGLContext);
        pvVar14 = _objc_msgSend(self->_movie,sel_tracksOfMediaType_,uVar24);
        pvVar14 = _objc_msgSend(pvVar14,sel_extraFirstObject);
        if (pvVar14 != (id)0x0) {
          pvVar14 = _objc_msgSend(pvVar14,sel_quickTimeTrack,uVar24);
          uVar24 = _GetTrackMedia(pvVar14);
          uVar24 = _GetMediaDuration(uVar24);
          _InsertMediaIntoTrack(pvVar14,0,0,uVar24,0x10000);
        }
      }
      uVar25._0_1_ = self->_lazyMovieCreation[0];
      uVar25._1_1_ = self->_roundedCornersForMovie[0];
      uVar25._2_1_ = self->_isWaitingForActivation[0];
      uVar25._3_1_ = self->_isThreadRoutineStarted[0];
      if (((uVar25 & 0x20) != 0) && ((uVar25 & 0x100) == 0)) {
        _pthread_cond_wait((pthread_cond_t *)poVar2,(pthread_mutex_t *)poVar1);
        uVar25._0_1_ = self->_lazyMovieCreation[0];
        uVar25._1_1_ = self->_roundedCornersForMovie[0];
        uVar25._2_1_ = self->_isWaitingForActivation[0];
        uVar25._3_1_ = self->_isThreadRoutineStarted[0];
      }
      uVar25 = uVar25 & 0xffffffbf;
      self->_lazyMovieCreation[0] = (char)uVar25;
      self->_roundedCornersForMovie[0] = (char)(uVar25 >> 8);
      self->_isWaitingForActivation[0] = (char)(uVar25 >> 0x10);
      self->_isThreadRoutineStarted[0] = (char)(uVar25 >> 0x18);
      pvVar18 = _objc_msgSend(self->_movie,sel_quickTimeMovie);
      iVar15 = _GetMovieDuration(pvVar18);
      iVar19 = _GetMovieTimeScale(pvVar18);
      pvVar14 = self->_soundMovies;
      self->_soundMovies = (id)0x0;
      _pthread_mutex_unlock((pthread_mutex_t *)poVar1);
      local_74 = 0;
      local_70 = 0;
      local_6c = (int *)0x0;
      local_68 = 0;
      local_64 = 0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      puVar30 = local_50;
      puVar42 = &local_74;
      iVar46 = 0x10;
      local_148 = _objc_msgSend(pvVar14,sel_countByEnumeratingWithState_objects_count_,puVar42,
                                puVar30,0x10);
      if (local_148 != (id)0x0) {
        dVar34 = (double)iVar15 / (double)iVar19;
        uVar24 = *(undefined4 *)PTR_00336404;
        iVar15 = *local_6c;
LAB_002692c7:
        local_140 = (id)0x0;
LAB_002692d1:
        if (iVar15 != *local_6c) {
          _objc_enumerationMutation(pvVar14);
        }
        self_00 = *(undefined1 **)(local_70 + (int)local_140 * 4);
        pvVar26 = _objc_msgSend(self_00,sel_objectForKey_,PTR_cfstr_HSRecorderQTMovieKey_003426c4,
                                puVar30,iVar46);
        if (pvVar26 != (id)0x0) {
          self_03 = _objc_msgSend(self_00,sel_objectForKey_,
                                  PTR_cfstr_HSRecorderPlaybackAttributesKey_003426c8);
          _objc_msgSend(pvVar26,sel_attachToCurrentThread);
          uVar22 = uVar24;
          self_04 = _objc_msgSend(pvVar26,sel_tracksOfMediaType_,uVar24);
          if (pvVar18 == (id)0x0 || dVar34 == 0.0) {
            local_124 = (id)0x0;
          }
          else {
            local_124 = _objc_msgSend(self_04,sel_count,uVar22);
          }
          pvVar27 = _objc_msgSend(pvVar26,sel_quickTimeMovie,uVar22);
          iVar19 = _GetMovieTimeScale(pvVar27);
          local_ec._0_4_ = iVar19;
          if (self_03 == (id)0x0) {
            local_134 = 0x100;
          }
          else {
            dVar35 = _objc_msgSend_fpret(self_03,sel_volume);
            local_134 = (short)(int)((float)dVar35 * 256.0);
          }
          dVar39 = _objc_msgSend_fpret(self_03,sel_currentPlaybackTime);
          dVar35 = (double)iVar19;
          local_104 = (id)0x0;
          local_100 = local_124;
          do {
            local_100 = (id)((int)local_100 + -1);
            if ((local_104 == local_124) || ((self->_lazyMovieCreation[0] & 0x10) != 0))
            goto LAB_00269802;
            pvVar27 = _objc_msgSend(self_04,sel_objectAtIndex_,local_100);
            pvVar27 = _objc_msgSend(pvVar27,sel_quickTimeTrack);
            if (pvVar27 != (id)0x0) {
              uVar22 = _GetTrackMedia(pvVar27);
              sVar13 = _GetMoviesError();
              if (sVar13 == 0) {
                uVar20 = _GetMediaTimeScale(uVar22);
                sVar13 = _GetMoviesError();
                if (sVar13 == 0) {
                  puVar30 = (undefined1 *)(int)local_134;
                  uVar28 = _NewMovieTrack(pvVar18,0,0);
                  sVar13 = _GetMoviesError();
                  if (sVar13 == 0) {
                    local_b0 = 0;
                    puVar30 = (undefined1 *)0x0;
                    _GetMediaHandlerDescription(uVar22,&local_b0,0);
                    sVar13 = _GetMoviesError();
                    if (sVar13 == 0) {
                      iVar46 = 0;
                      puVar30 = (undefined1 *)0x0;
                      uVar22 = _NewTrackMedia(uVar28,local_b0,uVar20);
                      sVar13 = _GetMoviesError();
                      if (sVar13 == 0) {
                        _BeginMediaEdits(uVar22);
                        sVar13 = _GetMoviesError();
                        if (sVar13 != 0) goto LAB_00269802;
                        if (self_03 == (id)0x0) {
                          local_ec._0_10_ = (unkuint10)(ushort)local_ec._8_2_ << 0x40;
LAB_002695f0:
                          pvVar29 = _objc_msgSend(pvVar26,sel_quickTimeMovie);
                          iVar19 = _GetMovieDuration(pvVar29);
                          dVar36 = (double)iVar19 / dVar35;
                        }
                        else {
                          local_ec._0_8_ = _objc_msgSend_fpret(self_03,sel_startTime);
                          dVar36 = _objc_msgSend_fpret(self_03,sel_duration);
                          local_ec._8_2_ =
                               (undefined2)((unkuint10)(longdouble)(double)local_ec._0_8_ >> 0x40);
                          if (dVar36 <= 0.0) goto LAB_002695f0;
                          dVar36 = _objc_msgSend_fpret(self_03,sel_duration);
                        }
                        if (dVar34 < (double)local_ec._0_8_ + dVar36) {
                          dVar36 = dVar34 - (double)local_ec._0_8_;
                        }
                        iVar46 = (int)((double)local_ec._0_8_ * 600.0);
                        puVar30 = (undefined1 *)(int)(dVar36 * dVar35);
                        iVar19 = (int)(dVar39 * dVar35);
                        _InsertTrackSegment(pvVar27,uVar28,(int)(dVar39 * dVar35));
                        pvVar27 = _objc_msgSend(self_03,sel_movie,iVar19,puVar30,iVar46);
                        dVar36 = _objc_msgSend_fpret(pvVar27,sel_soundFadeOutTime);
                        fVar8 = (float)dVar36;
                        if ((fVar8 != 0.0) || (NAN(fVar8))) {
                          fVar37 = ABS(fVar8);
                        }
                        else {
                          fVar37 = 1.0;
                        }
                        fVar38 = 0.0005;
                        if (1.0 <= fVar37) {
                          fVar38 = fVar37 * 0.0005;
                        }
                        if (fVar38 + 0.0 < fVar8) {
                          uVar20 = _GetTrackID(uVar28);
                          puVar30 = self_00;
                          _objc_msgSend(self,
                                        sel_scheduleAddingNotThreadSafeComponentForTrackWithID_attributes_
                                        ,uVar20,self_00,iVar46);
                        }
                        _EndMediaEdits(uVar22);
                        sVar13 = _GetMoviesError();
                        if (sVar13 != 0) goto LAB_00269802;
                      }
                    }
                  }
                }
              }
            }
            local_104 = (id)((int)local_104 + 1);
          } while( true );
        }
        goto LAB_0026981a;
      }
LAB_0026986f:
      _objc_msgSend(pvVar14,sel_release,puVar42,puVar30,iVar46);
      pcVar40 = sel_writeMovieToFile;
      if (self->_scheduledProcessing != (id)0x0) {
        pvVar14 = _objc_msgSend(self->_movie,sel_detachFromCurrentThread,puVar42,puVar30,iVar46);
        uVar5._0_1_ = self->_lazyMovieCreation[0];
        uVar5._1_1_ = self->_roundedCornersForMovie[0];
        uVar5._2_1_ = self->_isWaitingForActivation[0];
        uVar5._3_1_ = self->_isThreadRoutineStarted[0];
        *(uint *)self->_lazyMovieCreation = (uint)((char)pvVar14 == '\0') * 8 + (uVar5 & 0xfffffff7)
        ;
        puVar30 = _objc_msgSend(self->_delegate,sel_playbackThread);
        iVar46 = 0;
        pcVar40 = sel_performSelector_onThread_withObject_waitUntilDone_;
        puVar42 = (undefined4 *)sel_processNotThreadSafeComponent;
      }
      _objc_msgSend(self,pcVar40,puVar42,puVar30,iVar46);
    }
  }
  if ((self->_lazyMovieCreation[0] & 8) != 0) {
    _objc_msgSend(self->_movie,sel_detachFromCurrentThread);
  }
  _objc_msgSend(cls_QTMovie,sel_exitQTKitOnThread);
  _objc_msgSend(self_01,sel_release);
  return;
LAB_00269802:
  _objc_msgSend(pvVar26,sel_detachFromCurrentThread);
LAB_0026981a:
  local_140 = (id)((int)local_140 + 1);
  if (local_148 <= local_140) goto code_r0x00269833;
  goto LAB_002692d1;
code_r0x00269833:
  puVar30 = local_50;
  puVar42 = &local_74;
  iVar46 = 0x10;
  local_148 = _objc_msgSend(pvVar14,sel_countByEnumeratingWithState_objects_count_,puVar42,puVar30,
                            0x10);
  if (local_148 == (id)0x0) goto LAB_0026986f;
  goto LAB_002692c7;
}

*/
- (void)processingThreadRoutine:(id)aRoutine
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [QTMovie enterQTKitOnThread];
    _isThreadRoutineStarted = [_movie attachToCurrentThread];
    pthread_mutex_lock(&_processingThreadMutex);
    _isWaitingForActivation = YES;
    pthread_cond_signal(&_processingThreadCondition);
    if (!_isThreadRoutineStarted) {
        pthread_mutex_unlock(&_processingThreadMutex);
    } else {
        while (!_isProcessingCanceled && _outputMovieFilePath == nil) {
            pthread_cond_wait(&_processingThreadCondition, &_processingThreadMutex);
        }
        pthread_mutex_unlock(&_processingThreadMutex);
        if (!_isProcessingCanceled && _outputMovieFilePath != nil) {
            // The original rendered through an OpenGL context into a packed pixel buffer and added raw video
            // samples with AddMediaSample2 when _lazyMovieCreation was set; HSQTKit builds the video track from
            // images, so every frame takes the CGImage path.
            for (;;) {
                pthread_mutex_lock(&_processingThreadMutex);
                struct HSFramesQueueItem *item = NULL;
                while (!_isProcessingCanceled && (item = _videoFramesQueue->f0) == NULL) {
                    pthread_cond_wait(&_processingThreadCondition, &_processingThreadMutex);
                }
                pthread_mutex_unlock(&_processingThreadMutex);
                if (_isProcessingCanceled || item->buffer == NULL) {
                    break;
                }
                NSAutoreleasePool *framePool = [NSAutoreleasePool new];
                CVPixelBufferRef buffer = CVPixelBufferRetain(item->buffer);
                struct HyperStudio_anon7 itemDuration = item->duration;
                pthread_mutex_lock(&_processingThreadMutex);
                struct HSFramesQueue *queue = _videoFramesQueue;
                item = queue->f0;
                if (item != NULL) {
                    // The item moves to the free list.
                    queue->f0 = item->next;
                    if (item->next != NULL) {
                        item->next->previous = NULL;
                    }
                    item->next = queue->f2;
                    if (queue->f2 != NULL) {
                        queue->f2->previous = item;
                    }
                    queue->f2 = item;
                    if (queue->f1 == item) {
                        queue->f1 = NULL;
                    }
                    CVPixelBufferRelease(item->buffer);
                    queue->f3--;
                }
                if (_isWaitingForVideo && _videoFramesQueue->f3 < _videoFramesQueueLimit) {
                    pthread_cond_signal(&_processingThreadCondition);
                }
                pthread_mutex_unlock(&_processingThreadMutex);
                if (buffer == NULL) {
                    break;
                }
                CGImageRef cgImage = (CGImageRef)CVBufferGetAttachment(buffer, CFSTR("HSPixelBufferCGImage"), NULL);
                if (cgImage == NULL) {
                    cgImage = CGEImageCreateWithPixelBuffer(buffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
                } else {
                    CGImageRetain(cgImage);
                }
                if (cgImage == NULL) {
                    break;
                }
                CGFloat imageWidth = CGImageGetWidth(cgImage);
                CGFloat imageHeight = CGImageGetHeight(cgImage);
                NSSize frameSize = NSEqualSizes(_movieSize, NSZeroSize) ? NSMakeSize(imageWidth, imageHeight) : _movieSize;
                NSRect drawRect = NSMakeRect(0.0, 0.0, imageWidth, imageHeight);
                NSImage *image = [[NSImage alloc] initWithSize:frameSize];
                if (!NSEqualSizes(frameSize, NSMakeSize(imageWidth, imageHeight))) {
                    CGFloat scale = imageHeight / frameSize.height;
                    if (scale <= imageWidth / frameSize.width) {
                        scale = imageWidth / frameSize.width;
                    }
                    drawRect.size = NSMakeSize(floor(imageWidth / scale), floor(imageHeight / scale));
                    drawRect.origin = NSMakePoint((frameSize.width - drawRect.size.width) * 0.5, (frameSize.height - drawRect.size.height) * 0.5);
                }
                [image lockFocus];
                if (_roundedCornersForMovie) {
                    if (_cornersClipPath == nil) {
                        _cornersClipPath = [[NSBezierPath smkRoundedBorderPathWithRect:drawRect cornerRadius:16.0] retain];
                    }
                    [[NSColor blackColor] set];
                    NSRectFill(drawRect);
                    [_cornersClipPath setClip];
                }
                CGContextDrawImage((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort], NSRectToCGRect(drawRect), cgImage);
                [image unlockFocus];
                CGImageRelease(cgImage);
                QTTime duration = HSRecorderQTTimeFromDuration(itemDuration);
                [_movie addImage:image forDuration:duration withAttributes:_videoFramesAttributes];
                [image release];
                CVPixelBufferRelease(buffer);
                [framePool release];
            }
            pthread_mutex_lock(&_processingThreadMutex);
            _isWaitingForAudio = YES;
            if (_isAudioCapturingUsed && !_isAudioCaptirungDidFinish) {
                pthread_cond_wait(&_processingThreadCondition, &_processingThreadMutex);
            }
            _isWaitingForAudio = NO;
            QTTime movieDuration = [_movie duration];
            double movieSeconds = (movieDuration.timeScale != 0) ? (double)movieDuration.timeValue / (double)movieDuration.timeScale : 0.0;
            NSMutableArray *soundMovies = _soundMovies;
            _soundMovies = nil;
            pthread_mutex_unlock(&_processingThreadMutex);
            for (NSDictionary *entry in soundMovies) {
                QTMovie *soundMovie = [entry objectForKey:@"HSRecorderQTMovieKey"];
                if (soundMovie == nil) {
                    continue;
                }
                HSMoviePlaybackLogItem *playbackItem = [entry objectForKey:@"HSRecorderPlaybackAttributesKey"];
                [soundMovie attachToCurrentThread];
                NSArray *soundTracks = [soundMovie tracksOfMediaType:QTMediaTypeSound];
                NSUInteger trackCount = (movieSeconds != 0.0) ? [soundTracks count] : 0;
                long soundScale = [soundMovie duration].timeScale;
                short volume = (playbackItem == nil) ? 0x100 : (short)(int)([playbackItem volume] * 256.0);
                double currentPlaybackTime = [playbackItem currentPlaybackTime];
                for (NSUInteger i = trackCount; i > 0 && !_isProcessingCanceled; i--) {
                    QTTrack *soundTrack = [soundTracks objectAtIndex:i - 1];
                    double startTime = 0.0;
                    double length;
                    if (playbackItem != nil) {
                        startTime = [playbackItem startTime];
                    }
                    if (playbackItem != nil && [playbackItem duration] > 0.0) {
                        length = [playbackItem duration];
                    } else {
                        NSTimeInterval soundSeconds = 0.0;
                        QTGetTimeInterval([soundMovie duration], &soundSeconds);
                        length = soundSeconds;
                    }
                    if (movieSeconds < startTime + length) {
                        length = movieSeconds - startTime;
                    }
                    // InsertTrackSegment on a new movie track in the original; HSQTKit inserts the segment itself.
                    QTTimeRange source = QTMakeTimeRange(QTMakeTime((long long)(currentPlaybackTime * soundScale), soundScale), QTMakeTime((long long)(length * soundScale), soundScale));
                    QTTrack *inserted = [_movie insertSegmentOfTrack:soundTrack timeRange:source atTime:QTMakeTime((long long)(startTime * 600.0), 600)];
                    [inserted setVolume:(float)volume / 256.0f];
                    if ([[(id)[playbackItem movie] valueForKey:@"soundFadeOutTime"] doubleValue] > 0.0005 && inserted != nil) {
                        [self scheduleAddingNotThreadSafeComponentForTrackWithID:[[inserted attributeForKey:QTTrackIDAttribute] longValue] attributes:entry];
                    }
                }
                [soundMovie detachFromCurrentThread];
            }
            [soundMovies release];
            if (_scheduledProcessing != nil) {
                // The fade-outs are applied on the playback thread (QuickTime tween tracks are not thread safe).
                _isThreadRoutineStarted = ![_movie detachFromCurrentThread];
                [self performSelector:@selector(processNotThreadSafeComponent) onThread:[_delegate playbackThread] withObject:nil waitUntilDone:NO];
            } else {
                [self writeMovieToFile];
            }
        }
    }
    if (_isThreadRoutineStarted) {
        [_movie detachFromCurrentThread];
    }
    [QTMovie exitQTKitOnThread];
    [pool release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00269977 @ 00269977, 448 bytes * /

void FUN_00269977(HSThreadContext *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  
  self_00 = _objc_msgSend(cls_NSMutableDictionary,sel_new);
  pvVar2 = *(id *)PTR_00336908;
  pvVar1 = _objc_msgSend(self->_videoFramesAttributes,sel_objectForKey_,pvVar2);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1);
    _objc_msgSend(self_00,sel_setObject_forKey_,pvVar2,*(undefined4 *)PTR_00336948);
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithLong_,0x4d6f6f56);
    _objc_msgSend(self_00,sel_setObject_forKey_,pvVar2,*(undefined4 *)PTR_0033694c);
  }
  _objc_msgSend(self->_movie,sel_updateMovieFile,pvVar2);
  if ((self->_lazyMovieCreation[0] & 0x10) == 0) {
    pvVar2 = self->_outputMovieFilePath;
    pvVar1 = _objc_msgSend(self->_movie,sel_writeToFile_withAttributes_,pvVar2,self_00);
    if ((char)pvVar1 == '\0') {
      pvVar2 = (id)0x200;
      pvVar1 = _objc_msgSend(cls_HSError,sel_fileErrorWithHSCode_filePath_,0x200,
                             self->_outputMovieFilePath);
      goto LAB_00269acf;
    }
  }
  pvVar1 = (id)0x0;
LAB_00269acf:
  _objc_msgSend(self_00,sel_release,pvVar2);
  _pthread_mutex_lock((pthread_mutex_t *)&self->_delegateMutex);
  if ((self->_lazyMovieCreation[0] & 0x10) == 0) {
    _objc_msgSend(self->_delegate,
                  sel_HSThreadContextDelegate_threadContext_didFinishFlatteningToFile_dueToError_,
                  self,self->_outputMovieFilePath,pvVar1);
  }
  _pthread_mutex_unlock((pthread_mutex_t *)&self->_delegateMutex);
  return;
}

*/
- (void)writeMovieToFile
{
    NSMutableDictionary *exportAttributes = [NSMutableDictionary new];
    if ([_videoFramesAttributes objectForKey:QTAddImageCodecType] != nil) {
        [exportAttributes setObject:[NSNumber numberWithBool:YES] forKey:QTMovieExport];
        [exportAttributes setObject:[NSNumber numberWithLong:'MooV'] forKey:QTMovieExportType];
    }
    [_movie updateMovieFile];
    NSError *error = nil;
    if (!_isProcessingCanceled) {
        if (![_movie writeToFile:_outputMovieFilePath withAttributes:exportAttributes]) {
            error = [HSError fileErrorWithHSCode:0x200 filePath:_outputMovieFilePath];
        }
    }
    [exportAttributes release];
    pthread_mutex_lock(&_delegateMutex);
    if (!_isProcessingCanceled) {
        [_delegate HSThreadContextDelegate_threadContext:self didFinishFlatteningToFile:_outputMovieFilePath dueToError:error];
    }
    pthread_mutex_unlock(&_delegateMutex);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00269b37 @ 00269b37, 908 bytes * /

void FUN_00269b37(HSThreadContext *self,SEL _cmd)

{
  id self_00;
  int iVar1;
  short sVar2;
  id self_01;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int iVar7;
  undefined4 uVar8;
  int iVar9;
  int iVar10;
  int iVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  double dVar15;
  id local_80;
  
  self_01 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  _objc_msgSend(cls_QTMovie,sel_enterQTKitOnThread);
  _objc_msgSend(self->_movie,sel_attachToCurrentThread);
  self_00 = self->_scheduledProcessing;
  pvVar3 = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_);
  iVar1 = iRam00000000;
  while (pvVar3 != (id)0x0) {
    local_80 = (id)0x0;
    do {
      if (iVar1 != iRam00000000) {
        _objc_enumerationMutation(self->_scheduledProcessing);
      }
      pvVar5 = *(id *)((int)local_80 * 4);
      pvVar4 = _objc_msgSend(self->_scheduledProcessing,sel_objectForKey_);
      pvVar5 = _objc_msgSend(pvVar5,sel_longValue);
      pvVar6 = _objc_msgSend(self->_movie,sel_quickTimeMovie);
      iVar7 = _GetMovieTrack(pvVar6,pvVar5);
      if (iVar7 != 0) {
        pvVar5 = _objc_msgSend(pvVar4,sel_objectForKey_);
        pvVar4 = _objc_msgSend(pvVar5,sel_movie);
        dVar15 = _objc_msgSend_fpret(pvVar4,sel_soundFadeOutTime);
        if (pvVar5 != (id)0x0) {
          fVar12 = (float)dVar15;
          if ((fVar12 != 0.0) || (NAN(fVar12))) {
            fVar13 = ABS(fVar12);
          }
          else {
            fVar13 = 1.0;
          }
          fVar14 = 0.0005;
          if (1.0 <= fVar13) {
            fVar14 = fVar13 * 0.0005;
          }
          if (fVar14 + 0.0 < fVar12) {
            pvVar5 = _objc_msgSend(pvVar5,sel_movie);
            pvVar5 = _objc_msgSend(pvVar5,sel_quickTimeMovie);
            if (pvVar5 != (id)0x0) {
              uVar8 = _GetMovieTimeBase(pvVar5);
              sVar2 = _GetMoviesError();
              if (sVar2 == 0) {
                iVar9 = _GetMovieTimeScale(pvVar5);
                sVar2 = _GetMoviesError();
                if (sVar2 == 0) {
                  iVar10 = _GetTimeBaseStartTime(uVar8,iVar9,0);
                  iVar11 = _GetTimeBaseStopTime(uVar8,iVar9,0);
                  FUN_002a3e08(iVar7,(double)(iVar11 - ((int)(dVar15 * (double)iVar9) + iVar10)) /
                                     (double)iVar9,dVar15);
                }
              }
            }
          }
        }
      }
      local_80 = (id)((int)local_80 + 1);
    } while (local_80 < pvVar3);
    pvVar3 = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_);
  }
  _objc_msgSend(self,sel_writeMovieToFile);
  _objc_msgSend(cls_QTMovie,sel_exitQTKitOnThread);
  _objc_msgSend(self_01,sel_drain);
  return;
}

*/
- (void)processNotThreadSafeComponent
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [QTMovie enterQTKitOnThread];
    [_movie attachToCurrentThread];
    // The original also added a fade-out (a QuickTime tween track, FUN_002a3e08) to the sound tracks scheduled
    // in _scheduledProcessing whose movie has a sound fade-out time; HSQTKit tracks have no volume ramp, so
    // the sounds are written without it.
    [self writeMovieToFile];
    [QTMovie exitQTKitOnThread];
    [pool drain];
}

- (void)scheduleAddingNotThreadSafeComponentForTrackWithID:(NSInteger)aID attributes:(id)aAttributes
{
    id self_00;

    self_00 = _scheduledProcessing;
    if (self_00 == nil) {
        self_00 = [NSMutableDictionary new];
        _scheduledProcessing = self_00;
    }
    if (aAttributes != nil) {
        [self_00 setObject:aAttributes forKey:[NSNumber numberWithLong:aID]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00269ec3 @ 00269ec3, 122 bytes * /

BOOL FUN_00269ec3(HSThreadContext *self,SEL _cmd)

{
  opaque_pthread_mutex_t *poVar1;
  uint uVar2;
  BOOL BVar3;
  int iVar4;
  timespec local_1c;
  
  poVar1 = &self->_processingThreadMutex;
  _pthread_mutex_lock((pthread_mutex_t *)poVar1);
  do {
    if ((self->_lazyMovieCreation[0] & 4) != 0) break;
    local_1c.tv_sec = _time(0);
    local_1c.tv_sec = local_1c.tv_sec + 10;
    local_1c.tv_nsec = 0;
    iVar4 = _pthread_cond_timedwait
                      ((pthread_cond_t *)&self->_processingThreadCondition,(pthread_mutex_t *)poVar1
                       ,&local_1c);
  } while (iVar4 == 0);
  _pthread_mutex_unlock((pthread_mutex_t *)poVar1);
  uVar2._0_1_ = self->_lazyMovieCreation[0];
  uVar2._1_1_ = self->_roundedCornersForMovie[0];
  uVar2._2_1_ = self->_isWaitingForActivation[0];
  uVar2._3_1_ = self->_isThreadRoutineStarted[0];
  BVar3 = -1;
  if ((uVar2 & 8) == 0) {
    BVar3 = '\0';
  }
  return BVar3;
}

*/
- (BOOL)isProcessingThreadRoutineStarted
{
    pthread_mutex_lock(&_processingThreadMutex);
    // Wait until the processing thread has either started or given up; the wait is retried every 10 seconds.
    do {
        if (_isWaitingForActivation) {
            break;
        }
        struct timespec timeout;
        timeout.tv_sec = time(NULL) + 10;
        timeout.tv_nsec = 0;
        if (pthread_cond_timedwait(&_processingThreadCondition, &_processingThreadMutex, &timeout) != 0) {
            break;
        }
    } while (YES);
    pthread_mutex_unlock(&_processingThreadMutex);
    return _isThreadRoutineStarted;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026508d @ 0026508d, 371 bytes * /

BOOL FUN_0026508d(HSThreadContext *self,SEL _cmd,NSSize prepareOpenGLContextWithTextureSize)

{
  id pvVar1;
  NSSize NVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(self,sel_createOpenGLContext);
  if (((char)pvVar1 != '\0') &&
     (NVar2 = prepareOpenGLContextWithTextureSize,
     pvVar1 = _objc_msgSend(self,sel_canUseOpenGLContextWithTextureSize_,
                            prepareOpenGLContextWithTextureSize.width,
                            prepareOpenGLContextWithTextureSize.height), (char)pvVar1 != '\0')) {
    pvVar1 = _objc_msgSend(cls_NSWindow,sel_alloc,NVar2);
    uVar3 = 0;
    uVar6 = 0;
    uVar5 = 1;
    uVar4 = 0;
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithContentRect_styleMask_backing_defer_,0,
                           prepareOpenGLContextWithTextureSize,0,1,0);
    self->_offscreenWindow = pvVar1;
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(pvVar1,sel_setReleasedWhenClosed_,0,uVar3,prepareOpenGLContextWithTextureSize,
                    uVar4,uVar5,uVar6);
      _objc_msgSend(self->_offscreenWindow,sel_useOptimizedDrawing_,1);
      pvVar1 = _objc_msgSend(self->_offscreenWindow,sel_contentView);
      if (pvVar1 != (id)0x0) {
        _objc_msgSend(self->_openGLContext,sel_setView_,pvVar1,uVar3,
                      prepareOpenGLContextWithTextureSize,uVar4,uVar5,uVar6);
        return '\x01';
      }
    }
  }
  _objc_msgSend(self,sel_destroyOpenGLContext);
  return '\0';
}

*/
- (BOOL)prepareOpenGLContextWithTextureSize:(NSSize)aSize
{
    if ([self createOpenGLContext] && [self canUseOpenGLContextWithTextureSize:aSize]) {
        _offscreenWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, aSize.width, aSize.height) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreRetained defer:NO];
        if (_offscreenWindow != nil) {
            [_offscreenWindow setReleasedWhenClosed:NO];
            [_offscreenWindow useOptimizedDrawing:YES];
            NSView *contentView = [_offscreenWindow contentView];
            if (contentView != nil) {
                [_openGLContext setView:contentView];
                return YES;
            }
        }
    }
    [self destroyOpenGLContext];
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00269f3d @ 00269f3d, 436 bytes * /

BOOL FUN_00269f3d(HSThreadContext *self,SEL _cmd,NSSize canUseOpenGLContextWithTextureSize)

{
  char cVar1;
  id pvVar2;
  undefined *self_00;
  int iVar3;
  BOOL BVar4;
  undefined *self_01;
  SEL op;
  int local_1c;
  int local_18;
  int local_14;
  
  pvVar2 = _objc_msgSend(self,sel_createOpenGLContext);
  if ((char)pvVar2 == '\0') {
    return '\0';
  }
  pvVar2 = _objc_msgSend(cls_NSOpenGLContext,sel_currentContext);
  self_00 = _objc_msgSend(pvVar2,sel_retain);
  _objc_msgSend(self->_openGLContext,sel_makeCurrentContext);
  pvVar2 = _objc_msgSend(self->_openGLContext,sel_CGLContextObj);
  iVar3 = _CGLLockContext(pvVar2);
  if (iVar3 != 0) {
    BVar4 = '\0';
    goto LAB_0026a09e;
  }
  iVar3 = _glGetString("/Versions/A/Carbon");
  if ((iVar3 == 0) || (cVar1 = _gluCheckExtension("GL_EXT_texture_rectangle",iVar3), cVar1 == '\0'))
  {
LAB_00269fe9:
    BVar4 = '\0';
  }
  else {
    local_14 = 0;
    _glGetIntegerv(0x84f8,&local_14);
    if (((float)local_14 < canUseOpenGLContextWithTextureSize.width) ||
       ((float)local_14 < canUseOpenGLContextWithTextureSize.height)) goto LAB_00269fe9;
    local_1c = 0;
    local_18 = 0;
    _glGetIntegerv(0xd3a,&local_1c);
    if (((float)local_1c < canUseOpenGLContextWithTextureSize.width) ||
       ((float)local_18 < canUseOpenGLContextWithTextureSize.height)) goto LAB_00269fe9;
    BVar4 = '\x01';
  }
  pvVar2 = _objc_msgSend(self->_openGLContext,sel_CGLContextObj);
  _CGLUnlockContext(pvVar2);
LAB_0026a09e:
  self_01 = cls_NSOpenGLContext;
  op = sel_clearCurrentContext;
  if (self_00 != (undefined *)0x0) {
    _objc_msgSend(self_00,sel_makeCurrentContext);
    self_01 = self_00;
    op = sel_release;
  }
  _objc_msgSend(self_01,op);
  return BVar4;
}

*/
- (BOOL)canUseOpenGLContextWithTextureSize:(NSSize)aSize
{
    if (![self createOpenGLContext]) {
        return NO;
    }
    NSOpenGLContext *previousContext = [[NSOpenGLContext currentContext] retain];
    [_openGLContext makeCurrentContext];
    CGLContextObj cglContext = [_openGLContext CGLContextObj];
    BOOL canUse = YES;
    if (CGLLockContext(cglContext) != 0) {
        canUse = NO;
    }
    const GLubyte *extensions = glGetString(GL_EXTENSIONS);
    if (extensions == NULL || !gluCheckExtension((const GLubyte *)"GL_EXT_texture_rectangle", extensions)) {
        canUse = NO;
    } else {
        GLint maxRectangleSize = 0;
        glGetIntegerv(GL_MAX_RECTANGLE_TEXTURE_SIZE_EXT, &maxRectangleSize);
        if ((CGFloat)maxRectangleSize < aSize.width || (CGFloat)maxRectangleSize < aSize.height) {
            canUse = NO;
        } else {
            GLint maxViewport[2] = { 0, 0 };
            glGetIntegerv(GL_MAX_VIEWPORT_DIMS, maxViewport);
            canUse = !((CGFloat)maxViewport[0] < aSize.width || (CGFloat)maxViewport[1] < aSize.height);
        }
    }
    CGLUnlockContext(cglContext);
    if (previousContext != nil) {
        [previousContext makeCurrentContext];
        [previousContext release];
    } else {
        [NSOpenGLContext clearCurrentContext];
    }
    return canUse;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00264fd6 @ 00264fd6, 183 bytes * /

void FUN_00264fd6(HSThreadContext *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  
  if (self->_openGLContext != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSOpenGLContext,sel_currentContext);
    self_00 = self->_openGLContext;
    if (pvVar1 == self_00) {
      _objc_msgSend(cls_NSOpenGLContext,sel_clearCurrentContext);
      self_00 = self->_openGLContext;
    }
    _objc_msgSend(self_00,sel_clearDrawable);
    _objc_msgSend(self->_openGLContext,sel_release);
    self->_openGLContext = (id)0x0;
  }
  _objc_msgSend(self->_offscreenWindow,sel_release);
  self->_offscreenWindow = (id)0x0;
  return;
}

*/
- (void)destroyOpenGLContext
{
    if (_openGLContext != nil) {
        if ([NSOpenGLContext currentContext] == _openGLContext) {
            [NSOpenGLContext clearCurrentContext];
        }
        [_openGLContext clearDrawable];
        [_openGLContext release];
        _openGLContext = nil;
    }
    [_offscreenWindow release];
    _offscreenWindow = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00264f06 @ 00264f06, 208 bytes * /

BOOL FUN_00264f06(HSThreadContext *self,SEL _cmd)

{
  id pvVar1;
  undefined4 *self_00;
  undefined4 *puVar2;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  
  pvVar1 = self->_openGLContext;
  if (pvVar1 == (id)0x0) {
    local_1c = 0x50;
    local_18 = 0x49;
    local_14 = 0;
    pvVar1 = _objc_msgSend(cls_NSOpenGLPixelFormat,sel_alloc);
    puVar2 = &local_1c;
    self_00 = _objc_msgSend(pvVar1,sel_initWithAttributes_,puVar2);
    if (self_00 != (undefined4 *)0x0) {
      pvVar1 = _objc_msgSend(cls_NSOpenGLContext,sel_alloc,puVar2);
      puVar2 = self_00;
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithFormat_shareContext_,self_00,0);
      self->_openGLContext = pvVar1;
    }
    _objc_msgSend(self_00,sel_release,puVar2);
    pvVar1 = self->_openGLContext;
  }
  return pvVar1 != (id)0x0;
}

*/
- (BOOL)createOpenGLContext
{
    if (_openGLContext == nil) {
        NSOpenGLPixelFormatAttribute attributes[] = { NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, 0 };
        NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
        if (format != nil) {
            _openGLContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
        }
        [format release];
    }
    return _openGLContext != nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00264e10 @ 00264e10, 33 bytes * /

void FUN_00264e10(HSThreadContext *self,SEL _cmd,BOOL setLazyMovieCreation)

{
  uint uVar1;
  
  uVar1._0_1_ = self->_lazyMovieCreation[0];
  uVar1._1_1_ = self->_roundedCornersForMovie[0];
  uVar1._2_1_ = self->_isWaitingForActivation[0];
  uVar1._3_1_ = self->_isThreadRoutineStarted[0];
  *(uint *)self->_lazyMovieCreation = (uVar1 & 0xfffffffe) + (uint)(setLazyMovieCreation & 1);
  return;
}

*/
- (void)setLazyMovieCreation:(BOOL)aCreation
{
    _lazyMovieCreation = aCreation;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00264df6 @ 00264df6, 26 bytes * /

BOOL FUN_00264df6(HSThreadContext *self,SEL _cmd)

{
  uint uVar1;
  BOOL BVar2;
  
  uVar1._0_1_ = self->_lazyMovieCreation[0];
  uVar1._1_1_ = self->_roundedCornersForMovie[0];
  uVar1._2_1_ = self->_isWaitingForActivation[0];
  uVar1._3_1_ = self->_isThreadRoutineStarted[0];
  BVar2 = -1;
  if ((uVar1 & 1) == 0) {
    BVar2 = '\0';
  }
  return BVar2;
}

*/
- (BOOL)isLazyMovieCreation
{
    return _lazyMovieCreation;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026a0f1 @ 0026a0f1, 704 bytes * /

/* WARNING: Type propagation algorithm not settling * /

BOOL FUN_0026a0f1(HSThreadContext *self,SEL _cmd,double removeFrameItemWithSmallestDuration,
                 double *removedLastFrameDuration)

{
  HSFramesQueue *pHVar1;
  undefined8 **ppuVar2;
  BOOL BVar3;
  int iVar4;
  void **ppvVar5;
  void **ppvVar6;
  undefined8 **ppuVar7;
  void *pvVar8;
  int aiStackY_88 [2];
  undefined8 *local_80;
  void **local_48;
  undefined8 local_44;
  undefined4 local_3c;
  undefined4 local_38;
  undefined8 local_34;
  undefined4 local_2c;
  undefined4 local_28;
  
  local_80 = (undefined8 *)0x26a111;
  _pthread_mutex_lock((pthread_mutex_t *)&self->_processingThreadMutex);
  ppuVar2 = (undefined8 **)&stack0xffffff84;
  if ((self->_videoFramesQueue != (HSFramesQueue *)0x0) &&
     (ppvVar5 = self->_videoFramesQueue->f1, ppuVar2 = (undefined8 **)&stack0xffffff84,
     ppvVar5 != (void **)0x0)) {
    local_80 = (undefined8 *)0x26a141;
    _llroundf();
    local_80 = (undefined8 *)0x26a15c;
    _QTMakeTime();
    ppuVar7 = &local_80;
    local_48 = (void **)0x0;
    do {
      local_80 = ppvVar5[1];
      aiStackY_88[1] = 0x26a1db;
      iVar4 = _QTTimeCompare();
      if (iVar4 == -1) {
        local_48 = ppvVar5;
      }
      ppvVar5 = ppvVar5[5];
    } while (ppvVar5 != (void **)0x0);
    ppuVar2 = &local_80;
    if (local_48 != (void **)0x0) {
      if (self->_videoFramesQueue->f0 == self->_videoFramesQueue->f1) {
        ppuVar7 = &local_80;
        if (removedLastFrameDuration != (double *)0x0) {
          local_80 = local_48[1];
          aiStackY_88[1] = 0x26a239;
          _QTGetTimeInterval();
          ppuVar7 = &local_80;
        }
      }
      else {
        pvVar8 = local_48[5];
        if (pvVar8 == (void *)0x0) {
          pvVar8 = local_48[6];
          if (pvVar8 == (void *)0x0) goto LAB_0026a330;
          local_80 = &local_44;
          aiStackY_88[1] = 0x26a317;
          _QTTimeIncrement();
          *(undefined8 *)((int)pvVar8 + 4) = local_44;
          *(undefined4 *)((int)pvVar8 + 0xc) = local_3c;
          local_28 = local_38;
        }
        else {
          local_80 = &local_34;
          aiStackY_88[1] = 0x26a2a0;
          _QTTimeIncrement();
          *(undefined8 *)((int)pvVar8 + 4) = local_34;
          *(undefined4 *)((int)pvVar8 + 0xc) = local_2c;
        }
        ppuVar7 = (undefined8 **)(aiStackY_88 + 1);
        *(undefined4 *)((int)pvVar8 + 0x10) = local_28;
      }
LAB_0026a330:
      pHVar1 = self->_videoFramesQueue;
      if ((pHVar1->f0 != (void **)0x0) && (local_48 != (void **)0x0)) {
        ppvVar5 = local_48[6];
        if (local_48[5] == (void *)0x0) {
          pHVar1->f0 = ppvVar5;
          ppvVar5 = local_48[5];
          ppvVar6 = local_48[6];
        }
        else {
          local_48[5] = ppvVar5;
          ppvVar6 = ppvVar5;
        }
        if (ppvVar6 == (void **)0x0) {
          pHVar1->f1 = ppvVar5;
        }
        else {
          local_48[6] = ppvVar5;
        }
        local_48[6] = pHVar1->f2;
        if (pHVar1->f2 != (void **)0x0) {
          pHVar1->f2[5] = local_48;
        }
        pHVar1->f2 = local_48;
        *ppuVar7 = *local_48;
        ppuVar7[-1] = (undefined8 *)0x26a394;
        _CVPixelBufferRelease();
        pHVar1->f3 = pHVar1->f3 - 1;
      }
      BVar3 = '\x01';
      goto LAB_0026a399;
    }
  }
  ppuVar7 = ppuVar2;
  BVar3 = '\0';
LAB_0026a399:
  *ppuVar7 = (undefined8 *)&self->_processingThreadMutex;
  ppuVar7[-1] = (undefined8 *)0x26a3a7;
  _pthread_mutex_unlock((pthread_mutex_t *)*ppuVar7);
  return BVar3;
}

*/
- (BOOL)removeFrameItemWithSmallestDuration:(double)aDuration removedLastFrameDuration:(double *)aDuration2
{
    BOOL removed = NO;
    pthread_mutex_lock(&_processingThreadMutex);
    if (_videoFramesQueue != NULL && _videoFramesQueue->f1 != NULL) {
        QTTime threshold = QTMakeTime(llroundf((float)(aDuration * 600.0)), 600);
        struct HSFramesQueueItem *smallest = NULL;
        // Walk from the newest frame back to the oldest, keeping the shortest one under the threshold.
        for (struct HSFramesQueueItem *item = _videoFramesQueue->f1; item != NULL; item = item->previous) {
            QTTime limit = (smallest != NULL) ? HSRecorderQTTimeFromDuration(smallest->duration) : threshold;
            if (QTTimeCompare(HSRecorderQTTimeFromDuration(item->duration), limit) == NSOrderedAscending) {
                smallest = item;
            }
        }
        if (smallest != NULL) {
            if (_videoFramesQueue->f0 == _videoFramesQueue->f1) {
                if (aDuration2 != NULL) {
                    QTGetTimeInterval(HSRecorderQTTimeFromDuration(smallest->duration), aDuration2);
                }
            } else {
                // The dropped frame's time goes to its neighbour (the previous frame, else the next one).
                struct HSFramesQueueItem *neighbour = (smallest->previous != NULL) ? smallest->previous : smallest->next;
                if (neighbour != NULL) {
                    QTTime merged = QTTimeIncrement(HSRecorderQTTimeFromDuration(neighbour->duration), HSRecorderQTTimeFromDuration(smallest->duration));
                    neighbour->duration.f0 = merged.timeValue;
                    neighbour->duration.f1 = (int)merged.timeScale;
                    neighbour->duration.f2 = (int)merged.flags;
                }
            }
            struct HSFramesQueue *queue = _videoFramesQueue;
            if (queue->f0 != NULL) {
                struct HSFramesQueueItem *previous = smallest->previous;
                struct HSFramesQueueItem *next = smallest->next;
                if (previous == NULL) {
                    queue->f0 = next;
                } else {
                    previous->next = next;
                }
                if (next == NULL) {
                    queue->f1 = previous;
                } else {
                    next->previous = previous;
                }
                // The item goes to the free list for reuse.
                smallest->next = queue->f2;
                if (queue->f2 != NULL) {
                    queue->f2->previous = smallest;
                }
                queue->f2 = smallest;
                CVPixelBufferRelease(smallest->buffer);
                queue->f3--;
            }
            removed = YES;
        }
    }
    pthread_mutex_unlock(&_processingThreadMutex);
    return removed;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026a3b1 @ 0026a3b1, 353 bytes * /

void FUN_0026a3b1(HSThreadContext *self,SEL _cmd,CVBuffer *addNewItemWithFrameBuffer,
                 anon_16f4042c_24 duration,BOOL isLastFrame)

{
  opaque_pthread_mutex_t *poVar1;
  uint uVar2;
  uint uVar3;
  void *pvVar4;
  void **ppvVar5;
  HSFramesQueue *pHVar6;
  
  poVar1 = &self->_processingThreadMutex;
  _pthread_mutex_lock((pthread_mutex_t *)poVar1);
  uVar2._0_1_ = self->_lazyMovieCreation[0];
  uVar2._1_1_ = self->_roundedCornersForMovie[0];
  uVar2._2_1_ = self->_isWaitingForActivation[0];
  uVar2._3_1_ = self->_isThreadRoutineStarted[0];
  uVar3 = uVar2 | 0x80;
  self->_lazyMovieCreation[0] = (char)uVar3;
  self->_roundedCornersForMovie[0] = (char)(uVar3 >> 8);
  self->_isWaitingForActivation[0] = (char)(uVar3 >> 0x10);
  self->_isThreadRoutineStarted[0] = (char)(uVar3 >> 0x18);
  pHVar6 = self->_videoFramesQueue;
  if (self->_videoFramesQueueLimit <= pHVar6->f3) {
    do {
      _pthread_cond_wait((pthread_cond_t *)&self->_processingThreadCondition,
                         (pthread_mutex_t *)poVar1);
      pHVar6 = self->_videoFramesQueue;
    } while (self->_videoFramesQueueLimit <= pHVar6->f3);
    uVar3._0_1_ = self->_lazyMovieCreation[0];
    uVar3._1_1_ = self->_roundedCornersForMovie[0];
    uVar3._2_1_ = self->_isWaitingForActivation[0];
    uVar3._3_1_ = self->_isThreadRoutineStarted[0];
  }
  uVar3 = uVar3 & 0xffffff7f;
  self->_lazyMovieCreation[0] = (char)uVar3;
  self->_roundedCornersForMovie[0] = (char)(uVar3 >> 8);
  self->_isWaitingForActivation[0] = (char)(uVar3 >> 0x10);
  self->_isThreadRoutineStarted[0] = (char)(uVar3 >> 0x18);
  ppvVar5 = pHVar6->f2;
  if (ppvVar5 == (void **)0x0) {
    ppvVar5 = _malloc(0x1c);
  }
  else {
    pHVar6->f2 = ppvVar5[6];
  }
  if (ppvVar5 != (void **)0x0) {
    *ppvVar5 = (void *)0x0;
    ppvVar5[6] = (void *)0x0;
    ppvVar5[5] = (void *)0x0;
    if (pHVar6->f0 == (void **)0x0) {
      pHVar6->f0 = ppvVar5;
    }
    else {
      pHVar6->f1[6] = ppvVar5;
      ppvVar5[5] = pHVar6->f1;
    }
    pHVar6->f1 = ppvVar5;
    pHVar6->f3 = pHVar6->f3 + 1;
  }
  pvVar4 = (void *)_CVPixelBufferRetain(addNewItemWithFrameBuffer);
  *ppvVar5 = pvVar4;
  ppvVar5[2] = duration.f0._4_4_;
  ppvVar5[1] = (void *)duration.f0;
  ppvVar5[3] = (void *)duration.f1;
  ppvVar5[4] = (void *)duration.f2;
  if (self->_videoFramesQueue->f3 == 1) {
    _pthread_cond_signal((pthread_cond_t *)&self->_processingThreadCondition);
  }
  if (isLastFrame != '\0') {
    pHVar6 = self->_videoFramesQueue;
    ppvVar5 = pHVar6->f2;
    if (ppvVar5 == (void **)0x0) {
      ppvVar5 = _malloc(0x1c);
    }
    else {
      pHVar6->f2 = ppvVar5[6];
    }
    if (ppvVar5 != (void **)0x0) {
      *ppvVar5 = (void *)0x0;
      ppvVar5[6] = (void *)0x0;
      ppvVar5[5] = (void *)0x0;
      if (pHVar6->f0 == (void **)0x0) {
        pHVar6->f0 = ppvVar5;
      }
      else {
        pHVar6->f1[6] = ppvVar5;
        ppvVar5[5] = pHVar6->f1;
      }
      pHVar6->f1 = ppvVar5;
      pHVar6->f3 = pHVar6->f3 + 1;
    }
  }
  _pthread_mutex_unlock((pthread_mutex_t *)poVar1);
  return;
}

*/
- (void)addNewItemWithFrameBuffer:(struct __CVBuffer *)aBuffer duration:(struct HyperStudio_anon7)aDuration isLastFrame:(BOOL)aFrame
{
    pthread_mutex_lock(&_processingThreadMutex);
    _isWaitingForVideo = YES;
    struct HSFramesQueue *queue = _videoFramesQueue;
    while (_videoFramesQueueLimit <= queue->f3) {
        pthread_cond_wait(&_processingThreadCondition, &_processingThreadMutex);
        queue = _videoFramesQueue;
    }
    _isWaitingForVideo = NO;
    struct HSFramesQueueItem *item = HSRecorderFramesQueueAppendItem(queue);
    if (item != NULL) {
        item->buffer = CVPixelBufferRetain(aBuffer);
        item->duration = aDuration;
    }
    if (_videoFramesQueue->f3 == 1) {
        pthread_cond_signal(&_processingThreadCondition);
    }
    if (aFrame) {
        // An item without a buffer marks the end of the recording.
        HSRecorderFramesQueueAppendItem(_videoFramesQueue);
    }
    pthread_mutex_unlock(&_processingThreadMutex);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026a512 @ 0026a512, 137 bytes * /

void FUN_0026a512(HSThreadContext *self,SEL _cmd)

{
  uint uVar1;
  uint uVar2;
  
  _pthread_mutex_lock((pthread_mutex_t *)&self->_delegateMutex);
  self->_delegate = (id)0x0;
  _pthread_mutex_unlock((pthread_mutex_t *)&self->_delegateMutex);
  _pthread_mutex_lock((pthread_mutex_t *)&self->_processingThreadMutex);
  uVar1._0_1_ = self->_lazyMovieCreation[0];
  uVar1._1_1_ = self->_roundedCornersForMovie[0];
  uVar1._2_1_ = self->_isWaitingForActivation[0];
  uVar1._3_1_ = self->_isThreadRoutineStarted[0];
  uVar2 = uVar1 | 0x10;
  self->_lazyMovieCreation[0] = (char)uVar2;
  self->_roundedCornersForMovie[0] = (char)(uVar2 >> 8);
  self->_isWaitingForActivation[0] = (char)(uVar2 >> 0x10);
  self->_isThreadRoutineStarted[0] = (char)(uVar2 >> 0x18);
  if (self->_videoFramesQueue->f3 == 0) {
    _pthread_cond_signal((pthread_cond_t *)&self->_processingThreadCondition);
    uVar2._0_1_ = self->_lazyMovieCreation[0];
    uVar2._1_1_ = self->_roundedCornersForMovie[0];
    uVar2._2_1_ = self->_isWaitingForActivation[0];
    uVar2._3_1_ = self->_isThreadRoutineStarted[0];
  }
  if ((uVar2 & 1) != 0) {
    _objc_msgSend(self,sel_destroyOpenGLContext);
  }
  _pthread_mutex_unlock((pthread_mutex_t *)&self->_processingThreadMutex);
  return;
}

*/
- (void)cancelProcessing
{
    pthread_mutex_lock(&_delegateMutex);
    _delegate = nil;
    pthread_mutex_unlock(&_delegateMutex);
    pthread_mutex_lock(&_processingThreadMutex);
    _isProcessingCanceled = YES;
    if (_videoFramesQueue->f3 == 0) {
        pthread_cond_signal(&_processingThreadCondition);
    }
    if (_lazyMovieCreation) {
        [self destroyOpenGLContext];
    }
    pthread_mutex_unlock(&_processingThreadMutex);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026a59b @ 0026a59b, 101 bytes * /

void FUN_0026a59b(HSThreadContext *self,SEL _cmd,BOOL setAudioCaptirungDidFinish)

{
  uint uVar1;
  
  if ((self->_lazyMovieCreation[0] & 0x20) != 0) {
    _pthread_mutex_lock((pthread_mutex_t *)&self->_processingThreadMutex);
    uVar1._0_1_ = self->_lazyMovieCreation[0];
    uVar1._1_1_ = self->_roundedCornersForMovie[0];
    uVar1._2_1_ = self->_isWaitingForActivation[0];
    uVar1._3_1_ = self->_isThreadRoutineStarted[0];
    *(uint *)self->_lazyMovieCreation =
         (uVar1 & 0xfffffeff) + (uint)(setAudioCaptirungDidFinish & 1) * 0x100;
    if ((uVar1 & 0x40) != 0) {
      _pthread_cond_signal((pthread_cond_t *)&self->_processingThreadCondition);
    }
    _pthread_mutex_unlock((pthread_mutex_t *)&self->_processingThreadMutex);
  }
  return;
}

*/
- (void)setAudioCaptirungDidFinish:(BOOL)aFinish
{
    if (_isAudioCapturingUsed) {
        pthread_mutex_lock(&_processingThreadMutex);
        _isAudioCaptirungDidFinish = aFinish;
        if (_isWaitingForAudio) {
            pthread_cond_signal(&_processingThreadCondition);
        }
        pthread_mutex_unlock(&_processingThreadMutex);
    }
}

- (void)removeAllSoundMovies
{
    pthread_mutex_lock((pthread_mutex_t *)&_processingThreadMutex);
    [_soundMovies release];
    _soundMovies = nil;
    pthread_mutex_unlock((pthread_mutex_t *)&_processingThreadMutex);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026a649 @ 0026a649, 119 bytes * /

void FUN_0026a649(HSThreadContext *self,SEL _cmd,id addSoundMovieWithAttributes)

{
  id self_00;
  
  if ((self->_lazyMovieCreation[0] & 0x20) != 0) {
    _pthread_mutex_lock((pthread_mutex_t *)&self->_processingThreadMutex);
    self_00 = self->_soundMovies;
    if (self_00 == (id)0x0) {
      self_00 = _objc_msgSend(cls_NSMutableArray,sel_new);
      self->_soundMovies = self_00;
    }
    if (addSoundMovieWithAttributes != (id)0x0) {
      _objc_msgSend(self_00,sel_addObject_,addSoundMovieWithAttributes);
    }
    _pthread_mutex_unlock((pthread_mutex_t *)&self->_processingThreadMutex);
  }
  return;
}

*/
- (void)addSoundMovieWithAttributes:(id)aAttributes
{
    if (_isAudioCapturingUsed) {
        pthread_mutex_lock(&_processingThreadMutex);
        if (_soundMovies == nil) {
            _soundMovies = [NSMutableArray new];
        }
        if (aAttributes != nil) {
            [_soundMovies addObject:aAttributes];
        }
        pthread_mutex_unlock(&_processingThreadMutex);
    }
}

- (id)videoFramesAttributes
{
    return _videoFramesAttributes;
}

- (void)setVideoFramesQueueLimit:(NSUInteger)aLimit
{
    unsigned int uVar1;

    uVar1 = 1;
    if (aLimit != 0) {
        uVar1 = aLimit;
    }
    _videoFramesQueueLimit = uVar1;
}

- (NSUInteger)videoFramesQueueLimit
{
    return _videoFramesQueueLimit;
}

- (id)outputMovieFilePath
{
    return _outputMovieFilePath;
}

- (id)workFolderPath
{
    return _workFolderPath;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026a6c0 @ 0026a6c0, 150 bytes * /

void FUN_0026a6c0(HSThreadContext *self,SEL _cmd,id capturingDidStartForOutputFilePath,
                 BOOL isAudioCapturingUsed,BOOL isRoundedCorners,NSSize movieSize)

{
  uint uVar1;
  id pvVar2;
  
  uVar1._0_1_ = self->_lazyMovieCreation[0];
  uVar1._1_1_ = self->_roundedCornersForMovie[0];
  uVar1._2_1_ = self->_isWaitingForActivation[0];
  uVar1._3_1_ = self->_isThreadRoutineStarted[0];
  *(uint *)self->_lazyMovieCreation =
       (uint)(isRoundedCorners & 1) * 2 +
       (uint)(isAudioCapturingUsed & 1) * 0x20 + (uVar1 & 0xffffffdd);
  *(float *)self->_isProcessingCanceled = movieSize.width;
  *(float *)self->_isAudioCaptirungDidFinish = movieSize.height;
  _pthread_mutex_lock((pthread_mutex_t *)&self->_processingThreadMutex);
  pvVar2 = _objc_msgSend(capturingDidStartForOutputFilePath,sel_copy);
  self->_outputMovieFilePath = pvVar2;
  _pthread_cond_signal((pthread_cond_t *)&self->_processingThreadCondition);
  _pthread_mutex_unlock((pthread_mutex_t *)&self->_processingThreadMutex);
  return;
}

*/
- (void)capturingDidStartForOutputFilePath:(id)aPath isAudioCapturingUsed:(BOOL)aUsed isRoundedCorners:(BOOL)aCorners movieSize:(NSSize)aSize
{
    _isAudioCapturingUsed = aUsed;
    _roundedCornersForMovie = aCorners;
    _movieSize = aSize;
    pthread_mutex_lock(&_processingThreadMutex);
    _outputMovieFilePath = [aPath copy];
    pthread_cond_signal(&_processingThreadCondition);
    pthread_mutex_unlock(&_processingThreadMutex);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026a756 @ 0026a756, 694 bytes * /

void FUN_0026a756(HSThreadContext *self,SEL _cmd)

{
  HSFramesQueue *pHVar1;
  void **ppvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  char *pcVar5;
  char local_1d;
  HSThreadContext *local_1c;
  undefined *local_18;
  
  pvVar4 = *(id *)PTR_00336420;
  pvVar3 = _objc_msgSend(self->_movie,sel_attributeForKey_,pvVar4);
  pvVar3 = _objc_msgSend(pvVar3,sel_retain);
  _objc_msgSend(self->_cornersClipPath,sel_release);
  if (self->_movieStorage != (ComponentInstanceRecord *)0x0) {
    _CloseMovieStorage(self->_movieStorage);
  }
  _objc_msgSend(self->_scheduledProcessing,sel_release,pvVar4);
  _objc_msgSend(self->_movie,sel_release);
  if (pvVar3 != (id)0x0) {
    self_00 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar4 = _objc_msgSend(pvVar3,sel_path);
    _objc_msgSend(self_00,sel_removeFileAtPath_handler_,pvVar4,0);
    _objc_msgSend(pvVar3,sel_release);
  }
  _objc_msgSend(self->_soundMovies,sel_release,pvVar4);
  pHVar1 = self->_videoFramesQueue;
  while (ppvVar2 = pHVar1->f0, ppvVar2 != (void **)0x0) {
    pHVar1->f1 = ppvVar2;
    pHVar1->f0 = ppvVar2[6];
    _CVPixelBufferRelease(*ppvVar2);
    _free(pHVar1->f1);
  }
  while (ppvVar2 = pHVar1->f2, ppvVar2 != (void **)0x0) {
    pHVar1->f1 = ppvVar2;
    pHVar1->f2 = ppvVar2[6];
    _free(ppvVar2);
  }
  _free(pHVar1);
  _pthread_cond_destroy((pthread_cond_t *)&self->_processingThreadCondition);
  _pthread_mutex_destroy((pthread_mutex_t *)&self->_processingThreadMutex);
  _pthread_mutex_destroy((pthread_mutex_t *)&self->_delegateMutex);
  _objc_msgSend(self->_outputMovieFilePath,sel_release);
  _objc_msgSend(self->_videoFramesAttributes,sel_release);
  if (self->_workFolderPath != (id)0x0) {
    local_1d = '\0';
    pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar4 = self->_workFolderPath;
    pcVar5 = &local_1d;
    pvVar3 = _objc_msgSend(pvVar3,sel_fileExistsAtPath_isDirectory_,pvVar4,pcVar5);
    if (((char)pvVar3 != '\0') && (local_1d != '\0')) {
      pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar4,pcVar5);
      pvVar4 = self->_workFolderPath;
      pcVar5 = (char *)0x0;
      _objc_msgSend(pvVar3,sel_removeFileAtPath_handler_,pvVar4,0);
    }
    _objc_msgSend(self->_workFolderPath,sel_release,pvVar4,pcVar5);
  }
  if (self->_packedPixelsBuffer != (void *)0x0) {
    _free(self->_packedPixelsBuffer);
  }
  if ((self->_lazyMovieCreation[0] & 1) != 0) {
    _objc_msgSend(self,sel_destroyOpenGLContext);
  }
  local_1c = self;
  local_18 = PTR_s_NSObject_00356180;
  _objc_msgSendSuper(&local_1c,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    NSURL *movieURL = [[_movie attributeForKey:QTMovieURLAttribute] retain];
    [_cornersClipPath release];
    // CloseMovieStorage(_movieStorage) in the original; HSQTKit movies have no separate storage.
    [_scheduledProcessing release];
    [_movie release];
    if (movieURL != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:[movieURL path] error:NULL];
        [movieURL release];
    }
    [_soundMovies release];
    struct HSFramesQueue *queue = _videoFramesQueue;
    if (queue != NULL) {
        while (queue->f0 != NULL) {
            struct HSFramesQueueItem *item = queue->f0;
            queue->f1 = item;
            queue->f0 = item->next;
            CVPixelBufferRelease(item->buffer);
            free(queue->f1);
        }
        while (queue->f2 != NULL) {
            struct HSFramesQueueItem *item = queue->f2;
            queue->f1 = item;
            queue->f2 = item->next;
            free(item);
        }
        free(queue);
    }
    pthread_cond_destroy(&_processingThreadCondition);
    pthread_mutex_destroy(&_processingThreadMutex);
    pthread_mutex_destroy(&_delegateMutex);
    [_outputMovieFilePath release];
    [_videoFramesAttributes release];
    if (_workFolderPath != nil) {
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:_workFolderPath isDirectory:&isDirectory] && isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:_workFolderPath error:NULL];
        }
        [_workFolderPath release];
    }
    if (_packedPixelsBuffer != NULL) {
        free(_packedPixelsBuffer);
    }
    if (_lazyMovieCreation) {
        [self destroyOpenGLContext];
    }
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00267dad @ 00267dad, 990 bytes * /

id FUN_00267dad(HSThreadContext *self,SEL _cmd,id initWithVideoFramesAttributes,id delegate)

{
  short sVar1;
  HSThreadContext *self_00;
  int iVar2;
  HSFramesQueue *pHVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  undefined4 local_28;
  undefined4 local_24;
  int local_20;
  HSThreadContext *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSObject_00356180;
  self_00 = _objc_msgSendSuper(&local_1c,sel_init);
  if (self_00 != (HSThreadContext *)0x0) {
    local_20 = 0;
    if (initWithVideoFramesAttributes != (id)0x0) {
      iVar2 = _pthread_mutex_init((pthread_mutex_t *)&self_00->_delegateMutex,
                                  (pthread_mutexattr_t *)0x0);
      if (((iVar2 == 0) &&
          (iVar2 = _pthread_mutex_init((pthread_mutex_t *)&self_00->_processingThreadMutex,
                                       (pthread_mutexattr_t *)0x0), iVar2 == 0)) &&
         (iVar2 = _pthread_cond_init((pthread_cond_t *)&self_00->_processingThreadCondition,
                                     (pthread_condattr_t *)0x0), iVar2 == 0)) {
        pHVar3 = _malloc(0x10);
        if (pHVar3 == (HSFramesQueue *)0x0) {
          self_00->_videoFramesQueue = (HSFramesQueue *)0x0;
        }
        else {
          pHVar3->f1 = (void **)0x0;
          pHVar3->f0 = (void **)0x0;
          pHVar3->f3 = 0;
          pHVar3->f2 = (void **)0x0;
          self_00->_videoFramesQueue = pHVar3;
          pvVar4 = _objc_msgSend(self_00,sel_class);
          pvVar4 = _objc_msgSend(pvVar4,sel_HSThreadContext_createWorkFolder);
          pvVar4 = _objc_msgSend(pvVar4,sel_retain);
          self_00->_workFolderPath = pvVar4;
          if (pvVar4 != (id)0x0) {
            pvVar4 = _objc_msgSend(pvVar4,sel_stringByAppendingPathComponent_,&cfstr_video_mov);
            local_24 = 0;
            sVar1 = _QTNewDataReferenceFromFullPathCFString(pvVar4,0xffffffff,0,&local_20,&local_24)
            ;
            if (sVar1 == 0) {
              local_28 = 0;
              sVar1 = _CreateMovieStorage(local_20,local_24,0x54564f44,0xffffffff,0x80000001,
                                          &self_00->_movieStorage,&local_28);
              if (sVar1 == 0) {
                _SetMovieVisualContext(local_28,0);
                sVar1 = _GetMoviesError();
                if (sVar1 == 0) {
                  pvVar5 = _objc_msgSend(cls_QTMovie,sel_alloc);
                  uVar8 = 0;
                  uVar7 = 1;
                  pvVar5 = _objc_msgSend(pvVar5,sel_initWithQuickTimeMovie_disposeWhenDone_error_,
                                         local_28,1,0);
                  self_00->_movie = pvVar5;
                  if (pvVar5 != (id)0x0) {
                    pvVar6 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1,uVar7,uVar8);
                    _objc_msgSend(pvVar5,sel_setAttribute_forKey_,pvVar6,*(undefined4 *)PTR_00336910
                                 );
                    pvVar5 = self_00->_movie;
                    pvVar6 = _objc_msgSend(cls_NSNumber,sel_numberWithLong_,600);
                    _objc_msgSend(pvVar5,sel_setAttribute_forKey_,pvVar6,*(undefined4 *)PTR_00336954
                                 );
                    pvVar5 = self_00->_movie;
                    pvVar6 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,0);
                    _objc_msgSend(pvVar5,sel_setAttribute_forKey_,pvVar6,*(undefined4 *)PTR_0033690c
                                 );
                    uVar7 = *(undefined4 *)PTR_003361c4;
                    _objc_msgSend(self_00->_movie,sel_setAttribute_forKey_,&cfstr_video_mov,uVar7);
                    pvVar5 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar4);
                    if (pvVar5 != (id)0x0) {
                      uVar7 = *(undefined4 *)PTR_00336420;
                      _objc_msgSend(self_00->_movie,sel_setAttribute_forKey_,pvVar5,uVar7);
                      pvVar4 = pvVar5;
                    }
                    pvVar5 = _objc_msgSend(self_00->_movie,sel_detachFromCurrentThread,pvVar4,uVar7)
                    ;
                    if ((char)pvVar5 != '\0') {
                      self_00->_videoFramesQueueLimit = 0x32;
                      pvVar4 = _objc_msgSend(initWithVideoFramesAttributes,sel_copy,pvVar4,uVar7);
                      self_00->_videoFramesAttributes = pvVar4;
                      self_00->_delegate = delegate;
                      return self_00;
                    }
                  }
                }
              }
            }
          }
        }
      }
      if (local_20 != 0) {
        _DisposeHandle(local_20);
      }
    }
    local_18 = PTR_s_NSObject_00356180;
    local_1c = self_00;
    _objc_msgSendSuper(&local_1c,sel_release);
  }
  return (id)0x0;
}

*/
- (id)initWithVideoFramesAttributes:(id)aAttributes delegate:(id)aDelegate
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    if (aAttributes != nil
        && pthread_mutex_init(&_delegateMutex, NULL) == 0
        && pthread_mutex_init(&_processingThreadMutex, NULL) == 0
        && pthread_cond_init(&_processingThreadCondition, NULL) == 0) {
        _videoFramesQueue = malloc(sizeof(struct HSFramesQueue));
        if (_videoFramesQueue != NULL) {
            _videoFramesQueue->f0 = NULL;
            _videoFramesQueue->f1 = NULL;
            _videoFramesQueue->f2 = NULL;
            _videoFramesQueue->f3 = 0;
            _workFolderPath = [[[self class] HSThreadContext_createWorkFolder] retain];
            if (_workFolderPath != nil) {
                NSString *moviePath = [_workFolderPath stringByAppendingPathComponent:@"video.mov"];
                // The original made the movie with QTNewDataReferenceFromFullPathCFString and CreateMovieStorage;
                // HSQTKit writes the movie to the file directly.
                _movie = [[QTMovie alloc] initToWritableFile:moviePath error:NULL];
                if (_movie != nil) {
                    [_movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];
                    [_movie setAttribute:[NSNumber numberWithLong:600] forKey:QTMovieTimeScaleAttribute];
                    [_movie setAttribute:[NSNumber numberWithBool:NO] forKey:QTMovieDontInteractWithUserAttribute];
                    [_movie setAttribute:@"video.mov" forKey:QTMovieFileNameAttribute];
                    NSURL *url = [NSURL fileURLWithPath:moviePath];
                    if (url != nil) {
                        [_movie setAttribute:url forKey:QTMovieURLAttribute];
                    }
                    if ([_movie detachFromCurrentThread]) {
                        _videoFramesQueueLimit = 50;
                        _videoFramesAttributes = [aAttributes copy];
                        _delegate = aDelegate;
                        return self;
                    }
                }
            }
        }
    }
    [super release];
    return nil;
}

@end

