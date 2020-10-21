//
//  UIViewController+KWLazyPresent.h
//  KWLazyPresent
//
//  Created by Kawa on 2020/10/13.
//

#import <UIKit/UIKit.h>

#define LazyAlert(fmt, ...) { UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:fmt, ##__VA_ARGS__] preferredStyle:UIAlertControllerStyleAlert]; UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]; [alertController addAction:action];  [alertController lazyPresent]; }

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    
    //WindowLevel is Previous Window Level + 1
    KWLazyPresentDefaultStyle,
    
    //WindowLevel is always UIWindowLevelAlert - 1
    KWLazyPresentInAppNotification
    
} KWLazyPresentType;

@interface UIViewController (KWLazyPresent)

- (void)checkLifeCycleLinkingStatus:(void (^)(BOOL granted, UIViewController *linkedViewController))completion;
- (void)linkLifeCycleWith:(UIViewController *)viewController;
- (void)unlinkLifeCycle;

- (void)lazyPresent;

- (void)lazyPresentAnimated:(BOOL)animated;

- (void)lazyPresentAnimated:(BOOL)animated
                 completion:(void (^ __nullable)(void))completion;

- (void)lazyPresentAnimated:(BOOL)animated
                  alertType:(KWLazyPresentType)alertType
                 completion:(void (^ __nullable)(void))completion;

- (void)lazyDismiss;

- (void)lazyDismissAnimated:(BOOL)animated;

- (void)lazyDismissAnimated:(BOOL)animated
                 completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
