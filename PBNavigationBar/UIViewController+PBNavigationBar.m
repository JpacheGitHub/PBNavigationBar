//
//  UIViewController+PBNavigationBar.m
//  PBNavigationBar
//
//  Created by Jpache on 2019/4/21.
//  Copyright © 2019 Jpache. All rights reserved.
//

#import "UIViewController+PBNavigationBar.h"
#import <objc/runtime.h>
#import <objc/message.h>
#include <execinfo.h>
#import "UINavigationController+PBNavigationBar.h"
#import "UINavigationBar+PBNavigationBar.h"
#import "PBNavigationBarMarco.h"



NSString *const DifferentNavBarFakeSubClassPrefix = @"PB_DifferentNavBar_";

@interface UIViewController (PBMethodSwizzle)

@end

@implementation UIViewController (PBMethodSwizzle)

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




@interface UIViewController ()

/**
 self.navigationController.navigationBar.translucent;
 */
@property (nonatomic, assign) BOOL appearanceBarTranslucent;
/**
 [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
 */
@property (nonatomic, strong) UIImage *navBarBackgroundImage;
/**
 self.navigationController.navigationBar.shadowImage;
 */
@property (nonatomic, strong) UIImage *navBarShadowImage;
/**
 self.navigationController.navigationBar.barTintColor;
 */
@property (nonatomic, assign) UIColor *navBarTintColor;
/**
 self.navigationController.navigationBar.barStyle;
 */
@property (nonatomic, assign) UIBarStyle navBarStyle;
/**
 self.navigationController.navigationBar.alpha;
 */
@property (nonatomic, assign) CGFloat navBarAlpha;
/**
 self.navigationController.isNavigationBarHidden;
 */
@property (nonatomic, assign) BOOL hiddenNavBar;




@property (nonatomic, strong) UINavigationBar *fakeNavBar;
@property (nonatomic, assign) BOOL isRecordNavBarAttribute;
@property (nonatomic, copy) NSString *originalClass;

@end

@implementation UIViewController (PBNavigationBar)

+ (void)load {
    [self pb_swizzleInstanceMethod:@selector(pb_differentNavBar_viewWillAppear:) with:@selector(viewWillAppear:)];
    [self pb_swizzleInstanceMethod:@selector(pb_differentNavBar_viewDidAppear:) with:@selector(viewDidAppear:)];
    [self pb_swizzleInstanceMethod:@selector(pb_differentNavBar_viewWillDisappear:) with:@selector(viewWillDisappear:)];
    [self pb_swizzleInstanceMethod:@selector(pb_differentNavBar_viewDidDisappear:) with:@selector(viewDidDisappear:)];
    [self pb_swizzleInstanceMethod:@selector(pb_differentNavBar_viewDidLoad) with:@selector(viewDidLoad)];
}

- (BOOL)useDifferentNavigationBar {
    return NO;
}

- (void)pb_differentNavBar_viewDidLoad {
    [self pb_differentNavBar_viewDidLoad];
    self.originalClass = NSStringFromClass([self class]);
    
    if (![NSStringFromClass([self class]) hasPrefix:@"UI"] &&
        ![NSStringFromClass([self class]) hasPrefix:@"AV"] &&
        ![self.originalClass hasPrefix:DifferentNavBarFakeSubClassPrefix] &&
        (!self.parentViewController || [self.parentViewController isKindOfClass:[UINavigationController class]] || [self.parentViewController isKindOfClass:[UITabBarController class]]) &&
        ![self isKindOfClass:[UINavigationController class]] &&
        ![self isKindOfClass:[UITabBarController class]]) {
        
        NSString *fakeSubClassString = [NSString stringWithFormat:@"%@%@", DifferentNavBarFakeSubClassPrefix, self.originalClass];
        Class fakeSubClass = NSClassFromString(fakeSubClassString);
        if (fakeSubClass == nil) {
            fakeSubClass = objc_allocateClassPair([self class], [fakeSubClassString UTF8String], 0);
            objc_registerClassPair(fakeSubClass);
        }
        
        object_setClass(self, fakeSubClass);
        
        [fakeSubClass pb_swizzleInstanceMethod:@selector(viewWillAppear:) with:@selector(pb_differentNavBar_fake_viewWillAppear:)];
        [fakeSubClass pb_swizzleInstanceMethod:@selector(pb_differentNavBar_fake_class) with:@selector(class)];
    }
}

