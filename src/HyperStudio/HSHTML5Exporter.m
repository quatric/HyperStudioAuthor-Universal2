#import "HSHTML5Exporter.h"

// Indentation depth of the human readable JSON writer.
static NSUInteger sJSonIndentLevel;

@implementation HSHTML5Exporter

/* i386 ivar offsets: _isDownloadFinished=0x21, _linkedStackPaths=0x24, _linkedStacksNumber=0x28, _context=0x2c, _widgetSize=0x30, _embeddedCode=0x38 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028efef @ 0028efef, 1073 bytes * /

id FUN_0028efef(id self,SEL _cmd,id embeddedCodeForDocument,float cardWidth,float cardHeight,
               id urlPath)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  float extraout_EDX;
  double dVar6;
  undefined8 in_stack_ffffffd0;
  undefined4 uVar8;
  undefined8 uVar7;
  id local_20;
  id local_18;
  float local_14;
  
  uVar8 = (undefined4)((ulonglong)in_stack_ffffffd0 >> 0x20);
  pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  if (pvVar1 != (id)0x0) {
    uVar7 = CONCAT44(uVar8,&cfstr_html);
    pcVar5 = &cfstr_HTML5Template;
    pvVar1 = _objc_msgSend(pvVar1,sel_pathForResource_ofType_,&cfstr_HTML5Template,&cfstr_html);
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(cls_NSData,sel_alloc,pcVar5,uVar7);
      pvVar2 = _objc_msgSend(pvVar2,sel_initWithContentsOfFile_,pvVar1);
      if (pvVar2 != (id)0x0) {
        pvVar3 = _objc_msgSend(cls_HSXMLDocument,sel_alloc,pvVar1,uVar7);
        pvVar1 = pvVar2;
        pvVar3 = _objc_msgSend(pvVar3,sel_initWithData_,pvVar2);
        _objc_msgSend(pvVar2,sel_release);
        if (pvVar3 != (id)0x0) {
          pvVar1 = _objc_msgSend(pvVar3,sel_rootElement,pvVar1);
          local_20 = _objc_msgSend(pvVar1,sel_retain);
          _objc_msgSend(pvVar3,sel_release);
          if (local_20 != (id)0x0) {
            pcVar5 = &cfstr_iframe;
            pvVar1 = _objc_msgSend(local_20,sel_elementNamed_,&cfstr_iframe);
            if (((pvVar1 != (id)0x0) &&
                (pvVar2 = _objc_msgSend(pvVar1,sel_attributes,pcVar5), pvVar2 != (id)0x0)) &&
               (pvVar3 = _objc_msgSend(embeddedCodeForDocument,sel_stack,pcVar5), pvVar3 != (id)0x0)
               ) {
              local_14 = cardHeight;
              pvVar3 = _objc_msgSend(pvVar3,sel_hyperCardSize,pcVar5);
              pvVar4 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc);
              if (cardHeight <= 0.0) {
                local_14 = extraout_EDX;
              }
              local_18 = (id)cardWidth;
              if (cardWidth <= 0.0) {
                local_18 = pvVar3;
              }
              pvVar3 = _objc_msgSend(pvVar4,sel_initWithDictionary_,pvVar2);
              if (pvVar3 != (id)0x0) {
                pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pvVar2);
                pvVar2 = _objc_msgSend(pvVar2,sel_boolForKey_,*(undefined4 *)PTR_003369f0);
                if ((char)pvVar2 != '\0') {
                  local_18 = (id)((float)local_18 + 10.0);
                }
                pvVar4 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__0_2f,
                                       (double)(float)local_18);
                _objc_msgSend(pvVar3,sel_setObject_forKey_,pvVar4,&cfstr_width);
                if ((char)pvVar2 != '\0') {
                  local_14 = local_14 + 10.0;
                }
                dVar6 = (double)local_14;
                pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__0_2f,dVar6);
                uVar7 = CONCAT44((int)((ulonglong)dVar6 >> 0x20),&cfstr_height);
                _objc_msgSend(pvVar3,sel_setObject_forKey_,pvVar2,&cfstr_height);
                if (urlPath != (id)0x0) {
                  pvVar2 = _objc_msgSend(urlPath,sel_lastPathComponent,pvVar2,uVar7);
                  pcVar5 = &cfstr_index_html;
                  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_index_html);
                  if ((char)pvVar2 == '\0') {
                    pvVar2 = _objc_msgSend(urlPath,sel_hasSuffix_,&cfstr__,uVar7);
                    if ((char)pvVar2 == '\0') {
                      uVar7 = CONCAT44((int)((ulonglong)uVar7 >> 0x20),&cfstr_index_html);
                      pcVar5 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr____,
                                             &cfstr_index_html);
                    }
                    urlPath = _objc_msgSend(urlPath,sel_stringByAppendingString_,pcVar5,uVar7);
                  }
                  uVar7 = CONCAT44((int)((ulonglong)uVar7 >> 0x20),&cfstr_src);
                  _objc_msgSend(pvVar3,sel_setObject_forKey_,urlPath,&cfstr_src);
                }
                _objc_msgSend(pvVar1,sel_setAttributes_,pvVar3,uVar7);
                _objc_msgSend(pvVar3,sel_release);
              }
            }
          }
          goto LAB_0028f403;
        }
      }
    }
  }
  local_20 = (id)0x0;
LAB_0028f403:
  pvVar1 = _objc_msgSend(local_20,sel_autorelease);
  return pvVar1;
}

*/
+ (id)embeddedCodeForDocument:(id)aDocument cardWidth:(CGFloat)aWidth cardHeight:(CGFloat)aHeight urlPath:(id)aPath
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HTML5Template" ofType:@"html"];
    NSData *data;
    HSXMLDocument *document;
    id root;
    id iframe;
    id attributes;
    id stack;
    NSMutableDictionary *newAttributes;
    NSSize cardSize;
    BOOL withLogo;
    if (path == nil) {
        return nil;
    }
    data = [[NSData alloc] initWithContentsOfFile:path];
    if (data == nil) {
        return nil;
    }
    document = [[HSXMLDocument alloc] initWithData:data];
    [data release];
    if (document == nil) {
        return nil;
    }
    root = [[document rootElement] retain];
    [document release];
    if (root == nil) {
        return nil;
    }
    iframe = [root elementNamed:@"iframe"];
    if (iframe != nil && (attributes = [iframe attributes]) != nil && (stack = [aDocument stack]) != nil) {
        cardSize = [stack hyperCardSize];
        if (aHeight <= 0.0f) {
            aHeight = cardSize.height;
        }
        if (aWidth <= 0.0f) {
            aWidth = cardSize.width;
        }
        newAttributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
        if (newAttributes != nil) {
            withLogo = [[NSUserDefaults standardUserDefaults] boolForKey:HSHTML5ExportWithLogoKey];
            if (withLogo) {
                aWidth = aWidth + 10.0f;
            }
            [newAttributes setObject:[NSString stringWithFormat:@"%0.2f", (double)(float)aWidth] forKey:@"width"];
            if (withLogo) {
                aHeight = aHeight + 10.0f;
            }
            [newAttributes setObject:[NSString stringWithFormat:@"%0.2f", (double)(float)aHeight] forKey:@"height"];
            if (aPath != nil) {
                if (![[aPath lastPathComponent] isEqualToString:@"index.html"]) {
                    NSString *suffix = @"index.html";
                    if (![aPath hasSuffix:@"/"]) {
                        suffix = [NSString stringWithFormat:@"/%@", @"index.html"];
                    }
                    aPath = [aPath stringByAppendingString:suffix];
                }
                [newAttributes setObject:aPath forKey:@"src"];
            }
            [iframe setAttributes:newAttributes];
            [newAttributes release];
        }
    }
    return [root autorelease];
}

- (void)terminateExport
{
    [super terminateExport];
    [_context setShouldTerminateExport:YES];
}

- (id)embeddedCode
{
    return _embeddedCode;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028ea88 @ 0028ea88, 1383 bytes * /

void FUN_0028ea88(HSHTML5Exporter *self,SEL _cmd,id performExportDocument,id ofType)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *self_00;
  id pvVar4;
  id pvVar5;
  float extraout_EDX;
  SEL op;
  cfstringStruct *pcVar6;
  
  _objc_msgSend(self,sel_notifyExportWillStartWithSlideshowAttributes_,0);
  _objc_msgSend(self,sel_notifyExportDidStart);
  _objc_msgSend(self->_context,sel_release);
  pvVar1 = _objc_msgSend(cls_HSHTML5ExportContext,sel_alloc);
  pvVar2 = _objc_msgSend(cls_HSHTML5LinkedStacksContext,sel_alloc);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithLinkedStacksLevel_andDocument_,0,performExportDocument);
  pcVar3 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar2 = ofType;
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithDocument_ofType_linkedStacksContext_,
                         performExportDocument,ofType,pcVar3);
  self->_context = pvVar1;
  pvVar1 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  pcVar6 = performExportDocument;
  self_00 = _objc_msgSend(self,sel_unsupportedFeaturesInDocument_,performExportDocument);
  pvVar4 = _objc_msgSend(self_00,sel_count);
  if (pvVar4 != (id)0x0) {
    pvVar4 = _objc_msgSend(cls_HSErrorsAlert,sel_alloc,pcVar6,pvVar2,pcVar3);
    pvVar4 = _objc_msgSend(pvVar4,sel_init);
    if (pvVar4 == (id)0x0) goto LAB_0028ef77;
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar6);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSHTML5ExportUnsupportedFeaturesMessageText,&cfstr_empty,
                           &cfstr_Export);
    _objc_msgSend(pvVar4,sel_setMessageText_,pvVar2);
    pvVar2 = _objc_msgSend(ofType,sel_isEqualToString_,&cfstr_HSiBooksAuthorDocumentType);
    pvVar5 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    if ((char)pvVar2 == '\0') {
      pcVar3 = &cfstr_HSHTML5ExportUnsupportedFeaturesInformativeText;
    }
    else {
      pcVar3 = &cfstr_HSiBooksAuthorExportUnsupportedFeaturesInformati;
    }
    pvVar2 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,pcVar3,&cfstr_empty,
                           &cfstr_Export);
    _objc_msgSend(pvVar4,sel_setInformativeText_,pvVar2);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSHTML5ExportUnsupportedFeaturesExport,&cfstr_empty,&cfstr_Export)
    ;
    _objc_msgSend(pvVar4,sel_addButtonWithTitle_,pvVar2);
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pcVar3 = &cfstr_Export;
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                           &cfstr_HSHTML5ExportUnsupportedFeaturesCancel,&cfstr_empty,&cfstr_Export)
    ;
    _objc_msgSend(pvVar4,sel_addButtonWithTitle_,pvVar2);
    pvVar2 = (id)0x1;
    _objc_msgSend(pvVar4,sel_setScriptErrors_isSimpleView_,self_00,1);
    pvVar5 = _objc_msgSend(pvVar4,sel_runModal);
    _objc_msgSend(pvVar4,sel_release);
    pcVar6 = self_00;
    if (pvVar5 != (id)0x3e8) {
      _objc_msgSend(self,sel_terminateExport,self_00,pvVar2);
      pcVar6 = self_00;
      goto LAB_0028ef77;
    }
  }
  _objc_msgSend(*(id *)(self->super_HSExporter2 + 0x18),sel_release,pcVar6,pvVar2);
  _objc_msgSend(self,sel_exportRepresentation);
  pvVar2 = *(id *)(self->super_HSExporter2 + 0x18);
  pvVar4 = _objc_msgSend(self,sel_exportedDocumentName);
  _objc_msgSend(pvVar2,sel_setPreferredFilename_,pvVar4);
  pvVar2 = _objc_msgSend(performExportDocument,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperCardSize);
  (self->_widgetSize).width = (float)pvVar2;
  (self->_widgetSize).height = extraout_EDX;
  pvVar4 = _objc_msgSend(performExportDocument,sel_undoManager);
  _objc_msgSend(pvVar4,sel_disableUndoRegistration);
  _objc_msgSend(self,sel_finalizeExportForDocument_,performExportDocument);
  pvVar2 = performExportDocument;
  pcVar3 = ofType;
  _objc_msgSend(self,sel_correctTemplate_forDocument_ofType_,
                *(undefined4 *)(self->super_HSExporter2 + 0x18),performExportDocument,ofType);
  _objc_msgSend(pvVar4,sel_enableUndoRegistration);
  pcVar6 = &cfstr_HSHTML5DocumentType;
  pvVar4 = _objc_msgSend(ofType,sel_isEqualToString_,&cfstr_HSHTML5DocumentType);
  if ((char)pvVar4 != '\0') {
    pvVar4 = _objc_msgSend(self,sel_embeddedCodeForDocument_,performExportDocument,pvVar2,pcVar3);
    pvVar4 = _objc_msgSend(pvVar4,sel_retain);
    self->_embeddedCode = pvVar4;
    pcVar6 = performExportDocument;
  }
