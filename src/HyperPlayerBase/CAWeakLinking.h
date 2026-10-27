#import <stdbool.h>

// Weak binding from CoreAudio's PublicUtility: a symbol looked up by name
// (with its leading underscore) in a framework image, or in all loaded images
// when aImage is NULL, stored into *aAddress, or aFallback when it's missing.
// The functions return true on failure.

bool CAWeakRegisterAndBind(const char *aImage, const char *aSymbol, void *aFallback, void **aAddress);
bool CAWeakRegisterSubstitution(const char *aImage, const char *aSymbol, void *aFallback, void **aAddress);
void CAWeakLookupAndBind(void);
