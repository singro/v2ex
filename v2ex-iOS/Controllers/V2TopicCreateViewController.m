//
//  V2TopicCreateViewController.m
//  v2ex-iOS
//
//  Created by Singro on 5/1/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2TopicCreateViewController.h"

#import "SCMetionTextView.h"

#import "MBProgressHUD.h"

static CGFloat kKeyboardHeightDefault = 217.0f;
static CGFloat kTitleHeight           = 55.0f;

@interface V2TopicCreateViewController () <MBProgressHUDDelegate>

@property (nonatomic, strong) SCBarButtonItem  *leftBarItem;
@property (nonatomic, strong) SCBarButtonItem  *doneBarItem;

@property (nonatomic, strong) UIView           *contentPanel;
@property (nonatomic, strong) UITextField      *titleTextField;
@property (nonatomic, strong) UIView           *borderLine1;
@property (nonatomic, strong) SCMetionTextView *contentTextView;
@property (nonatomic, strong) UIView           *titleBorderView;
@property (nonatomic, strong) UIView           *contentBorderView;

@property (nonatomic, strong) MBProgressHUD    *HUD;
@property (nonatomic, strong) NSMutableArray   *notifications;

@end

@implementation V2TopicCreateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.notifications = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self configureNavibarItems];
    [self configureTextViews];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationItem.rightBarButtonItem = nil;
    self.sc_navigationItem.title = @"Create";

    self.view.backgroundColor = kBackgroundColorWhite;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    
    for (NSNotification *notification in _notifications) {
        [[NSNotificationCenter defaultCenter] removeObserver:notification];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.titleTextField becomeFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.titleTextField resignFirstResponder];
    [self.contentTextView resignFirstResponder];
}


#pragma mark - Configure

- (void)configureNavibarItems {
    
    @weakify(self);
    self.leftBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    self.doneBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_done"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.titleTextField resignFirstResponder];
        self.titleTextField.userInteractionEnabled = NO;
        [self.contentTextView resignFirstResponder];
        self.contentTextView.userInteractionEnabled = NO;
        
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
        self.HUD.removeFromSuperViewOnHide = YES;
        [self.view addSubview:self.HUD];
        [self.HUD show:YES];
        
        
        [[V2DataManager manager] topicCreateWithNodeName:self.nodeName title:self.titleTextField.text content:self.contentTextView.text success:^(NSString *message) {
            @strongify(self);
            
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            self.HUD.customView = imageView;
            self.HUD.mode = MBProgressHUDModeCustomView;
            [self.HUD hide:YES afterDelay:0.6];

            [[NSNotificationCenter defaultCenter] postNotificationName:kTopicCreateSuccessNotification object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError *error) {
            @strongify(self);
            
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            self.HUD.customView = imageView;
            self.HUD.mode = MBProgressHUDModeText;
            self.HUD.labelText = @"Failed";
            [self.HUD hide:YES afterDelay:0.6];

            self.titleTextField.userInteractionEnabled = YES;
            self.contentTextView.userInteractionEnabled = YES;
            [self.contentTextView resignFirstResponder];

        }];
        
    }];
    
}

