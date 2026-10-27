#include "CAWeakLinking.h"
#include <dlfcn.h>
#include <stdlib.h>

// NSAddImage and NSLookupSymbolInImage in the original, which are gone;
// dlopen and dlsym do the same.

typedef struct CAWeakBinding {
    const char *image;
    const char *symbol;
    void *fallback;
    void **address;
    void *imageHandle;
    struct CAWeakBinding *next;
} CAWeakBinding;

static CAWeakBinding *CAWeakBindings;

static void CAWeakBind(CAWeakBinding *aBinding)
{
    const char *symbol = aBinding->symbol[0] == '_' ? aBinding->symbol + 1 : aBinding->symbol;
    void *address = NULL;
    if (aBinding->image == NULL)
        address = dlsym(RTLD_DEFAULT, symbol);
    else {
        if (aBinding->imageHandle == NULL)
            aBinding->imageHandle = dlopen(aBinding->image, RTLD_LAZY | RTLD_GLOBAL);
        if (aBinding->imageHandle != NULL)
            address = dlsym(aBinding->imageHandle, symbol);
    }
    if (address == NULL)
        address = aBinding->fallback;
    if (aBinding->address != NULL)
        *aBinding->address = address;
}

static CAWeakBinding *CAWeakRegister(const char *aImage, const char *aSymbol, void *aFallback, void **aAddress)
{
    CAWeakBinding *binding = calloc(1, sizeof(CAWeakBinding));
    if (binding == NULL)
        return NULL;
    binding->image = aImage;
    binding->symbol = aSymbol;
    binding->fallback = aFallback;
    binding->address = aAddress;
    binding->next = CAWeakBindings;
    CAWeakBindings = binding;
    return binding;
}

bool CAWeakRegisterAndBind(const char *aImage, const char *aSymbol, void *aFallback, void **aAddress)
{
    if (aSymbol == NULL || aAddress == NULL)
        return true;
    CAWeakBinding *binding = CAWeakRegister(aImage, aSymbol, aFallback, aAddress);
    if (binding == NULL)
        return true;
    CAWeakBind(binding);
    return false;
}

// Registered to be bound by the next CAWeakLookupAndBind.
bool CAWeakRegisterSubstitution(const char *aImage, const char *aSymbol, void *aFallback, void **aAddress)
{
    if (aSymbol == NULL || aAddress == NULL)
        return true;
    return CAWeakRegister(aImage, aSymbol, aFallback, aAddress) == NULL;
}

void CAWeakLookupAndBind(void)
{
    for (CAWeakBinding *binding = CAWeakBindings; binding != NULL; binding = binding->next)
        CAWeakBind(binding);
}
