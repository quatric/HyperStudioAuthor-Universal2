// The licensor library of the application: license descriptors read from and written to a serialized,
// partly encrypted blob, and the licensor data the application ships with.
#include <stddef.h>
#include "SSLicense.h"

typedef struct SLAllocatorContext {
    void *info;
    void *(*allocate)(size_t aSize);
    void (*deallocate)(void *aPointer);
} SLAllocatorContext;

void *SLAllocatorAllocate(const SLAllocatorContext *aContext, size_t aSize);
void SLAllocatorDeallocate(const SLAllocatorContext *aContext, void *aPointer);

typedef void (*SLReleaseCallBack)(void *aContext, void *aObject, size_t aSize);

// Result codes of the licensor functions.
enum {
    SLResultOK = 0,
    SLResultFailed = 1,
    SLResultInvalidData = 2,
    SLResultNoLicensor = 3,
    SLResultNoLicenseeInfo = 4,
    SLResultAlreadyAttached = 5,
    SLResultBadArgument = 8
};

void SLEnvironmentCleanUp(void);
void *SLEnvironmentGetLicensor(void);
void *SLEnvironmentGetLicenseeInfo(void);
void *SLEnvironmentGetLicense(void);
void SLEnvironmentSetLicensorNoCopy(void *aLicensor, size_t aSize, void *aContext, SLReleaseCallBack aCallBack);
void SLEnvironmentSetLicenseeInfoNoCopy(void *aInfo, size_t aSize, void *aContext, SLReleaseCallBack aCallBack);
void SLEnvironmentSetLicenseNoCopy(void *aLicense, size_t aSize, void *aContext, SLReleaseCallBack aCallBack);

// A string with a length and a pointer into the blob; absent when the pointer is NULL.
typedef struct SLLicenseDescriptor {
    unsigned int version;
    double creationDate;
    double dates[3];
    unsigned int contentSize;
    unsigned int reserved;
    unsigned int codeInfo;
    unsigned int registrationLength;
    const unsigned char *registration;
    unsigned short registrationCRC;
    unsigned int identifierLength;
    const unsigned char *identifier;
    unsigned int typeLength;
    const unsigned char *type;
    unsigned int pathLength;
    const unsigned char *path;
    unsigned int field84;
    const unsigned char *field88;
    unsigned int codeLimit;
    unsigned int field96;
    const unsigned char *field100;
    unsigned int shortVersionLength;
    const unsigned char *shortVersion;
    unsigned int versionLength;
    const unsigned char *version2;
    unsigned int userDataLength;
    const unsigned char *userData;
    unsigned int serialUserDataLength;
    const unsigned char *serialUserData;
    unsigned int bannedLength;
    const unsigned char *banned;
    unsigned int flags;
    const unsigned char *base;
} SLLicenseDescriptor;

typedef struct SLLicense {
    const SLAllocatorContext *allocator;
    SLLicenseDescriptor descriptor;
    void *bytes;
    size_t bytesSize;
    void *releaseContext;
    SLReleaseCallBack releaseCallBack;
} SLLicense;

extern unsigned int SLLicenseDescriptorBytesEncryptedFlag;

int SLLicenseValidateLicense(const unsigned char *aBytes, unsigned int aSize, const char *aKey,
                             SLLicenseDescriptor *aDescriptor);
unsigned int SLLicenseGetBytes(const SLLicenseDescriptor *aDescriptor, const void *aSource, size_t aLength,
                               void *aTarget);
int SLLicenseSerialize(const SLLicense *aLicense, unsigned char *aBytes, unsigned int *aSize);
void SLLicenseDestroy(SLLicense *aLicense);
const char *SLLicenseEncryptKeyForDate(double aDate);

