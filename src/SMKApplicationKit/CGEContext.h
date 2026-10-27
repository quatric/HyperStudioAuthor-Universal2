// Attachments and destinations of CGContexts (SMKApplicationKit's CGEContext
// functions): values kept beside a context, keyed by kCGEContext…AttachmentKey
// strings, and saved / restored with it.
#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

CFTypeRef CGEContextGetAttachmentForKey(CGContextRef context, CFStringRef key);
// A NULL value removes the key.
void CGEContextSetAttachmentForKey(CGContextRef context, CFStringRef key, CFTypeRef value);
// All current attachments (an empty dictionary if there are none).
CFDictionaryRef CGEContextCopyAttachments(CGContextRef context);
// Push / pop the attachments (pair them with CGContextSaveGState / RestoreGState).
void CGEContextSaveAttachments(CGContextRef context);
void CGEContextRestoreAttachments(CGContextRef context);

// The object a context draws for, by kind (e.g. NSEOpenGLCGContextDestination).
// The destination is not retained.
void *CGEContextGetDestination(CGContextRef context, CFStringRef kind);
void CGEContextSetDestination(CGContextRef context, CFStringRef kind, void *destination);
