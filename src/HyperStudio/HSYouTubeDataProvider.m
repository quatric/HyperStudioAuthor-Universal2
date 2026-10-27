#import "HSYouTubeDataProvider.h"
static id sDAT_00342a00;

static id sDAT_00342a00;


@implementation HSYouTubeDataProvider

/* i386 ivar offsets: _receivedData=0x4, _dataArray=0x8, _requestFormatString=0xc, _youTubeConnection=0x10, _numberOfDataItems=0x14, _startIndex=0x18 */

+ (id)allocWithZone:(NSZone *)aZone
{
    id pvVar1;

    if (sDAT_00342a00 == nil) {
        pvVar1 = [super allocWithZone:aZone];
        sDAT_00342a00 = pvVar1;
    }
    else {
        pvVar1 = nil;
    }
    return pvVar1;
}

+ (id)sharedYouTubeDataProvider
{
    if (sDAT_00342a00 == nil) {
        [[self alloc] init];
    }
    return sDAT_00342a00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002024c8 @ 002024c8, 3757 bytes * /

/* WARNING: Type propagation algorithm not settling * /

void FUN_002024c8(HSYouTubeDataProvider *self,SEL _cmd,id connectionDidFinishLoading)

{
  int iVar1;
  int iVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  undefined *self_00;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  id pvVar14;
  id pvVar15;
  cfstringStruct *pcVar16;
  SEL op;
  uint uVar17;
  int *piVar18;
  cfstringStruct *pcVar19;
  HSYouTubeDataProvider *pHVar20;
  undefined1 *puVar21;
  int *piVar22;
  cfstringStruct *pcVar23;
  undefined4 uVar24;
  id local_184;
  cfstringStruct *local_15c;
  cfstringStruct *local_158;
  id local_150;
  cfstringStruct *local_144;
  id local_140;
  int local_138 [3];
  int *local_12c;
  undefined4 local_128;
  undefined4 local_124;
  undefined4 local_120;
  undefined4 local_11c;
  undefined4 local_118;
  undefined1 local_114 [64];
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined1 local_b4 [64];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  local_138[0] = 0;
  pvVar4 = _objc_msgSend(cls_NSXMLDocument,sel_alloc);
  pcVar23 = self->_receivedData;
  piVar18 = local_138;
  pHVar20 = (HSYouTubeDataProvider *)0x400;
  piVar22 = piVar18;
  pvVar4 = _objc_msgSend(pvVar4,sel_initWithData_options_error_,pcVar23,0x400,piVar18);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  if (local_138[0] == 0) {
    pvVar4 = _objc_msgSend(pvVar4,sel_rootElement,pcVar23,pHVar20,piVar22);
    pvVar5 = _objc_msgSend(pvVar4,sel_nodesForXPath_error_,&cfstr_openSearch_totalResults,piVar18);
    pvVar6 = _objc_msgSend(pvVar5,sel_count);
    if (pvVar6 != (id)0x0) {
      pvVar5 = _objc_msgSend(pvVar5,sel_objectAtIndex_,0,piVar18);
      pvVar5 = _objc_msgSend(pvVar5,sel_objectValue);
      pvVar5 = _objc_msgSend(pvVar5,sel_intValue);
      self->_numberOfDataItems = (uint)pvVar5;
      piVar18 = local_138;
      pvVar5 = _objc_msgSend(pvVar4,sel_nodesForXPath_error_,&cfstr_openSearch_startIndex,piVar18);
      pvVar6 = _objc_msgSend(pvVar5,sel_count);
      if (pvVar6 != (id)0x0) {
        pvVar5 = _objc_msgSend(pvVar5,sel_objectAtIndex_,0,piVar18);
        pvVar5 = _objc_msgSend(pvVar5,sel_objectValue);
        pvVar5 = _objc_msgSend(pvVar5,sel_intValue);
        self->_startIndex = (uint)pvVar5;
        pvVar4 = _objc_msgSend(pvVar4,sel_nodesForXPath_error_,&cfstr_entry,local_138);
        local_138[1] = 0;
        local_138[2] = 0;
        local_12c = (int *)0x0;
        local_128 = 0;
        local_124 = 0;
        local_120 = 0;
        local_11c = 0;
        local_118 = 0;
        puVar21 = local_114;
        piVar18 = local_138 + 1;
        pcVar23 = (cfstringStruct *)0x10;
        local_184 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,piVar18,
                                  puVar21,0x10);
        if (local_184 != (id)0x0) {
          iVar1 = *local_12c;
          do {
            local_150 = (id)0x0;
            do {
              if (iVar1 != *local_12c) {
                _objc_enumerationMutation(pvVar4);
              }
              pvVar5 = *(id *)(local_138[2] + (int)local_150 * 4);
              piVar18 = local_138;
              pvVar6 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,&cfstr_id,piVar18,pcVar23);
              pvVar7 = _objc_msgSend(pvVar6,sel_count);
              if (pvVar7 != (id)0x0) {
                pvVar6 = _objc_msgSend(pvVar6,sel_objectAtIndex_,0,piVar18);
                pvVar6 = _objc_msgSend(pvVar6,sel_objectValue);
                pvVar6 = _objc_msgSend(pvVar6,sel_lastPathComponent);
                piVar18 = local_138;
                pvVar7 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,&cfstr_title,piVar18);
                pvVar8 = _objc_msgSend(pvVar7,sel_count);
                if (pvVar8 != (id)0x0) {
                  pvVar7 = _objc_msgSend(pvVar7,sel_objectAtIndex_,0,piVar18);
                  pvVar7 = _objc_msgSend(pvVar7,sel_objectValue);
                  piVar18 = local_138;
                  pcVar19 = &cfstr_media_group_media_description;
                  pvVar8 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,
                                         &cfstr_media_group_media_description,piVar18);
                  pvVar9 = _objc_msgSend(pvVar8,sel_count);
                  self_00 = cls_NSString;
                  op = sel_string;
                  if (pvVar9 != (id)0x0) {
                    pcVar19 = (cfstringStruct *)0x0;
                    self_00 = _objc_msgSend(pvVar8,sel_objectAtIndex_,0,piVar18);
                    op = sel_objectValue;
                  }
                  pvVar8 = _objc_msgSend(self_00,op,pcVar19,piVar18);
                  piVar18 = local_138;
                  pvVar9 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,&cfstr_published,piVar18);
                  pvVar10 = _objc_msgSend(pvVar9,sel_count);
                  if (pvVar10 != (id)0x0) {
                    pvVar9 = _objc_msgSend(pvVar9,sel_objectAtIndex_,0,piVar18);
                    pvVar9 = _objc_msgSend(pvVar9,sel_objectValue);
                    piVar18 = local_138;
                    pvVar10 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,&cfstr_author_name,
                                            piVar18);
                    pvVar11 = _objc_msgSend(pvVar10,sel_count);
                    if (pvVar11 != (id)0x0) {
                      pvVar10 = _objc_msgSend(pvVar10,sel_objectAtIndex_,0,piVar18);
                      pvVar10 = _objc_msgSend(pvVar10,sel_objectValue);
                      pvVar11 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,
                                              &cfstr_http___www_youtube_com_user___,pvVar10);
                      piVar18 = local_138;
                      pvVar12 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,&cfstr_yt_statistics,
                                              piVar18);
                      pvVar13 = _objc_msgSend(pvVar12,sel_count);
                      if (pvVar13 == (id)0x0) {
                        local_158 = &cfstr_empty;
                      }
                      else {
                        pvVar12 = _objc_msgSend(pvVar12,sel_objectAtIndex_,0,piVar18);
                        pvVar12 = _objc_msgSend(pvVar12,sel_attributeForName_,&cfstr_viewCount);
                        local_158 = _objc_msgSend(pvVar12,sel_objectValue);
                      }
                      piVar18 = local_138;
                      pvVar12 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,&cfstr_gd_rating,
                                              piVar18);
                      pvVar13 = _objc_msgSend(pvVar12,sel_count);
                      if (pvVar13 == (id)0x0) {
                        local_15c = &cfstr_empty;
                      }
                      else {
                        pvVar12 = _objc_msgSend(pvVar12,sel_objectAtIndex_,0,piVar18);
                        pvVar12 = _objc_msgSend(pvVar12,sel_attributeForName_,&cfstr_average);
                        local_15c = _objc_msgSend(pvVar12,sel_objectValue);
                      }
                      piVar18 = local_138;
                      pvVar12 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,
                                              &cfstr_media_group_yt_duration,piVar18);
                      pvVar13 = _objc_msgSend(pvVar12,sel_count);
                      if (pvVar13 != (id)0x0) {
                        pvVar12 = _objc_msgSend(pvVar12,sel_objectAtIndex_,0,piVar18);
                        pvVar12 = _objc_msgSend(pvVar12,sel_attributeForName_,&cfstr_seconds);
                        pvVar12 = _objc_msgSend(pvVar12,sel_objectValue);
                        pvVar13 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,
                                                &cfstr_media_group_media_content,local_138);
                        local_d4 = 0;
                        local_d0 = 0;
                        local_cc = (int *)0x0;
                        local_c8 = 0;
                        local_c4 = 0;
                        local_c0 = 0;
                        local_bc = 0;
                        local_b8 = 0;
                        puVar21 = local_b4;
                        pcVar23 = (cfstringStruct *)0x10;
                        local_140 = _objc_msgSend(pvVar13,
                                                  sel_countByEnumeratingWithState_objects_count_,
                                                  &local_d4,puVar21,0x10);
                        if (local_140 != (id)0x0) {
                          iVar2 = *local_cc;
                          do {
                            pvVar14 = (id)0x0;
                            do {
                              if (iVar2 != *local_cc) {
                                _objc_enumerationMutation(pvVar13);
                              }
                              pvVar3 = *(id *)(local_d0 + (int)pvVar14 * 4);
                              pvVar15 = _objc_msgSend(pvVar3,sel_attributeForName_,&cfstr_yt_format,
                                                      puVar21,pcVar23);
                              pvVar15 = _objc_msgSend(pvVar15,sel_objectValue);
                              pvVar15 = _objc_msgSend(pvVar15,sel_intValue);
                              if (pvVar15 == (id)0x5) {
                                pvVar13 = _objc_msgSend(pvVar3,sel_attributeForName_,&cfstr_url);
                                pcVar19 = _objc_msgSend(pvVar13,sel_objectValue);
                                goto LAB_00202cb0;
                              }
                              pvVar14 = (id)((int)pvVar14 + 1);
                            } while (pvVar14 < local_140);
                            puVar21 = local_b4;
                            pcVar23 = (cfstringStruct *)0x10;
                            local_140 = _objc_msgSend(pvVar13,
                                                  sel_countByEnumeratingWithState_objects_count_,
                                                  &local_d4,puVar21,0x10);
                          } while (local_140 != (id)0x0);
                        }
                        pcVar19 = &cfstr_empty;
LAB_00202cb0:
                        piVar18 = local_138;
                        pvVar13 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,
                                                &cfstr_media_group_media_player,piVar18,pcVar23);
                        pvVar14 = _objc_msgSend(pvVar13,sel_count);
                        if (pvVar14 != (id)0x0) {
                          pvVar13 = _objc_msgSend(pvVar13,sel_objectAtIndex_,0,piVar18);
                          pvVar13 = _objc_msgSend(pvVar13,sel_attributeForName_,&cfstr_url);
                          pvVar13 = _objc_msgSend(pvVar13,sel_objectValue);
                          pvVar5 = _objc_msgSend(pvVar5,sel_nodesForXPath_error_,
                                                 &cfstr_media_group_media_thumbnail,local_138);
                          local_74 = 0;
                          local_70 = 0;
                          local_6c = (int *)0x0;
                          local_68 = 0;
                          local_64 = 0;
                          local_60 = 0;
                          local_5c = 0;
                          local_58 = 0;
                          puVar21 = local_50;
                          uVar24 = 0x10;
                          local_140 = _objc_msgSend(pvVar5,
                                                  sel_countByEnumeratingWithState_objects_count_,
                                                  &local_74,puVar21,0x10);
                          if (local_140 == (id)0x0) {
                            pcVar23 = &cfstr_empty;
                            pcVar16 = pcVar23;
                            local_144 = pcVar23;
                          }
                          else {
                            iVar2 = *local_6c;
                            do {
                              pvVar14 = (id)0x0;
                              do {
                                if (iVar2 != *local_6c) {
                                  _objc_enumerationMutation(pvVar5);
                                }
                                pvVar3 = *(id *)(local_70 + (int)pvVar14 * 4);
                                pvVar15 = _objc_msgSend(pvVar3,sel_attributeForName_,&cfstr_url,
                                                        puVar21,uVar24);
                                local_144 = _objc_msgSend(pvVar15,sel_objectValue);
                                pvVar15 = _objc_msgSend(local_144,sel_lastPathComponent);
                                pvVar15 = _objc_msgSend(pvVar15,sel_isEqualToString_,&cfstr_0_jpg);
                                if ((char)pvVar15 != '\0') {
                                  pvVar5 = _objc_msgSend(pvVar3,sel_attributeForName_,&cfstr_width);
                                  pcVar16 = _objc_msgSend(pvVar5,sel_objectValue);
                                  pvVar5 = _objc_msgSend(pvVar3,sel_attributeForName_,&cfstr_height)
                                  ;
                                  pcVar23 = _objc_msgSend(pvVar5,sel_objectValue);
                                  goto LAB_00202ff4;
                                }
                                pvVar14 = (id)((int)pvVar14 + 1);
                              } while (pvVar14 < local_140);
                              puVar21 = local_50;
                              uVar24 = 0x10;
                              local_140 = _objc_msgSend(pvVar5,
                                                  sel_countByEnumeratingWithState_objects_count_,
                                                  &local_74,puVar21,0x10);
                            } while (local_140 != (id)0x0);
                            pcVar23 = &cfstr_empty;
                            pcVar16 = pcVar23;
                          }
LAB_00202ff4:
                          pvVar5 = self->_dataArray;
                          pvVar6 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,
                                                 pvVar6,&cfstr_HSYouTubeDataIDCondition,pcVar19,
                                                 &cfstr_HSYouTubeDataURLCondition,pvVar13,
                                                 &cfstr_HSYouTubeDataWatchURLCondition,pvVar7,
                                                 &cfstr_HSYouTubeDataTitleCondition,pvVar8,
                                                 &cfstr_HSYouTubeDataDescriptionCondition,pvVar10,
                                                 &cfstr_HSYouTubeDataAuthorCondition,pvVar11,
                                                 &cfstr_HSYouTubeDataAuthorURLCondition,pvVar9,
                                                 &cfstr_HSYouTubeDataPublishedDateCondition,
                                                 local_158,&cfstr_HSYouTubeDataViewCountCondition,
                                                 local_15c,&cfstr_HSYouTubeDataRatingCondition,
                                                 pvVar12,&cfstr_HSYouTubeDataDurationCondition,
                                                 pcVar16,&cfstr_HSYouTubeDataWidthCondition,pcVar23,
                                                 &cfstr_HSYouTubeDataHeightCondition,local_144,
                                                 &cfstr_HSYouTubeDataThumbnailURLCondition,0);
                          _objc_msgSend(pvVar5,sel_addObject_,pvVar6);
                          pcVar23 = pcVar19;
                        }
                      }
                    }
                  }
                }
              }
              local_150 = (id)((int)local_150 + 1);
            } while (local_150 < local_184);
            puVar21 = local_114;
            piVar18 = local_138 + 1;
            pcVar23 = (cfstringStruct *)0x10;
            local_184 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,piVar18,
                                      puVar21,0x10);
          } while (local_184 != (id)0x0);
        }
        uVar17 = self->_startIndex;
        pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,piVar18,puVar21,pcVar23);
        if (uVar17 < 2) {
          pcVar19 = &cfstr_HSYouTubeDataDidLoadNotification;
        }
        else {
          pcVar19 = &cfstr_HSYouTubeDataDidUpdatedNotification;
        }
        _objc_msgSend(pvVar4,sel_postNotificationName_object_,pcVar19,self,pcVar23);
        _objc_msgSend(connectionDidFinishLoading,sel_release);
        self->_youTubeConnection = (id)0x0;
        _objc_msgSend(self->_receivedData,sel_release);
        self->_receivedData = (id)0x0;
        pvVar4 = _objc_msgSend(self->_dataArray,sel_count);
        if (pvVar4 < (id)self->_numberOfDataItems) {
          uVar17 = self->_startIndex + 0x14;
          self->_startIndex = uVar17;
          _objc_msgSend(self,sel_provideYouTubeDataForIndex_,uVar17);
        }
      }
    }
  }
  else {
    if (self->_startIndex < 2) {
      pvVar4 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pcVar23,pHVar20,piVar22);
      pcVar23 = &cfstr_HSYouTubeDataLoadFailedNotification;
      pHVar20 = self;
      _objc_msgSend(pvVar4,sel_postNotificationName_object_,
                    &cfstr_HSYouTubeDataLoadFailedNotification,self);
    }
    _objc_msgSend(connectionDidFinishLoading,sel_release,pcVar23,pHVar20,piVar22);
    self->_youTubeConnection = (id)0x0;
    _objc_msgSend(self->_receivedData,sel_release);
    self->_receivedData = (id)0x0;
  }
  return;
}

*/
- (void)connectionDidFinishLoading:(id)aLoading
{
    NSError *error = nil;
    NSXMLDocument *document = [[[NSXMLDocument alloc] initWithData:_receivedData options:NSXMLDocumentTidyXML error:&error] autorelease];
    if (error != nil) {
        if (_startIndex < 2) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HSYouTubeDataLoadFailedNotification" object:self];
        }
        [aLoading release];
        _youTubeConnection = nil;
        [_receivedData release];
        _receivedData = nil;
        return;
    }
    NSXMLElement *root = [document rootElement];
    NSArray *nodes = [root nodesForXPath:@"openSearch:totalResults" error:&error];
    if ([nodes count] == 0) {
        return;
    }
    _numberOfDataItems = (NSUInteger)[[[nodes objectAtIndex:0] objectValue] intValue];
    nodes = [root nodesForXPath:@"openSearch:startIndex" error:&error];
    if ([nodes count] == 0) {
        return;
    }
    _startIndex = (NSUInteger)[[[nodes objectAtIndex:0] objectValue] intValue];
    for (NSXMLElement *entry in [root nodesForXPath:@"entry" error:&error]) {
        nodes = [entry nodesForXPath:@"id" error:&error];
        if ([nodes count] == 0) {
            continue;
        }
        id videoID = [[[nodes objectAtIndex:0] objectValue] lastPathComponent];
        nodes = [entry nodesForXPath:@"title" error:&error];
        if ([nodes count] == 0) {
            continue;
        }
        id title = [[nodes objectAtIndex:0] objectValue];
        nodes = [entry nodesForXPath:@"media:group/media:description" error:&error];
        id description = ([nodes count] != 0) ? [[nodes objectAtIndex:0] objectValue] : [NSString string];
        nodes = [entry nodesForXPath:@"published" error:&error];
        if ([nodes count] == 0) {
            continue;
        }
        id published = [[nodes objectAtIndex:0] objectValue];
        nodes = [entry nodesForXPath:@"author/name" error:&error];
        if ([nodes count] == 0) {
            continue;
        }
        id author = [[nodes objectAtIndex:0] objectValue];
        id authorURL = [NSString stringWithFormat:@"http://www.youtube.com/user/%@", author];
        nodes = [entry nodesForXPath:@"yt:statistics" error:&error];
        id viewCount = ([nodes count] == 0) ? @"" : [[[nodes objectAtIndex:0] attributeForName:@"viewCount"] objectValue];
        nodes = [entry nodesForXPath:@"gd:rating" error:&error];
        id rating = ([nodes count] == 0) ? @"" : [[[nodes objectAtIndex:0] attributeForName:@"average"] objectValue];
        nodes = [entry nodesForXPath:@"media:group/yt:duration" error:&error];
        if ([nodes count] == 0) {
            continue;
        }
        id duration = [[[nodes objectAtIndex:0] attributeForName:@"seconds"] objectValue];
        id contentURL = @"";
        for (NSXMLElement *content in [entry nodesForXPath:@"media:group/media:content" error:&error]) {
            if ([[[content attributeForName:@"yt:format"] objectValue] intValue] == 5) {
                contentURL = [[content attributeForName:@"url"] objectValue];
                break;
            }
        }
        nodes = [entry nodesForXPath:@"media:group/media:player" error:&error];
        if ([nodes count] == 0) {
            continue;
        }
        id watchURL = [[[nodes objectAtIndex:0] attributeForName:@"url"] objectValue];
        id width = @"";
        id height = @"";
        id thumbnailURL = @"";
        for (NSXMLElement *thumbnail in [entry nodesForXPath:@"media:group/media:thumbnail" error:&error]) {
            thumbnailURL = [[thumbnail attributeForName:@"url"] objectValue];
            if ([[thumbnailURL lastPathComponent] isEqualToString:@"0.jpg"]) {
                width = [[thumbnail attributeForName:@"width"] objectValue];
                height = [[thumbnail attributeForName:@"height"] objectValue];
                goto haveThumbnail;
            }
        }
        thumbnailURL = @"";
haveThumbnail:
        [_dataArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            videoID, HSYouTubeDataIDCondition,
            contentURL, HSYouTubeDataURLCondition,
            watchURL, HSYouTubeDataWatchURLCondition,
            title, HSYouTubeDataTitleCondition,
            description, HSYouTubeDataDescriptionCondition,
            author, HSYouTubeDataAuthorCondition,
            authorURL, HSYouTubeDataAuthorURLCondition,
            published, HSYouTubeDataPublishedDateCondition,
            viewCount, HSYouTubeDataViewCountCondition,
            rating, HSYouTubeDataRatingCondition,
            duration, HSYouTubeDataDurationCondition,
            width, HSYouTubeDataWidthCondition,
            height, HSYouTubeDataHeightCondition,
            thumbnailURL, HSYouTubeDataThumbnailURLCondition, nil]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:(_startIndex < 2) ? @"HSYouTubeDataDidLoadNotification" : @"HSYouTubeDataDidUpdatedNotification" object:self];
    [aLoading release];
    _youTubeConnection = nil;
    [_receivedData release];
    _receivedData = nil;
    if ([_dataArray count] < _numberOfDataItems) {
        _startIndex += 20;
        [self provideYouTubeDataForIndex:_startIndex];
    }
}

