//
//  UINavigationController+PBNavigationBar.m
//  PBNavigationBar
//
//  Created by Jpache on 2019/4/21.
//  Copyright © 2019 Jpache. All rights reserved.
//

#import "UINavigationController+PBNavigationBar.h"
#import "UIViewController+PBNavigationBar.h"
#import <objc/runtime.h>

@interface UINavigationController (PBMethodSwizzle)

@end

@implementation UINavigationController (PBMethodSwizzle)

+ (BOOL)pb_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel {
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    Method newMethod = class_getInstanceMethod(self, newSel);
    if (!originalMethod || !newMethod) return NO;
    
    class_addMethod(self,
                    originalSel,
                    class_getMethodImplementation(self, originalSel),
                    method_getTypeEncoding(originalMethod));
    class_addMethod(self,
                    newSel,
                    class_getMethodImplementation(self, newSel),
                    method_getTypeEncoding(newMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, originalSel),
                                   class_getInstanceMethod(self, newSel));
    return YES;
}

@end




@implementation UINavigationController (PBNavigationBar)

+ (void)load {
    [self pb_swizzleInstanceMethod:@selector(pb_differentNavBar_pushViewController:animated:) with:@selector(pushViewController:animated:)];
    [self pb_swizzleInstanceMethod:@selector(pb_differentNavBar_popViewControllerAnimated:) with:@selector(popViewControllerAnimated:)];
    [self pb_swizzleInstanceMethod:@selector(pb_differentNavBar_popToViewController:animated:) with:@selector(popToViewController:animated:)];
    [self pb_swizzleInstanceMethod:@selector(pb_differentNavBar_popToRootViewControllerAnimated:) with:@selector(popToRootViewControllerAnimated:)];
}

- (void)pb_differentNavBar_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *currentVC = self.viewControllers.lastObject;
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    if ((![viewController useDifferentNavigationBar] && ![currentVC useDifferentNavigationBar]) || (viewController.hiddenNavBar || currentVC.hiddenNavBar)) {
        self.needAddFakeNavigationBar = NO;
    } else {
        self.needAddFakeNavigationBar = YES;
    }
    [self pb_differentNavBar_pushViewController:viewController animated:animated];
}

- (UIViewController *)pb_differentNavBar_popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) {
        return [self pb_differentNavBar_popViewControllerAnimated:animated];
    }
    UIViewController *previousVC = self.viewControllers[self.viewControllers.count - 2];
    UIViewController *currentVC = self.viewControllers.lastObject;
    if ((![currentVC useDifferentNavigationBar] && ![previousVC useDifferentNavigationBar]) || (previousVC.hiddenNavBar || currentVC.hiddenNavBar)) {
        self.needAddFakeNavigationBar = NO;
    } else {
        self.needAddFakeNavigationBar = YES;
    }
    
    return [self pb_differentNavBar_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)pb_differentNavBar_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *previousVC = viewController;
    UIViewController *currentVC = self.viewControllers.lastObject;
    if ((![currentVC useDifferentNavigationBar] && ![previousVC useDifferentNavigationBar]) || (previousVC.hiddenNavBar || currentVC.hiddenNavBar)) {
        self.needAddFakeNavigationBar = NO;
    } else {
        self.needAddFakeNavigationBar = YES;
    }
    
    return [self pb_differentNavBar_popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)pb_differentNavBar_popToRootViewControllerAnimated:(BOOL)animated {
    UIViewController *previousVC = self.viewControllers.firstObject;
    UIViewController *currentVC = self.viewControllers.lastObject;
    if ((![currentVC useDifferentNavigationBar] && ![previousVC useDifferentNavigationBar]) || (previousVC.hiddenNavBar || currentVC.hiddenNavBar)) {
        self.needAddFakeNavigationBar = NO;
    } else {
        self.needAddFakeNavigationBar = YES;
    }
    
    return [self pb_differentNavBar_popToRootViewControllerAnimated:animated];
}

- (BOOL)needAddFakeNavigationBar {
    return [objc_getAssociatedObject(self, @selector(needAddFakeNavigationBar)) boolValue];
}

- (void)setNeedAddFakeNavigationBar:(BOOL)needAddFakeNavigationBar {
    objc_setAssociatedObject(self, @selector(needAddFakeNavigationBar), @(needAddFakeNavigationBar), OBJC_ASSOCIATION_ASSIGN);
}

@end
