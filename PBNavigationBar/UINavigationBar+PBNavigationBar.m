//
//  UINavigationBar+PBNavigationBar.m
//  PBNavigationBar
//
//  Created by Jpache on 2019/4/21.
//  Copyright © 2019 Jpache. All rights reserved.
//

#import "UINavigationBar+PBNavigationBar.h"
#import "PBNavigationBarMarco.h"
#import <objc/runtime.h>

CGFloat const kDefaultColorLayerOpacity = 0.4f;

@interface UINavigationBar (PBMethodSwizzle)

@end

@implementation UINavigationBar (PBMethodSwizzle)

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



@interface UINavigationBar ()

@property (nonatomic, strong) CALayer *barTintColorLayer;

@end

@implementation UINavigationBar (PBNavigationBar)

+ (void)load {
    [self pb_swizzleInstanceMethod:@selector(setBarTintColor:) with:@selector(pb_setBarTintColor:)];
    [self pb_swizzleInstanceMethod:@selector(layoutSubviews) with:@selector(pb_layoutSubviews)];
    [self pb_swizzleInstanceMethod:@selector(setBackgroundImage:forBarMetrics:) with:@selector(pb_setBackgroundImage:forBarMetrics:)];
}

- (void)pb_setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    if (backgroundImage) {
        [self.barTintColorLayer removeFromSuperlayer];
        self.barTintColorLayer = nil;
    }
    [self pb_setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
}

- (void)pb_setBarTintColor:(UIColor *)barTintColor {
    CGFloat red, green, blue, alpha;
    [barTintColor getRed:&red green:&green blue:&blue alpha:&alpha];
    UIColor *clearColor = [UIColor clearColor];
    CGFloat clearRed, clearGreen, clearBlue, clearAlpha;
    [clearColor getRed:&clearRed green:&clearGreen blue:&clearBlue alpha:&clearAlpha];
    
    BOOL isClearColor = (red == clearRed && green == clearGreen && blue == clearBlue && alpha == clearAlpha);
    UIColor *calibratedColor;
    
    if (barTintColor) {
        if (isClearColor || alpha == 0 || !self.translucent) {
            calibratedColor = barTintColor;
        }else {
            calibratedColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.66];
        }
    }else {
        calibratedColor = nil;
    }
    
    [self pb_setBarTintColor:calibratedColor];
    
    if ((red == 1 && green == 1 && blue == 1) || isClearColor || alpha == 0 || !barTintColor || [self backgroundImageForBarMetrics:UIBarMetricsDefault] || !self.translucent) {
        [self.barTintColorLayer removeFromSuperlayer];
        self.barTintColorLayer = nil;
        return;
    }
    
    if (self.barTintColorLayer == nil) {
        self.barTintColorLayer = [CALayer layer];
        self.barTintColorLayer.opacity = kDefaultColorLayerOpacity;
        self.barTintColorLayer.frame = CGRectMake(0, 0 - PB_StatusBarHeight, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + PB_StatusBarHeight);
        [self.layer addSublayer:self.barTintColorLayer];
    }
    
    CGFloat opacity = kDefaultColorLayerOpacity;
    
    CGFloat minVal = MIN(MIN(red, green), blue);
    
    if ([self convertValue:minVal withOpacity:opacity] < 0) {
        opacity = [self minOpacityForValue:minVal];
    }
    
    self.barTintColorLayer.opacity = opacity;
    
    red = [self convertValue:red withOpacity:opacity];
    green = [self convertValue:green withOpacity:opacity];
    blue = [self convertValue:blue withOpacity:opacity];

    red = MAX(MIN(1.0, red), 0);
    green = MAX(MIN(1.0, green), 0);
    blue = MAX(MIN(1.0, blue), 0);
    
    self.barTintColorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:opacity].CGColor;
}

- (void)pb_layoutSubviews {
    [self pb_layoutSubviews];
    if (self.barTintColorLayer) {
        [self.layer insertSublayer:self.barTintColorLayer atIndex:1];
    }
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([NSStringFromClass([obj class]) containsString:@"BarBackground"]) {
            CGRect objFrame = obj.frame;
            objFrame.size.height = PB_TopBarHeight;
            obj.frame = objFrame;
        }
    }];
}

/**
 下面这两个公式分别参考了下面两篇文章算出来的
 https://objccn.io/issue-3-1/
 http://www.cocoachina.com/industry/20131024/7233.html
 */
- (CGFloat)minOpacityForValue:(CGFloat)value {
    return (0.4 - 0.4 * value) / (0.6 * value + 0.4);
}

- (CGFloat)convertValue:(CGFloat)value withOpacity:(CGFloat)opacity {
    return value - (0.6 * value + 0.4) * (1 - opacity);
}

- (CALayer *)barTintColorLayer {
    return objc_getAssociatedObject(self, @selector(barTintColorLayer));
}

- (void)setBarTintColorLayer:(CALayer *)barTintColorLayer {
    objc_setAssociatedObject(self, @selector(barTintColorLayer), barTintColorLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
