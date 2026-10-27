#import "HSError.h"
// Errors whose texts come from the "Alerts" table, keyed "Err<code>-<suffix>",
// with placeholders %1$@...%10$@ filled from the user info.
@implementation HSError
+ (id)cantOpenFileErrorWithFileName:(id)aName
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSString stringWithFormat:[bundle localizedStringForKey:@"Cannot add the file \"%@\" to the card." value:@"" table:nil], aName] forKey:NSLocalizedDescriptionKey];
    [userInfo setObject:[bundle localizedStringForKey:@"The file may be damaged or its type might not be supported. Select another file and try again." value:@"" table:nil] forKey:NSLocalizedRecoverySuggestionErrorKey];
    return [HSError errorWithDomain:@"HSSpecificErrorDomain" code:20516 userInfo:userInfo];
}
// The script's error dictionary isn't used: the texts are generic.
+ (id)appleScriptErrorWithDictionary:(id)aDictionary
{
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    NSString *description = [provider localizedStringForKey:@"NBA_RunAppleScript_Error_DescriptionText" value:@"" table:@"Alerts"];
    NSString *message = [provider localizedStringForKey:@"NBA_RunAppleScript_Error_MessageText" value:@"" table:@"Alerts"];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message, @"HSAdditionalInfo1", description, @"HSAdditionalInfo2", nil];
    return [HSError errorWithDomain:@"HSSpecificErrorDomain" code:20005 userInfo:userInfo];
}
// Codes below 10000 are Cocoa's.
+ (id)fileErrorWithHSCode:(NSInteger)aCode URL:(id)aURL
{
    NSMutableDictionary *userInfo = nil;
    if (aURL != nil) {
        userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:aURL forKey:NSURLErrorKey];
        if ([aURL isFileURL])
            [userInfo setObject:[aURL path] forKey:NSFilePathErrorKey];
    }
    NSString *domain = aCode < 10000 ? NSCocoaErrorDomain : @"HSSpecificErrorDomain";
    return [self errorWithError:[HSError errorWithDomain:domain code:aCode userInfo:userInfo]];
}
+ (id)fileErrorWithHSCode:(NSInteger)aCode filePath:(id)aPath
{
    return [self fileErrorWithHSCode:aCode URL:aPath != nil ? [NSURL fileURLWithPath:aPath] : nil];
}
// As an HSError. The original also collects the localized texts into a copy
// of the user info, then doesn't use it: the result has the error's own user
// info (its texts still come from the Alerts table on demand).
+ (id)errorWithError:(id)aError
{
    NSError *error = [HSError errorWithDomain:[aError domain] code:[(NSError *)aError code] userInfo:[aError userInfo]];
    return [HSError errorWithDomain:[error domain] code:[error code] userInfo:[error userInfo]];
}
+ (id)errorWithHSCode:(NSInteger)aCode
{
    return [self fileErrorWithHSCode:aCode URL:nil];
}
- (id)localizedRecoveryOptions
{
    return [super localizedRecoveryOptions];
}
- (id)localizedRecoverySuggestion
{
    NSString *text = [self localizationForSuffix:@"RecoverySuggestion"];
    return text != nil ? text : [super localizedRecoverySuggestion];
}
- (id)localizedFailureReason
{
    NSString *text = [self localizationForSuffix:@"FailureReason"];
    return text != nil ? text : [super localizedFailureReason];
}
- (id)localizedDescription
{
    NSString *text = [self localizationForSuffix:@"Description"];
    return text != nil ? text : [super localizedDescription];
}
static void HSErrorReplace(NSMutableString *aText, NSString *aPlaceholder, NSString *aValue)
{
    [aText replaceOccurrencesOfString:aPlaceholder withString:aValue options:NSCaseInsensitiveSearch range:NSMakeRange(0, [aText length])];
}
// nil when the table has no text. Placeholders: 1 display name, 2 file name
// (without ".stack"), 3 folder name, 4 volume, 5 file type, 6 URL type,
// 7 encoding (all quoted), 8/9 additional infos, 10 the application's name.
- (id)localizationForSuffix:(id)aSuffix
{
    NSString *key = [NSString stringWithFormat:@"Err%d-%@", (int)[self code], aSuffix];
    NSMutableString *text = [NSMutableString stringWithString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:key value:@"" table:@"Alerts"]];
    if ([text isEqualToString:@""] || [text isEqualToString:key])
        return nil;
    NSDictionary *userInfo = [self userInfo];
    if ([text rangeOfString:@"%1$@"].location != NSNotFound)
        HSErrorReplace(text, @"%1$@", [NSString stringWithFormat:@"\"%@\"", [userInfo objectForKey:@"HSDisplayName"]]);
    if ([text rangeOfString:@"%2$@"].location != NSNotFound) {
        NSString *name = [[userInfo objectForKey:NSFilePathErrorKey] lastPathComponent];
        if ([[name pathExtension] isEqualToString:@"stack"])
            name = [name stringByDeletingPathExtension];
        HSErrorReplace(text, @"%2$@", name != nil ? [NSString stringWithFormat:@"\"%@\"", name] : @"");
    }
    if ([text rangeOfString:@"%3$@"].location != NSNotFound)
        HSErrorReplace(text, @"%3$@", [NSString stringWithFormat:@"\"%@\"", [[[userInfo objectForKey:NSFilePathErrorKey] stringByDeletingLastPathComponent] lastPathComponent]]);
    if ([text rangeOfString:@"%4$@"].location != NSNotFound)
        HSErrorReplace(text, @"%4$@", [NSString stringWithFormat:@"\"%@\"", [userInfo objectForKey:@"HSVolumeName"]]);
    if ([text rangeOfString:@"%5$@"].location != NSNotFound)
        HSErrorReplace(text, @"%5$@", [NSString stringWithFormat:@"\"%@\"", [userInfo objectForKey:@"HSFileType"]]);
    if ([text rangeOfString:@"%6$@"].location != NSNotFound)
        HSErrorReplace(text, @"%6$@", [NSString stringWithFormat:@"\"%@\"", [userInfo objectForKey:@"HSURLType"]]);
    if ([text rangeOfString:@"%7$@"].location != NSNotFound)
        HSErrorReplace(text, @"%7$@", [NSString stringWithFormat:@"\"%@\"", [userInfo objectForKey:@"HSEncoding"]]);
    // missing additional infos become empty (the original raises on nil)
    if ([text rangeOfString:@"%8$@"].location != NSNotFound) {
        NSString *info = [userInfo objectForKey:@"HSAdditionalInfo1"];
        HSErrorReplace(text, @"%8$@", info != nil ? info : @"");
    }
    if ([text rangeOfString:@"%9$@"].location != NSNotFound) {
        NSString *info = [userInfo objectForKey:@"HSAdditionalInfo2"];
        HSErrorReplace(text, @"%9$@", info != nil ? info : @"");
    }
    if ([text rangeOfString:@"%10$@"].location != NSNotFound)
        HSErrorReplace(text, @"%10$@", [[[[NSBundle mainBundle] bundlePath] lastPathComponent] stringByDeletingPathExtension]);
    return text;
}
@end
