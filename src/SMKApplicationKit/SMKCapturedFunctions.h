#import <CoreFoundation/CoreFoundation.h>

// Functions SMKApplicationKit replaced, so other code patching the same
// functions can chain: each dictionary maps a captured (original) function to
// the replacement calling it (kCFEAlignedPointerDictionaryKeyCallBacks keys).
// Recapturing swaps a captured function for another one, e.g. after someone
// else replaced the replacement.

// CoreFoundation functions (the pre-10.5 associated objects hooked CF
// deallocation; nothing is captured on macOS 11+).
CFDictionaryRef CFECopyCapturedFunctions(void);
void CFERecaptureFunction(void *function, void *newFunction);
// Foundation methods (the NSUndoManager hooks of NSE_endUndoAutogroup and
// NSE_setActionNameIfNeeded:, once installed).
CFDictionaryRef NSECopyCapturedFunctions(void);
void NSERecaptureFunction(void *function, void *newFunction);
// AppKit methods (setControlTint: before 10.6; none now).
CFDictionaryRef NSECopyCapturedApplicationFunctions(void);
void NSERecaptureApplicationFunction(void *function, void *newFunction);

// The system version as major << 24 | minor << 16 | bug fix (Gestalt's
// sys1 / sys2 / sys3), e.g. 0x0b030001 for 11.3.1.
uint32_t OSESystemVersionGetCurrent(void);
