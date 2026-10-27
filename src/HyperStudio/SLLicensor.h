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

// The identity of the application the licensor is attached to; the strings follow the structure in one block.
typedef struct SLLicenseeInfo {
    const char *name;
    const char *shortVersion;
    const char *version;
    const char *key;
    void *reserved;
    char *rawSerial;
    char *trialSign;
    char *trialSerial;
} SLLicenseeInfo;

// What a serial decodes to; the encoded form of the serial follows in the same block.
typedef struct SLSerialInfo {
    unsigned int value;
    unsigned int pathIndex;
    unsigned int typeCode;
    unsigned int count;
    unsigned int codeLength;
    const unsigned char *code;
    const char *encoded;
} SLSerialInfo;

typedef struct SLCodeMapItem {
    unsigned int type;
    unsigned int index;
    unsigned int length;
    const unsigned char *data;
} SLCodeMapItem;

typedef struct SLLicenseCheckContext {
    void *context;
    double dates[3];
    int (*isBanned)(void *aContext, const char *aEncoded, unsigned int aValue);
    int (*checkSettings)(void *aContext, int aType, const char *aEncoded, const char *aPath);
} SLLicenseCheckContext;

typedef struct SLLicenseCreationContext {
    void *context;
    double dates[3];
    unsigned int typeLength;
    unsigned int pathLength;
    unsigned int userDataLength;
    unsigned int serialUserDataLength;
    unsigned int (*getType)(void *aContext, char *aBuffer, unsigned int aSize);
    unsigned int (*getPath)(void *aContext, char *aBuffer, unsigned int aSize);
    unsigned int (*getUserData)(void *aContext, void *aBuffer, unsigned int aSize);
    unsigned int (*getSerialUserData)(void *aContext, void *aBuffer, unsigned int aSize);
} SLLicenseCreationContext;

unsigned int SLLicenseTypeCodeToString(int aCode, char *aBuffer, unsigned int aSize);
int SLLicenseTypeStringToCode(const char *aString);
int SLLicenseIsSerialSame(const SLLicense *aLicense, const char *aSerial);
int SLLicenseIsSerialBanned(const SLLicense *aLicense, const char *aSerial);
void SLLicenseMakeIdentifier(const char *aSerial, char *aIdentifier);
int SLLicenseUpdateOtherData(const SLLicense *aLicense, const char *aSerial, unsigned char *aBuffer,
                             unsigned int *aSize);
int SLLicenseGetOldIdentifiers(const SLLicense *aLicense, unsigned int *aBuffer, unsigned int *aSize);
int SLLicenseCreateWithBytesNoCopy(const SLAllocatorContext *aAllocator, const char *aKey, const char *aVersion,
                                   const char *aShortVersion, const char *aTrialSign,
                                   const SLLicenseCheckContext *aContext, const void *aBytes, unsigned int aSize,
                                   void *aReleaseContext, SLReleaseCallBack aReleaseCallBack, SLLicense **aLicense);
int SLLicenseCreateWithSerial(const SLAllocatorContext *aAllocator, const char *aSerial, const char *aSerialString,
                              unsigned int aCodeInfo, unsigned int aCodeLimit, const char *aKey,
                              const char *aVersion, const char *aShortVersion,
                              const SLLicenseCreationContext *aContext, SLLicense **aLicense);

void *SLLicenseStorageCopyBytes(const char *aPath, const char *aInstallPath, size_t *aSize);
int SLLicenseStorageSaveData(const char *aPath, const char *aInstallPath, const void *aBytes, size_t aSize);
int SLLicenseStorageCleanup(const char *aPath, const char *aInstallPath);
void *SLLicenseStorageCopyExternal(const char *aDomain, unsigned int aRevision, const char *aName,
                                   const char *aVersion, const char *aShortVersion, size_t *aSize);
int SLLicenseStorageUpdateExternal(const char *aDomain, unsigned int aRevision, const char *aName,
                                   const char *aVersion, const char *aShortVersion, const void *aBytes,
                                   size_t aSize);
typedef struct SLStorageEnvironment {
    const char *secret;
    const char *key;
    unsigned int revision;
    unsigned int index;
    unsigned int count;
    const char *paths[1];
} SLStorageEnvironment;

int SLLicenseStorageValidateEnvironmentRepresentation(const unsigned char *aBytes, unsigned int aSize,
                                                      const char *aKey, SLStorageEnvironment *aEnvironment,
                                                      unsigned int *aEnvironmentSize);
