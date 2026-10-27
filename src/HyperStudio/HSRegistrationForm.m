#import "HSRegistrationForm.h"

@implementation HSRegistrationForm

- (void)dealloc
{
    [userDefaultsKeyMap release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [self setupTextFieldsFormatters];
    [self setupPopUpButtons];
    [self setupPrivacyStatementButton];
}

- (id)settingsView
{
    return settingsView;
}

- (id)firstNameField
{
    return firstNameField;
}

- (id)lastNameField
{
    return lastNameField;
}

- (id)emailField
{
    return emailField;
}

- (id)cityField
{
    return cityField;
}

- (id)schoolNameField
{
    return schoolNameField;
}

- (id)statesStarField
{
    return statesStarField;
}

- (id)addressField
{
    return addressField;
}

- (id)schoolTitleField
{
    return schoolTitleField;
}

- (id)schoolDistrictField
{
    return schoolDistrictField;
}

- (id)zipField
{
    return zipField;
}

- (id)countryPopUp
{
    return countryPopUp;
}

- (id)stateProvPopUp
{
    return stateProvPopUp;
}

- (id)locationPopUp
{
    return locationPopUp;
}

- (id)mySchoolDistrictPopUp
{
    return mySchoolDistrictPopUp;
}

- (id)macsTypePopUp
{
    return macsTypePopUp;
}

- (id)schoolPricesCheckBox
{
    return schoolPricesCheckBox;
}

- (id)educationPricingCheckBox
{
    return educationPricingCheckBox;
}

- (id)eNewsEmailsCheckBox
{
    return eNewsEmailsCheckBox;
}

- (id)freeUpdatesCheckBox
{
    return freeUpdatesCheckBox;
}

- (id)companyNewsCheckBox
{
    return companyNewsCheckBox;
}

- (id)privacyStatementButton
{
    return privacyStatementButton;
}

- (id)countriesMap
{
    static NSDictionary *sCountriesMap;
    if (sCountriesMap == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"Countries" ofType:@"plist"];
        sCountriesMap = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return sCountriesMap;
}

- (id)userDefaultsKeyForControl:(id)aControl
{
    if (aControl == nil)
        return nil;
    if (userDefaultsKeyMap == nil) {
        userDefaultsKeyMap = [NSMutableDictionary new];
        [userDefaultsKeyMap setValue:firstNameField forKey:kHSUsersDefaultsRegistrationFirstNameKey];
        [userDefaultsKeyMap setValue:lastNameField forKey:kHSUsersDefaultsRegistrationLastNameKey];
        [userDefaultsKeyMap setValue:emailField forKey:kHSUsersDefaultsRegistrationEmailKey];
        [userDefaultsKeyMap setValue:cityField forKey:kHSUsersDefaultsRegistrationCityKey];
        [userDefaultsKeyMap setValue:schoolNameField forKey:kHSUsersDefaultsRegistrationSchoolNameKey];
        [userDefaultsKeyMap setValue:addressField forKey:kHSUsersDefaultsRegistrationAddressKey];
        [userDefaultsKeyMap setValue:schoolTitleField forKey:kHSUsersDefaultsRegistrationSchoolTitleKey];
        [userDefaultsKeyMap setValue:schoolDistrictField forKey:kHSUsersDefaultsRegistrationSchoolDistrictKey];
        [userDefaultsKeyMap setValue:zipField forKey:kHSUsersDefaultsRegistrationZipKey];
        [userDefaultsKeyMap setValue:countryPopUp forKey:kHSUsersDefaultsRegistrationCountryKey];
        [userDefaultsKeyMap setValue:stateProvPopUp forKey:kHSUsersDefaultsRegistrationStateProvKey];
        [userDefaultsKeyMap setValue:locationPopUp forKey:kHSUsersDefaultsRegistrationLocationKey];
        [userDefaultsKeyMap setValue:mySchoolDistrictPopUp forKey:kHSUsersDefaultsRegistrationMySchoolDistrictKey];
        [userDefaultsKeyMap setValue:macsTypePopUp forKey:kHSUsersDefaultsRegistrationMacsTypeKey];
        [userDefaultsKeyMap setValue:schoolPricesCheckBox forKey:kHSUsersDefaultsRegistrationSchoolPricesKey];
        [userDefaultsKeyMap setValue:educationPricingCheckBox forKey:kHSUsersDefaultsRegistrationReceiveSchoolMailKey];
        [userDefaultsKeyMap setValue:eNewsEmailsCheckBox forKey:kHSUsersDefaultsRegistrationENewsEmailsKey];
        [userDefaultsKeyMap setValue:freeUpdatesCheckBox forKey:kHSUsersDefaultsRegistrationReceiveHSMailKey];
        [userDefaultsKeyMap setValue:companyNewsCheckBox forKey:kHSUsersDefaultsRegistrationReceiveAllMailKey];
    }
    return [[userDefaultsKeyMap allKeysForObject:aControl] lastObject];
}

- (id)normalizedString:(id)aString
{
    NSString *string = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [string length] == 0 ? nil : string;
}

- (id)menuWithItemTitles:(id)aTitles
{
    NSMenu *menu = [[NSMenu new] autorelease];
    for (id title in aTitles) {
        if (![title isKindOfClass:[NSString class]])
            continue;
        if ([title isEqualToString:@"-"])
            [menu addItem:[NSMenuItem separatorItem]];
        else
            [menu addItemWithTitle:title action:NULL keyEquivalent:@""];
    }
    return menu;
}

- (void)setupTextFieldsFormatters
{
    [[self firstNameField] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:64]];
    [[self lastNameField] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:64]];
    [[self emailField] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:64]];
    [[self cityField] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:64]];
    [[self zipField] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:64]];
    [[self addressField] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:255]];
    [[self schoolNameField] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:255]];
    [[self schoolTitleField] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:255]];
    [[self schoolDistrictField] setFormatter:[HSLimitedLengthStringFormatter formatterWithLengthLimit:255]];
}

