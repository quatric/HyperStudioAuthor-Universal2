#import "CGEContext.h"
#import <pthread.h>

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
// Context -> its attachments: a dictionary, or once saved, a stack (array) of
// them where kCFNull stands for none.
static CFMutableDictionaryRef contextAttachments;
// Context -> {kind -> destination}.
static CFMutableDictionaryRef contextDestinations;

static CFMutableDictionaryRef newAttachments(void)
{
    return CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks,
                                     &kCFTypeDictionaryValueCallBacks);
}

// The context's current attachments, made if create is set. *saved tells
// whether they're on a stack. Call with the lock held.
static CFMutableDictionaryRef currentAttachments(CGContextRef context, Boolean create, Boolean *saved)
{
    if (saved)
        *saved = false;
    CFTypeRef entry = CFDictionaryGetValue(contextAttachments, context);
    if (!entry) {
        if (!create)
            return NULL;
        CFMutableDictionaryRef attachments = newAttachments();
        if (!attachments)
            return NULL;
        CFDictionarySetValue(contextAttachments, context, attachments);
        CFRelease(attachments);
        return attachments;
    }
    if (CFGetTypeID(entry) == CFDictionaryGetTypeID())
        return (CFMutableDictionaryRef)entry;

    CFMutableArrayRef stack = (CFMutableArrayRef)entry;
    if (saved)
        *saved = true;
    CFIndex count = CFArrayGetCount(stack);
    if (count == 0) {
        if (!create)
            return NULL;
        CFMutableDictionaryRef attachments = newAttachments();
        if (!attachments)
            return NULL;
        CFArrayAppendValue(stack, attachments);
        CFRelease(attachments);
        return attachments;
    }
    CFTypeRef top = CFArrayGetValueAtIndex(stack, count - 1);
    if (CFGetTypeID(top) != CFNullGetTypeID())
        return (CFMutableDictionaryRef)top;
    if (!create)
        return NULL;
    CFMutableDictionaryRef attachments = newAttachments();
    if (!attachments)
        return NULL;
    CFArrayReplaceValues(stack, CFRangeMake(count - 1, 1), (const void **)&attachments, 1);
    CFRelease(attachments);
    return attachments;
}

static CFMutableDictionaryRef newContextDictionary(void)
{
    return CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks,
                                     &kCFTypeDictionaryValueCallBacks);
}

CFTypeRef CGEContextGetAttachmentForKey(CGContextRef context, CFStringRef key)
{
    if (!context || !contextAttachments || pthread_mutex_lock(&lock) != 0)
        return NULL;
    CFDictionaryRef attachments = currentAttachments(context, false, NULL);
    pthread_mutex_unlock(&lock);
    return attachments ? CFDictionaryGetValue(attachments, key) : NULL;
}

void CGEContextSetAttachmentForKey(CGContextRef context, CFStringRef key, CFTypeRef value)
{
    if (!context || (!contextAttachments && !value) || pthread_mutex_lock(&lock) != 0)
        return;
    if (contextAttachments || (contextAttachments = newContextDictionary())) {
        Boolean saved = false;
        CFMutableDictionaryRef attachments = currentAttachments(context, value != NULL, &saved);
        if (attachments) {
            if (value)
                CFDictionarySetValue(attachments, key, value);
            else if (saved || CFDictionaryGetCount(attachments) != 1)
                CFDictionaryRemoveValue(attachments, key);
            else if (CFDictionaryGetValue(attachments, key))
                // The last one: drop the context's entry.
                CFDictionaryRemoveValue(contextAttachments, context);
        }
    }
    pthread_mutex_unlock(&lock);
}

CFDictionaryRef CGEContextCopyAttachments(CGContextRef context)
{
    if (context && contextAttachments && pthread_mutex_lock(&lock) == 0) {
        CFDictionaryRef attachments = currentAttachments(context, false, NULL);
        pthread_mutex_unlock(&lock);
        if (attachments)
            return CFDictionaryCreateCopy(kCFAllocatorDefault, attachments);
    }
    return CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFCopyStringDictionaryKeyCallBacks,
                              &kCFTypeDictionaryValueCallBacks);
}