LAB_0028ef77:
  _objc_msgSend(pvVar1,sel_release,pcVar6,pvVar2,pcVar3);
  op = sel_notifyExportDidTerminate;
  if (((self->super_HSExporter2[0x20] & 1) == 0) &&
     (pvVar2 = _objc_msgSend(self->_context,sel_shouldTerminateExport,pcVar6),
     op = sel_notifyExportDidTerminate, (char)pvVar2 == '\0')) {
    _objc_msgSend(self,sel_notifyExportWillEnd,pcVar6);
    op = sel_notifyExportDidEnd;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)performExportDocument:(id)aDocument ofType:(id)aType
{
    NSAutoreleasePool *pool;
    id unsupportedFeatures;
    HSErrorsAlert *alert;
    NSSize cardSize;
    NSUndoManager *undoManager;
    [self notifyExportWillStartWithSlideshowAttributes:nil];
    [self notifyExportDidStart];
    [_context release];
    _context = [[HSHTML5ExportContext alloc] initWithDocument:aDocument ofType:aType linkedStacksContext:[[[HSHTML5LinkedStacksContext alloc] initWithLinkedStacksLevel:0 andDocument:aDocument] autorelease]];
    pool = [NSAutoreleasePool new];
    unsupportedFeatures = [self unsupportedFeaturesInDocument:aDocument];
    if ([unsupportedFeatures count] != 0) {
        alert = [[HSErrorsAlert alloc] init];
        if (alert == nil) {
            goto done;
        }
        [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5ExportUnsupportedFeaturesMessageText" value:@"" table:@"Export"]];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:([aType isEqualToString:@"HSiBooksAuthorDocumentType"] ? @"HSiBooksAuthorExportUnsupportedFeaturesInformativeText" : @"HSHTML5ExportUnsupportedFeaturesInformativeText") value:@"" table:@"Export"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5ExportUnsupportedFeaturesExport" value:@"" table:@"Export"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5ExportUnsupportedFeaturesCancel" value:@"" table:@"Export"]];
        [alert setScriptErrors:unsupportedFeatures isSimpleView:YES];
        if ([alert runModal] != NSAlertFirstButtonReturn) {
            [alert release];
            [self terminateExport];
            goto done;
        }
        [alert release];
    }
    // The original released the representation without clearing it, so the
    // template wrapper was never reloaded; clear it so it is rebuilt.
    [_exportRepresentation release];
    _exportRepresentation = nil;
    [self exportRepresentation];
    [_exportRepresentation setPreferredFilename:[self exportedDocumentName]];
    cardSize = [[aDocument stack] hyperCardSize];
    _widgetSize = cardSize;
    undoManager = [aDocument undoManager];
    [undoManager disableUndoRegistration];
    [self finalizeExportForDocument:aDocument];
    [self correctTemplate:_exportRepresentation forDocument:aDocument ofType:aType];
    [undoManager enableUndoRegistration];
    if ([aType isEqualToString:@"HSHTML5DocumentType"]) {
        _embeddedCode = [[self embeddedCodeForDocument:aDocument] retain];
    }
done:
    [pool release];
    if (!_shouldTerminateExport && ![_context shouldTerminateExport]) {
        [self notifyExportWillEnd];
        [self notifyExportDidEnd];
    }
    else {
        [self notifyExportDidTerminate];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028f4ee @ 0028f4ee, 2001 bytes * /

void FUN_0028f4ee(HSHTML5Exporter *self,SEL _cmd,id correctTemplate,id forDocument,id ofType)

{
  int iVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined4 *puVar8;
  cfstringStruct *pcVar9;
  cfstringStruct *pcVar10;
  cfstringStruct *pcVar11;
  SEL op;
  undefined4 uVar12;
  undefined1 *puVar13;
  undefined4 uVar14;
  undefined4 uVar15;
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pcVar9 = &cfstr_index_html;
  pvVar6 = correctTemplate;
  pvVar3 = _objc_msgSend(self,sel_stringContentsOfFileWrapperAtKey_atDirectory_,&cfstr_index_html,
                         correctTemplate);
  if (pvVar3 != (id)0x0) {
    pvVar4 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar9,pvVar6);
    pcVar9 = &cfstr_CFBundleShortVersionString;
    pvVar5 = _objc_msgSend(pvVar4,sel_objectForInfoDictionaryKey_,&cfstr_CFBundleShortVersionString)
    ;
    if ((pvVar5 != (id)0x0) &&
       (pvVar6 = _objc_msgSend(pvVar4,sel_HS_buildVersion,pcVar9,pvVar6), puVar2 = cls_NSString,
       pvVar6 != (id)0x0)) {
      pvVar4 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr________,
                             &cfstr_empty,&cfstr_Localizable);
      pvVar7 = _objc_msgSend(puVar2,sel_stringWithFormat_,pvVar4,pvVar5,pvVar6);
      if (pvVar7 != (id)0x0) {
        pvVar6 = _objc_msgSend(pvVar3,sel_length,pvVar4,pvVar5,pvVar6);
        pcVar9 = &cfstr__hyperStudioVersion;
        uVar15 = 0;
        uVar14 = 0;
        _objc_msgSend(pvVar3,sel_replaceOccurrencesOfString_withString_options_range_,
                      &cfstr__hyperStudioVersion,pvVar7,0,0,pvVar6);
        pvVar4 = _objc_msgSend(pvVar3,sel_length);
        if (pvVar4 != (id)0x0) {
          pvVar6 = _objc_msgSend(pvVar3,sel_length,pcVar9,pvVar7,uVar14,uVar15,pvVar6);
          pvVar4 = _objc_msgSend(ofType,sel_isEqualToString_,&cfstr_HSiBooksAuthorDocumentType);
          pcVar9 = &cfstr_true;
          if ((char)pvVar4 == '\0') {
            pcVar9 = &cfstr_false;
          }
          uVar15 = 0;
          uVar14 = 0;
          _objc_msgSend(pvVar3,sel_replaceOccurrencesOfString_withString_options_range_,
                        &cfstr__isWidgetVar,pcVar9,0,0,pvVar6);
          pvVar4 = _objc_msgSend(pvVar3,sel_length);
          if (pvVar4 != (id)0x0) {
            pcVar11 = &cfstr_HSHTML5DocumentType;
            pvVar4 = _objc_msgSend(ofType,sel_isEqualToString_,&cfstr_HSHTML5DocumentType,pcVar9,
                                   uVar14,uVar15,pvVar6);
            pcVar10 = &cfstr_false;
            if ((char)pvVar4 != '\0') {
              pvVar5 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pcVar11,pcVar9,
                                     uVar14,uVar15,pvVar6);
              pcVar11 = *(cfstringStruct **)PTR_003369f0;
              pvVar5 = _objc_msgSend(pvVar5,sel_boolForKey_,pcVar11);
              pcVar10 = &cfstr_false;
              if ((char)pvVar5 != '\0') {
                pcVar10 = &cfstr_true;
              }
            }
            pvVar6 = _objc_msgSend(pvVar3,sel_length,pcVar11,pcVar9,uVar14,uVar15,pvVar6);
            pcVar9 = &cfstr__isFrameEnabledVar;
            uVar15 = 0;
            uVar14 = 0;
            _objc_msgSend(pvVar3,sel_replaceOccurrencesOfString_withString_options_range_,
                          &cfstr__isFrameEnabledVar,pcVar10,0,0,pvVar6);
            pvVar5 = _objc_msgSend(pvVar3,sel_length);
            if (pvVar5 != (id)0x0) {
              if ((char)pvVar4 == '\0') {
                pcVar11 = &cfstr_false;
              }
              else {
                pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pcVar9,pcVar10,
                                       uVar14,uVar15,pvVar6);
                pcVar9 = *(cfstringStruct **)PTR_003369e4;
                pvVar4 = _objc_msgSend(pvVar4,sel_boolForKey_,pcVar9);
                pcVar11 = &cfstr_false;
                if ((char)pvVar4 != '\0') {
                  pcVar11 = &cfstr_true;
                }
              }
              pvVar6 = _objc_msgSend(pvVar3,sel_length,pcVar9,pcVar10,uVar14,uVar15,pvVar6);
              pcVar9 = &cfstr__isAutoResize;
              uVar15 = 0;
              uVar14 = 0;
              _objc_msgSend(pvVar3,sel_replaceOccurrencesOfString_withString_options_range_,
                            &cfstr__isAutoResize,pcVar11,0,0,pvVar6);
              pvVar4 = _objc_msgSend(pvVar3,sel_length);
              if (pvVar4 != (id)0x0) {
                pvVar4 = _objc_msgSend(forDocument,sel_fileURL,pcVar9,pcVar11,uVar14,uVar15,pvVar6);
                puVar2 = cls_HSHTML5ExporterHelper;
                op = sel_displayName;
                if (pvVar4 != (id)0x0) {
                  forDocument = _objc_msgSend(pvVar4,sel_URLByDeletingPathExtension,pcVar9,pcVar11,
                                              uVar14,uVar15,pvVar6);
                  op = sel_lastPathComponent;
                }
                pvVar6 = _objc_msgSend(forDocument,op,pcVar9,pcVar11,uVar14,uVar15,pvVar6);
                pvVar6 = _objc_msgSend(puVar2,sel_JSonCorrectFilenameWithString_,pvVar6);
                pvVar4 = _objc_msgSend(pvVar3,sel_length);
                pvVar6 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_____,pvVar6);
                uVar15 = 0;
                uVar14 = 0;
                _objc_msgSend(pvVar3,sel_replaceOccurrencesOfString_withString_options_range_,
                              &cfstr__homeStackNameVar,pvVar6,0,0,pvVar4);
                pvVar5 = _objc_msgSend(pvVar3,sel_length);
                if (pvVar5 != (id)0x0) {
                  uVar12 = 4;
                  pvVar3 = _objc_msgSend(pvVar3,sel_dataUsingEncoding_,4,pvVar6,uVar14,uVar15,pvVar4
                                        );
                  pvVar5 = _objc_msgSend(pvVar3,sel_length);
                  if (pvVar5 != (id)0x0) {
                    pvVar6 = _objc_msgSend(correctTemplate,sel_fileWrappers,uVar12,pvVar6,uVar14,
                                           uVar15,pvVar4);
                    pvVar6 = _objc_msgSend(pvVar6,sel_objectForKey_,&cfstr_index_html);
                    _objc_msgSend(correctTemplate,sel_removeFileWrapper_,pvVar6);
                    _objc_msgSend(correctTemplate,sel_addRegularFileWithContents_preferredFilename_,
                                  pvVar3,&cfstr_index_html);
                    pcVar9 = &cfstr_hs_manifest;
                    pvVar6 = correctTemplate;
                    pvVar3 = _objc_msgSend(self,sel_stringContentsOfFileWrapperAtKey_atDirectory_,
                                           &cfstr_hs_manifest,correctTemplate);
                    puVar2 = cls_NSString;
                    if (pvVar3 != (id)0x0) {
                      pvVar6 = _objc_msgSend(cls_HSUID,sel_UID,pcVar9,pvVar6);
                      pvVar6 = _objc_msgSend(pvVar6,sel_stringValue);
                      pvVar6 = _objc_msgSend(puVar2,sel_stringWithFormat_,&cfstr__v_____,pvVar6);
                      local_74 = 0;
                      local_70 = 0;
                      local_6c = (int *)0x0;
                      local_68 = 0;
                      local_64 = 0;
                      local_60 = 0;
                      local_5c = 0;
                      local_58 = 0;
                      pvVar4 = _objc_msgSend(self,sel_stackDataManifestFiles);
                      puVar13 = local_50;
                      puVar8 = &local_74;
                      uVar14 = 0x10;
                      local_78 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_
                                               ,puVar8,puVar13,0x10);
                      if (local_78 != (id)0x0) {
                        iVar1 = *local_6c;
                        do {
                          pvVar5 = (id)0x0;
                          do {
                            if (iVar1 != *local_6c) {
                              pvVar7 = _objc_msgSend(self,sel_stackDataManifestFiles,puVar8,puVar13,
                                                     uVar14);
                              _objc_enumerationMutation(pvVar7);
                            }
                            puVar13 = *(undefined1 **)(local_70 + (int)pvVar5 * 4);
                            puVar8 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr____,
                                                   puVar13,uVar14);
                            _objc_msgSend(pvVar3,sel_appendString_,puVar8);
                            pvVar5 = (id)((int)pvVar5 + 1);
                          } while (pvVar5 < local_78);
                          puVar13 = local_50;
                          puVar8 = &local_74;
                          uVar14 = 0x10;
                          local_78 = _objc_msgSend(pvVar4,
                                                  sel_countByEnumeratingWithState_objects_count_,
                                                  puVar8,puVar13,0x10);
                        } while (local_78 != (id)0x0);
                      }
                      _objc_msgSend(pvVar3,sel_appendString_,pvVar6,puVar13,uVar14);
                      uVar14 = 4;
                      pvVar6 = _objc_msgSend(pvVar3,sel_dataUsingEncoding_,4);
                      pvVar3 = _objc_msgSend(pvVar6,sel_length);
                      if (pvVar3 != (id)0x0) {
                        pvVar3 = _objc_msgSend(correctTemplate,sel_fileWrappers,uVar14);
                        pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_hs_manifest);
                        _objc_msgSend(correctTemplate,sel_removeFileWrapper_,pvVar3);
                        _objc_msgSend(correctTemplate,
                                      sel_addRegularFileWithContents_preferredFilename_,pvVar6,
                                      &cfstr_hs_manifest);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return;
}

*/
- (void)correctTemplate:(id)aTemplate forDocument:(id)aDocument ofType:(id)aType
{
    NSMutableString *index = [self stringContentsOfFileWrapperAtKey:@"index.html" atDirectory:aTemplate];
    NSBundle *bundle;
    id shortVersion;
    id buildVersion;
    NSString *version;
    BOOL isHTML5;
    NSString *value;
    id url;
    id name;
    NSData *data;
    NSMutableString *manifest;
    NSString *versionLine;
    if (index == nil) {
        return;
    }
    bundle = [NSBundle mainBundle];
    shortVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (shortVersion == nil || (buildVersion = [bundle HS_buildVersion]) == nil) {
        return;
    }
    version = [NSString stringWithFormat:[bundle localizedStringForKey:@"%@ (%@)" value:@"" table:@"Localizable"], shortVersion, buildVersion];
    if (version == nil) {
        return;
    }
    [index replaceOccurrencesOfString:@"$hyperStudioVersion" withString:version options:0 range:NSMakeRange(0, [index length])];
    if ([index length] == 0) {
        return;
    }
    value = [aType isEqualToString:@"HSiBooksAuthorDocumentType"] ? @"true" : @"false";
    [index replaceOccurrencesOfString:@"$isWidgetVar" withString:value options:0 range:NSMakeRange(0, [index length])];
    if ([index length] == 0) {
        return;
    }
    isHTML5 = [aType isEqualToString:@"HSHTML5DocumentType"];
    value = @"false";
    if (isHTML5 && [[NSUserDefaults standardUserDefaults] boolForKey:HSHTML5ExportWithLogoKey]) {
        value = @"true";
    }
    [index replaceOccurrencesOfString:@"$isFrameEnabledVar" withString:value options:0 range:NSMakeRange(0, [index length])];
    if ([index length] == 0) {
        return;
    }
    value = @"false";
    if (isHTML5 && [[NSUserDefaults standardUserDefaults] boolForKey:HSHTML5ExportAdjustBrowserWindowKey]) {
        value = @"true";
    }
    [index replaceOccurrencesOfString:@"$isAutoResize" withString:value options:0 range:NSMakeRange(0, [index length])];
    if ([index length] == 0) {
        return;
    }
    url = [aDocument fileURL];
    if (url != nil) {
        name = [[url URLByDeletingPathExtension] lastPathComponent];
    }
    else {
        name = [aDocument displayName];
    }
    name = [HSHTML5ExporterHelper JSonCorrectFilenameWithString:name];
    [index replaceOccurrencesOfString:@"$homeStackNameVar" withString:[NSString stringWithFormat:@"'%@'", name] options:0 range:NSMakeRange(0, [index length])];
    if ([index length] == 0) {
        return;
    }
    data = [index dataUsingEncoding:NSUTF8StringEncoding];
    if ([data length] == 0) {
        return;
    }
    [aTemplate removeFileWrapper:[[aTemplate fileWrappers] objectForKey:@"index.html"]];
    [aTemplate addRegularFileWithContents:data preferredFilename:@"index.html"];
    manifest = [self stringContentsOfFileWrapperAtKey:@"hs.manifest" atDirectory:aTemplate];
    if (manifest != nil) {
        versionLine = [NSString stringWithFormat:@"#v = %@", [[HSUID UID] stringValue]];
        for (id file in [self stackDataManifestFiles]) {
            [manifest appendString:[NSString stringWithFormat:@"%@\n", file]];
        }
        [manifest appendString:versionLine];
        data = [manifest dataUsingEncoding:NSUTF8StringEncoding];
        if ([data length] != 0) {
            [aTemplate removeFileWrapper:[[aTemplate fileWrappers] objectForKey:@"hs.manifest"]];
            [aTemplate addRegularFileWithContents:data preferredFilename:@"hs.manifest"];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028fcbf @ 0028fcbf, 420 bytes * /

id FUN_0028fcbf(HSHTML5Exporter *self,SEL _cmd)

{
  int iVar1;
  id self_00;
  undefined *self_01;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  undefined1 *puVar6;
  undefined4 uVar7;
  id local_80;
  cfstringStruct local_74;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(*(id *)(self->super_HSExporter2 + 0x18),sel_fileWrappers);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_data);
  self_01 = cls_NSMutableArray;
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperWrapperContents);
  pvVar2 = _objc_msgSend(self_01,sel_arrayWithArray_,pvVar2);
  local_74.field0_0x0 = 0;
  local_74.field1_0x4 = 0;
  local_74.field2_0x8 = (undefined *)0x0;
  local_74.field3_0xc = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar6 = local_50;
  pcVar5 = &local_74;
  uVar7 = 0x10;
  local_80 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,pcVar5,puVar6,0x10)
  ;
  if (local_80 != (id)0x0) {
    iVar1 = *(int *)local_74.field2_0x8;
    do {
      pvVar4 = (id)0x0;
      do {
        if (iVar1 != *(int *)local_74.field2_0x8) {
          _objc_enumerationMutation(pvVar2);
        }
        self_00 = *(id *)(local_74.field1_0x4 + (int)pvVar4 * 4);
        pvVar3 = _objc_msgSend(self_00,sel_lastPathComponent,pcVar5,puVar6,uVar7);
        pcVar5 = &cfstr__htaccess;
        pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_);
        if ((char)pvVar3 != '\0') {
          _objc_msgSend(pvVar2,sel_removeObject_,self_00);
          return pvVar2;
        }
        pvVar4 = (id)((int)pvVar4 + 1);
      } while (pvVar4 < local_80);
      puVar6 = local_50;
      pcVar5 = &local_74;
      uVar7 = 0x10;
      local_80 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,pcVar5,puVar6,
                               0x10);
    } while (local_80 != (id)0x0);
  }
  return pvVar2;
}

*/
- (id)stackDataManifestFiles
{
    NSMutableArray *files = [NSMutableArray arrayWithArray:[[[_exportRepresentation fileWrappers] objectForKey:@"data"] hyperWrapperContents]];
    for (id file in [[files copy] autorelease]) {
        if ([[file lastPathComponent] isEqualToString:@".htaccess"]) {
            [files removeObject:file];
        }
    }
    return files;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028e973 @ 0028e973, 277 bytes * /

id FUN_0028e973(HSHTML5Exporter *self,SEL _cmd,id stringContentsOfFileWrapperAtKey,id atDirectory)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(atDirectory,sel_fileWrappers);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,stringContentsOfFileWrapperAtKey);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_regularFileContents,stringContentsOfFileWrapperAtKey);
    pvVar2 = _objc_msgSend(pvVar1,sel_length);
    if (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(cls_NSString,sel_alloc,stringContentsOfFileWrapperAtKey);
      uVar4 = 4;
      pvVar2 = _objc_msgSend(pvVar2,sel_initWithData_encoding_,pvVar1,4);
      pvVar3 = _objc_msgSend(pvVar2,sel_length);
      if (pvVar3 != (id)0x0) {
        pvVar1 = _objc_msgSend(pvVar2,sel_mutableCopy,pvVar1,uVar4);
        pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
        _objc_msgSend(pvVar2,sel_release);
        return pvVar1;
      }
      _objc_msgSend(pvVar2,sel_release,pvVar1,uVar4);
    }
  }
  return (id)0x0;
}

*/
- (id)stringContentsOfFileWrapperAtKey:(id)aKey atDirectory:(id)aDirectory
{
    id wrapper = [[aDirectory fileWrappers] objectForKey:aKey];
    NSData *data;
    NSString *string;
    id result = nil;
    if (wrapper == nil) {
        return nil;
    }
    data = [wrapper regularFileContents];
    if ([data length] == 0) {
        return nil;
    }
    string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([string length] != 0) {
        result = [[string mutableCopy] autorelease];
    }
    [string release];
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028e55b @ 0028e55b, 1048 bytes * /

void FUN_0028e55b(HSHTML5Exporter *self,SEL _cmd,id finalizeExportForDocument)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  undefined *puVar7;
  SEL op;
  undefined4 uVar8;
  
  pvVar1 = _objc_msgSend(finalizeExportForDocument,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_HTML5DictionaryRepresentationInContext_,self->_context);
  puVar7 = cls_NSDictionary;
  pvVar1 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,pvVar1);
  pvVar1 = _objc_msgSend(puVar7,sel_dictionaryWithObject_forKey_,pvVar1,&cfstr_stacks);
  puVar7 = cls_NSString;
  pvVar2 = _objc_msgSend(self,sel_JSonStringWithDictionary_humanReadable_,pvVar1,0);
  pvVar1 = _objc_msgSend(puVar7,sel_stringWithFormat_,&cfstr_getStack____,pvVar2);
  pvVar3 = _objc_msgSend(cls_NSFileWrapper,sel_alloc);
  pvVar3 = _objc_msgSend(pvVar3,sel_initDirectoryWithFileWrappers_,0);
  _objc_msgSend(pvVar3,sel_setPreferredFilename_,&cfstr_stackData);
  pvVar4 = _objc_msgSend(cls_NSFileWrapper,sel_alloc);
  uVar8 = 0;
  pvVar4 = _objc_msgSend(pvVar4,sel_initDirectoryWithFileWrappers_,0);
  pvVar5 = _objc_msgSend(finalizeExportForDocument,sel_fileURL);
  puVar7 = cls_HSHTML5ExporterHelper;
  if (pvVar5 == (id)0x0) {
    pcVar6 = _objc_msgSend(finalizeExportForDocument,sel_displayName,uVar8);
    op = sel_JSonCorrectFilenameWithString_;
  }
  else {
    _objc_msgSend(self->_context,sel_addLinkedStackURL_,pvVar5);
    puVar7 = cls_NSString;
    pvVar2 = _objc_msgSend(self->_context,sel_nameForLinkedStackURL_,pvVar5);
    pcVar6 = &cfstr___;
    op = sel_stringWithFormat_;
  }
  pvVar5 = _objc_msgSend(puVar7,op,pcVar6,pvVar2);
  _objc_msgSend(pvVar4,sel_setPreferredFilename_,pvVar5);
  pvVar1 = _objc_msgSend(pvVar1,sel_dataUsingEncoding_,4);
  pcVar6 = &cfstr_stack_json;
  _objc_msgSend(pvVar4,sel_addRegularFileWithContents_preferredFilename_,pvVar1,&cfstr_stack_json);
  pvVar1 = _objc_msgSend(self,sel_resourcesWrapperWithContext_,self->_context);
  _objc_msgSend(pvVar4,sel_addFileWrapper_,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_previewsWrapperForDocument_,finalizeExportForDocument);
  _objc_msgSend(pvVar4,sel_addFileWrapper_,pvVar1);
  pvVar1 = *(id *)(self->super_HSExporter2 + 0x18);
  pvVar5 = _objc_msgSend(self,sel_previewIconWrapperForDocument_,finalizeExportForDocument);
  _objc_msgSend(pvVar1,sel_addFileWrapper_,pvVar5);
  pvVar1 = pvVar4;
  _objc_msgSend(pvVar3,sel_addFileWrapper_,pvVar4);
  _objc_msgSend(pvVar4,sel_release);
  pvVar4 = _objc_msgSend(self->_context,sel_linkedStackURLs);
  pvVar4 = _objc_msgSend(pvVar4,sel_count);
  if (pvVar4 != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_integerForKey_,*(undefined4 *)PTR_PTR_003369ec);
    self->_linkedStacksNumber = (uint)pvVar1;
    pcVar6 = self->_context;
    pvVar1 = pvVar3;
    _objc_msgSend(self,sel_linkedStacksFileWrapper_withContext_currentLevel_,pvVar3,pcVar6,1);
  }
  pvVar1 = _objc_msgSend(*(id *)(self->super_HSExporter2 + 0x18),sel_fileWrappers,pvVar1,pcVar6);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_data);
  _objc_msgSend(pvVar1,sel_addFileWrapper_,pvVar3);
  _objc_msgSend(pvVar3,sel_release);
  return;
}