- (void)connection:(id)aConnection didFailWithError:(id)aError
{
    [aConnection release];
    _youTubeConnection = nil;
    [_receivedData release];
    _receivedData = nil;
    if (_startIndex < 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSYouTubeDataLoadFailedNotification" object:self];
    }
}

- (void)connection:(id)aConnection didReceiveData:(id)aData
{
    [_receivedData appendData:aData];
}

- (void)connection:(id)aConnection didReceiveResponse:(id)aResponse
{
    [_receivedData setLength:0];
}

- (id)autorelease
{
    return self;
}

- (void)release
{

}

- (NSUInteger)retainCount
{
    return 0xffffffff;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

- (void)dealloc
{
    [_requestFormatString release];
    [_receivedData release];
    [_dataArray release];
    [_youTubeConnection cancel];
    [_youTubeConnection release];
    [super dealloc];
}

- (id)standardTimeString:(NSInteger)aString
{
    id pcVar2;

    switch(aString) {
        case 0:
        pcVar2 = @"today";
        break;
        case 1:
        pcVar2 = @"this_week";
        break;
        case 2:
        pcVar2 = @"this_month";
        break;
        case 3:
        pcVar2 = @"all_time";
        break;
        default:
        pcVar2 = NULL;
    }
    return [NSString stringWithFormat:@"&time=%@", pcVar2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00201d00 @ 00201d00, 96 bytes * /

id FUN_00201d00(HSYouTubeDataProvider *self,SEL _cmd,int standardFeedString)

{
  switch(standardFeedString) {
  case 0:
    return &cfstr_http___gdata_youtube_com_feeds_api_videos;
  case 1:
    return &cfstr_https___gdata_youtube_com_feeds_api_standardfeed;
  case 2:
    return &cfstr_http___gdata_youtube_com_feeds_api_standardfeeds;
  case 3:
    return &cfstr_http___gdata_youtube_com_feeds_api_standardfeeds;
  case 4:
    return &cfstr_https___gdata_youtube_com_feeds_api_standardfeed;
  case 5:
    return &cfstr_https___gdata_youtube_com_feeds_api_standardfeed;
  case 6:
    return &cfstr_http___gdata_youtube_com_feeds_api_standardfeeds;
  case 7:
    return &cfstr_http___gdata_youtube_com_feeds_api_standardfeeds;
  default:
    return (id)0x0;
  }
}

*/
- (id)standardFeedString:(NSInteger)aString
{
    switch (aString) {
        case 0: return @"http://gdata.youtube.com/feeds/api/videos";
        case 1: return @"https://gdata.youtube.com/feeds/api/standardfeeds/most_popular";
        case 2: return @"http://gdata.youtube.com/feeds/api/standardfeeds/top_rated";
        case 3: return @"http://gdata.youtube.com/feeds/api/standardfeeds/top_favorites";
        case 4: return @"https://gdata.youtube.com/feeds/api/standardfeeds/most_recent";
        case 5: return @"https://gdata.youtube.com/feeds/api/standardfeeds/most_discussed";
        case 6: return @"http://gdata.youtube.com/feeds/api/standardfeeds/most_responded";
        case 7: return @"http://gdata.youtube.com/feeds/api/standardfeeds/recently_featured";
        default: return nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002020a2 @ 002020a2, 380 bytes * /

void FUN_002020a2(HSYouTubeDataProvider *self,SEL _cmd,uint provideYouTubeDataForIndex)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  HSYouTubeDataProvider *pHVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  
  if (self->_youTubeConnection != (id)0x0) {
    _objc_msgSend(self->_youTubeConnection,sel_cancel);
    _objc_msgSend(self->_youTubeConnection,sel_release);
    self->_youTubeConnection = (id)0x0;
  }
  pvVar1 = _objc_msgSend(self->_requestFormatString,sel_stringByAppendingFormat_,
                         &cfstr__start_index__u,provideYouTubeDataForIndex);
  self_00 = cls_NSURLRequest;
  pvVar1 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar1);
  uVar5 = 0x404e0000;
  uVar4 = 0;
  pvVar1 = _objc_msgSend(self_00,sel_requestWithURL_cachePolicy_timeoutInterval_,pvVar1,0,0,
                         0x404e0000);
  pvVar2 = _objc_msgSend(cls_NSURLConnection,sel_alloc);
  pHVar3 = self;
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithRequest_delegate_,pvVar1,self);
  self->_youTubeConnection = pvVar2;
  if (pvVar2 == (id)0x0) {
    if (provideYouTubeDataForIndex < 2) {
      pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pvVar1,pHVar3,uVar4,uVar5);
      _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                    &cfstr_HSYouTubeDataLoadFailedNotification,self);
    }
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSMutableData,sel_data,pvVar1,pHVar3,uVar4,uVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_receivedData = pvVar1;
  }
  return;
}