- (void)setupPopUpButtons
{
    id countries = [[self countriesMap] objectForKey:@"Countries"];
    if (countries != nil && [countries isKindOfClass:[NSArray class]])
        [[self countryPopUp] setMenu:[self menuWithItemTitles:countries]];
    [[self countryPopUp] selectItemAtIndex:0];
    [[self countryPopUp] setAction:@selector(changeCountry:)];
    [(NSPopUpButton *)[self countryPopUp] setTarget:self];
    [[self locationPopUp] setAction:@selector(changeLocation:)];
    [(NSPopUpButton *)[self locationPopUp] setTarget:self];
}

- (void)setupPrivacyStatementButton
{
    NSString *title = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"HSPrivacyStatement" value:@"" table:@"RegistrationFormLocalized"];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[[self privacyStatementButton] font], NSFontAttributeName, [NSColor blueColor], NSForegroundColorAttributeName, [NSNumber numberWithInt:1], NSUnderlineStyleAttributeName, nil];
    [[self privacyStatementButton] setAttributedTitle:[[[NSAttributedString alloc] initWithString:title attributes:attributes] autorelease]];
}

- (void)changeCountry:(id)aSender
{
    [self validateStateProvPopUp];
}

- (void)changeLocation:(id)aSender
{
    [self validateSchoolNameField];
}

- (void)validateStateProvPopUp
{
    [[self stateProvPopUp] selectItemAtIndex:0];
    id states = [[[self countriesMap] objectForKey:@"States"] objectForKey:[[[self countryPopUp] selectedItem] title]];
    if (states == nil) {
        [[self stateProvPopUp] setMenu:noStatesMenu];
        [[self stateProvPopUp] setEnabled:NO];
        [[self statesStarField] setStringValue:@""];
    } else {
        [[self stateProvPopUp] setMenu:[self menuWithItemTitles:states]];
        [[self stateProvPopUp] setEnabled:YES];
        [[self statesStarField] setStringValue:@"*"];
    }
}

- (void)validateSchoolNameField
{
    if ([self locationPopUp] != nil) {
        NSInteger tag = [[[self locationPopUp] selectedItem] tag];
        [[self schoolNameField] setEnabled:tag == 1];
        if (tag != 1)
            [[self schoolNameField] setStringValue:@""];
    }
}

- (BOOL)isTextFieldFilled:(id)aField
{
    [aField validateEditing];
    if (![aField isEnabled])
        return YES;
    return [[self normalizedString:[aField stringValue]] length] != 0;
}

- (BOOL)isPopUpButtonFilled:(id)aButton
{
    if (![aButton isEnabled])
        return YES;
    return [aButton indexOfSelectedItem] > 0;
}