*/
- (void)finalizeExportForDocument:(id)aDocument
{
    id stackDictionary = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[[aDocument stack] HTML5DictionaryRepresentationInContext:_context]] forKey:@"stacks"];
    NSString *json = [NSString stringWithFormat:@"getStack(%@)", [self JSonStringWithDictionary:stackDictionary humanReadable:NO]];
    NSFileWrapper *stackData = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
    NSFileWrapper *stackWrapper;
    id url;
    [stackData setPreferredFilename:@"stackData"];
    stackWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
    url = [aDocument fileURL];
    if (url == nil) {
        [stackWrapper setPreferredFilename:[HSHTML5ExporterHelper JSonCorrectFilenameWithString:[aDocument displayName]]];
    }
    else {
        [_context addLinkedStackURL:url];
        [stackWrapper setPreferredFilename:[NSString stringWithFormat:@"%@", [_context nameForLinkedStackURL:url]]];
    }
    [stackWrapper addRegularFileWithContents:[json dataUsingEncoding:NSUTF8StringEncoding] preferredFilename:@"stack.json"];
    [stackWrapper addFileWrapper:[self resourcesWrapperWithContext:_context]];
    [stackWrapper addFileWrapper:[self previewsWrapperForDocument:aDocument]];
    [_exportRepresentation addFileWrapper:[self previewIconWrapperForDocument:aDocument]];
    [stackData addFileWrapper:stackWrapper];
    [stackWrapper release];
    if ([[_context linkedStackURLs] count] != 0) {
        _linkedStacksNumber = (unsigned int)[[NSUserDefaults standardUserDefaults] integerForKey:HSHTML5ExportLinkedStacksDepth];
        [self linkedStacksFileWrapper:stackData withContext:_context currentLevel:1];
    }
    [[[_exportRepresentation fileWrappers] objectForKey:@"data"] addFileWrapper:stackData];
    [stackData release];
}