int SLLicenseStorageGetEnvironmentRepresentationForLicensor(const SLLicensorAnalysis *aAnalysis,
                                                            const char *aSecret, unsigned int aRevision,
                                                            const char *aKey, unsigned int aKeyLength,
                                                            const char *aName, const char *aCurrentPath,
                                                            unsigned char *aBuffer, unsigned int *aSize);

int SLLicensorGetCodeMapItemForKey(const SLLicensorAnalysis *aAnalysis, const char *aEncoded, const char *aKey,
                                   unsigned int aKeyLength, SLCodeMapItem *aItem);
unsigned int SLLicensorGetSerialUserData(const SLLicensorAnalysis *aAnalysis, const char *aEncoded,
                                         unsigned int aValue, const char *aKey, unsigned int aKeyLength,
                                         const unsigned char **aData);
int SLLicensorGetRawSerialString(unsigned int aLength, unsigned int aGroupSize, unsigned int aGroupCount,
                                 const char *aSerial, char *aBuffer, unsigned int aSize);
int SLLicensorMakeFullSerialString(unsigned int aLength, unsigned int aGroupSize, unsigned int aGroupCount,
                                   const char *aRaw, char *aBuffer, unsigned int aSize);
unsigned int SLLicensorGetTrialSign(const SLLicensorAnalysis *aAnalysis, const char *aKey, unsigned int aKeyLength,
                                    char *aBuffer, unsigned int aSize);
int SLLicensorIsRawSerialProbablyTrial(const char *aRaw, const char *aKey, const char *aPrefix);
int SLLicensorMakeRawTrialSerial(unsigned int aLength, unsigned int aGroupSize, unsigned int aGroupCount,
                                 const char *aKey, const char *aPrefix, char *aBuffer, unsigned int aSize);
int SLLicensorFillRawTrialSerial(SLLicenseeInfo *aInfo, unsigned int aLength, unsigned int aGroupSize,
                                 unsigned int aGroupCount);
int SLLicensorCreateSerialInfoWithRawSerial(const SLAllocatorContext *aAllocator, const SLLicensorAnalysis *aAnalysis,
                                            const char *aKey, const char *aRaw, SLSerialInfo **aInfo);
int SLLicensorCreateSerialInfo(const SLAllocatorContext *aAllocator, const char *aSerial, unsigned int aLength,
                               unsigned int aGroupSize, unsigned int aGroupCount,
                               const SLLicensorAnalysis *aAnalysis, const char *aKey, const char *aTrialSerial,
                               char *aRawBuffer, unsigned int aRawSize, SLSerialInfo **aInfo);
int SLLicensorIsSerialBanned(const SLLicensorAnalysis *aAnalysis, const char *aKey, unsigned int aKeyLength,
                             const char *aEncoded, unsigned int aValue);

int SLLicensorAttach(const char *aKey, const char *aName, const char *aShortVersion, const char *aVersion);
void SLLicensorDestroy(void);
int SLLicensorGetLicense(SLLicense **aLicense);
int SLLicensorSetLicense(SLLicense *aLicense);
void SLLicensorDestroyLicense(SLLicense *aLicense);
int SLLicensorGetLicenseInfo(const SLLicense *aLicense, void *aBytes, unsigned int *aSize);
int SLLicensorLoadLicenseInfo(const char *aInstallPath);
int SLLicensorLoadLicenseInfoFromBytesNoCopy(const void *aBytes, unsigned int aSize, void *aContext,
                                             SLReleaseCallBack aCallBack);
int SLLicensorSaveLicenseInfo(const char *aInstallPath);
int SLLicensorCreateLicenseForSerial(const SLAllocatorContext *aAllocator, const char *aSerial, SLLicense **aLicense);
int SLLicensorMakeLicenseForSerial(const char *aSerial, SLLicense **aLicense);
int SLLicensorGetTrialSerial(char *aBuffer, unsigned int *aSize);
int SLLicensorIsTrialLicenseAvailable(void);
int SLLicensorGetStorageEnvironment(unsigned char *aBuffer, unsigned int *aSize);
int SLLicensorCleanupLicenses(const SLLicensorAnalysis *aAnalysis, const char *aInstallPath, const char *aKey,
                              unsigned int aKeyLength, const char *aCurrentPath);
int SLLicensorGenerateIdentifierWithBytes(const void *aBytes, unsigned char aLength, char *aResult, unsigned int *aSize);
