//
//  ViewController.m
//  PBNavigationBarDemo
//
//  Created by Jpache on 2019/4/21.
//  Copyright © 2019 Jpache. All rights reserved.
//

#import "ViewController.h"
#import "DefaultViewController.h"
#import "DifferentViewController.h"
#import "UIViewController+PBNavigationBar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavBarBackgroundImage:nil shadowImage:nil];
    /*
     或者使用系统的设置方法
     [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
     [self.navigationController.navigationBar setShadowImage:nil];
     */
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.backgroundColor = [UIColor redColor];
    button1.frame = CGRectMake(100, 100, 100, 50);
    [button1 setTitle:@"default" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(defaultButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.backgroundColor = [UIColor blueColor];
    button2.frame = CGRectMake(100, 200, 100, 50);
    [button2 setTitle:@"different" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(differentButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}


- (void)defaultButtonAction {
    DefaultViewController *vc = [DefaultViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)differentButtonAction {
    DifferentViewController *vc = [DifferentViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