- (id)embeddedCodeForDocument:(id)aDocument
{
    return [HSHTML5Exporter embeddedCodeForDocument:aDocument cardWidth:0 cardHeight:0 urlPath:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028fe63 @ 0028fe63, 2653 bytes * /

id FUN_0028fe63(HSHTML5Exporter *self,SEL _cmd,id unsupportedFeaturesInDocument)

{
  int iVar1;
  id pvVar2;
  id self_00;
  id self_01;
  id self_02;
  id self_03;
  id self_04;
  id pvVar3;
  id self_05;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined *puVar8;
  cfstringStruct *pcVar9;
  id pvVar10;
  undefined4 *puVar11;
  cfstringStruct *pcVar12;
  cfstringStruct *pcVar13;
  int iVar14;
  undefined4 uVar15;
  undefined4 uVar16;
  undefined4 uVar17;
  id local_114;
  id local_104;
  id local_ec;
  id local_e0;
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  cfstringStruct local_b4 [4];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  cfstringStruct local_50 [4];
  
  pvVar2 = _objc_msgSend(cls_NSMutableSet,sel_set);
  self_00 = _objc_msgSend(cls_NSMutableSet,sel_set);
  self_01 = _objc_msgSend(cls_NSMutableSet,sel_set);
  self_02 = _objc_msgSend(cls_NSMutableSet,sel_set);
  self_03 = _objc_msgSend(cls_NSMutableSet,sel_set);
  self_04 = _objc_msgSend(cls_NSMutableSet,sel_set);
  pvVar3 = _objc_msgSend(unsupportedFeaturesInDocument,sel_stack);
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperDeepEnumerator);
  pvVar3 = _objc_msgSend(pvVar3,sel_allObjects);
  local_d4 = 0;
  local_d0 = 0;
  local_cc = (int *)0x0;
  local_c8 = 0;
  local_c4 = 0;
  local_c0 = 0;
  local_bc = 0;
  local_b8 = 0;
  pcVar12 = local_b4;
  puVar11 = &local_d4;
  pcVar13 = (cfstringStruct *)0x10;
  local_114 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar11,pcVar12,
                            0x10);
  if (local_114 != (id)0x0) {
    uVar17 = *(undefined4 *)PTR_00336084;
    uVar16 = *(undefined4 *)PTR_00336080;
    uVar15 = *(undefined4 *)PTR_00336500;
    iVar14 = *local_cc;
    do {
      local_104 = (id)0x0;
      do {
        if (iVar14 != *local_cc) {
          _objc_enumerationMutation(pvVar3);
        }
        pvVar7 = *(id *)(local_d0 + (int)local_104 * 4);
        self_05 = _objc_msgSend(cls_NSAutoreleasePool,sel_new,puVar11,pcVar12,pcVar13,iVar14,uVar15,
                                uVar16,uVar17);
        pvVar4 = _objc_msgSend(self->_context,sel_documentType);
        pvVar6 = pvVar4;
        pvVar5 = _objc_msgSend(pvVar7,sel_canBeExportedToHTML5DocumentType_,pvVar4);
        if ((char)pvVar5 == '\0') {
          pvVar6 = _objc_msgSend(pvVar7,sel_HTML5UnsupportedFunctionalityDescription,pvVar6);
          if (pvVar6 != (id)0x0) {
            _objc_msgSend(pvVar2,sel_addObject_,pvVar6);
          }
        }
        pvVar6 = _objc_msgSend(pvVar7,sel_hasUnsupportedHTML5FeaturesForDocumentType_,pvVar4);
        if ((char)pvVar6 != '\0') {
          pvVar6 = _objc_msgSend(pvVar7,sel_HTML5UnsupportedFeaturesForDocumentType_,pvVar4);
          if (pvVar6 != (id)0x0) {
            _objc_msgSend(self_00,sel_unionSet_,pvVar6);
          }
        }
        pvVar6 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,&DAT_003886c4);
        puVar8 = &DAT_003885ac;
        pvVar7 = _objc_msgSend(pvVar7,sel_implementsHyperInterface_,&DAT_003885ac);
        if ((char)pvVar7 != '\0') {
          pvVar7 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,uVar15);
          pvVar5 = _objc_msgSend(pvVar6,sel_hyperActionsForEvent_,pvVar7);
          pvVar5 = _objc_msgSend(pvVar5,sel_count);
          if (pvVar5 != (id)0x0) {
            pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar7);
            pcVar13 = &cfstr_Export;
            pcVar12 = &cfstr_empty;
            pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                                   &cfstr_HSHTML5UnsupportedFeatureLeavingStack,&cfstr_empty,
                                   &cfstr_Export);
            _objc_msgSend(self_02,sel_addObject_,pvVar7);
          }
          pvVar7 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,uVar16,pcVar12,pcVar13);
          pvVar5 = _objc_msgSend(pvVar6,sel_hyperActionsForEvent_,pvVar7);
          pvVar5 = _objc_msgSend(pvVar5,sel_count);
          if (pvVar5 != (id)0x0) {
            pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar7);
            pcVar13 = &cfstr_Export;
            pcVar12 = &cfstr_empty;
            pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                                   &cfstr_HSHTML5UnsupportedFeatureArrivingStack,&cfstr_empty,
                                   &cfstr_Export);
            _objc_msgSend(self_02,sel_addObject_,pvVar7);
          }
          puVar8 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,uVar17,pcVar12,pcVar13);
          pvVar7 = _objc_msgSend(pvVar6,sel_hyperActionsForEvent_,puVar8);
          pvVar7 = _objc_msgSend(pvVar7,sel_count);
          if (pvVar7 != (id)0x0) {
            pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,puVar8);
            pcVar13 = &cfstr_Export;
            pcVar12 = &cfstr_empty;
            puVar8 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                                   &cfstr_HSHTML5UnsupportedFeatureClickingStack,&cfstr_empty,
                                   &cfstr_Export);
            _objc_msgSend(self_02,sel_addObject_,puVar8);
          }
        }
        pvVar7 = _objc_msgSend(pvVar6,sel_hyperActions,puVar8,pcVar12,pcVar13);
        local_74 = 0;
        local_70 = 0;
        local_6c = (int *)0x0;
        local_68 = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        pcVar12 = local_50;
        puVar11 = &local_74;
        pcVar13 = (cfstringStruct *)0x10;
        local_ec = _objc_msgSend(pvVar7,sel_countByEnumeratingWithState_objects_count_,puVar11);
        if (local_ec != (id)0x0) {
          iVar1 = *local_6c;
          do {
            local_e0 = (id)0x0;
            do {
              if (iVar1 != *local_6c) {
                _objc_enumerationMutation(pvVar7);
              }
              pvVar6 = *(id *)(local_70 + (int)local_e0 * 4);
              puVar8 = &DAT_003887c8;
              pvVar5 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_003887c8,pcVar12,pcVar13);
              pcVar9 = _objc_msgSend(pvVar5,sel_localizedName);
              if (pvVar5 != (id)0x0) {
                pvVar10 = _objc_msgSend(self->_context,sel_documentType,puVar8);
                pvVar5 = _objc_msgSend(pvVar5,sel_canBeExportedToHTML5DocumentType_,pvVar10);
                puVar8 = cls_NSString;
                if ((char)pvVar5 == '\0') {
                  pvVar5 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar10
                                        );
                  pcVar13 = &cfstr_Export;
                  pvVar5 = _objc_msgSend(pvVar5,sel_localizedStringForKey_value_table_,
                                         &cfstr_HSHTML5UnsupportedFeatureAction,&cfstr_empty,
                                         &cfstr_Export);
                  pvVar5 = _objc_msgSend(puVar8,sel_stringWithFormat_,pvVar5,pcVar9);
                  _objc_msgSend(self_03,sel_addObject_,pvVar5);
                  pcVar12 = pcVar9;
                }
              }
              pvVar5 = _objc_msgSend(pvVar6,sel_hasUnsupportedHTML5FeaturesForDocumentType_,pvVar4,
                                     pcVar12,pcVar13);
              if ((char)pvVar5 != '\0') {
                pvVar5 = _objc_msgSend(pvVar6,sel_HTML5UnsupportedFeaturesForDocumentType_,pvVar4,
                                       pcVar12);
                pvVar10 = _objc_msgSend(pvVar5,sel_count);
                if (pvVar10 != (id)0x0) {
                  _objc_msgSend(self_04,sel_unionSet_,pvVar5);
                }
              }
              puVar8 = &DAT_0038882c;
              pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_0038882c);
              pvVar6 = _objc_msgSend(pvVar6,sel_transition);
              if (pvVar6 != (id)0x0) {
                pvVar5 = _objc_msgSend(self->_context,sel_documentType,puVar8);
                pvVar10 = _objc_msgSend(pvVar6,sel_canBeExportedToHTML5DocumentType_,pvVar5);
                if ((char)pvVar10 == '\0') {
                  pvVar5 = _objc_msgSend(pvVar6,sel_HTML5UnsupportedFunctionalityDescription,pvVar5)
                  ;
                  if (pvVar5 != (id)0x0) {
                    _objc_msgSend(self_01,sel_addObject_,pvVar5);
                  }
                }
                pvVar5 = _objc_msgSend(pvVar6,sel_hasUnsupportedHTML5FeaturesForDocumentType_,pvVar4
                                      );
                if ((char)pvVar5 != '\0') {
                  pvVar6 = _objc_msgSend(pvVar6,sel_HTML5UnsupportedFeaturesForDocumentType_,pvVar4)
                  ;
                  if (pvVar6 != (id)0x0) {
                    _objc_msgSend(self_00,sel_unionSet_,pvVar6);
                  }
                }
              }
              local_e0 = (id)((int)local_e0 + 1);
            } while (local_e0 < local_ec);
            pcVar12 = local_50;
            puVar11 = &local_74;
            pcVar13 = (cfstringStruct *)0x10;
            local_ec = _objc_msgSend(pvVar7,sel_countByEnumeratingWithState_objects_count_,puVar11,
                                     pcVar12,0x10);
          } while (local_ec != (id)0x0);
        }
        local_104 = (id)((int)local_104 + 1);
        _objc_msgSend(self_05,sel_release,puVar11,pcVar12,pcVar13);
      } while (local_104 < local_114);
      pcVar12 = local_b4;
      puVar11 = &local_d4;
      pcVar13 = (cfstringStruct *)0x10;
      local_114 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar11,
                                pcVar12,0x10);
    } while (local_114 != (id)0x0);
  }
  pvVar2 = _objc_msgSend(cls_NSMutableSet,sel_setWithSet_,pvVar2,pcVar12,pcVar13);
  _objc_msgSend(pvVar2,sel_unionSet_,self_00);
  _objc_msgSend(pvVar2,sel_unionSet_,self_01);
  _objc_msgSend(pvVar2,sel_unionSet_,self_02);
  _objc_msgSend(pvVar2,sel_unionSet_,self_03);
  _objc_msgSend(pvVar2,sel_unionSet_,self_04);
  pvVar2 = _objc_msgSend(pvVar2,sel_allObjects);
  return pvVar2;
}