- (Class)pb_differentNavBar_fake_class {
    Class fakeClass = [self pb_differentNavBar_fake_class];
    if ([NSStringFromClass(fakeClass) isEqualToString:[NSString stringWithFormat:@"%@%@", DifferentNavBarFakeSubClassPrefix, self.originalClass]]) {
        return NSClassFromString(self.originalClass);
    }else {
        if ([NSStringFromClass(fakeClass) containsString:DifferentNavBarFakeSubClassPrefix] && ![NSStringFromClass(fakeClass) hasPrefix:DifferentNavBarFakeSubClassPrefix]) {
            return NSClassFromString([NSString stringWithFormat:@"%@%@", DifferentNavBarFakeSubClassPrefix, self.originalClass]);
        }else {
            return fakeClass;
        }
    }
}

- (void)pb_differentNavBar_fake_viewWillAppear:(BOOL)animated {
    Class fakeClass = [self pb_differentNavBar_fake_class];
    if ([NSStringFromClass(fakeClass) containsString:DifferentNavBarFakeSubClassPrefix] && ![NSStringFromClass(fakeClass) hasPrefix:DifferentNavBarFakeSubClassPrefix]) {
        fakeClass = NSClassFromString([NSString stringWithFormat:@"%@%@", DifferentNavBarFakeSubClassPrefix, self.originalClass]);
    }
    
    struct objc_super sup = {
        .receiver = self,
        .super_class = class_getSuperclass(fakeClass)
    };
    void(*func)(struct objc_super*,SEL) = (void*)&objc_msgSendSuper;
    func(&sup, _cmd); // 等同于[super viewWillAppear:]
    
    
    if (!self.isRecordNavBarAttribute) {
        self.isRecordNavBarAttribute = YES;
        self.appearanceBarTranslucent = self.navigationController.navigationBar.translucent;
        self.navBarBackgroundImage = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        self.navBarShadowImage = self.navigationController.navigationBar.shadowImage;
        self.navBarTintColor = self.navigationController.navigationBar.barTintColor;
        self.navBarStyle = self.navigationController.navigationBar.barStyle;
        self.hiddenNavBar = self.navigationController.isNavigationBarHidden;
        self.navBarAlpha = self.navigationController.navigationBar.alpha;
    }
    
    [self removeFakeNavBar];
    if (self.navigationController.needAddFakeNavigationBar && self.parentViewController && ([self.parentViewController isKindOfClass:[UINavigationController class]] || [self.parentViewController isKindOfClass:[UITabBarController class]])) {
        [self setNavBarBackgroundImage:[UIImage new] shadowImage:[UIImage new]];
        if (self.navigationController.navigationBar.subviews.count) {
            self.navigationController.navigationBar.subviews[0].alpha = 0;
        }
        
        [self addFakeNavBar];
    }
    
    if ([NSStringFromClass(fakeClass) hasPrefix:DifferentNavBarFakeSubClassPrefix]) {
        Class originalClass = NSClassFromString([NSStringFromClass(fakeClass) substringFromIndex:DifferentNavBarFakeSubClassPrefix.length]);
        object_setClass(self, originalClass);
        objc_disposeClassPair(fakeClass);
    }
}

- (void)pb_differentNavBar_viewWillAppear:(BOOL)animated {
    [self pb_differentNavBar_viewWillAppear:animated];
    
    if ([self judgeNeedHandleWindow]) {
        
        self.navigationController.navigationBar.userInteractionEnabled = NO;
    }
    
    if (self.isRecordNavBarAttribute) {
        [self removeFakeNavBar];
        if (self.navigationController.needAddFakeNavigationBar && self.parentViewController && ([self.parentViewController isKindOfClass:[UINavigationController class]] || [self.parentViewController isKindOfClass:[UITabBarController class]])) {
            [self setNavBarBackgroundImage:[UIImage new] shadowImage:[UIImage new]];
            if (self.navigationController.navigationBar.subviews.count) {
                self.navigationController.navigationBar.subviews[0].alpha = 0;
            }
            
            [self addFakeNavBar];
        }
    }
}