*/
- (void)provideYouTubeDataForIndex:(NSUInteger)aIndex
{
    if (_youTubeConnection != nil) {
        [_youTubeConnection cancel];
        [_youTubeConnection release];
        _youTubeConnection = nil;
    }
    NSString *urlString = [_requestFormatString stringByAppendingFormat:@"&start-index=%u", (unsigned int)aIndex];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    _youTubeConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (_youTubeConnection == nil) {
        if (aIndex < 2) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HSYouTubeDataLoadFailedNotification" object:self];
        }
    }
    else {
        _receivedData = [[NSMutableData data] retain];
    }
}

- (id)allInformationForIndex:(NSUInteger)aIndex
{
    return [_dataArray objectAtIndex:aIndex];
}

- (id)dataValueForIndex:(NSUInteger)aIndex valueCondition:(id)aCondition
{
    return [[_dataArray objectAtIndex:aIndex] objectForKey:aCondition];
}

- (NSUInteger)numberOfDataItems
{
    return (unsigned int)[_dataArray count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00201da7 @ 00201da7, 599 bytes * /

void FUN_00201da7(HSYouTubeDataProvider *self,SEL _cmd,id provideYouTubeDataForCategory,id keyWord,
                 int standardFeed,int standardTime)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  cfstringStruct *pcVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  
  self->_startIndex = 1;
  _objc_msgSend(self->_requestFormatString,sel_release);
  pvVar1 = _objc_msgSend(cls_NSMutableString,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_standardFeedString_,standardFeed);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithString_,pvVar2);
  self->_requestFormatString = pvVar1;
  _objc_msgSend(self->_dataArray,sel_release);
  pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_new);
  self->_dataArray = pvVar1;
  if ((provideYouTubeDataForCategory == (id)0x0) ||
     (pvVar1 = _objc_msgSend(provideYouTubeDataForCategory,sel_length,pvVar2), pvVar1 == (id)0x0)) {
    pvVar1 = self->_requestFormatString;
    op = sel_appendString_;
    pcVar4 = &cfstr__orderby_relevance;
  }
  else {
    pvVar1 = self->_requestFormatString;
    op = sel_appendFormat_;
    pcVar4 = &cfstr_____orderby_relevance;
    if (standardFeed == 0) {
      pcVar4 = &cfstr_______orderby_relevance;
    }
  }
  _objc_msgSend(pvVar1,op,pcVar4);
  pvVar1 = _objc_msgSend(keyWord,sel_length);
  if ((pvVar1 != (id)0x0) &&
     (pvVar1 = _objc_msgSend(keyWord,sel_mutableCopy,pcVar4), pvVar1 != (id)0x0)) {
    pvVar2 = _objc_msgSend(pvVar1,sel_length,pcVar4);
    uVar6 = 0;
    uVar5 = 2;
    _objc_msgSend(pvVar1,sel_replaceOccurrencesOfString_withString_options_range_,&cfstr__,&cfstr__,
                  2,0,pvVar2);
    pvVar3 = _objc_msgSend(pvVar1,sel_stringByAddingPercentEscapesUsingEncoding_,4);
    _objc_msgSend(pvVar1,sel_release);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(self->_requestFormatString,sel_appendFormat_,&cfstr__vq___,pvVar3,uVar5,uVar6,
                    pvVar2);
    }
  }
  if ((standardFeed != 4) && (standardFeed != 7)) {
    pvVar1 = self->_requestFormatString;
    pvVar2 = _objc_msgSend(self,sel_standardTimeString_,standardTime);
    _objc_msgSend(pvVar1,sel_appendString_,pvVar2);
  }
  _objc_msgSend(self,sel_provideYouTubeDataForIndex_,self->_startIndex);
  return;
}