*/
- (id)unsupportedFeaturesInDocument:(id)aDocument
{
    NSMutableSet *objectFeatures = [NSMutableSet set];
    NSMutableSet *unsupportedFeatures = [NSMutableSet set];
    NSMutableSet *transitionFeatures = [NSMutableSet set];
    NSMutableSet *stackEventFeatures = [NSMutableSet set];
    NSMutableSet *actionFeatures = [NSMutableSet set];
    NSMutableSet *actionUnsupportedFeatures = [NSMutableSet set];
    NSMutableSet *result;
    for (id object in [[[aDocument stack] hyperDeepEnumerator] allObjects]) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        id documentType = [_context documentType];
        id description;
        id features;
        id actor;
        if (![object canBeExportedToHTML5DocumentType:documentType]) {
            description = [object HTML5UnsupportedFunctionalityDescription];
            if (description != nil) {
                [objectFeatures addObject:description];
            }
        }
        if ([object hasUnsupportedHTML5FeaturesForDocumentType:documentType]) {
            features = [object HTML5UnsupportedFeaturesForDocumentType:documentType];
            if (features != nil) {
                [unsupportedFeatures unionSet:features];
            }
        }
        actor = [object queryHyperInterface:@protocol(HSActor)];
        if ([object implementsHyperInterface:@protocol(HSStackAttributes)]) {
            if ([[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSLeaveActionEventType]] count] != 0) {
                [stackEventFeatures addObject:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureLeavingStack" value:@"" table:@"Export"]];
            }
            if ([[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]] count] != 0) {
                [stackEventFeatures addObject:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureArrivingStack" value:@"" table:@"Export"]];
            }
            if ([[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]] count] != 0) {
                [stackEventFeatures addObject:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureClickingStack" value:@"" table:@"Export"]];
            }
        }
        for (id action in [actor hyperActions]) {
            id attributes = [action queryHyperInterface:@protocol(HSActionAttributes)];
            id name = [attributes localizedName];
            id transition;
            if (attributes != nil && ![attributes canBeExportedToHTML5DocumentType:[_context documentType]]) {
                [actionFeatures addObject:[NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureAction" value:@"" table:@"Export"], name]];
            }
            if ([action hasUnsupportedHTML5FeaturesForDocumentType:documentType]) {
                features = [action HTML5UnsupportedFeaturesForDocumentType:documentType];
                if ([features count] != 0) {
                    [actionUnsupportedFeatures unionSet:features];
                }
            }
            transition = [[action queryHyperInterface:@protocol(HSTransitionOwner)] transition];
            if (transition != nil) {
                if (![transition canBeExportedToHTML5DocumentType:[_context documentType]]) {
                    description = [transition HTML5UnsupportedFunctionalityDescription];
                    if (description != nil) {
                        [transitionFeatures addObject:description];
                    }
                }
                if ([transition hasUnsupportedHTML5FeaturesForDocumentType:documentType]) {
                    features = [transition HTML5UnsupportedFeaturesForDocumentType:documentType];
                    if (features != nil) {
                        [unsupportedFeatures unionSet:features];
                    }
                }
            }
        }
        [pool release];
    }
    result = [NSMutableSet setWithSet:objectFeatures];
    [result unionSet:unsupportedFeatures];
    [result unionSet:transitionFeatures];
    [result unionSet:stackEventFeatures];
    [result unionSet:actionFeatures];
    [result unionSet:actionUnsupportedFeatures];
    return [result allObjects];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002908c0 @ 002908c0, 2081 bytes * /

void FUN_002908c0(HSHTML5Exporter *self,SEL _cmd,id linkedStacksFileWrapper,id withContext,
                 uint currentLevel)

{
  id pvVar1;
  int iVar2;
  undefined *puVar3;
  undefined *self_00;
  id self_01;
  id pvVar4;
  id pvVar5;
  undefined4 *self_02;
  undefined4 *puVar6;
  id pvVar7;
  id pvVar8;
  id self_03;
  id pvVar9;
  undefined4 uVar10;
  cfstringStruct *pcVar11;
  undefined4 extraout_EDX;
  bool bVar12;
  undefined4 *puVar13;
  undefined4 *self_04;
  id pvVar14;
  id local_a0;
  id local_84;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  cfstringStruct local_50 [4];
  
  _objc_msgSend(withContext,sel_retain);
  self_01 = _objc_msgSend(withContext,sel_linkedStackURLs);
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  pcVar11 = local_50;
  puVar13 = &local_74;
  pvVar14 = (id)0x10;
  local_a0 = _objc_msgSend(self_01,sel_countByEnumeratingWithState_objects_count_,puVar13,pcVar11,
                           0x10);
  if (local_a0 != (id)0x0) {
    local_84 = (id)currentLevel;
    iVar2 = *local_6c;
    do {
      pvVar4 = (id)0x0;
      do {
        if (iVar2 != *local_6c) {
          _objc_enumerationMutation(self_01);
        }
        if ((self->super_HSExporter2[0x20] & 1) != 0) goto LAB_002910c1;
        pvVar1 = (id)((int)pvVar4 + 1);
        self_04 = *(undefined4 **)(local_70 + (int)pvVar4 * 4);
        puVar13 = self_04;
        pvVar4 = _objc_msgSend(withContext,sel_isRootStackURL_,self_04,pcVar11,pvVar14);
        if ((char)pvVar4 == '\0') {
          pvVar4 = self->_linkedStackPaths;
          if (pvVar4 == (id)0x0) {
            pvVar4 = _objc_msgSend(cls_NSMutableSet,sel_new,puVar13);
            self->_linkedStackPaths = pvVar4;
          }
          puVar13 = self_04;
          pvVar4 = _objc_msgSend(pvVar4,sel_containsObject_,self_04);
          if ((char)pvVar4 == '\0') {
            pvVar4 = _objc_msgSend(cls_NSAutoreleasePool,sel_new,puVar13);
            pvVar5 = _objc_msgSend(self_04,sel_isFileURL);
            bVar12 = (char)pvVar5 == '\0';
            self_02 = self_04;
            if (bVar12) {
              puVar13 = self_04;
              self_02 = _objc_msgSend(self,sel_downloadFile_,self_04);
            }
            puVar6 = _objc_msgSend(self_02,sel_path,puVar13);
            if (puVar6 != (undefined4 *)0x0) {
              pvVar5 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,puVar13);
              puVar13 = puVar6;
              pvVar5 = _objc_msgSend(pvVar5,sel_fileExistsAtPath_,puVar6);
              if ((char)pvVar5 != '\0') {
                pvVar14 = _objc_msgSend(cls_HSEditorDocument,sel_new,puVar13);
                pvVar5 = _objc_msgSend(pvVar14,sel_autorelease);
                _objc_msgSend(pvVar5,sel_setSuppressAlerts_,1);
                pvVar14 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
                pvVar14 = _objc_msgSend(pvVar14,sel_hyperFileTypeAtPath_,puVar6);
                pvVar7 = _objc_msgSend(pvVar14,sel_isEqualToString_,&cfstr__Stak_);
                if (((char)pvVar7 == '\0') &&
                   (pvVar14 = _objc_msgSend(pvVar14,sel_isEqualToString_,&cfstr_stk),
                   (char)pvVar14 == '\0')) {
                  pcVar11 = &cfstr_HSDocumentType;
                }
                else {
                  pcVar11 = &cfstr_HSNativeDocumentType;
                }
                pvVar14 = (id)0x0;
                puVar13 = self_02;
                pvVar7 = _objc_msgSend(pvVar5,sel_readFromURL_ofType_error_,self_02,pcVar11,0);
                if ((char)pvVar7 == '\0') {
                  pvVar5 = _objc_msgSend(pvVar5,sel_isCanceledByUser,puVar13,pcVar11,pvVar14);
                  if ((char)pvVar5 != '\0') {
                    self->super_HSExporter2[0x20] = self->super_HSExporter2[0x20] | 1;
                  }
                }
                else {
                  _objc_msgSend(pvVar5,sel_setFileURL_,self_02,pcVar11,pvVar14);
                  pvVar14 = _objc_msgSend(self->_context,sel_documentType);
                  pvVar8 = _objc_msgSend(pvVar14,sel_retain);
                  pvVar14 = _objc_msgSend(self->_context,sel_linkedStacksContext);
                  self_03 = _objc_msgSend(pvVar14,sel_retain);
                  _objc_msgSend(self_03,sel_setStackLevel_,local_84);
                  _objc_msgSend(self->_context,sel_release);
                  pvVar9 = _objc_msgSend(cls_HSHTML5ExportContext,sel_alloc);
                  pvVar7 = pvVar8;
                  pvVar14 = self_03;
                  pvVar9 = _objc_msgSend(pvVar9,sel_initWithDocument_ofType_linkedStacksContext_,
                                         pvVar5,pvVar8,self_03);
                  self->_context = pvVar9;
                  _objc_msgSend(pvVar8,sel_release);
                  _objc_msgSend(self_03,sel_release);
                  uVar10 = 0;
                  if ((self->super_HSExporter2[0x20] & 1) != 0) {
                    uVar10 = 0xffffffff;
                  }
                  _objc_msgSend(self->_context,sel_setShouldTerminateExport_,uVar10,pvVar7,pvVar14);
                  pvVar7 = _objc_msgSend(cls_NSFileWrapper,sel_alloc);
                  pvVar7 = _objc_msgSend(pvVar7,sel_initDirectoryWithFileWrappers_,0);
                  pvVar8 = _objc_msgSend(pvVar5,sel_stack);
                  pvVar8 = _objc_msgSend(pvVar8,sel_hyperCardSize);
                  _objc_msgSend(self,sel_correctWidgetSizeWithLinkedStackSize_,pvVar8,extraout_EDX);
                  self_00 = cls_NSDictionary;
                  puVar3 = cls_NSArray;
                  pvVar8 = _objc_msgSend(pvVar5,sel_stack);
                  pvVar8 = _objc_msgSend(pvVar8,sel_HTML5DictionaryRepresentationInContext_,
                                         self->_context);
                  pvVar8 = _objc_msgSend(puVar3,sel_arrayWithObject_,pvVar8);
                  pvVar8 = _objc_msgSend(self_00,sel_dictionaryWithObject_forKey_,pvVar8,
                                         &cfstr_stacks);
                  puVar3 = cls_NSString;
                  pvVar8 = _objc_msgSend(self,sel_JSonStringWithDictionary_humanReadable_,pvVar8,0);
                  pvVar8 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr_getStack____,pvVar8);
                  pvVar8 = _objc_msgSend(pvVar8,sel_dataUsingEncoding_,4);
                  _objc_msgSend(pvVar7,sel_addRegularFileWithContents_preferredFilename_,pvVar8,
                                &cfstr_stack_json);
                  pvVar8 = _objc_msgSend(self,sel_resourcesWrapperWithContext_,self->_context);
                  _objc_msgSend(pvVar7,sel_addFileWrapper_,pvVar8);
                  pvVar5 = _objc_msgSend(self,sel_previewsWrapperForDocument_,pvVar5);
                  puVar3 = cls_NSString;
                  pcVar11 = _objc_msgSend(withContext,sel_nameForLinkedStackURL_,self_04);
                  pvVar8 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr___,pcVar11);
                  _objc_msgSend(pvVar7,sel_setPreferredFilename_,pvVar8);
                  _objc_msgSend(pvVar7,sel_addFileWrapper_,pvVar5);
                  _objc_msgSend(linkedStacksFileWrapper,sel_addFileWrapper_,pvVar7);
                  _objc_msgSend(pvVar7,sel_release);
                }
                _objc_msgSend(self->_linkedStackPaths,sel_addObject_,self_04,pcVar11,pvVar14);
                puVar13 = self_04;
              }
            }
            if (bVar12) {
              _objc_msgSend(cls_HSTemporaryFilesManager,sel_unregisterTempFileAtPath_,puVar6);
              puVar13 = puVar6;
            }
            _objc_msgSend(pvVar4,sel_release,puVar13);
            if ((id)self->_linkedStacksNumber != local_84) {
              pvVar4 = _objc_msgSend(self->_context,sel_linkedStackURLs,puVar13);
              pvVar4 = _objc_msgSend(pvVar4,sel_count);
              if (pvVar4 != (id)0x0) {
                pcVar11 = self->_context;
                local_84 = (id)((int)local_84 + 1);
                puVar13 = linkedStacksFileWrapper;
                pvVar14 = local_84;
                _objc_msgSend(self,sel_linkedStacksFileWrapper_withContext_currentLevel_,
                              linkedStacksFileWrapper,pcVar11,local_84);
              }
            }
          }
        }
        pvVar4 = pvVar1;
      } while (pvVar1 < local_a0);
      pcVar11 = local_50;
      puVar13 = &local_74;
      pvVar14 = (id)0x10;
      local_a0 = _objc_msgSend(self_01,sel_countByEnumeratingWithState_objects_count_,puVar13,
                               pcVar11,0x10);
    } while (local_a0 != (id)0x0);
  }
LAB_002910c1:
  _objc_msgSend(withContext,sel_release,puVar13,pcVar11,pvVar14);
  return;
}

