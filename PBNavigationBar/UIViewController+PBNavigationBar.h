//
//  UIViewController+PBNavigationBar.h
//  PBNavigationBar
//
//  Created by Jpache on 2019/4/21.
//  Copyright © 2019 Jpache. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PBNavigationBar)
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
/**
 self.navigationController.isNavigationBarHidden;
 */
@property (nonatomic, assign, readonly) BOOL hiddenNavBar;
/**
 特殊处理的页面用的假 navBar
 */
@property (nonatomic, strong, readonly) UINavigationBar *fakeNavBar;
/**
 返回当前页面是否需要不同风格的 NavBar 处理
 */
- (BOOL)useDifferentNavigationBar;

@end




@interface UIViewController (PBNavBarImage)

/**
 正常的 nav 不需要调用此方法处理, 需要透明 nav 处理时, 传 [UIImage new], 传 nil 是正常状态

 @param backgroundImage navBar的背景图片
 @param shadowImage navBar下面一像素的阴影
 */
- (void)setNavBarBackgroundImage:(UIImage *)backgroundImage shadowImage:(UIImage *)shadowImage;

@end
