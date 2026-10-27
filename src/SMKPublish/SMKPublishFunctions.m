// Plain C functions of the original binary. The client data provider's map
// table callbacks live with it; what remains is the framework's init hook.
#import "SMKPublishPrefix.h"

static int gSMKPublishInitialized;

void SMKPublishInit(void)
{
    if (gSMKPublishInitialized == 0)
        gSMKPublishInitialized = 1;
}
