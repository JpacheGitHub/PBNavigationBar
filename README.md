# PBNavigationBar

PBNavigationBar 可以让你的 App 的 UINavigationBar 具有完美的转场动画, 完全使用 Category 实现, 不会对你的业务代码造成入侵, 你可以完全无感知的使用它, 只需要像往常一样在 `- viewWillAppear:` 中设置你想要的 UINavigationBar 样式.

<!--more-->

## 使用CocoaPods安装

```bash
target 'TargetName' do
	pod 'PBNavigationBar'
end
```

## 使用

当你前后两级页面的 UINavigationBar 颜色不一样的时候, 你可以像往常一样设置颜色:

```bash

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

```

然后在 UIViewController 中写入下面的方法, 并返回 YES, 就可以获得这种完美的 UINavigationBar 转场动画.

```bash

- (BOOL)useDifferentNavigationBar {
    return YES;
}

```

当只需要使用系统默认的转场方式的时候, 什么都不需要做, 也不需要在 `- useDifferentNavigationBar` 中返回 NO, 因为它默认就是返回 NO 的.


## 效果



如果 App 对 UINavigationBar 的处理不到位, 一些时候它的转场动画会很丑, 比如从有颜色的返回到白色的时候, UINavigationBar 会突然变成白色, 完全没有动画过度效果可言, 看了很多 App 和网上的很多`"一次性解决 UINavigationBar 所有问题"`类似的文章之后仍然没有找到很好的解决方案, 便想到了细节做足的微信, 之前有注意到微信的红包和web页返回的时候会让人看得很舒服, 然后就开始了寻找方案之路...

先来看一下微信在返回时 UINavigationBar 的两种返回状态

这种是正常的返回动画:

![](http://ww1.sinaimg.cn/large/af15588cgy1g0adug3542g20cg0qokjl.gif)

这种是红包, web页面等需要特殊处理的页面的返回动画(这个特殊处理就要看自身的业务需求了):

![特殊处理](http://ww1.sinaimg.cn/large/af15588cgy1g0adugbpi9g20cg0qoe82.gif)

尝试了各种方法之后, 终于实现了类似的效果

简单说一下效果, 就是正常返回保持不变, 需要处理的返回, 返回时, 上下两个页面的 UINavigationBar 分别附着在各自的页面上, 但只是背景颜色和图片, 对于 UIBarButtonItem, 还在原来的位置不动, 只是进行系统那种透明度的转变来达到消失和出现.


下面是使用PBNavigationBar之后的效果

![](http://ww1.sinaimg.cn/large/af15588cgy1g0ak42u7l7g20cg0qo7wh.gif)
