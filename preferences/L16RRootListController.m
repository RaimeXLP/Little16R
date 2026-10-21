#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "../L16RPreferences.h"
#include <dlfcn.h>

// Only the interfaces used here; no third-party implementation is imported.
@interface SBSRelaunchAction : NSObject
+ (instancetype)actionWithReason:(NSString *)reason options:(NSUInteger)options targetURL:(NSURL *)url;
@end
@interface FBSSystemService : NSObject
+ (instancetype)sharedService;
- (void)sendActions:(NSSet *)actions withResult:(id)result;
@end

@interface L16RRootListController : PSListController
@end

@implementation L16RRootListController
- (NSArray *)specifiers {
    if (!_specifiers) _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    (void)specifier;
    return @(L16RReadShowHomebar());
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    (void)specifier;
    CFPreferencesSetAppValue(L16RShowHomebarKey,
        [value boolValue] ? kCFBooleanTrue : kCFBooleanFalse, L16RPreferencesDomain);
    if (!CFPreferencesAppSynchronize(L16RPreferencesDomain)) {
        [self showError:@"Die Einstellung konnte nicht gespeichert werden. Bitte erneut versuchen."];
        [self reloadSpecifiers];
    }
}

- (void)showError:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Little16R"
        message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)applySettings {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Änderungen übernehmen?"
        message:@"SpringBoard wird neu gestartet. Speichere vorher offene Arbeiten. Falls eine App danach noch falsche Abstände hat, schließe sie im App-Wechsler und öffne sie erneut."
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Abbrechen" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Respring" style:UIAlertActionStyleDefault
        handler:^(__unused UIAlertAction *action) {
            // Resolve the optional relaunch API at runtime. These frameworks
            // are provided by iOS; they are neither bundled nor linked to SDK stubs.
            dlopen("/System/Library/PrivateFrameworks/FrontBoardServices.framework/FrontBoardServices", RTLD_LAZY);
            dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY);
            Class actionClass = NSClassFromString(@"SBSRelaunchAction");
            Class serviceClass = NSClassFromString(@"FBSSystemService");
            if (![actionClass respondsToSelector:@selector(actionWithReason:options:targetURL:)] ||
                ![serviceClass respondsToSelector:@selector(sharedService)]) {
                [self showError:@"Der Systemaufruf ist nicht verfügbar. Bitte einen Respring über deinen Jailbreak ausführen."];
                return;
            }
            id service = [serviceClass sharedService];
            id relaunch = [actionClass actionWithReason:@"Little16R preferences" options:0 targetURL:nil];
            if (!relaunch || ![service respondsToSelector:@selector(sendActions:withResult:)]) {
                [self showError:@"Der Systemaufruf ist nicht verfügbar. Bitte einen Respring über deinen Jailbreak ausführen."];
                return;
            }
            [service sendActions:[NSSet setWithObject:relaunch] withResult:nil];
        }]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