- (void)pb_differentNavBar_viewDidAppear:(BOOL)animated {
    [self pb_differentNavBar_viewDidAppear:animated];
    
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [self removeFakeNavBar];
    if (self.navigationController.needAddFakeNavigationBar && self.parentViewController && ([self.parentViewController isKindOfClass:[UINavigationController class]] || [self.parentViewController isKindOfClass:[UITabBarController class]])) {
        self.navigationController.navigationBar.translucent = self.appearanceBarTranslucent;
        [self setNavBarBackgroundImage:self.navBarBackgroundImage shadowImage:self.navBarShadowImage];
        self.navigationController.navigationBar.barTintColor = self.navBarTintColor;
        self.navigationController.navigationBar.barStyle = self.navBarStyle;
        self.navigationController.navigationBar.alpha = self.navBarAlpha;
    }
    if (self.navigationController.navigationBar.subviews.count) {
        self.navigationController.navigationBar.subviews[0].alpha = 1;
    }
}

- (void)pb_differentNavBar_viewWillDisappear:(BOOL)animated {
    [self pb_differentNavBar_viewWillDisappear:animated];
    
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    [self removeFakeNavBar];
    if (self.navigationController.needAddFakeNavigationBar && self.parentViewController && ([self.parentViewController isKindOfClass:[UINavigationController class]] || [self.parentViewController isKindOfClass:[UITabBarController class]])) {
        
        [self addFakeNavBar];
    }
}

- (void)pb_differentNavBar_viewDidDisappear:(BOOL)animated {
    [self pb_differentNavBar_viewDidDisappear:animated];
    
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [self removeFakeNavBar];
    if (self.navigationController.navigationBar.subviews.count) {
        self.navigationController.navigationBar.subviews[0].alpha = 1;
    }
}

#pragma mark - Private

- (BOOL)judgeNeedHandleWindow {
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    
    if ([NSStringFromClass(window.class) isEqualToString:@"UIRemoteKeyboardWindow"] || [NSStringFromClass(window.class) isEqualToString:@"UITextEffectsWindow"] || window.windowLevel == 0) return YES;
    
    return NO;
}

- (void)addFakeNavBar {
    if (self.hiddenNavBar) {
        return;
    }
    
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    NSString *callerMethodName = [[array objectAtIndex:4] componentsSeparatedByString:@"_"].lastObject;
    BOOL isViewWillAppear = [callerMethodName isEqualToString:@"viewWillAppear:"];
    
    CGFloat navigationBarTop = 0;
    if (isViewWillAppear) {
        self.navigationController.navigationBar.showFakeNavBar = YES;
    }else {
        navigationBarTop = -PB_TopBarHeight;
    }
    
    if (self.appearanceBarTranslucent) {
        navigationBarTop = 0;
    }
    
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.view;
        CGPoint currentOffset = scrollView.contentOffset;
        [scrollView setContentOffset:currentOffset animated:NO];
        self.view.layer.masksToBounds = NO;
        navigationBarTop += currentOffset.y;
        
        if (@available(iOS 11.0, *)) {
            if (scrollView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
                if (isViewWillAppear && !scrollView.safeAreaInsets.top) {
                    navigationBarTop -= PB_TopBarHeight;
                }
            }
        }else {
            if (self.automaticallyAdjustsScrollViewInsets == YES) {
                if (isViewWillAppear) {
                    navigationBarTop -= PB_TopBarHeight;
                }
            }
        }
    }
    
    
    self.fakeNavBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, navigationBarTop, UIScreen.mainScreen.bounds.size.width, PB_TopBarHeight)];
    self.fakeNavBar.shadowImage = self.navBarShadowImage;
    [self.fakeNavBar setBackgroundImage:self.navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    self.fakeNavBar.barTintColor = self.navBarTintColor;
    self.fakeNavBar.translucent = self.appearanceBarTranslucent;
    self.fakeNavBar.alpha = self.navBarAlpha;
    
    [self.view addSubview:self.fakeNavBar];
}