*/
- (void)linkedStacksFileWrapper:(id)aWrapper withContext:(id)aContext currentLevel:(NSUInteger)aLevel
{
    [aContext retain];
    for (id url in [aContext linkedStackURLs]) {
        NSAutoreleasePool *pool;
        BOOL isRemote;
        id fileURL;
        NSString *path;
        if (_shouldTerminateExport) {
            break;
        }
        if ([aContext isRootStackURL:url]) {
            continue;
        }
        if (_linkedStackPaths == nil) {
            _linkedStackPaths = [NSMutableSet new];
        }
        if ([_linkedStackPaths containsObject:url]) {
            continue;
        }
        pool = [NSAutoreleasePool new];
        isRemote = ![url isFileURL];
        fileURL = url;
        if (isRemote) {
            fileURL = [self downloadFile:url];
        }
        path = [fileURL path];
        if (path != nil && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
            HSEditorDocument *document = [[HSEditorDocument new] autorelease];
            id fileType;
            id documentType;
            [document setSuppressAlerts:YES];
            fileType = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
            if ([fileType isEqualToString:@"'Stak'"] || [fileType isEqualToString:@"stk"]) {
                documentType = @"HSNativeDocumentType";
            }
            else {
                documentType = @"HSDocumentType";
            }
            if (![document readFromURL:fileURL ofType:documentType error:NULL]) {
                if ([document isCanceledByUser]) {
                    _shouldTerminateExport = YES;
                }
            }
            else {
                id exportType;
                id linkedStacksContext;
                NSFileWrapper *stackWrapper;
                id stackDictionary;
                NSString *json;
                id previews;
                [document setFileURL:fileURL];
                exportType = [[_context documentType] retain];
                linkedStacksContext = [[_context linkedStacksContext] retain];
                [linkedStacksContext setStackLevel:aLevel];
                [_context release];
                _context = [[HSHTML5ExportContext alloc] initWithDocument:document ofType:exportType linkedStacksContext:linkedStacksContext];
                [exportType release];
                [linkedStacksContext release];
                [_context setShouldTerminateExport:_shouldTerminateExport];
                stackWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
                [self correctWidgetSizeWithLinkedStackSize:[[document stack] hyperCardSize]];
                stackDictionary = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[[document stack] HTML5DictionaryRepresentationInContext:_context]] forKey:@"stacks"];
                json = [NSString stringWithFormat:@"getStack(%@)", [self JSonStringWithDictionary:stackDictionary humanReadable:NO]];
                [stackWrapper addRegularFileWithContents:[json dataUsingEncoding:NSUTF8StringEncoding] preferredFilename:@"stack.json"];
                [stackWrapper addFileWrapper:[self resourcesWrapperWithContext:_context]];
                previews = [self previewsWrapperForDocument:document];
                [stackWrapper setPreferredFilename:[NSString stringWithFormat:@"%@", [aContext nameForLinkedStackURL:url]]];
                [stackWrapper addFileWrapper:previews];
                [aWrapper addFileWrapper:stackWrapper];
                [stackWrapper release];
            }
            [_linkedStackPaths addObject:url];
        }
        if (isRemote) {
            [HSTemporaryFilesManager unregisterTempFileAtPath:path];
        }
        [pool release];
        if (_linkedStacksNumber != aLevel && [[_context linkedStackURLs] count] != 0) {
            aLevel++;
            [self linkedStacksFileWrapper:aWrapper withContext:_context currentLevel:aLevel];
        }
    }
    [aContext release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028dfce @ 0028dfce, 40 bytes * /

void FUN_0028dfce(HSHTML5Exporter *self,SEL _cmd,NSSize correctWidgetSizeWithLinkedStackSize)

{
  float *pfVar1;
  
  if ((self->_widgetSize).width <= correctWidgetSizeWithLinkedStackSize.width &&
      correctWidgetSizeWithLinkedStackSize.width != (self->_widgetSize).width) {
    (self->_widgetSize).width = correctWidgetSizeWithLinkedStackSize.width;
  }
  pfVar1 = &(self->_widgetSize).height;
  if (*pfVar1 <= correctWidgetSizeWithLinkedStackSize.height &&
      correctWidgetSizeWithLinkedStackSize.height != *pfVar1) {
    (self->_widgetSize).height = correctWidgetSizeWithLinkedStackSize.height;
  }
  return;
}

*/
- (void)correctWidgetSizeWithLinkedStackSize:(NSSize)aSize
{
    if (_widgetSize.width < aSize.width) {
        _widgetSize.width = aSize.width;
    }
    if (_widgetSize.height < aSize.height) {
        _widgetSize.height = aSize.height;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002910e1 @ 002910e1, 824 bytes * /

id FUN_002910e1(HSHTML5Exporter *self,SEL _cmd,id resourcesWrapperWithContext)

{
  int iVar1;
  id self_00;
  undefined *self_01;
  id pvVar2;
  id self_02;
  id self_03;
  undefined4 *puVar3;
  undefined4 *puVar4;
  id pvVar5;
  id pvVar6;
  undefined1 *puVar7;
  id pvVar8;
  undefined4 *puVar9;
  undefined4 uVar10;
  id local_90;
  id local_84;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(cls_NSFileWrapper,sel_alloc);
  pvVar2 = _objc_msgSend(pvVar2,sel_initDirectoryWithFileWrappers_,0);
  _objc_msgSend(pvVar2,sel_setPreferredFilename_,&cfstr_Resources);
  self_02 = _objc_msgSend(cls_NSMutableSet,sel_new);
  self_03 = _objc_msgSend(resourcesWrapperWithContext,sel_mediaArray);
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar7 = local_50;
  puVar9 = &local_74;
  uVar10 = 0x10;
  local_90 = _objc_msgSend(self_03,sel_countByEnumeratingWithState_objects_count_,puVar9,puVar7,0x10
                          );
  if (local_90 == (id)0x0) {
    local_84 = (id)0x0;
  }
  else {
    iVar1 = *local_6c;
    local_84 = (id)0x0;
    do {
      pvVar8 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(self_03);
        }
        if ((self->super_HSExporter2[0x20] & 1) != 0) goto LAB_002913c9;
        self_00 = *(id *)(local_70 + (int)pvVar8 * 4);
        _objc_msgSend(local_84,sel_release,puVar9,puVar7,uVar10);
        local_84 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
        puVar3 = _objc_msgSend(self_00,sel_mediaUID);
        if (puVar3 != (undefined4 *)0x0) {
          puVar4 = _objc_msgSend(self_00,sel_mediaData);
          if (puVar4 != (undefined4 *)0x0) {
            pvVar5 = _objc_msgSend(self_02,sel_count);
            puVar9 = puVar3;
            _objc_msgSend(self_02,sel_addObject_,puVar3);
            pvVar6 = _objc_msgSend(self_02,sel_count);
            if (pvVar5 != pvVar6) {
              _objc_msgSend(self_02,sel_addObject_,puVar3);
              self_01 = cls_HSHTML5ExporterHelper;
              pvVar5 = _objc_msgSend(resourcesWrapperWithContext,sel_documentType);
              puVar7 = _objc_msgSend(self_01,sel_JSonCorrectFilenameForMedia_andDocumentType_,
                                     self_00,pvVar5);
              _objc_msgSend(pvVar2,sel_addRegularFileWithContents_preferredFilename_,puVar4,puVar7);
              puVar9 = puVar4;
            }
          }
        }
        pvVar8 = (id)((int)pvVar8 + 1);
      } while (pvVar8 < local_90);
      puVar7 = local_50;
      puVar9 = &local_74;
      uVar10 = 0x10;
      local_90 = _objc_msgSend(self_03,sel_countByEnumeratingWithState_objects_count_,puVar9,puVar7,
                               0x10);
    } while (local_90 != (id)0x0);
  }
LAB_002913c9:
  _objc_msgSend(self_02,sel_release,puVar9,puVar7,uVar10);
  _objc_msgSend(local_84,sel_release);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  return pvVar2;
}

*/
- (id)resourcesWrapperWithContext:(id)aContext
{
    NSFileWrapper *resources = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
    NSMutableSet *mediaUIDs;
    NSAutoreleasePool *pool = nil;
    [resources setPreferredFilename:@"Resources"];
    mediaUIDs = [NSMutableSet new];
    for (id media in [aContext mediaArray]) {
        id mediaUID;
        id mediaData;
        NSUInteger count;
        if (_shouldTerminateExport) {
            break;
        }
        [pool release];
        pool = [NSAutoreleasePool new];
        mediaUID = [media mediaUID];
        if (mediaUID == nil) {
            continue;
        }
        mediaData = [media mediaData];
        if (mediaData == nil) {
            continue;
        }
        count = [mediaUIDs count];
        [mediaUIDs addObject:mediaUID];
        if (count != [mediaUIDs count]) {
            [mediaUIDs addObject:mediaUID];
            [resources addRegularFileWithContents:mediaData preferredFilename:[HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media andDocumentType:[(HSHTML5ExportContext *)aContext documentType]]];
        }
    }
    [mediaUIDs release];
    [pool release];
    return [resources autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00291419 @ 00291419, 2049 bytes * /

id FUN_00291419(HSHTML5Exporter *self,SEL _cmd,id previewsWrapperForDocument)

{
  int iVar1;
  int iVar2;
  undefined *puVar3;
  id pvVar4;
  id pvVar5;
  id self_00;
  id pvVar6;
  id pvVar7;
  cfstringStruct *pcVar8;
  cfstringStruct *pcVar9;
  id pvVar10;
  id pvVar11;
  cfstringStruct *pcVar12;
  undefined4 *puVar13;
  cfstringStruct *self_01;
  cfstringStruct *pcVar14;
  undefined1 *puVar15;
  id pvVar16;
  undefined4 uVar17;
  id local_15c;
  id local_14c;
  id local_140;
  cfstringStruct local_134;
  undefined4 local_124;
  undefined4 local_120;
  undefined4 local_11c;
  undefined4 local_118;
  cfstringStruct local_114 [4];
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
  
  pvVar4 = _objc_msgSend(cls_NSFileWrapper,sel_alloc);
  pvVar4 = _objc_msgSend(pvVar4,sel_initDirectoryWithFileWrappers_,0);
  _objc_msgSend(pvVar4,sel_setPreferredFilename_,&cfstr_Previews);
  pvVar5 = _objc_msgSend(previewsWrapperForDocument,sel_stack);
  pvVar5 = _objc_msgSend(pvVar5,sel_hyperChildren);
  local_134.field0_0x0 = 0;
  local_134.field1_0x4 = 0;
  local_134.field2_0x8 = (undefined *)0x0;
  local_134.field3_0xc = 0;
  local_124 = 0;
  local_120 = 0;
  local_11c = 0;
  local_118 = 0;
  pcVar14 = local_114;
  pcVar12 = &local_134;
  pvVar16 = (id)0x10;
  local_15c = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,pcVar12,pcVar14,
                            0x10);
  if (local_15c != (id)0x0) {
    iVar1 = *(int *)local_134.field2_0x8;
    do {
      local_14c = (id)0x0;
      do {
        if (iVar1 != *(int *)local_134.field2_0x8) {
          _objc_enumerationMutation(pvVar5);
        }
        if ((self->super_HSExporter2[0x20] & 1) != 0) goto LAB_00291bf7;
        self_01 = *(cfstringStruct **)(local_134.field1_0x4 + (int)local_14c * 4);
        self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new,pcVar12,pcVar14,pvVar16);
        pvVar16 = _objc_msgSend(cls_NSMutableArray,sel_new);
        pvVar6 = _objc_msgSend(self_01,sel_hyperChildren);
        local_d4 = 0;
        local_d0 = 0;
        local_cc = (int *)0x0;
        local_c8 = 0;
        local_c4 = 0;
        local_c0 = 0;
        local_bc = 0;
        local_b8 = 0;
        puVar15 = local_b4;
        puVar13 = &local_d4;
        uVar17 = 0x10;
        local_140 = _objc_msgSend(pvVar6,sel_countByEnumeratingWithState_objects_count_,puVar13,
                                  puVar15,0x10);
        if (local_140 != (id)0x0) {
          iVar2 = *local_cc;
          do {
            pvVar11 = (id)0x0;
            do {
              if (iVar2 != *local_cc) {
                _objc_enumerationMutation(pvVar6);
              }
              pvVar10 = *(id *)(local_d0 + (int)pvVar11 * 4);
              pvVar11 = (id)((int)pvVar11 + 1);
              pvVar7 = _objc_msgSend(pvVar10,sel_implementsHyperInterface_,&DAT_00388908,puVar15,
                                     uVar17);
              if ((((char)pvVar7 != '\0') ||
                  (pvVar7 = _objc_msgSend(pvVar10,sel_implementsHyperInterface_,&DAT_00388930),
                  (char)pvVar7 != '\0')) &&
                 (pvVar7 = _objc_msgSend(pvVar10,sel_canBeExportedToHTML5DocumentType_,
                                         &cfstr_HSHTML5DocumentType), (char)pvVar7 == '\0')) {
                _objc_msgSend(pvVar10,sel_setHidden_,1);
                _objc_msgSend(pvVar16,sel_addObject_,pvVar10);
              }
            } while (pvVar11 < local_140);
            puVar15 = local_b4;
            puVar13 = &local_d4;
            uVar17 = 0x10;
            local_140 = _objc_msgSend(pvVar6,sel_countByEnumeratingWithState_objects_count_,puVar13,
                                      puVar15,0x10);
          } while (local_140 != (id)0x0);
        }
        pvVar6 = _objc_msgSend(self_01,sel_previewForHTML5Export,puVar13,puVar15,uVar17);
        local_74 = 0;
        local_70 = 0;
        local_6c = (int *)0x0;
        local_68 = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        puVar15 = local_50;
        puVar13 = &local_74;
        uVar17 = 0x10;
        pvVar11 = _objc_msgSend(pvVar16,sel_countByEnumeratingWithState_objects_count_,puVar13,
                                puVar15,0x10);
        if (pvVar11 != (id)0x0) {
          iVar2 = *local_6c;
          do {
            pvVar10 = (id)0x0;
            do {
              if (iVar2 != *local_6c) {
                _objc_enumerationMutation(pvVar16);
              }
              _objc_msgSend(*(id *)(local_70 + (int)pvVar10 * 4),sel_setHidden_,0,puVar15,uVar17);
              pvVar10 = (id)((int)pvVar10 + 1);
            } while (pvVar10 < pvVar11);
            puVar15 = local_50;
            puVar13 = &local_74;
            uVar17 = 0x10;
            pvVar11 = _objc_msgSend(pvVar16,sel_countByEnumeratingWithState_objects_count_,puVar13,
                                    puVar15,0x10);
          } while (pvVar11 != (id)0x0);
        }
        _objc_msgSend(pvVar16,sel_release,puVar13,puVar15,uVar17);
        pvVar16 = _objc_msgSend(cls_NSFileWrapper,sel_alloc);
        pvVar6 = _objc_msgSend(pvVar6,sel_hyperPNGRepresentation);
        pcVar8 = _objc_msgSend(pvVar16,sel_initRegularFileWithContents_,pvVar6);
        pcVar9 = _objc_msgSend(self_01,sel_hyperUID);
        puVar3 = cls_NSString;
        pvVar16 = _objc_msgSend(pcVar9,sel_stringValue);
        pcVar14 = &cfstr_preview_;
        pcVar12 = &cfstr______png;
        pvVar6 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr______png,&cfstr_preview_,pvVar16)
        ;
        pvVar11 = _objc_msgSend(pvVar6,sel_length);
        if (pvVar11 != (id)0x0) {
          _objc_msgSend(pcVar8,sel_setPreferredFilename_,pvVar6,pcVar14,pvVar16);
          pcVar12 = pcVar8;
          _objc_msgSend(pvVar4,sel_addFileWrapper_,pcVar8);
        }
        _objc_msgSend(pcVar8,sel_release,pcVar12,pcVar14,pvVar16);
        pvVar6 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_00388b38);
        pvVar6 = _objc_msgSend(pvVar6,sel_editableImageMedia);
        pcVar8 = _objc_msgSend(pvVar6,sel_mediaUID);
        pcVar12 = pcVar8;
        pvVar11 = _objc_msgSend(self->_context,sel_mediaNameForGroupUID_,pcVar8);
        puVar3 = cls_NSString;
        if (pvVar11 == (id)0x0) {
          if (pcVar8 != (cfstringStruct *)0x0) {
            pcVar9 = pcVar8;
          }
          pvVar16 = _objc_msgSend(pcVar9,sel_stringValue,pcVar12);
          pcVar14 = &cfstr_background_;
          pcVar12 = &cfstr______png;
          pcVar9 = _objc_msgSend(puVar3,sel_stringWithFormat_,&cfstr______png,&cfstr_background_,
                                 pvVar16);
          if (pcVar8 != (cfstringStruct *)0x0) {
            pcVar14 = pcVar9;
            _objc_msgSend(self->_context,sel_addGroupUID_withMediaName_,pcVar8,pcVar9,pvVar16);
            pcVar12 = pcVar8;
          }
          pvVar11 = _objc_msgSend(self->_context,sel_documentType,pcVar12,pcVar14,pvVar16);
          pcVar12 = &cfstr_HSHTML5DocumentType;
          pvVar11 = _objc_msgSend(pvVar11,sel_isEqualToString_,&cfstr_HSHTML5DocumentType);
          if ((char)pvVar11 == '\0') {
            pcVar8 = (cfstringStruct *)0x0;
          }
          else {
            pcVar8 = _objc_msgSend(pvVar6,sel_mediaData,pcVar12,pcVar14,pvVar16);
          }
          pvVar6 = _objc_msgSend(pcVar8,sel_length,pcVar12);
          if (pvVar6 == (id)0x0) {
            pvVar6 = _objc_msgSend(cls_HSHTML5ExporterHelper,sel_defaultCardBackgroundImageForCard_,
                                   self_01);
            pcVar8 = _objc_msgSend(pvVar6,sel_hyperPNGRepresentation);
            pvVar6 = _objc_msgSend(pcVar8,sel_length);
            pcVar12 = self_01;
            if (pvVar6 == (id)0x0) goto LAB_00291b84;
          }
          _objc_msgSend(pvVar4,sel_addRegularFileWithContents_preferredFilename_,pcVar8,pcVar9);
          pcVar12 = pcVar8;
          pcVar14 = pcVar9;
        }
LAB_00291b84:
        local_14c = (id)((int)local_14c + 1);
        _objc_msgSend(self_00,sel_release,pcVar12,pcVar14);
      } while (local_14c < local_15c);
      pcVar14 = local_114;
      pcVar12 = &local_134;
      pvVar16 = (id)0x10;
      local_15c = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,pcVar12,
                                pcVar14,0x10);
    } while (local_15c != (id)0x0);
  }
LAB_00291bf7:
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease,pcVar12,pcVar14,pvVar16);
  return pvVar4;
}

