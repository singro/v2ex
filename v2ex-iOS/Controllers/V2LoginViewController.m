//
//  V2LoginViewController.m
//  v2ex-iOS
//
//  Created by Singro on 4/7/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2LoginViewController.h"

static CGFloat const kContainViewYNormal = 120.0;
static CGFloat const kContainViewYEditing = 60.0;

@interface V2LoginViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIButton    *closeButton;

@property (nonatomic, strong) UIView      *containView;

@property (nonatomic, strong) UILabel     *logoLabel;
@property (nonatomic, strong) UILabel     *descriptionLabel;

@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton    *loginButton;

@property (nonatomic, assign) BOOL isKeyboardShowing;
@property (nonatomic, strong) NSTimer *loginTimer;
@property (nonatomic, assign) BOOL isLogining;

@end

@implementation V2LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.isKeyboardShowing = NO;
        self.isLogining = NO;
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    [super loadView];
    
    [self configureViews];
    [self configureContainerView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    /* iPad有隐藏键盘按钮，没有监听该消息，会导致containView没有恢复 */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                          name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    
    self.backgroundImageView.frame = self.view.frame;
    self.closeButton.frame = (CGRect){10, 20, 44, 44};
    
    self.containView.frame = (CGRect){0, kContainViewYNormal, kScreenWidth, 300};
    self.logoLabel.center = (CGPoint){kScreenWidth/2, 30};
    self.descriptionLabel.frame = (CGRect){20, 60, kScreenWidth - 20,70};
    self.usernameField.frame = (CGRect){60, 150, kScreenWidth - 120, 30};
    self.passwordField.frame = (CGRect){60, 190, kScreenWidth - 120, 30};
    self.loginButton.center = (CGPoint){kScreenWidth/2, 270};
    
}

#pragma mark - Configure Views

- (void)configureViews {
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568_blurred"]];
    self.backgroundImageView.userInteractionEnabled = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.closeButton setTintColor:[UIColor whiteColor]];
    self.closeButton.alpha = 0.5;
    [self.view addSubview:self.closeButton];
    
    self.containView = [[UIView alloc] init];
    [self.view addSubview:self.containView];
    
    self.logoLabel = [[UILabel alloc] init];
    self.logoLabel.text = @"V2EX";
    self.logoLabel.font = [UIFont fontWithName:@"Kailasa" size:36];
    self.logoLabel.textColor = kFontColorBlackDark;
    [self.logoLabel sizeToFit];
    [self.containView addSubview:self.logoLabel];
    
    self.descriptionLabel = [[UILabel alloc] init];
//    self.descriptionLabel.text = @"A community of start-ups, designers, developers and creative people.";
    self.descriptionLabel.text = @"V2EX是创意工作者们的社区";
    self.descriptionLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18];
    self.descriptionLabel.textColor = kFontColorBlackLight;
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [self.containView addSubview:self.descriptionLabel];
    

    
    // Handles
    @weakify(self);
    [self.closeButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.containView bk_whenTapped:^{
        @strongify(self);
        [self hideKeyboard];
    }];
    
    [self.backgroundImageView bk_whenTapped:^{
        @strongify(self);
        
        [self hideKeyboard];
        
    }];
    
}

/* 这个方法不止是设置textfield，还有LoginButton，因此这个方法名不合适 */
- (void)configureContainerView {
//- (void)configureTextField {
    
    self.usernameField = [[UITextField alloc] init];
    self.usernameField.textAlignment = NSTextAlignmentCenter;
    self.usernameField.textColor = kFontColorBlackDark;
    self.usernameField.font = [UIFont systemFontOfSize:18];
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"用户名"
       attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.836 alpha:1.000],
                   NSFontAttributeName:[UIFont italicSystemFontOfSize:18]}];
    self.usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    self.usernameField.returnKeyType = UIReturnKeyNext;
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.usernameField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.containView addSubview:self.usernameField];

    self.passwordField = [[UITextField alloc] init];
    self.passwordField.textAlignment = NSTextAlignmentCenter;
    self.passwordField.textColor = kFontColorBlackDark;
    self.passwordField.font = [UIFont systemFontOfSize:18];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码"        attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.836 alpha:1.000],
                     NSFontAttributeName:[UIFont italicSystemFontOfSize:18]}];
    self.passwordField.secureTextEntry = YES;
    self.passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    self.passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.containView addSubview:self.passwordField];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:kFontColorBlackLight forState:UIControlStateHighlighted];
    self.loginButton.size = CGSizeMake(180, 44);
    [self.loginButton setBackgroundImage:[V2Helper getImageWithColor:[UIColor colorWithWhite:0.000 alpha:0.30] size:self.loginButton.size] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[V2Helper getImageWithColor:[UIColor colorWithWhite:0.000 alpha:0.060] size:self.loginButton.size] forState:UIControlStateHighlighted];
    self.loginButton.layer.borderColor = [UIColor colorWithWhite:0.000 alpha:0.10].CGColor;
    self.loginButton.layer.borderWidth = 0.5;
    [self.containView addSubview:self.loginButton];

    // Handles
    @weakify(self);
    [self.usernameField setBk_shouldBeginEditingBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        
        [self showKeyboard];
        
        return YES;
    }];
    
    [self.usernameField setBk_shouldReturnBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        
        [self.passwordField becomeFirstResponder];
        
        return YES;
    }];
    
    [self.passwordField setBk_shouldBeginEditingBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        
        [self showKeyboard];
        
        return YES;
    }];
    
    [self.passwordField setBk_shouldReturnBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        
        [self login];
        
        return YES;
    }];
    
    [self.loginButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        [self login];
        
    } forControlEvents:UIControlEventTouchUpInside];

}

