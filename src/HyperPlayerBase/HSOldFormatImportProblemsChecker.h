#import "HyperPlayerBasePrefix.h"


@interface HSOldFormatImportProblemsChecker : NSObject
{
    HSOldFormatDocument *_oldFormatDocument;
    HSImportProblems *_problems;
    HSOldFormatParser *_parser;
    BOOL _isLegacyPlayerDetected;
}
- (id)descriptionForFontTraitMask:(NSInteger)aMask;
- (id)nbaNameById:(NSInteger)aId;
- (void)oldFormatParser:(id)aParser didDeriveSimpleValue:(id)aValue forName:(id)aName parentName:(id)aName2 parameters:(id)aParameters;
- (void)addCursorImportingProblemIfNeededForOldCursorID:(NSInteger)aID;
- (void)addImportingProblemForCode:(NSInteger)aCode point:(id)aPoint info:(id)aInfo;
- (BOOL)isLegacyPlayerDetected;
- (void)setParser:(id)aParser;
- (id)parser;
- (BOOL)shouldImportStack;
- (void)submitRequestWithString:(id)aString;
- (id)oldFormatDocument;
- (void)setOldFormatDocument:(id)aDocument;
- (void)dealloc;
- (id)init;
@end