- (BOOL)areRequiredFieldsFilled
{
    BOOL personFilled = NO;
    if ([self isTextFieldFilled:[self firstNameField]] && [self isTextFieldFilled:[self lastNameField]])
        personFilled = [self isTextFieldFilled:[self emailField]];
    BOOL filled = personFilled;
    if ([self schoolTitleField] != nil) {
        BOOL schoolFilled = NO;
        if ([self isTextFieldFilled:[self schoolNameField]] && [self isTextFieldFilled:[self schoolTitleField]])
            schoolFilled = [self isTextFieldFilled:[self schoolDistrictField]];
        filled = filled && schoolFilled;
    }
    BOOL popUpsFilled = NO;
    if ([self isPopUpButtonFilled:[self countryPopUp]] && [self isPopUpButtonFilled:[self stateProvPopUp]] && [self isPopUpButtonFilled:[self macsTypePopUp]])
        popUpsFilled = [self isPopUpButtonFilled:[self mySchoolDistrictPopUp]];
    return filled && popUpsFilled;
}

- (BOOL)isEmailTextFieldValid
{
    NSString *email = [[self emailField] stringValue];
    if (![email canBeConvertedToEncoding:NSASCIIStringEncoding])
        return NO;
    NSRange at = [email rangeOfString:@"@"];
    if (at.location == 0 || at.length != 1)
        return NO;
    NSRange lastAt = [email rangeOfString:@"@" options:NSBackwardsSearch];
    if (lastAt.location != at.location || [email length] - 1 == at.location)
        return NO;
    NSString *local = [email substringToIndex:at.location];
    NSString *domain = [email substringFromIndex:at.location + 1];
    NSMutableCharacterSet *localCharacters = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
    [localCharacters addCharactersInString:@"!#$%'*+-./=?^_`~&"];
    NSMutableCharacterSet *domainCharacters = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
    [domainCharacters addCharactersInString:@".-"];
    if (local == nil || domain == nil)
        return NO;
    if ([local rangeOfCharacterFromSet:[localCharacters invertedSet]].location != NSNotFound)
        return NO;
    if ([domain rangeOfCharacterFromSet:[domainCharacters invertedSet]].location != NSNotFound)
        return NO;
    if ([domain hasSuffix:@"."] || [domain hasPrefix:@"."] || [domain rangeOfString:@".."].location != NSNotFound)
        return NO;
    return [domain rangeOfString:@"."].location != NSNotFound;
}

- (id)unfilledFieldError
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[bundle localizedStringForKey:@"Required information incomplete" value:@"" table:@"RegistrationFormLocalized"], NSLocalizedDescriptionKey, [bundle localizedStringForKey:@"Required information incomplete..." value:@"" table:@"RegistrationFormLocalized"], NSLocalizedRecoverySuggestionErrorKey, nil];
    return [NSError errorWithDomain:NSCocoaErrorDomain code:0x800 userInfo:info];
}

- (id)incorrectEmailError
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[bundle localizedStringForKey:@"Email address not complete" value:@"" table:@"RegistrationFormLocalized"], NSLocalizedDescriptionKey, [bundle localizedStringForKey:@"Email address not complete..." value:@"" table:@"RegistrationFormLocalized"], NSLocalizedRecoverySuggestionErrorKey, nil];
    return [NSError errorWithDomain:NSCocoaErrorDomain code:0x800 userInfo:info];
}

- (BOOL)validateValuesWithError:(id *)aError
{
    BOOL valid = YES;
    if (![self areRequiredFieldsFilled]) {
        valid = NO;
        if (aError != NULL)
            *aError = [self unfilledFieldError];
    }
    if (![self isEmailTextFieldValid]) {
        valid = NO;
        if (aError != NULL)
            *aError = [self incorrectEmailError];
    }
    return valid;
}

- (void)setValueForTextField:(id)aField fromDictionary:(id)aDictionary
{
    id value = [aDictionary objectForKey:[self userDefaultsKeyForControl:aField]];
    if (value != nil && [aField isEnabled])
        [aField setStringValue:value];
}

- (void)setValueForPopUpButton:(id)aButton fromDictionary:(id)aDictionary
{
    id value = [aDictionary objectForKey:[self userDefaultsKeyForControl:aButton]];
    if (value != nil && [aButton isEnabled])
        [aButton selectItemWithTitle:value];
    if ([aButton selectedItem] == nil)
        [aButton selectItemAtIndex:0];
}

- (void)setValueForCheckBox:(id)aButton fromDictionary:(id)aDictionary
{
    id value = [aDictionary objectForKey:[self userDefaultsKeyForControl:aButton]];
    [aButton setIntValue:(value == nil || [value intValue] > 0) ? 1 : 0];
}