*/
- (id)previewsWrapperForDocument:(id)aDocument
{
    NSFileWrapper *previews = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];
    [previews setPreferredFilename:@"Previews"];
    for (id card in [[aDocument stack] hyperChildren]) {
        NSAutoreleasePool *pool;
        NSMutableArray *hiddenObjects;
        id preview;
        NSFileWrapper *previewWrapper;
        id cardUID;
        NSString *name;
        id media;
        id mediaUID;
        if (_shouldTerminateExport) {
            break;
        }
        pool = [NSAutoreleasePool new];
        hiddenObjects = [NSMutableArray new];
        // Movies and live video that cannot be exported are hidden while the preview is taken.
        for (id object in [card hyperChildren]) {
            if (([object implementsHyperInterface:@protocol(HSLiveVideoAttributes)] || [object implementsHyperInterface:@protocol(HSMovieObjectAttributes)])
                && ![object canBeExportedToHTML5DocumentType:@"HSHTML5DocumentType"]) {
                [object setHidden:YES];
                [hiddenObjects addObject:object];
            }
        }
        preview = [card previewForHTML5Export];
        for (id object in hiddenObjects) {
            [object setHidden:NO];
        }
        [hiddenObjects release];
        previewWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[preview hyperPNGRepresentation]];
        cardUID = [card hyperUID];
        name = [NSString stringWithFormat:@"%@%@.png", @"preview_", [cardUID stringValue]];
        if ([name length] != 0) {
            [previewWrapper setPreferredFilename:name];
            [previews addFileWrapper:previewWrapper];
        }
        [previewWrapper release];
        media = [[card queryHyperInterface:@protocol(HSEditableImageMediaAttributes)] editableImageMedia];
        mediaUID = [media mediaUID];
        if ([_context mediaNameForGroupUID:mediaUID] == nil) {
            NSData *data;
            name = [NSString stringWithFormat:@"%@%@.png", @"background_", [(mediaUID != nil ? mediaUID : cardUID) stringValue]];
            if (mediaUID != nil) {
                [_context addGroupUID:mediaUID withMediaName:name];
            }
            data = [[_context documentType] isEqualToString:@"HSHTML5DocumentType"] ? [media mediaData] : nil;
            if ([data length] == 0) {
                data = [[HSHTML5ExporterHelper defaultCardBackgroundImageForCard:card] hyperPNGRepresentation];
            }
            if ([data length] != 0) {
                [previews addRegularFileWithContents:data preferredFilename:name];
            }
        }
        [pool release];
    }
    return [previews autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00291c1a @ 00291c1a, 2133 bytes * /

id FUN_00291c1a(HSHTML5Exporter *self,SEL _cmd,id JSonStringWithDictionary,BOOL humanReadable)

{
  int iVar1;
  int iVar2;
  undefined4 uVar3;
  undefined *self_00;
  id pvVar4;
  undefined1 *self_01;
  id pvVar5;
  undefined1 *puVar6;
  cfstringStruct *pcVar7;
  id pvVar8;
  id pvVar9;
  undefined1 *puVar10;
  cfstringStruct *pcVar11;
  id pvVar12;
  undefined4 *puVar13;
  id pvVar14;
  SEL op;
  undefined1 *puVar15;
  undefined4 uVar16;
  id local_100;
  id local_f4;
  id local_e4;
  id local_d8;
  cfstringStruct local_d4;
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
  
  pvVar4 = _objc_msgSend(cls_NSString,sel_string);
  self_01 = _objc_msgSend(pvVar4,sel_stringByPaddingToLength_withString_startingAtIndex_,
                          DAT_00342a60,&cfstr__,0);
  pvVar4 = _objc_msgSend(cls_NSMutableString,sel_stringWithString_,&cfstr__);
  pvVar5 = _objc_msgSend(JSonStringWithDictionary,sel_allKeys);
  local_d4.field0_0x0 = 0;
  local_d4.field1_0x4 = 0;
  local_d4.field2_0x8 = (undefined *)0x0;
  local_d4.field3_0xc = 0;
  local_c4 = 0;
  local_c0 = 0;
  local_bc = 0;
  local_b8 = 0;
  puVar10 = local_b4;
  pcVar7 = &local_d4;
  local_d8 = (id)0x10;
  local_100 = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,pcVar7,puVar10,
                            0x10);
  if (local_100 != (id)0x0) {
    puVar6 = (undefined1 *)(uint)(byte)humanReadable;
    iVar1 = *(int *)local_d4.field2_0x8;
    do {
      local_f4 = (id)0x0;
      puVar15 = puVar10;
      do {
        puVar10 = puVar15;
        if (iVar1 != *(int *)local_d4.field2_0x8) {
          _objc_enumerationMutation(pvVar5);
          puVar10 = puVar15;
        }
        if ((self->super_HSExporter2[0x20] & 1) != 0) goto LAB_002923d7;
        pvVar14 = (id)((int)local_f4 + 1);
        puVar15 = *(undefined1 **)(local_d4.field1_0x4 + (int)local_f4 * 4);
        pcVar7 = _objc_msgSend(JSonStringWithDictionary,sel_valueForKey_,puVar15,puVar10,local_d8);
        pvVar8 = _objc_msgSend(cls_NSString,sel_class);
        pvVar9 = _objc_msgSend(pcVar7,sel_isKindOfClass_,pvVar8);
        if ((char)pvVar9 == '\0') {
          pvVar8 = _objc_msgSend(cls_NSDictionary,sel_class,pvVar8);
          pvVar9 = _objc_msgSend(pcVar7,sel_isKindOfClass_,pvVar8);
          if ((char)pvVar9 == '\0') {
            pcVar11 = _objc_msgSend(cls_NSArray,sel_class,pvVar8);
            pvVar8 = _objc_msgSend(pcVar7,sel_isKindOfClass_,pcVar11);
            if ((char)pvVar8 != '\0') {
              pvVar8 = _objc_msgSend(cls_NSMutableString,sel_stringWithString_,&cfstr__);
              local_74 = 0;
              local_70 = 0;
              local_6c = (int *)0x0;
              local_68 = 0;
              local_64 = 0;
              local_60 = 0;
              local_5c = 0;
              local_58 = 0;
              puVar10 = local_50;
              puVar13 = &local_74;
              uVar16 = 0x10;
              local_e4 = _objc_msgSend(pcVar7,sel_countByEnumeratingWithState_objects_count_,puVar13
                                       ,puVar10,0x10);
              if (local_e4 != (id)0x0) {
                iVar2 = *local_6c;
                do {
                  pvVar9 = (id)0x0;
                  do {
                    if (iVar2 != *local_6c) {
                      _objc_enumerationMutation(pcVar7);
                    }
                    uVar3 = *(undefined4 *)(local_70 + (int)pvVar9 * 4);
                    pvVar12 = _objc_msgSend(pvVar8,sel_length,puVar13,puVar10,uVar16);
                    if ((id)0x1 < pvVar12) {
                      _objc_msgSend(pvVar8,sel_appendString_,&cfstr__);
                    }
                    pvVar9 = (id)((int)pvVar9 + 1);
                    if (humanReadable == '\0') {
                      puVar10 = puVar6;
                      puVar13 = _objc_msgSend(self,sel_JSonStringWithDictionary_humanReadable_,uVar3
                                              ,0);
                      _objc_msgSend(pvVar8,sel_appendString_,puVar13);
                    }
                    else {
                      DAT_00342a60 = DAT_00342a60 + 2;
                      _objc_msgSend(pvVar8,sel_appendFormat_,&cfstr______,self_01);
                      puVar10 = puVar6;
                      puVar13 = _objc_msgSend(self,sel_JSonStringWithDictionary_humanReadable_,uVar3
                                              ,puVar6);
                      _objc_msgSend(pvVar8,sel_appendString_,puVar13);
                      DAT_00342a60 = DAT_00342a60 + -2;
                    }
                  } while (pvVar9 < local_e4);
                  puVar10 = local_50;
                  puVar13 = &local_74;
                  uVar16 = 0x10;
                  local_e4 = _objc_msgSend(pcVar7,sel_countByEnumeratingWithState_objects_count_,
                                           puVar13,puVar10,0x10);
                } while (local_e4 != (id)0x0);
              }
              if (humanReadable != '\0') {
                pvVar9 = _objc_msgSend(pvVar8,sel_length,puVar13,puVar10,uVar16);
                if ((id)0x1 < pvVar9) {
                  puVar10 = self_01;
                  _objc_msgSend(pvVar8,sel_appendFormat_,&cfstr_____,self_01,uVar16);
                }
              }
              pcVar11 = &cfstr__;
              op = sel_appendString_;
              local_d8 = pvVar8;
              goto LAB_002922ad;
            }
            local_d8 = (id)0x0;
            goto LAB_002922b5;
          }
          if (humanReadable != '\0') {
            DAT_00342a60 = DAT_00342a60 + 1;
            puVar10 = puVar6;
            local_d8 = _objc_msgSend(self,sel_JSonStringWithDictionary_humanReadable_,pcVar7,puVar6)
            ;
            DAT_00342a60 = DAT_00342a60 + -1;
            pcVar11 = pcVar7;
            goto LAB_002922b5;
          }
          pvVar8 = (id)0x1;
          puVar10 = puVar6;
          local_d8 = _objc_msgSend(self,sel_JSonStringWithDictionary_humanReadable_,pcVar7,0);
        }
        else {
          pvVar8 = _objc_msgSend(pcVar7,sel_mutableCopy,pvVar8);
          pvVar9 = _objc_msgSend(pvVar8,sel_length);
          _objc_msgSend(pvVar8,sel_replaceOccurrencesOfString_withString_options_range_,&cfstr__,
                        &cfstr___,0,0,pvVar9);
          pvVar9 = _objc_msgSend(pvVar8,sel_length);
          uVar16 = 0;
          _objc_msgSend(pvVar8,sel_replaceOccurrencesOfString_withString_options_range_,&cfstr__,
                        &cfstr___,0,0,pvVar9);
          self_00 = cls_NSMutableString;
          pvVar9 = _objc_msgSend(cls_NSCharacterSet,sel_controlCharacterSet);
          puVar10 = _objc_msgSend(pvVar8,sel_hyperStringByRemovingCharactersInSet_,pvVar9);
          pcVar11 = &cfstr_____;
          local_d8 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr_____,puVar10);
          op = sel_release;
LAB_002922ad:
          _objc_msgSend(pvVar8,op,pcVar11,puVar10,uVar16);
LAB_002922b5:
          if (humanReadable == '\0') {
            pvVar8 = (id)0x1;
            pcVar7 = pcVar11;
          }
          else {
            pvVar8 = _objc_msgSend(self_01,sel_length,pcVar11,puVar10);
            pvVar8 = (id)((int)pvVar8 + 1);
            pcVar7 = pcVar11;
          }
        }
        pvVar9 = _objc_msgSend(pvVar4,sel_length,pcVar7,puVar10);
        if (pvVar8 < pvVar9) {
          _objc_msgSend(pvVar4,sel_appendString_,&cfstr__,puVar10);
        }
        if (humanReadable != '\0') {
          _objc_msgSend(pvVar4,sel_appendFormat_,&cfstr_____,self_01);
        }
        pcVar7 = &cfstr________;
        _objc_msgSend(pvVar4,sel_appendFormat_,&cfstr________,puVar15,local_d8);
        local_f4 = pvVar14;
      } while (pvVar14 < local_100);
      puVar10 = local_b4;
      pcVar7 = &local_d4;
      local_d8 = (id)0x10;
      local_100 = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,pcVar7,puVar10
                                ,0x10);
    } while (local_100 != (id)0x0);
  }
LAB_002923d7:
  if (humanReadable != '\0') {
    pvVar5 = _objc_msgSend(pvVar4,sel_length,pcVar7,puVar10,local_d8);
    pvVar14 = _objc_msgSend(self_01,sel_length);
    if ((id)((int)pvVar14 + 1) < pvVar5) {
      _objc_msgSend(pvVar4,sel_appendFormat_,&cfstr____,self_01,local_d8);
      puVar10 = self_01;
    }
  }
  _objc_msgSend(pvVar4,sel_appendString_,&cfstr__,puVar10,local_d8);
  return pvVar4;
}

*/
- (id)JSonStringWithDictionary:(id)aDictionary humanReadable:(BOOL)aReadable
{
    NSString *indent = [[NSString string] stringByPaddingToLength:sJSonIndentLevel withString:@"\t" startingAtIndex:0];
    NSMutableString *json = [NSMutableString stringWithString:@"{"];
    for (id key in [aDictionary allKeys]) {
        id value;
        id string;
        NSUInteger threshold;
        if (_shouldTerminateExport) {
            break;
        }
        value = [aDictionary valueForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            NSMutableString *escaped = [value mutableCopy];
            // Only slashes and quotes are escaped; control characters are dropped.
            [escaped replaceOccurrencesOfString:@"/" withString:@"\\/" options:0 range:NSMakeRange(0, [escaped length])];
            [escaped replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, [escaped length])];
            string = [NSMutableString stringWithFormat:@"\"%@\"", [escaped hyperStringByRemovingCharactersInSet:[NSCharacterSet controlCharacterSet]]];
            [escaped release];
        }
        else if ([value isKindOfClass:[NSDictionary class]]) {
            if (aReadable) {
                sJSonIndentLevel++;
                string = [self JSonStringWithDictionary:value humanReadable:YES];
                sJSonIndentLevel--;
            }
            else {
                string = [self JSonStringWithDictionary:value humanReadable:NO];
            }
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableString *array = [NSMutableString stringWithString:@"["];
            for (id item in value) {
                if ([array length] >= 2) {
                    [array appendString:@","];
                }
                if (aReadable) {
                    sJSonIndentLevel += 2;
                    [array appendFormat:@"\n\t\t%@", indent];
                    [array appendString:[self JSonStringWithDictionary:item humanReadable:YES]];
                    sJSonIndentLevel -= 2;
                }
                else {
                    [array appendString:[self JSonStringWithDictionary:item humanReadable:NO]];
                }
            }
            if (aReadable && [array length] >= 2) {
                [array appendFormat:@"\n\t%@", indent];
            }
            [array appendString:@"]"];
            string = array;
        }
        else {
            // Other values are written as "(null)", as in the original.
            string = nil;
        }
        threshold = aReadable ? [indent length] + 1 : 1;
        if ([json length] > threshold) {
            [json appendString:@","];
        }
        if (aReadable) {
            [json appendFormat:@"\n\t%@", indent];
        }
        [json appendFormat:@"\"%@\":%@", key, string];
    }
    if (aReadable && [json length] > [indent length] + 1) {
        [json appendFormat:@"\n%@", indent];
    }
    [json appendString:@"}"];
    return json;
}

- (BOOL)download:(id)aDownload shouldDecodeSourceDataOfMIMEType:(id)aType
{
    return NO;
}

- (void)download:(id)aDownload didFailWithError:(id)aError
{
    _isDownloadFinished = YES;
}

