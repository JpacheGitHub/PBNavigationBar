//
//  PBNavigationBarMarco.h
//  PBNavigationBar
//
//  Created by Jpache on 2019/4/21.
//  Copyright © 2019 Jpache. All rights reserved.
//

#ifndef PBNavigationBarMarco_h
#define PBNavigationBarMarco_h

#define PB_StatusBarHeight           ([UIApplication sharedApplication].isStatusBarHidden ? ((PB_iPhoneX || PB_iPhoneXR || PB_iPhoneXSMax) ? 44.0 : 20.0) : [[UIApplication sharedApplication] statusBarFrame].size.height)
#define PB_NavigationBarHeight       44.0
#define PB_TopBarHeight              (PB_NavigationBarHeight + PB_StatusBarHeight)
#define PB_TopBarSafeAreaHeight      (PB_TopBarHeight - 64.f)


// 机型
// iPhone4, iPhone4s
#define PB_iPhone4 \
([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
// iPhone5, iPhone5s, iPhone5c
#define PB_iPhone5 \
([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
// iPhone6, iPhone6s
#define PB_iPhone6 \
([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
// iPhone6Plus, iPhone6sPlus
#define PB_iPhone6Plus \
([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
(CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) \
|| \
CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
// iPhone X, iPhone XS
#define PB_iPhoneX \
([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
// iPhone XR
#define PB_iPhoneXR \
([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
// iPhone XS Max
#define PB_iPhoneXSMax \
([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

#endif /* PBNavigationBarMarco_h */