int SLLicenseGetType(const SLLicense *aLicense);
int SLLicenseGetIdentifier(const SLLicense *aLicense, char *aBuffer, unsigned int *aSize);
double SLLicenseGetCreationDate(const SLLicense *aLicense);
unsigned int SLLicenseGetCodeLimit(const SLLicense *aLicense);
int SLLicenseGetCodeInfo(const SLLicense *aLicense);
int SLLicenseGetUserData(const SLLicense *aLicense, void *aBuffer, unsigned int *aSize);
int SLLicenseGetSerialUserData(const SLLicense *aLicense, void *aBuffer, unsigned int *aSize);
int SLLicenseGetApplicationVersion(const SLLicense *aLicense, char *aBuffer, unsigned int *aSize);
int SLLicenseGetApplicationShortVersion(const SLLicense *aLicense, char *aBuffer, unsigned int *aSize);
int SLLicenseGetRegistrationString(const SLLicense *aLicense, char *aBuffer, unsigned int *aSize);
int SLLicenseGetStoragePath(char *aBuffer, unsigned int *aSize);
double SLLicenseGetSystemTime(void);

struct SLBannedIdentifier {
    unsigned int flags;
    unsigned int length;
    const unsigned char *data;
};
int SLLicenseGetBannedIdentifiers(const SLLicenseDescriptor *aDescriptor, int aMode,
                                  struct SLBannedIdentifier *aItems, unsigned int *aCount, int *aTotalLength);
int SLLicenseCompareIdentifiers(const char *aFirst, const char *aSecond);

unsigned int SLDecodeGetBufferSizeForSerialStringLength(unsigned int aLength);
unsigned int SLDecodeSerialString(char *aText, char *aBuffer, unsigned int aBufferSize, const short *aCRC);
unsigned int SLEncodeSerialString(const char *aString, char *aBuffer, unsigned int aBufferSize, unsigned short *aCRC);
int SLValidateEncodedSerialString(const char *aText, short aCRC);

// The licensor data the application ships with, parsed in place; offsets in the blob are turned into pointers.
typedef struct SLLicensorAnalysis {
    unsigned int version;
    unsigned int size;
    double date;
    unsigned int sizeA;
    const unsigned char *baseA;
    const unsigned char *keyBase;
    unsigned int pathCount;
    const unsigned char *pathTable;
    unsigned int typeCount;
    const unsigned char *typeTable;
    unsigned int length11;
    const unsigned char *pointer12;
    unsigned int defaultIndex;
    unsigned int magic;
    unsigned int codeMapCount;
    const unsigned char *codeMapTable;
    double dateB;
    unsigned int sizeB;
    const unsigned char *baseB;
    const unsigned char *keyBaseB;
    unsigned int restrictionCount;
    const unsigned char *restrictions;
    double dateC;
    unsigned int sizeC;
    const unsigned char *baseC;
    const unsigned char *pointerC;
    unsigned int countC;
    const unsigned char *tableC;
    const unsigned char *base;
} SLLicensorAnalysis;

typedef struct SLLicensor {
    const unsigned char *bytes;
    unsigned int size;
    void *releaseContext;
    SLReleaseCallBack releaseCallBack;
    unsigned int rawSerialLength;
    unsigned int groupSize;
    unsigned int groupCount;
    SLLicensorAnalysis analysis;
} SLLicensor;

typedef struct SLLicensorRestriction {
    unsigned int identifierLength;
    const unsigned char *identifier;
    unsigned int serialCount;
    unsigned int serialSize;
    const unsigned char *serials;
} SLLicensorRestriction;

int SLLicensorIsDataConsistent(const unsigned char *aBytes, unsigned int aSize, SLLicensorAnalysis *aAnalysis);
int SLLicensor4444InitializeWithBytesNoCopy(const void *aBytes, unsigned int aSize, void *aContext,
                                             SLReleaseCallBack aCallBack);
int SLLicensor55554InitializeWithBytesNoCopy(const void *aBytes, unsigned int aSize, void *aContext,
                                             SLReleaseCallBack aCallBack);
unsigned int SLLicensorGetLicensePathAtIndex(const SLLicensorAnalysis *aAnalysis, const unsigned char *aKey,
                                             unsigned int aKeyLength, unsigned int aIndex, char *aBuffer,
                                             unsigned int aSize);
unsigned int SLLicensorGetLicenseTypeAtIndex(const SLLicensorAnalysis *aAnalysis, const unsigned char *aKey,
                                             unsigned int aKeyLength, unsigned int aIndex, char *aBuffer,
                                             unsigned int aSize);
int SLLicensorGetRestrictionAtIndex(const SLLicensorAnalysis *aAnalysis, const unsigned char *aKey,
                                    unsigned int aKeyLength, unsigned int aIndex, SLLicensorRestriction *aRestriction);
