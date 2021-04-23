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

////Enable: Auto call lazyDismissAnimated:NO when viewController's viewDidDisappear
//@property (nonatomic, readwrite) BOOL kwAutoRemoveLazyWindow;
@property (nonatomic, readwrite) NSInteger tag;

//Linked: Call linkedViewController's viewWillDisappear/viewDidDisappear in viewController's viewWillAppear/viewDidAppear, and vice versa.
- (void)kw_checkLifeCycleLinkingStatus:(void (^)(BOOL granted, UIViewController *linkedViewController))completion;
- (void)kw_linkLifeCycleWith:(UIViewController *)viewController;
- (void)kw_unlinkLifeCycle;

- (void)lazyPresent;

- (void)lazyPresentAnimated:(BOOL)animated;

- (void)lazyPresentAnimated:(BOOL)animated
                 completion:(void (^ __nullable)(void))completion;

- (void)lazyPresentAnimated:(BOOL)animated
                  alertType:(KWLazyPresentType)alertType
                 completion:(void (^ __nullable)(void))completion;

//- (void)lazyDismiss;
//
//- (void)lazyDismissAnimated:(BOOL)animated;
//
//- (void)lazyDismissAnimated:(BOOL)animated
//                 completion:(void (^ __nullable)(void))completion;

- (void)releaseLazyWindow;

- (UIViewController *)kw_viewControllerWithTag:(NSInteger)tag;

- (BOOL)lazyDismissWithTag:(NSInteger)tag animation:(BOOL)animation;
- (BOOL)lazyDismissWithTag:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
