#import <CoreFoundation/CoreFoundation.h>

// A new file URL in the temporary folder for saving an object as a type (a
// UTI), named for the time, the process, a name and the object's address.
CFURLRef CFEURLCreateTemporaryFileURLForObject(CFStringRef type, CFStringRef name, const void *object);
