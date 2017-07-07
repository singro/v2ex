[![Build Status](https://travis-ci.org/singro/v2ex.svg?branch=master)](https://travis-ci.org/singro/v2ex)

#### 关于
V2EX for iOS


#### 下载

https://itunes.apple.com/us/app/v2ex-chuang-yi-gong-zuo-zhe/id898181535?ls=1&mt=8

#### 截图

![ScreenShoot 1](http://i.v2ex.co/EwnuC7uf.png)

#### 运行

```
pod install
```
若出现 `ld: library not found for -lPods-AFNetworking` 类似的， 设置 `Project` -> `Pods` 的 `Build Active Architecture Only` 为 `NO`

#### 部分独立组件

  * [SCPullRefresh](https://github.com/singro/SCPullRefresh)  
    ```
方便自定义下拉刷新和上拉加载动画
```

  * [SCNavigation](https://github.com/singro/SCNavigation) 
    ```
自定义 Navigation （NavigationBar相关以及NavigationController）所有元素完全自定义，
通过 Pan 手势来完成类似 iOS7 的手势返回效果 。
```

  * [SCWeiboManager](https://github.com/singro/SCWeiboManager) 
    ```
对微博官方 SDK 的 block 封装。 更加易用，配置更简单。
```



#### 说明

1. `发图功能`
  目前通过绑定微博后，发一条带图片的微博到密友来实现。*（更好的方法有待研究）*
  **使用方式**：绑定微博后，在输入界面输入 "&" 调出发图按钮。

2. `现有问题`
  一些细节优化、错误提示、操作限制
 
3.  `接口限制`  由于接口限制，一些功能暂时不做：比如 markdown， 部分 markdown 帖子的图片、链接显示问题等；回复的延时，新回复从接口返回延时比较大，长的可能超过 1 个小时，暂时不做处理，可以通过操作菜单 safari 打开从 web 页面看最新回复

4. `HTTPS` 默认是以 HTTP 访问所有接口，考虑被墙，稍后后更新支持 HTTPS 切换的版本到 App Store
    

#### 已知的 bug
* ~~话题内容过长时微信分享失败 [1.0.0]~~
* ~~连续回复时，第二次回复失败 [1.0.0]~~
* 某几个帖子点开 Crash [1.0.0]

#### LICENSE
MIT

#### 捐赠
支付宝（singroapp#gmail.com）：

![donate](http://i.v2ex.co/2O0eZEc9b.png)