*/
- (void)provideYouTubeDataForCategory:(id)aCategory keyWord:(id)aWord standardFeed:(NSInteger)aFeed standardTime:(NSInteger)aTime
{
    _startIndex = 1;
    [_requestFormatString release];
    _requestFormatString = [[NSMutableString alloc] initWithString:[self standardFeedString:aFeed]];
    [_dataArray release];
    _dataArray = [[NSMutableArray alloc] init];
    if (aCategory == nil || [aCategory length] == 0) {
        [_requestFormatString appendString:@"?orderby=relevance"];
    }
    else {
        [_requestFormatString appendFormat:(aFeed == 0) ? @"/-/%@?orderby=relevance" : @"_%@?orderby=relevance", aCategory];
    }
    if ([aWord length] != 0) {
        NSMutableString *keyword = [aWord mutableCopy];
        if (keyword != nil) {
            [keyword replaceOccurrencesOfString:@" " withString:@"+" options:NSLiteralSearch range:NSMakeRange(0, [keyword length])];
            NSString *escaped = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [keyword release];
            if (escaped != nil) {
                [_requestFormatString appendFormat:@"&vq=%@", escaped];
            }
        }
    }
    if (aFeed != 4 && aFeed != 7) {
        [_requestFormatString appendString:[self standardTimeString:aTime]];
    }
    [self provideYouTubeDataForIndex:_startIndex];
}

@end