void CGEContextSaveAttachments(CGContextRef context)
{
    if (!context || pthread_mutex_lock(&lock) != 0)
        return;
    if (!contextAttachments && !(contextAttachments = newContextDictionary())) {
        pthread_mutex_unlock(&lock);
        return;
    }
    CFTypeRef entry = CFDictionaryGetValue(contextAttachments, context);
    CFMutableArrayRef stack;
    CFTypeRef current;
    if (entry && CFGetTypeID(entry) == CFArrayGetTypeID()) {
        stack = (CFMutableArrayRef)entry;
        CFIndex count = CFArrayGetCount(stack);
        current = count ? CFArrayGetValueAtIndex(stack, count - 1) : NULL;
        if (current && CFGetTypeID(current) == CFNullGetTypeID())
            current = NULL;
    }
    else {
        // First save: the stack starts with the attachments as they are.
        stack = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        if (!stack) {
            pthread_mutex_unlock(&lock);
            return;
        }
        current = entry;
        CFArrayAppendValue(stack, entry ? entry : kCFNull);
        CFDictionarySetValue(contextAttachments, context, stack);
        CFRelease(stack);
    }
    CFTypeRef copy = current ? CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, current) : CFRetain(kCFNull);
    if (copy) {
        CFArrayAppendValue(stack, copy);
        CFRelease(copy);
    }
    pthread_mutex_unlock(&lock);
}

void CGEContextRestoreAttachments(CGContextRef context)
{
    if (!context)
        return;
    if (contextAttachments) {
        if (pthread_mutex_lock(&lock) != 0) {
            CFShow(CFSTR("Failed to restore context attachments."));
            return;
        }
        CFTypeRef entry = CFDictionaryGetValue(contextAttachments, context);
        if (entry && CFGetTypeID(entry) != CFDictionaryGetTypeID()) {
            CFMutableArrayRef stack = (CFMutableArrayRef)entry;
            CFIndex count = CFArrayGetCount(stack);
            if (count > 1) {
                CFTypeRef base = CFArrayGetValueAtIndex(stack, 0);
                if (count == 2 && (CFGetTypeID(base) == CFNullGetTypeID() || CFDictionaryGetCount(base) == 0))
                    CFDictionaryRemoveValue(contextAttachments, context);
                else
                    CFArrayRemoveValueAtIndex(stack, count - 1);
                pthread_mutex_unlock(&lock);
                return;
            }
            // Nothing was saved: drop an empty stack.
            CFTypeRef base = count ? CFArrayGetValueAtIndex(stack, 0) : NULL;
            if (!base || CFGetTypeID(base) == CFNullGetTypeID() || CFDictionaryGetCount(base) == 0)
                CFDictionaryRemoveValue(contextAttachments, context);
        }
        pthread_mutex_unlock(&lock);
    }
    CFShow(CFSTR("Tried to restore unsaved context attachments."));
}

void *CGEContextGetDestination(CGContextRef context, CFStringRef kind)
{
    if (!context || !contextDestinations || pthread_mutex_lock(&lock) != 0)
        return NULL;
    CFDictionaryRef destinations = CFDictionaryGetValue(contextDestinations, context);
    void *destination = destinations ? (void *)CFDictionaryGetValue(destinations, kind) : NULL;
    pthread_mutex_unlock(&lock);
    return destination;
}

void CGEContextSetDestination(CGContextRef context, CFStringRef kind, void *destination)
{
    if (!context || (!contextDestinations && !destination) || pthread_mutex_lock(&lock) != 0)
        return;
    CFMutableDictionaryRef destinations = NULL;
    if (contextDestinations)
        destinations = (CFMutableDictionaryRef)CFDictionaryGetValue(contextDestinations, context);
    else if (!(contextDestinations = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
                                                               &kCFEWeakObjectPointerDictionaryKeyCallBacks,
                                                               &kCFTypeDictionaryValueCallBacks))) {
        pthread_mutex_unlock(&lock);
        return;
    }
    if (!destination) {
        if (destinations) {
            if (CFDictionaryGetCount(destinations) != 1)
                CFDictionaryRemoveValue(destinations, kind);
            else if (CFDictionaryContainsKey(destinations, kind))
                CFDictionaryRemoveValue(contextDestinations, context);
        }
        pthread_mutex_unlock(&lock);
        return;
    }
    if (!destinations) {
        destinations = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, NULL);
        if (!destinations) {
            pthread_mutex_unlock(&lock);
            return;
        }
        CFDictionarySetValue(contextDestinations, context, destinations);
        CFRelease(destinations);
    }
    CFDictionarySetValue(destinations, kind, destination);
    pthread_mutex_unlock(&lock);
}
