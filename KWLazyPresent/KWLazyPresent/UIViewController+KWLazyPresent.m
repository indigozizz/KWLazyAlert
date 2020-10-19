//
//  UIViewController+KWLazyPresent.m
//  KWLazyPresent
//
//  Created by Kawa on 2020/10/13.
//

/*
 [Show AlertController in NEW Windows]
 Reference: https://stackoverflow.com/questions/26554894/how-to-present-uialertcontroller-when-not-in-a-view-controller
*/

#import "UIViewController+KWLazyPresent.h"

#import "KWWindow.h"
#import <objc/runtime.h>

#define KWWindowLevelNotification (UIWindowLevelAlert - 1)

@interface UIViewController (Private)

@property (nonatomic, strong) KWWindow *kwPresentWindow;

@end

@implementation UIViewController (Private)

@dynamic kwPresentWindow;

- (void)setKwPresentWindow:(UIWindow *)alertWindow {
    objc_setAssociatedObject(self, @selector(kwPresentWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)kwPresentWindow {
    return objc_getAssociatedObject(self, @selector(kwPresentWindow));
}

@end

@implementation UIViewController (KWLazyPresent)

//MARK: - Lazy Present
- (void)lazyPresent {
    [self lazyPresentAnimated:YES];
}

- (void)lazyPresentAnimated:(BOOL)animated {
    [self lazyPresentAnimated:animated
                   completion:nil];
}

- (void)lazyPresentAnimated:(BOOL)animated
                 completion:(void (^ __nullable)(void))completion {
    [self lazyPresentAnimated:animated
                    alertType:KWLazyPresentDefaultStyle
                   completion:completion];
}

- (void)lazyPresentAnimated:(BOOL)animated
                  alertType:(KWLazyPresentType)alertType
                 completion:(void (^ __nullable)(void))completion {
    
    UIWindow *window;
    
    if (@available(iOS 13, *)) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"activationState == %ld", UISceneActivationStateForegroundActive];
        
        UIWindowScene *windowScene = (UIWindowScene *)[[UIApplication sharedApplication].connectedScenes filteredSetUsingPredicate:predicate].allObjects.firstObject;
        
        if (windowScene != nil) {
            window = windowScene.windows.firstObject;
            
            self.kwPresentWindow = [[KWWindow alloc] initWithWindowScene:windowScene];
            self.kwPresentWindow.frame = UIScreen.mainScreen.bounds;
        }
        
    }
    
    if (self.kwPresentWindow == nil) {
        self.kwPresentWindow = [[KWWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    self.kwPresentWindow.rootViewController = [[UIViewController alloc] init];

    if (window == nil) {
        NSLog(@"Window not found in SceneDelegate");
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    
    if (window == nil) {
        NSLog(@"Window not found in AppDelegate");
    }
    else {
        self.kwPresentWindow.tintColor = window.tintColor;
    }
    

    switch (alertType) {
        case KWLazyPresentInAppNotification:
            self.kwPresentWindow.windowLevel = KWWindowLevelNotification;
            break;
            
        default:
            self.kwPresentWindow.windowLevel = [self kwGetSuitableWindowLevel];
            break;
    }

    [self.kwPresentWindow makeKeyAndVisible];
    [self.kwPresentWindow.rootViewController presentViewController:self animated:animated completion:completion];
}

//MARK: - Lazy Dismiss
- (void)lazyDismiss {
    [self lazyDismissAnimated:YES completion:nil];
}

- (void)lazyDismissAnimated:(BOOL)animated {
    [self lazyDismissAnimated:animated completion:nil];
}

- (void)lazyDismissAnimated:(BOOL)animated
                 completion:(void (^ __nullable)(void))completion {
    
    [self dismissViewControllerAnimated:animated completion:^{
        self.kwPresentWindow.hidden = YES;
        self.kwPresentWindow = nil;
        
        if (completion != nil) {
            completion();
        }
    }];
}

//TODO: Create a InApp Notification Template with KWPassthroughView


//MARK: - kw Utils
- (long)kwGetSuitableWindowLevel {
    // Default Max Window Level
    long windowLevel = KWWindowLevelNotification - 1;
    
    for (UIWindow *window in [[UIApplication sharedApplication].windows reverseObjectEnumerator])
    {
        // Max Window Level should not over  UIWindowLevelAlert
        if (window.windowLevel >= KWWindowLevelNotification - 1) {
            continue;
        }
        windowLevel = window.windowLevel + 1;
    }
    
    return windowLevel;
}

@end
