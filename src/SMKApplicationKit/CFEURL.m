#import "CFEURL.h"

CFURLRef CFEURLCreateTemporaryFileURLForObject(CFStringRef type, CFStringRef name, const void *object)
{
    CFTimeZoneRef zone = CFTimeZoneCopySystem();
    if (!zone)
        return NULL;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CFGregorianDate date = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), zone);
#pragma clang diagnostic pop
    CFRelease(zone);
    CFStringRef process = (CFStringRef)[[[NSProcessInfo processInfo] processName] copy];
    if (!process)
        return NULL;
    CFStringRef extension = UTTypeCopyPreferredTagWithClass(type, kUTTagClassFilenameExtension);
    if (!extension) {
        CFRelease(process);
        return NULL;
    }
    CFStringRef fileName = CFStringCreateWithFormat(kCFAllocatorDefault, NULL,
                                                    CFSTR("%04i-%02i-%02i %02i-%02i-%02.0f.%03.0f %@[%i] %@-0x%08x.%@"),
                                                    (int)date.year, date.month, date.day, date.hour, date.minute,
                                                    date.second, fmod(date.second, 1.0) * 1000.0, process, getpid(),
                                                    name, (unsigned int)(uintptr_t)object, extension);
    CFRelease(extension);
    CFRelease(process);
    if (!fileName)
        return NULL;
    CFURLRef url = NULL;
    CFURLRef folder = (CFURLRef)[[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES] retain];
    if (folder) {
        url = CFURLCreateCopyAppendingPathComponent(kCFAllocatorDefault, folder, fileName, false);
        CFRelease(folder);
    }
    CFRelease(fileName);
    return url;
}
