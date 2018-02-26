//
//  V2WeiboViewController.m
//  v2ex-iOS
//
//  Created by Singro on 5/30/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2WeiboViewController.h"

@interface V2WeiboViewController () <UIWebViewDelegate>

@property (nonatomic, strong) SCBarButtonItem *backBarItem;
@property (nonatomic, strong) SCBarButtonItem *actionBarItem;

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation V2WeiboViewController

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
    
    [self configureBarItems];
    [self configureWebView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sc_navigationItem.leftBarButtonItem = self.backBarItem;
    self.sc_navigationItem.title = @"登录微薄";
    self.sc_navigationItem.rightBarButtonItem = self.actionBarItem;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
    
    NSString *userAgentPC = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14";

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.weibo.com"]];
    [request setValue:userAgentPC forHTTPHeaderField:@"User-Agent"];
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configureBarItems {
    
    @weakify(self);
    self.backBarItem = [[SCBarButtonItem alloc] initWithTitle:@"关闭" style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    self.actionBarItem = [[SCBarButtonItem alloc] initWithTitle:@"上传" style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self uploadImage];
    }];
    
}

- (void)configureWebView {
    
    self.webView = [[UIWebView alloc] initWithFrame:(CGRect){0, UIView.sc_navigationBarHeight, kScreenWidth, kScreenHeight - 64}];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
}

#pragma mark - Private Methods

- (void)uploadImage {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *userAgentPC = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14";
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:userAgentPC forHTTPHeaderField:@"User-Agent"];
//    [requestSerializer setValue:@"http://photo.weibo.com/upload/index?from=profile_wb" forHTTPHeaderField:@"Referer"];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer = responseSerializer;
    
    //http://picupload.service.weibo.com/interface/pic_upload.php?&mime=image/jpeg&data=base64&url=0&markpos=1&logo=&nick=0&marks=1&app=miniblog
    [manager POST:@"http://picupload.service.weibo.com/interface/pic_upload.php?rotate=0&app=miniblog&mime=image/jpeg&data=base64&url=0" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Hahu" ofType:@"png"]];
//        data = [data base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
        NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"navi_menu_2"]);
        NSString *encodedString = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        NSData *dataBase64 = [encodedString dataUsingEncoding:NSUTF8StringEncoding];
//        [formData appendPartWithFormData:dataBase64 name:@"b64_data"];
        [formData appendPartWithFileData:dataBase64 name:@"b64_data" fileName:@"image.jpeg" mimeType:@"application/octet-stream"];

    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        NSLog(@"success:\n%@", htmlString);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failed:\n%@", [error description]);
    }];

    
}

#pragma mark - WebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

@end