- (void)writeValueFromTextField:(id)aField toDictionary:(id)aDictionary
{
    NSString *value = [self normalizedString:[aField stringValue]];
    if ([aField isEnabled] && [value length] != 0)
        [aDictionary setObject:value forKey:[self userDefaultsKeyForControl:aField]];
}

- (void)writeValueFromPopUpButton:(id)aButton toDictionary:(id)aDictionary
{
    NSString *title = [[aButton selectedItem] title];
    if ([aButton isEnabled] && [aButton indexOfSelectedItem] > 0 && title != nil)
        [aDictionary setObject:title forKey:[self userDefaultsKeyForControl:aButton]];
}

- (void)writeValueFromCheckBox:(id)aButton toDictionary:(id)aDictionary
{
    if (aButton != nil)
        [aDictionary setObject:[NSString stringWithFormat:@"%u", [aButton intValue]] forKey:[self userDefaultsKeyForControl:aButton]];
}

- (id)dictionaryRepresentation
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [self writeValueFromTextField:[self firstNameField] toDictionary:result];
    [self writeValueFromTextField:[self lastNameField] toDictionary:result];
    [self writeValueFromTextField:[self emailField] toDictionary:result];
    [self writeValueFromTextField:[self addressField] toDictionary:result];
    [self writeValueFromTextField:[self zipField] toDictionary:result];
    [self writeValueFromTextField:[self cityField] toDictionary:result];
    [self writeValueFromTextField:[self schoolNameField] toDictionary:result];
    [self writeValueFromTextField:[self schoolTitleField] toDictionary:result];
    [self writeValueFromTextField:[self schoolDistrictField] toDictionary:result];
    [self writeValueFromPopUpButton:[self countryPopUp] toDictionary:result];
    [self writeValueFromPopUpButton:[self stateProvPopUp] toDictionary:result];
    [self writeValueFromPopUpButton:[self mySchoolDistrictPopUp] toDictionary:result];
    [self writeValueFromPopUpButton:[self macsTypePopUp] toDictionary:result];
    [self writeValueFromPopUpButton:[self locationPopUp] toDictionary:result];
    [self writeValueFromCheckBox:[self freeUpdatesCheckBox] toDictionary:result];
    [self writeValueFromCheckBox:[self schoolPricesCheckBox] toDictionary:result];
    [self writeValueFromCheckBox:[self eNewsEmailsCheckBox] toDictionary:result];
    [self writeValueFromCheckBox:[self companyNewsCheckBox] toDictionary:result];
    [self writeValueFromCheckBox:[self educationPricingCheckBox] toDictionary:result];
    return result;
}

- (void)setValuesFromDictionaryRepresentation:(id)aDictionary
{
    [self setValueForTextField:[self firstNameField] fromDictionary:aDictionary];
    [self setValueForTextField:[self lastNameField] fromDictionary:aDictionary];
    [self setValueForTextField:[self emailField] fromDictionary:aDictionary];
    [self setValueForTextField:[self cityField] fromDictionary:aDictionary];
    [self setValueForTextField:[self addressField] fromDictionary:aDictionary];
    [self setValueForTextField:[self zipField] fromDictionary:aDictionary];
    [self setValueForTextField:[self schoolTitleField] fromDictionary:aDictionary];
    [self setValueForTextField:[self schoolDistrictField] fromDictionary:aDictionary];
    [self setValueForPopUpButton:[self countryPopUp] fromDictionary:aDictionary];
    [self validateStateProvPopUp];
    [self setValueForPopUpButton:[self stateProvPopUp] fromDictionary:aDictionary];
    [self setValueForPopUpButton:[self mySchoolDistrictPopUp] fromDictionary:aDictionary];
    [self setValueForPopUpButton:[self macsTypePopUp] fromDictionary:aDictionary];
    [self setValueForPopUpButton:[self locationPopUp] fromDictionary:aDictionary];
    [self validateSchoolNameField];
    [self setValueForTextField:[self schoolNameField] fromDictionary:aDictionary];
    [self setValueForCheckBox:[self schoolPricesCheckBox] fromDictionary:aDictionary];
    [self setValueForCheckBox:[self educationPricingCheckBox] fromDictionary:aDictionary];
    [self setValueForCheckBox:[self eNewsEmailsCheckBox] fromDictionary:aDictionary];
    [self setValueForCheckBox:[self freeUpdatesCheckBox] fromDictionary:aDictionary];
    [self setValueForCheckBox:[self companyNewsCheckBox] fromDictionary:aDictionary];
}

@end