- (void)removeFakeNavBar {
    self.navigationController.navigationBar.showFakeNavBar = NO;
    
    if ([self.view isKindOfClass:[UIScrollView class]]) {
        self.view.layer.masksToBounds = NO;
    }
    
    if (self.fakeNavBar) {
        [self.fakeNavBar removeFromSuperview];
        self.fakeNavBar = nil;
    }
}



#pragma mark - Getter, Setter

- (UINavigationBar *)fakeNavBar {
    return objc_getAssociatedObject(self, @selector(fakeNavBar));
}

- (void)setFakeNavBar:(UINavigationBar *)fakeNavBar {
    objc_setAssociatedObject(self, @selector(fakeNavBar), fakeNavBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isRecordNavBarAttribute {
    return [objc_getAssociatedObject(self, @selector(isRecordNavBarAttribute)) boolValue];
}

- (void)setIsRecordNavBarAttribute:(BOOL)isRecordNavBarAttribute {
    objc_setAssociatedObject(self, @selector(isRecordNavBarAttribute), @(isRecordNavBarAttribute), OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *)originalClass {
    return objc_getAssociatedObject(self, @selector(originalClass));
}

- (void)setOriginalClass:(NSString *)originalClass {
    objc_setAssociatedObject(self, @selector(originalClass), originalClass, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)appearanceBarTranslucent {
    return [objc_getAssociatedObject(self, @selector(appearanceBarTranslucent)) boolValue];
}

- (void)setAppearanceBarTranslucent:(BOOL)appearanceBarTranslucent {
    objc_setAssociatedObject(self, @selector(appearanceBarTranslucent), @(appearanceBarTranslucent), OBJC_ASSOCIATION_ASSIGN);
}

- (UIImage *)navBarBackgroundImage {
    return objc_getAssociatedObject(self, @selector(navBarBackgroundImage));
}

- (void)setNavBarBackgroundImage:(UIImage *)navBarBackgroundImage {
    objc_setAssociatedObject(self, @selector(navBarBackgroundImage), navBarBackgroundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)navBarShadowImage {
    return objc_getAssociatedObject(self, @selector(navBarShadowImage));
}

- (void)setNavBarShadowImage:(UIImage *)navBarShadowImage {
    objc_setAssociatedObject(self, @selector(navBarShadowImage), navBarShadowImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)navBarTintColor {
    return objc_getAssociatedObject(self, @selector(navBarTintColor));
}

- (void)setNavBarTintColor:(UIColor *)navBarTintColor {
    objc_setAssociatedObject(self, @selector(navBarTintColor), navBarTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIBarStyle)navBarStyle {
    NSNumber *value = objc_getAssociatedObject(self, @selector(navBarStyle));
    UIBarStyle style;
    [value getValue:&style];
    return style;
}

- (void)setNavBarStyle:(UIBarStyle)navBarStyle {
    objc_setAssociatedObject(self, @selector(navBarStyle), @(navBarStyle), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)hiddenNavBar {
    return [objc_getAssociatedObject(self, @selector(hiddenNavBar)) boolValue];
}

- (void)setHiddenNavBar:(BOOL)hiddenNavBar {
    objc_setAssociatedObject(self, @selector(hiddenNavBar), @(hiddenNavBar), OBJC_ASSOCIATION_ASSIGN);
}

- (CGFloat)navBarAlpha {
    return [objc_getAssociatedObject(self, @selector(navBarAlpha)) floatValue];
}

- (void)setNavBarAlpha:(CGFloat)navBarAlpha {
    objc_setAssociatedObject(self, @selector(navBarAlpha), [NSNumber numberWithFloat:navBarAlpha], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



@end


@implementation UIViewController (NavBarImage)

- (void)setNavBarBackgroundImage:(UIImage *)backgroundImage shadowImage:(UIImage *)shadowImage {
    if (self.parentViewController && ([self.parentViewController isKindOfClass:[UINavigationController class]] || [self.parentViewController isKindOfClass:[UITabBarController class]])) {
        [self.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:shadowImage];
    }
}

@end
