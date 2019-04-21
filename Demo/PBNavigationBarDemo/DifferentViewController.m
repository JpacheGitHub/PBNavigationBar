//
//  DifferentViewController.m
//  DifferentNavBarDemo
//
//  Created by zhaimi on 2019/2/18.
//  Copyright © 2019 Jpache. All rights reserved.
//

#import "DifferentViewController.h"
#import "UIViewController+PBNavigationBar.h"

@interface DifferentViewController ()

@end

@implementation DifferentViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavBarBackgroundImage:nil shadowImage:nil];
    /*
     或者使用系统的设置方法
     [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
     [self.navigationController.navigationBar setShadowImage:nil];
     */
    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (BOOL)useDifferentNavigationBar {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
