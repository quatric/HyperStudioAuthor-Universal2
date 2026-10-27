#ifndef SLLicense_h
#define SLLicense_h

#include <stddef.h>
#include <stdint.h>

/* Host-side licensing library ("SL") embedded in the HyperStudio executable. */

struct SLLicense;
typedef struct SLLicense SLLicense;

enum {
    SLLicenseTypeNone = 0,
    SLLicenseTypeLocalMachine = 1,
    SLLicenseTypeLimitedNetwork = 2,
    SLLicenseTypeLocalMachineTrial = 3
};

int SLInitialize(const void *data, size_t size, void *context, void (*release)(void *, const void *, size_t));   /* FUN_002afbe2 */
int SLSetApplicationInfo(const char *name, const char *bundleIdentifier, const char *major, const char *minor); /* FUN_002af494 */
int SLLicenseLoadHostFile(const char *bundlePath);                                    /* FUN_002aea49 */
void SLShutdown(void);                                                                /* FUN_002ae0d4 */
int SLLicenseCreateFromSerial(const char *serial, SLLicense **license);               /* FUN_002afb3b */
int SLLicenseStoreToHostFile(const char *bundlePath);                                 /* FUN_002aeef1 */
int SLLicenseCopyData(SLLicense *license, void *buffer, uint32_t *size);              /* FUN_002aed55 */
int SLLicenseCopyEnvironment(void *buffer, uint32_t *size);                           /* FUN_002af392 */
int SLLicenseHasPendingSerial(void);                                                  /* FUN_002afb5d */
int SLLicenseCopyPendingSerial(void *buffer, uint32_t *size);                         /* FUN_002af75b */
int SLEncodeHardwareIdentifier(const void *bytes, uint32_t length, void *buffer, uint32_t *size); /* FUN_002af2e3 */
int SLLicenseCopyUserData(SLLicense *license, int which, void *buffer, uint32_t *size);  /* which 0: FUN_002b4cc8, 1: FUN_002b4d44 */
int SLLicenseGetType(SLLicense *license);                                             /* FUN_002b48a2 */
double SLLicenseGetExpirationTime(SLLicense *license);                                /* FUN_002b49d8 */
int SLLicenseCopyRegistrationInfo(SLLicense *license, void *buffer, uint32_t *size);  /* FUN_002b49fc */
int SLLicenseGetUsageTimeFlags(SLLicense *license);                                   /* FUN_002b4a8b */
int SLLicenseGetAllowedCount(SLLicense *license);                                     /* FUN_002b4aad */
int SLLicenseCopyNetworkIdentifier(SLLicense *license, void *buffer, uint32_t *size); /* FUN_002b4acc */
int SLLicenseCopyBlockingIdentifiers(SLLicense *license, void *buffer, uint32_t *size); /* FUN_002b4b3d; buffer is uintptr_t[count, ptr...] */
int SLLicenseRelease(SLLicense *license);                                             /* FUN_002af216 */
int SLLicenseActivate(SLLicense *license);                                            /* FUN_002af240 */

#endif

#ifdef __OBJC__
@class NSData;
NSData *HSPrimaryEthernetMACAddress(void);
#endif
