//
//  V2WebViewController.m
//  v2ex-iOS
//
//  Created by Singro on 8/1/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2WebViewController.h"

#import <RegexKitLite/RegexKitLite.h>

#import "SCActionSheet.h"

@interface V2WebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) SCBarButtonItem *backBarItem;
@property (nonatomic, strong) SCBarButtonItem *actionBarItem;

@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic, strong) SCActionSheet      *actionSheet;

@property (nonatomic, strong) UIView *toolBar;

@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *refreshButton;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;


@end

@implementation V2WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self configureWebView];
    [self configureToolbar];
    [self configureBarItems];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = kBackgroundColorWhite;

    self.sc_navigationItem.leftBarButtonItem = self.backBarItem;
    self.sc_navigationItem.rightBarButtonItem = self.actionBarItem;
    
    if (self.url) {
        NSString *regex1 = @"^[\\s]*|[\\s]*$";
        NSString *urlString = [self.url.absoluteString stringByReplacingOccurrencesOfRegex:regex1 withString:@""];
        NSURL *newUrl = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:newUrl];
        [self.webView loadRequest:request];
        
//        [self.webView loadRequest:request progress:^(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
//            SPLog(@"progress:   %.2f", (CGFloat)bytesWritten/(CGFloat)totalBytesWritten)
//        } success:^NSString *(NSHTTPURLResponse *response, NSString *HTML) {
//            return HTML;
//        } failure:^(NSError *error) {
//            ;
//        }];
        
//        self.sc_navigationItem.title = @"载入中...";
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect rect = self.view.bounds;
    self.webView.frame = (CGRect){0, UIView.sc_navigationBarHeight, kScreenWidth, kScreenHeight - (44 + UIView.sc_bottomInset)};
    
    self.toolBar.frame = CGRectMake(0, rect.size.height - (44 + UIView.sc_bottomInset), rect.size.width, (44 + UIView.sc_bottomInset));
    self.prevButton.frame = CGRectMake(15, 12, 20, 20);
    self.refreshButton.frame = CGRectMake(kScreenWidth/2 - 10, 12, 20, 20);
    self.nextButton.frame = CGRectMake(kScreenWidth - 35, 12, 20, 20);
    
    self.activityIndicatorView.center = self.refreshButton.center;
}

- (void)dealloc {
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    self.webView = nil;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self startLoading];
    [self checkButtonEnabled];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self stopLoading];
    [self checkButtonEnabled];
    
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    self.title = title;
    self.sc_navigationItem.title =title;
    
}

- (void)prevPage:(id)sender {
    [self.webView goBack];
}

- (void)nextPage:(id)sender {
    [self.webView goForward];
}

- (void)refreshPage:(id)sender {
    [self.webView stopLoading];
    [self.webView reload];
}

- (void)setPrevButtonEnabled:(BOOL)enabled {
    self.prevButton.alpha = enabled ? 1.0 : 0.7f;
    self.prevButton.enabled = enabled;
}

- (void)setNextButtonEnabled:(BOOL)enabled {
    self.nextButton.alpha = enabled ? 1.0 : 0.7f;
    self.nextButton.enabled = enabled;
}

- (void)checkButtonEnabled {
    BOOL canback = [self.webView canGoBack];
    BOOL canforworld = [self.webView canGoForward];
    
    [self setPrevButtonEnabled:canback];
    [self setNextButtonEnabled:canforworld];
}

#pragma mark - activityIndicatorView
- (void)startLoading {
    self.refreshButton.hidden = YES;
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)stopLoading {
    self.refreshButton.hidden = NO;
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden  = YES;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}



- (void)configureBarItems {
    
    @weakify(self);
    self.backBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.actionBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_more"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        self.actionSheet  = [[SCActionSheet alloc] sc_initWithTitles:@[@"操作"] customViews:nil buttonTitles:@"复制", @"用 Safari 打开", nil];
        
        [self.actionSheet sc_setButtonHandler:^{
            @strongify(self);
            
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:self.url.absoluteString];
            
        } forIndex:0];
        
        [self.actionSheet sc_setButtonHandler:^{
            @strongify(self);
            
            [[UIApplication sharedApplication] openURL:self.url];
            
        } forIndex:1];
        
        [self.actionSheet sc_show:YES];
        
        
    }];

    
}

- (void)configureWebView {
    
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque=NO;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    UIScrollView *webScrollView = nil;
    for (UIView *v in _webView.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            webScrollView = (UIScrollView *)v;
            break;
        }
    }
    
    if (webScrollView) {
        webScrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, UIView.sc_navigationBarHeight, 0);
    }

}

- (void)configureToolbar {
    self.toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,44)];
    self.toolBar.backgroundColor = kNavigationBarColor;
    
    UIView *topLineView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0.5}];
    topLineView.backgroundColor = kNavigationBarLineColor;
    [self.toolBar addSubview:topLineView];
    
    self.prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.prevButton  setImage:[UIImage imageNamed:@"Browser_Icon_Backward"].imageForCurrentTheme forState:UIControlStateNormal];
    [self.prevButton  addTarget:self action:@selector(prevPage:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton  setImage:[UIImage imageNamed:@"Browser_Icon_Forward"].imageForCurrentTheme forState:UIControlStateNormal];
    [self.nextButton  addTarget:self action:@selector(nextPage:) forControlEvents:UIControlEventTouchUpInside];
    
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.refreshButton  setImage:[UIImage imageNamed:@"Browser_Icon_Refresh"].imageForCurrentTheme forState:UIControlStateNormal];
    [self.refreshButton  addTarget:self action:@selector(refreshPage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.toolBar addSubview:self.prevButton];
    [self.toolBar addSubview:self.nextButton];
    [self.toolBar addSubview:self.refreshButton];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.hidden = YES;
    
    [self.toolBar addSubview:self.activityIndicatorView];
    
    [self.view addSubview:self.toolBar];
}


@end
