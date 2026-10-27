// The SS* helpers of the license library: base-64 style text encoding, CRCs, XOR key
// streams, packed user info and unique data strings.
#include <CoreFoundation/CoreFoundation.h>
#include <stdint.h>

unsigned short SSCRC16Digest(const unsigned char *aBytes, unsigned short aLength);

struct SSCRC32Context {
    unsigned int crc;
    unsigned int length;
    const unsigned int *table;
};
void SSCRC32Init(struct SSCRC32Context *aContext);
unsigned int SSCRC32Update(struct SSCRC32Context *aContext, const unsigned char *aBytes, unsigned int aLength);

void SSCopyBit(unsigned char aSource, unsigned char aSourceBit, unsigned char *aTarget, unsigned char aTargetBit);
int SSEncodeBytes(const unsigned char *aBytes, int aLength, char *aText, unsigned int aTextSize);
int SSDecodeBytes(const char *aText, int aLength, unsigned char *aBytes, unsigned int aBytesSize);
void SSEncryptBytesWithKeyAndOffset(const unsigned char *aBytes, int aLength, const unsigned char *aKey,
                                    unsigned int aKeyLength, unsigned int aOffset, unsigned char *aResult);
void SSDecryptBytesWithKey(const unsigned char *aBytes, int aLength, unsigned int aOffset,
                           const unsigned char *aKey, unsigned int aKeyLength, unsigned char *aResult);
int SSExtractCodeBytes(const char *aCode, unsigned int aLength, unsigned char *aBytes);
void SSPackUserInfo(const unsigned char *aInfo, int aLength, unsigned int aValue, unsigned short aCRC,
                    unsigned char *aResult);
void SSUnpackUserInfo(const unsigned char *aPacked, int aLength, unsigned char *aInfo, unsigned int aInfoLength,
                      unsigned int *aValue, unsigned short *aCRC);
int SSDecoderExtractUserBytes(void);
int SSDecoderExtractUserInfo(const char *aCode, int aLength, int aType, unsigned char *aInfo,
                             unsigned int *aInfoLength, unsigned int *aValue);
int SSDecomposeNetworkSignature(char *aSignature, unsigned int aLength, int *aCount);
int SSUDGenerateSecurityCodeWithUniqueDataString(void);
int SSUDValidateSecurityCode(void);
int SSUDGenerateUniqueDataString(const void *aData, unsigned char aDataLength, const char *aString1,
                                 const char *aString2, const char *aString3, const char *aString4,
                                 int aReserved, char *aResult, unsigned int *aResultSize);
int SSUtilityIsPropertyListValid(CFPropertyListRef aList);
CFIndex SSUtilityCreateDataWithPropertyList(CFAllocatorRef aAllocator, CFPropertyListRef aList, CFDataRef *aData);
CFPropertyListRef SSUtilityCreatePropertyListWithBytes(CFAllocatorRef aAllocator, const UInt8 *aBytes, CFIndex aLength);
