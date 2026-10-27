// Marks code that hasn't been translated from the i386 original yet.
// HS_UNTRANSLATED() logs the method the first time it runs, so a session
// shows which missing pieces the app actually reaches.
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
void HSUntranslated(const char *function);
#ifdef __cplusplus
}
#endif

#define HS_UNTRANSLATED() do { \
		static int hs_seen; \
		if (!hs_seen) { hs_seen = 1; HSUntranslated(__PRETTY_FUNCTION__); } \
	} while (0)