#pragma mark - Private Methods

- (void)beginLogin {
    
    self.isLogining = YES;
    
    self.usernameField.enabled = NO;
    self.passwordField.enabled = NO;
    
    static NSUInteger dotCount = 0;
    dotCount = 1;
    [self.loginButton setTitle:@"登录." forState:UIControlStateNormal];

    @weakify(self);
    self.loginTimer = [NSTimer bk_scheduledTimerWithTimeInterval:0.5 block:^(NSTimer *timer) {
        @strongify(self);
        
        if (dotCount > 3) {
            dotCount = 0;
        }
        NSString *loginString = @"登录";
        for (int i = 0; i < dotCount; i ++) {
            loginString = [loginString stringByAppendingString:@"."];
        }
        dotCount ++;
        
        [self.loginButton setTitle:loginString forState:UIControlStateNormal];
        
    } repeats:YES];
    
}

- (void)endLogin {
    
    self.usernameField.enabled = YES;
    self.passwordField.enabled = YES;
    
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];

    self.isLogining = NO;
    
    [self.loginTimer invalidate];
    self.loginTimer = nil;
    
}

- (void)login {
    
    if (!self.isLogining) {
        
        if (self.usernameField.text.length && self.passwordField.text.length) {
            if ([self isValidEmail:self.usernameField.text]) {
                //输入邮箱登录 会导致获取profile 信息失败的bug
                [SVProgressHUD showErrorWithStatus:@"请输入用户名，而非注册邮箱"];
                return;
            }
            [self hideKeyboard];

            [[V2DataManager manager] UserLoginWithUsername:self.usernameField.text password:self.passwordField.text success:^(NSString *message) {
                
                [[V2DataManager manager] getMemberProfileWithUserId:nil username:self.usernameField.text success:^(V2MemberModel *member) {
                    
                    V2UserModel *user = [[V2UserModel alloc] init];
                    
                    user.member = member;
                    user.name = member.memberName;
                    
                    [V2DataManager manager].user = user;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil];
                    
                    [self endLogin];
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } failure:^(NSError *error) {
                    
                    [self endLogin];
                    
                }];
                
                
                
            } failure:^(NSError *error) {
                
                NSString *reasonString;
                
                if (error.code < 700) {
                    reasonString = @"请检查网络状态";
                } else {
                    reasonString = @"请检查用户名或密码";
                }
                UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"登录失败" message:reasonString];
                [alertView bk_setCancelButtonWithTitle:@"确定" handler:^{
                    [self endLogin];
                }];
                
                [alertView show];
                
            }];
            
            [self beginLogin];
            
        }
        
    }
    
}

- (void)showKeyboard {
    
    if (self.isKeyboardShowing) {
        ;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.containView.y      = kContainViewYEditing;
            self.descriptionLabel.y -= 5;
            self.usernameField.y    -= 10;
            self.passwordField.y    -= 12;
            self.loginButton.y      -= 14;
        }];
        self.isKeyboardShowing = YES;
    }
    
}

- (void)hideKeyboard {
    
    if (self.isKeyboardShowing) {
        self.isKeyboardShowing = NO;
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.containView.y      = kContainViewYNormal;
            self.descriptionLabel.y += 5;
            self.usernameField.y    += 10;
            self.passwordField.y    += 12;
            self.loginButton.y      += 14;
        } completion:^(BOOL finished) {
        }];
    }

}

- (BOOL)isValidEmail:(NSString *)email{
    if (email == nil) {
        return NO;
    }
    NSString *phoneRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:email];
}

#pragma mark - Keyboard Notification
- (void)keyboardWillHide:(NSNotification *)notification {
    [self hideKeyboard];
}

@end