- (void)configureTextViews {
    
    self.contentPanel = [[UIView alloc] init];
    [self.view addSubview:self.contentPanel];

    self.titleTextField = [[UITextField alloc] init];
    self.titleTextField.font = [UIFont systemFontOfSize:17.0f];
    self.titleTextField.returnKeyType = UIReturnKeyNext;
    self.titleTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.titleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.titleTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.titleTextField.placeholder = @"Title";
    [self.contentPanel addSubview:self.titleTextField];
    
    self.contentTextView = [[SCMetionTextView alloc] init];
    self.contentTextView.placeholder = @"Content";
    self.contentTextView.placeholderColor = [UIColor colorWithRed:0.82f green:0.82f blue:0.84f alpha:1.00f];
    self.contentTextView.font = [UIFont systemFontOfSize:17];
    self.contentTextView.returnKeyType = UIReturnKeyDefault;
    self.contentTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.contentTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.contentTextView.contentInsetTop = 10;
    [self.contentPanel addSubview:self.contentTextView];
    
    self.borderLine1 = [[UIView alloc] init];
    self.borderLine1.backgroundColor = kLineColorBlackLight;
    [self.contentPanel addSubview:self.borderLine1];
    
    self.titleBorderView = [[UIView alloc] init];
    self.titleBorderView.userInteractionEnabled = NO;
    self.titleBorderView.layer.cornerRadius = 3.0;
    self.titleBorderView.layer.borderColor = kColorBlue.CGColor;
    self.titleBorderView.layer.borderWidth = 0.5f;
    self.titleBorderView.alpha = 0.0;
    [self.contentPanel addSubview:self.titleBorderView];

    self.contentBorderView = [[UIView alloc] init];
    self.contentBorderView.userInteractionEnabled = NO;
    self.contentBorderView.layer.cornerRadius = 3.0;
    self.contentBorderView.layer.borderColor = kColorBlue.CGColor;
    self.contentBorderView.layer.borderWidth = 0.5;
    self.contentBorderView.alpha = 0.0;
    [self.contentPanel addSubview:self.contentBorderView];
    
    // layout
    
    self.contentPanel.frame = (CGRect){0, 0 + UIView.sc_navigationBarHeight, kScreenWidth, kScreenHeight - kKeyboardHeightDefault - UIView.sc_navigationBarHeight};
    self.titleTextField.frame = (CGRect){12, 0, kScreenWidth - 24, kTitleHeight};
    self.contentTextView.frame = (CGRect){8, kTitleHeight, kScreenWidth - 16, 0};
    self.contentTextView.height = self.contentPanel.height - kTitleHeight - 10;
    self.borderLine1.frame = (CGRect){0, kTitleHeight, kScreenWidth, 0.5};
    self.titleBorderView.frame = (CGRect){8, 10, kScreenWidth - 16, kTitleHeight - 20};
    self.contentBorderView.frame = (CGRect){8, kTitleHeight + 10, kScreenWidth - 16, 0};
    self.contentBorderView.height = self.contentPanel.height - kTitleHeight - 30;
    
    // Handles
    @weakify(self);
    // TitleTextField
    id<NSObject> notification = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        @strongify(self);
        
        if (self.titleTextField.text.length > 0 && self.contentTextView.text.length > 0) {
            self.sc_navigationItem.rightBarButtonItem = self.doneBarItem;
        } else {
            self.sc_navigationItem.rightBarButtonItem = nil;
        }

    }];
    [self.notifications addObject:notification];
    
    [self.titleTextField setBk_didBeginEditingBlock:^void(UITextField *textField) {
        @strongify(self);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.titleBorderView.alpha = 0.3;
        }];
        
    }];
    
    [self.titleTextField setBk_didEndEditingBlock:^void(UITextField *textField) {
        @strongify(self);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.titleBorderView.alpha = 0.0;
        }];
        
    }];
    
    [self.titleTextField setBk_shouldReturnBlock:^BOOL(UITextField *text) {
        @strongify(self);
        
        [self.contentTextView becomeFirstResponder];
        
        return YES;
    }];

    // ContentTextView
    [self.contentTextView setTextViewDidChangeBlock:^(UITextView *textView) {
        @strongify(self);
        
        if (self.titleTextField.text.length > 0 && self.contentTextView.text.length > 0) {
            self.sc_navigationItem.rightBarButtonItem = self.doneBarItem;
        } else {
            self.sc_navigationItem.rightBarButtonItem = nil;
        }

    }];
    
    [self.contentTextView setTextViewShouldBeginEditingBlock:^BOOL(UITextView *textView) {
        @strongify(self);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.contentBorderView.alpha = 0.3;
        }];
        
        return YES;
    }];
    
//#warning textView endEditing
    
//    [self.contentTextView setTextViewDidEndEditingBlock:^(UITextView *textView) {
//        @strongify(self);
//        
//        [UIView animateWithDuration:0.2 animations:^{
//            self.contentBorderView.alpha = 0.0;
//        }];
//        
//    }];

}

@end