- (void)downloadDidFinish:(id)aFinish
{
    _isDownloadFinished = YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028e214 @ 0028e214, 553 bytes * /

id FUN_0028e214(HSHTML5Exporter *self,SEL _cmd,id downloadFile)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  SEL op;
  HSHTML5Exporter *pHVar5;
  
  self->_isDownloadFinished = '\0';
  pvVar1 = _objc_msgSend(cls_NSURLRequest,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithURL_,downloadFile);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSURLDownload,sel_alloc,downloadFile);
    pHVar5 = self;
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithRequest_delegate_,pvVar1,self);
    _objc_msgSend(pvVar1,sel_release);
    if (pvVar2 != (id)0x0) {
      pcVar4 = &cfstr_stack;
      pvVar1 = _objc_msgSend(cls_HSTemporaryFilesManager,sel_generatedTempFilePathWithExtension_,
                             &cfstr_stack,pHVar5);
      pcVar3 = _objc_msgSend(pvVar1,sel_retain);
      if (pcVar3 == (cfstringStruct *)0x0) {
        _objc_msgSend(pvVar2,sel_cancel,pcVar4,pHVar5);
      }
      else {
        _objc_msgSend(cls_HSTemporaryFilesManager,sel_registerTempFileAtPath_,pcVar3,pHVar5);
        pHVar5 = (HSHTML5Exporter *)0x1;
        op = sel_setDestination_allowOverwrite_;
        pcVar4 = pcVar3;
        while (_objc_msgSend(pvVar2,op,pcVar4,pHVar5), self->_isDownloadFinished == '\0') {
          pvVar1 = _objc_msgSend(cls_NSAutoreleasePool,sel_alloc,pcVar4,pHVar5);
          pvVar2 = _objc_msgSend(pvVar1,sel_init);
          pHVar5 = (HSHTML5Exporter *)0x3fc99999;
          pcVar4 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceNow_,0x9999999a);
          pvVar1 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
          _objc_msgSend(pvVar1,sel_runUntilDate_);
          op = sel_release;
        }
      }
      if (pcVar3 != (cfstringStruct *)0x0) {
        pvVar1 = _objc_msgSend(cls_NSURL,sel_alloc,pcVar4,pHVar5);
        pvVar1 = _objc_msgSend(pvVar1,sel_initFileURLWithPath_,pcVar3);
        pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
        return pvVar1;
      }
    }
  }
  return (id)0x0;
}

*/
- (id)downloadFile:(id)aFile
{
    NSURLRequest *request;
    NSURLDownload *download;
    NSString *path;
    NSURL *url = nil;
    _isDownloadFinished = NO;
    request = [[NSURLRequest alloc] initWithURL:aFile];
    if (request == nil) {
        return nil;
    }
    download = [[NSURLDownload alloc] initWithRequest:request delegate:(id)self];
    [request release];
    if (download == nil) {
        return nil;
    }
    path = [[HSTemporaryFilesManager generatedTempFilePathWithExtension:@"stack"] retain];
    if (path == nil) {
        [download cancel];
    }
    else {
        [HSTemporaryFilesManager registerTempFileAtPath:path];
        [download setDestination:path allowOverwrite:YES];
        while (!_isDownloadFinished) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
            [pool release];
        }
        url = [[[NSURL alloc] initFileURLWithPath:path] autorelease];
        [path release];
    }
    [download release];
    return url;
}

- (id)progressSheetDescription
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ExportSheetProgressHTML5Description" value:@"" table:@"Export"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028e0ba @ 0028e0ba, 228 bytes * /

id FUN_0028e0ba(HSHTML5Exporter *self,SEL _cmd,int exportAccessoryViewControllerForPublishType)

{
  id pvVar1;
  id self_00;
  
  pvVar1 = *(id *)(self->super_HSExporter2 + 0x1c);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentDocument);
    self_00 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
    pvVar1 = _objc_msgSend(self,sel_areLinkedStacksInDocument_,pvVar1);
    _objc_msgSend(self_00,sel_setBool_forKey_,(int)(char)pvVar1,*(undefined4 *)PTR_PTR_003369e8);
    pvVar1 = _objc_msgSend(cls_HSHTML5ExportAccessoryViewController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithExporter_publishType_,self,
                           exportAccessoryViewControllerForPublishType);
    *(id *)(self->super_HSExporter2 + 0x1c) = pvVar1;
  }
  return pvVar1;
}

*/
- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType
{
    if (_exportAccessoryViewController == nil) {
        id document = [[NSDocumentController sharedDocumentController] currentDocument];
        [[NSUserDefaults standardUserDefaults] setBool:[self areLinkedStacksInDocument:document] forKey:HSHTML5ExportAreLinkedStacksInDocument];
        _exportAccessoryViewController = [[HSHTML5ExportAccessoryViewController alloc] initWithExporter:self publishType:aType];
    }
    return _exportAccessoryViewController;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029246f @ 0029246f, 1612 bytes * /

BOOL FUN_0029246f(HSHTML5Exporter *self,SEL _cmd,id areLinkedStacksInDocument)

{
  int iVar1;
  int iVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  id self_00;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  cfstringStruct *pcVar9;
  SEL op;
  undefined1 *puVar10;
  undefined4 uVar11;
  id local_150;
  id local_148;
  id local_140;
  id local_13c;
  cfstringStruct local_134;
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
  cfstringStruct local_74;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar3 = _objc_msgSend(areLinkedStacksInDocument,sel_stack);
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperDeepEnumerator);
  pvVar3 = _objc_msgSend(pvVar3,sel_allObjects);
  local_134.field0_0x0 = 0;
  local_134.field1_0x4 = 0;
  local_134.field2_0x8 = (undefined *)0x0;
  local_134.field3_0xc = 0;
  local_124 = 0;
  local_120 = 0;
  local_11c = 0;
  local_118 = 0;
  puVar10 = local_114;
  pcVar9 = &local_134;
  uVar11 = 0x10;
  local_150 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,pcVar9,puVar10,
                            0x10);
  if (local_150 != (id)0x0) {
    iVar1 = *(int *)local_134.field2_0x8;
    do {
      local_148 = (id)0x0;
      do {
        if (iVar1 != *(int *)local_134.field2_0x8) {
          _objc_enumerationMutation(pvVar3);
        }
        pvVar6 = *(id *)(local_134.field1_0x4 + (int)local_148 * 4);
        self_00 = _objc_msgSend(cls_NSMutableArray,sel_array,pcVar9,puVar10,uVar11);
        pvVar5 = _objc_msgSend(pvVar6,sel_implementsHyperInterface_,&DAT_003885ac);
        if ((char)pvVar5 == '\0') {
          pvVar5 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_003886c4);
          pvVar5 = _objc_msgSend(pvVar5,sel_hyperActions);
          _objc_msgSend(self_00,sel_addObjectsFromArray_,pvVar5);
        }
        pvVar5 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_00388764);
        pvVar5 = _objc_msgSend(pvVar5,sel_willBeExportedAsImage);
        if ((char)pvVar5 == '\0') {
          pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_00388778);
          pvVar6 = _objc_msgSend(pvVar6,sel_allLinks);
          local_d4 = 0;
          local_d0 = 0;
          local_cc = (int *)0x0;
          local_c8 = 0;
          local_c4 = 0;
          local_c0 = 0;
          local_bc = 0;
          local_b8 = 0;
          puVar10 = local_b4;
          uVar11 = 0x10;
          local_140 = _objc_msgSend(pvVar6,sel_countByEnumeratingWithState_objects_count_,&local_d4,
                                    puVar10,0x10);
          if (local_140 != (id)0x0) {
            iVar2 = *local_cc;
            do {
              pvVar5 = (id)0x0;
              do {
                if (iVar2 != *local_cc) {
                  _objc_enumerationMutation(pvVar6);
                }
                pvVar7 = _objc_msgSend(*(id *)(local_d0 + (int)pvVar5 * 4),sel_queryHyperInterface_,
                                       &DAT_003886c4,puVar10,uVar11);
                pvVar7 = _objc_msgSend(pvVar7,sel_hyperActions);
                pvVar8 = _objc_msgSend(pvVar7,sel_count);
                if (pvVar8 != (id)0x0) {
                  _objc_msgSend(self_00,sel_addObjectsFromArray_,pvVar7);
                }
                pvVar5 = (id)((int)pvVar5 + 1);
              } while (pvVar5 < local_140);
              puVar10 = local_b4;
              uVar11 = 0x10;
              local_140 = _objc_msgSend(pvVar6,sel_countByEnumeratingWithState_objects_count_,
                                        &local_d4,puVar10,0x10);
            } while (local_140 != (id)0x0);
          }
        }
        local_74.field0_0x0 = 0;
        local_74.field1_0x4 = 0;
        local_74.field2_0x8 = (undefined *)0x0;
        local_74.field3_0xc = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        puVar10 = local_50;
        pcVar9 = &local_74;
        uVar11 = 0x10;
        local_13c = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,pcVar9,
                                  puVar10,0x10);
        if (local_13c != (id)0x0) {
          iVar2 = *(int *)local_74.field2_0x8;
          do {
            pvVar6 = (id)0x0;
            do {
              if (iVar2 != *(int *)local_74.field2_0x8) {
                _objc_enumerationMutation(self_00);
              }
              pvVar5 = (id)((int)pvVar6 + 1);
              pvVar6 = *(id *)(local_74.field1_0x4 + (int)pvVar6 * 4);
              pcVar9 = _objc_msgSend(cls_HSGoToHomeStackAction,sel_class,pcVar9,puVar10,uVar11);
              pvVar7 = _objc_msgSend(pvVar6,sel_isKindOfClass_);
              if ((char)pvVar7 == '\0') {
                pvVar7 = _objc_msgSend(pvVar6,sel_implementsHyperInterface_,&DAT_003887a0);
                if (((char)pvVar7 != '\0') ||
                   (pvVar7 = _objc_msgSend(pvVar6,sel_implementsHyperInterface_,&DAT_0038887c),
                   (char)pvVar7 != '\0')) {
LAB_002925ef:
                  pcVar9 = (cfstringStruct *)&DAT_00388868;
                  pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_00388868);
                  op = sel_URL;
                  goto LAB_00292615;
                }
                pcVar9 = (cfstringStruct *)&DAT_00388890;
                pvVar7 = _objc_msgSend(pvVar6,sel_implementsHyperInterface_,&DAT_00388890);
                if ((char)pvVar7 != '\0') {
                  pcVar9 = &cfstr_HSHTML5DocumentType;
                  pvVar7 = _objc_msgSend(pvVar6,sel_canBeExportedToHTML5DocumentType_,
                                         &cfstr_HSHTML5DocumentType);
                  if ((char)pvVar7 != '\0') goto LAB_002925ef;
                }
              }
              else {
                pvVar6 = _objc_msgSend(cls_HSHomeStackController,sel_sharedHomeStackController,
                                       pcVar9);
                op = sel_homeStackURL;
LAB_00292615:
                pvVar6 = _objc_msgSend(pvVar6,op,pcVar9);
                pcVar4 = _objc_msgSend(areLinkedStacksInDocument,sel_fileURL);
                if ((pvVar6 != (id)0x0) &&
                   (pvVar6 = _objc_msgSend(pvVar6,sel_isEqual_,pcVar4), pcVar9 = pcVar4,
                   (char)pvVar6 == '\0')) {
                  return '\x01';
                }
              }
              pvVar6 = pvVar5;
            } while (pvVar5 < local_13c);
            puVar10 = local_50;
            pcVar9 = &local_74;
            uVar11 = 0x10;
            local_13c = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,pcVar9,
                                      puVar10,0x10);
          } while (local_13c != (id)0x0);
        }
        local_148 = (id)((int)local_148 + 1);
      } while (local_148 < local_150);
      puVar10 = local_114;
      pcVar9 = &local_134;
      uVar11 = 0x10;
      local_150 = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,pcVar9,puVar10
                                ,0x10);
    } while (local_150 != (id)0x0);
  }
  return '\0';
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0028e001 @ 0028e001, 185 bytes * /

id FUN_0028e001(HSHTML5Exporter *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  
  pvVar1 = *(id *)(self->super_HSExporter2 + 0x18);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pvVar1 = _objc_msgSend(pvVar1,sel_resourcePath);
    pcVar3 = &cfstr_HTML5Template;
    pvVar1 = _objc_msgSend(pvVar1,sel_stringByAppendingPathComponent_,&cfstr_HTML5Template);
    pvVar2 = _objc_msgSend(pvVar1,sel_length);
    if (pvVar2 == (id)0x0) {
      pvVar1 = *(id *)(self->super_HSExporter2 + 0x18);
    }
    else {
      pvVar2 = _objc_msgSend(cls_NSFileWrapper,sel_alloc,pcVar3);
      pvVar1 = _objc_msgSend(pvVar2,sel_initWithPath_,pvVar1);
      *(id *)(self->super_HSExporter2 + 0x18) = pvVar1;
    }
  }
  return pvVar1;
}

*/
- (id)exportRepresentation
{
    NSString *path;
    if (_exportRepresentation == nil) {
        path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"HTML5Template"];
        if ([path length] != 0) {
            _exportRepresentation = [[NSFileWrapper alloc] initWithPath:path];
        }
    }
    return _exportRepresentation;
}

- (void)dealloc
{
    [_context release];
    [_linkedStackPaths release];
    [_embeddedCode release];
    [super dealloc];
}

- (id)defaultExportSettings
{
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithDictionary:[super defaultExportSettings]];
    id document = [[NSDocumentController sharedDocumentController] currentDocument];
    [settings setValue:[NSNumber numberWithBool:[self areLinkedStacksInDocument:document]] forKey:HSHTML5ExportDocumentContainsLinkedStacksKey];
    [settings setValue:[NSNumber numberWithInt:1] forKey:HSHTML5ExportLinkedStacksLevelKey];
    return settings;
}

- (id)requiredFileType
{
    return @"";
}

// The stack's web app icon drawn at 160 x 160 as icon.png.
- (id)webAppIconWrapperForDocument:(id)aDocument
{
    NSImage *icon = [[aDocument stack] webAppIcon];
    NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(160.0, 160.0)] autorelease];
    [image lockFocus];
    [icon drawInRect:NSMakeRect(0, 0, [image size].width, [image size].height) fromRect:NSMakeRect(0, 0, [icon size].width, [icon size].height) operation:NSCompositingOperationSourceOver fraction:1.0];
    [image unlockFocus];
    NSFileWrapper *wrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:[image hyperPNGRepresentation]] autorelease];
    [wrapper setPreferredFilename:@"icon.png"];
    return wrapper;
}

@end

