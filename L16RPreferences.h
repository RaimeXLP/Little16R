#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#define L16RPreferencesDomain CFSTR("io.github.raimexlp.little16r")
#define L16RShowHomebarKey CFSTR("ShowHomebar")

// Missing or malformed preferences must never opt the user into layout changes.
static inline BOOL L16RHomebarValueIsEnabled(CFPropertyListRef value) {
    return value && CFGetTypeID(value) == CFBooleanGetTypeID() &&
        CFBooleanGetValue((CFBooleanRef)value);
}

static inline BOOL L16RReadShowHomebar(void) {
    CFPreferencesAppSynchronize(L16RPreferencesDomain);
    CFPropertyListRef value = CFPreferencesCopyAppValue(L16RShowHomebarKey,
                                                       L16RPreferencesDomain);
    BOOL enabled = L16RHomebarValueIsEnabled(value);
    if (value) CFRelease(value);
    return enabled;
}
