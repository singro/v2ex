//
//  V2TopicViewController.m
//  v2ex-iOS
//
//  Created by Singro on 3/18/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2TopicViewController.h"

#import "V2TopicStateManager.h"
#import "SCWeixinManager.h"
#import "V2AppDelegate.h"

#import "V2NodeViewController.h"
#import "V2WebViewController.h"

#import "UIView+REFrosted.h"
#import "UIImage+REFrosted.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <NYXImagesKit.h>
#import <Social/Social.h>

#import "V2TopicToolBarView.h"
#import "SCAnimationView.h"
#import "MBProgressHUD.h"
#import "V2TopicToolBarItemView.h"
#import "SCActionSheet.h"
#import "V2ActionCellView.h"
#import "BlockImagePickerController.h"
#import "SCImageUploader.h"

#import "V2TopicTitleCell.h"
#import "V2TopicInfoCell.h"
#import "V2TopicBodyCell.h"
#import "V2TopicReplyCell.h"

typedef NS_ENUM(NSInteger, V2ImagePickerSourceType) {
    V2ImagePickerSourceTypePhotoLibrary,
    V2ImagePickerSourceTypeCamera,
};


@interface V2TopicViewController () <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) UIView             *headerView;
@property (nonatomic, strong) UILabel            *nodeNameLabel;

@property (nonatomic, strong) SCBarButtonItem    *leftBarItem;
@property (nonatomic, strong) SCBarButtonItem    *addBarItem;
@property (nonatomic, strong) SCBarButtonItem    *doneBarItem;
@property (nonatomic, strong) SCBarButtonItem    *activityBarItem;

@property (nonatomic, strong) V2TopicToolBarView *toolBarView;
@property (nonatomic, strong) UITextField        *titleTextField;

@property (nonatomic, strong) UIView             *menuContainView;
@property (nonatomic, strong) UIView             *menuView;
@property (nonatomic, strong) UIButton           *menuBackgroundButton;
@property (nonatomic, assign) BOOL               isMenuShowing;

@property (nonatomic, strong) MBProgressHUD      *HUD;
@property (nonatomic, strong) SCActionSheet      *actionSheet;
@property (nonatomic, strong) SCActionSheet      *shareActionSheet;
@property (nonatomic, strong) SCImageUploader    *imageUploader;

@property (nonatomic, strong) V2ReplyList        *replyList;
@property (nonatomic, strong) V2ReplyModel       *selectedReplyModel;
@property (nonatomic, copy  ) NSString           *replyCountentSting;
@property (nonatomic, strong) V2NodeModel        *nodeModel;

@property (nonatomic, assign) BOOL               isDragging;
@property (nonatomic, assign) BOOL               needsCreate;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePanRecognizer;

@property (nonatomic, copy) NSURLSessionDataTask* (^getTopicBlock)();
@property (nonatomic, copy) NSURLSessionDataTask* (^getReplyListBlock)(NSInteger page);
@property (nonatomic, copy) NSURLSessionDataTask* (^replyCreateBlock)(NSString *content);
@property (nonatomic, copy) NSURLSessionDataTask* (^topicCreateBlock)(NSString *content, NSString *title);

@property (nonatomic, copy) NSString *token;

@end

@implementation V2TopicViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.isDragging = NO;
        self.isMenuShowing = NO;
        self.create = NO;
        self.needsCreate = YES;
        self.preview = NO;
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self configureBarItems];
    [self configureTableView];
    [self configureHeaderView];
    [self configureMenuView];
    [self configureToolBarView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColorWhite;
    
    if (self.isPreview) {
        [self createNavigationBar];
        self.sc_navigationItem.title = @"预览";
        self.sc_navigationItem.titleLabel.centerY = UIView.sc_statusBarHeight + UIView.sc_navigationBarHeighExcludeStatusBar/2;
    } else {
        self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
        self.sc_navigationItem.rightBarButtonItem = self.addBarItem;
        
        if (self.model) {
            self.sc_navigationItem.title = self.model.topicTitle;
            self.nodeModel = self.model.topicNode;
        } else {
            self.sc_navigationItem.title = @"Topic";
        }
    }
    
    [self configureBlocks];
    [self configureGestures];
    [self configureNotifications];
    
    if (!self.model.topicContent && !self.isCreate) {
        self.getTopicBlock();
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)dealloc {
    
    /**
     *  Since inherit tableView from super. without set tableView's delegate to nil,
     *  super will call ScrollViewDelegate(When a network request success after pop 
     *  self VC & call [self endloadMore/Refresh]) even after self(self.tableView) is dealloced.
     *  This will lead a crash.
     */
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.titleTextField) {
        [self.titleTextField removeFromSuperview];
        self.titleTextField = nil;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isCreate) {
        [self configureNavigationBar];
        [self.toolBarView showReplyViewWithQuotes:nil animated:NO];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.replyList && !self.isCreate) {
        @weakify(self);
        [self bk_performBlock:^(id obj) {
            @strongify(self);
            
            [self beginLoadMore];
            
        } afterDelay:0.5];
    }

    if (self.isCreate) {
        [self updateNaviBarStatus];
    }

}

#pragma mark - Setter

- (void)setPreview:(BOOL)preview {
    _preview = preview;
    
    if (self.isPreview) {
        [self createNavigationBar];
        self.sc_navigationItem.title = @"预览";
        self.sc_navigationItem.titleLabel.centerY = UIView.sc_statusBarHeight + UIView.sc_navigationBarHeighExcludeStatusBar/2;
    } else {
        self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
        self.sc_navigationItem.rightBarButtonItem = self.addBarItem;
        
        if (self.model) {
            self.sc_navigationItem.title = self.model.topicTitle;
            self.nodeModel = self.model.topicNode;
        } else {
            self.sc_navigationItem.title = @"Topic";
        }
    }
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.view.backgroundColor = kBackgroundColorWhite;
    self.tableView.backgroundColor = kBackgroundColorWhite;
    self.hiddenEnabled = YES;
    
    self.tableView.contentInsetTop = UIView.sc_navigationBarHeight - 36;
    self.menuContainView.frame = self.view.bounds;
    self.menuBackgroundButton.frame = self.menuContainView.bounds;

}

#pragma mark - Configure Views & blocks

- (void)configureTableView {
    
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    [self.view addSubview:self.tableView];
    
}

- (void)configureHeaderView {
    
    self.headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 36}];

    UIView *headerContainView = [[UIView alloc] initWithFrame:(CGRect){0, self.headerView.height - 36, kScreenWidth, 36}];
    headerContainView.backgroundColor = kBackgroundColorWhiteDark;
    [self.headerView addSubview:headerContainView];
    
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headerButton.frame = (CGRect){0, 0, headerContainView.width, headerContainView.height};
    [self.headerView addSubview:headerButton];
    
//    UILabel *nodeLabel = [[UILabel alloc] initWithFrame:(CGRect){10, 0, 70, 36}];
//    nodeLabel.textColor = kFontColorBlackLight;
//    nodeLabel.font = [UIFont systemFontOfSize:15];
//    nodeLabel.text = @"Node: ";
//    [headerContainView addSubview:nodeLabel];
    
    self.nodeNameLabel = [[UILabel alloc] initWithFrame:(CGRect){10, 0, 200, 36}];
    self.nodeNameLabel.textColor = kFontColorBlackLight;
    self.nodeNameLabel.font = [UIFont systemFontOfSize:15];
    self.nodeNameLabel.userInteractionEnabled = NO;
    [headerContainView addSubview:self.nodeNameLabel];
    
    UIImageView *rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow"]];
    rightArrowImageView.userInteractionEnabled = NO;
    rightArrowImageView.frame = (CGRect){0, 13, 5, 10};
    rightArrowImageView.x = headerContainView.width - rightArrowImageView.width - 10;
    [headerContainView addSubview:rightArrowImageView];
    
    self.tableView.tableHeaderView = self.headerView;
    
    // Handles
    @weakify(self);
    [headerButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        V2NodeViewController *nodeVC = [[V2NodeViewController alloc] init];
        nodeVC.model = self.nodeModel;
        [self.navigationController pushViewController:nodeVC animated:YES];
        
        
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configureBarItems {
    
    @weakify(self);
    self.leftBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if (self.toolBarView.isShowing) {
            [self.toolBarView popToolBar];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
    
    self.addBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_more"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
//        [self showMenuAnimated:YES];
        
        V2ActionCellView *shareAction = [[V2ActionCellView alloc] initWithTitles:nil imageNames:@[@"share_wechat_friends", @"share_wechat_moments", @"share_twitter", @"share_weibo"]];
        V2ActionCellView *actionAction = [[V2ActionCellView alloc] initWithTitles:@[@"忽略", @"收藏", @"感谢", @"Safari"] imageNames:@[@"action_forbidden", @"action_favorite", @"action_thank", @"action_safari"]];

        self.actionSheet = [[SCActionSheet alloc] sc_initWithTitles:@[@"分享", @""] customViews:@[shareAction, actionAction] buttonTitles:@"回复", nil];
        shareAction.actionSheet = self.actionSheet;
        actionAction.actionSheet = self.actionSheet;
        
        @weakify(self);
        [self.actionSheet sc_setButtonHandler:^{
            @strongify(self);
            
            [self.toolBarView showReplyViewWithQuotes:nil animated:YES];
            
        } forIndex:0];
        
        [shareAction sc_setButtonHandler:^{
            @strongify(self);
            [self shareToWeixinWithScene:WXSceneSession];
        } forIndex:0];
        
        [shareAction sc_setButtonHandler:^{
            @strongify(self);
            [self shareToWeixinWithScene:WXSceneTimeline];
        } forIndex:1];
        
        [shareAction sc_setButtonHandler:^{
            @strongify(self);
            [self shareToTwitter];
        } forIndex:2];
        
        [shareAction sc_setButtonHandler:^{
            @strongify(self);
            [self shareToWeibo];
        } forIndex:3];
        
        
        [actionAction sc_setButtonHandler:^{
            @strongify(self);
            [self ignoreTopic];
        } forIndex:0];
        
        [actionAction sc_setButtonHandler:^{
            @strongify(self);
            [self favTopic];
        } forIndex:1];
        
        [actionAction sc_setButtonHandler:^{
            @strongify(self);
            [self thankTopic];
        } forIndex:2];
        
        [actionAction sc_setButtonHandler:^{
            @strongify(self);
            [self openWithWeb];
        } forIndex:3];
        
        [self.actionSheet sc_show:YES];

    }];

    self.doneBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_done"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if (self.toolBarView.replyContentString) {
            if (self.isCreate) {
                self.topicCreateBlock(self.toolBarView.replyContentString, self.titleTextField.text);
            } else {
                self.replyCreateBlock(self.toolBarView.replyContentString);
            }
        }
        
    }];

//    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    activityView.color = [UIColor blackColor];
//    self.activityBarItem = [[SCBarButtonItem alloc] initWithCustomView:activityView];
//    [activityView startAnimating];
    
}

- (void)configureToolBarView {
    
    self.toolBarView = [[V2TopicToolBarView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, self.view.height}];
    self.toolBarView.create = self.isCreate;
    [self.view addSubview:self.toolBarView];
    
    @weakify(self);
    [self.toolBarView setContentIsEmptyBlock:^(BOOL isEmpty) {
        @strongify(self);
        
        [self updateNaviBarStatus];

    }];
    
    [self.toolBarView setInsertImageBlock:^{
        @strongify(self);
        
        self.actionSheet = [[SCActionSheet alloc] sc_initWithTitles:@[@"插入图片"] customViews:nil buttonTitles:@"拍照", @"图片库", nil];
        
        @weakify(self);
        
        [self.actionSheet sc_setButtonHandler:^{
            @strongify(self);
            
            [self pickImageFrom:V2ImagePickerSourceTypeCamera];
            
        } forIndex:0];
        
        [self.actionSheet sc_setButtonHandler:^{
            @strongify(self);
            
            [self pickImageFrom:V2ImagePickerSourceTypePhotoLibrary];

        } forIndex:1];
        
        [self.actionSheet sc_show:YES];
        
    }];
    
}

- (void)configureNavigationBar {
    
    if (!self.needsCreate) {
        return;
    }
    
    self.needsCreate = NO;
    
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.titleTextField.font = [UIFont systemFontOfSize:17];
    self.titleTextField.textColor = kNavigationBarTintColor;
    self.titleTextField.textAlignment = NSTextAlignmentCenter;
    self.titleTextField.placeholder = @"输入标题";
    [self.sc_navigationBar addSubview:self.titleTextField];

    NSUInteger otherButtonWidth = self.sc_navigationItem.leftBarButtonItem.view.width + self.sc_navigationItem.rightBarButtonItem.view.width;
    self.titleTextField.width = kScreenWidth - otherButtonWidth - 20;
    self.titleTextField.height = 44;
    self.titleTextField.centerY = 42;
    self.titleTextField.centerX = kScreenWidth/2;
    
    // handles
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        
        [self updateNaviBarStatus];
    }];

}

- (void)configureMenuView {
    
//    self.menuContainView = [[UIView alloc] init];
//    self.menuContainView.userInteractionEnabled = NO;
//    [self.view addSubview:self.menuContainView];
//    
//    self.menuBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.menuBackgroundButton.backgroundColor = [UIColor colorWithWhite:0.667 alpha:0];
//    [self.menuContainView addSubview:self.menuBackgroundButton];
//    
//    self.menuView = [[UIView alloc] init];
//    self.menuView.alpha = 0.0;
//    self.menuView.frame = (CGRect){200, 64, 130, 118};
//    [self.menuContainView addSubview:self.menuView];
//    
//    UIView *topArrowView = [[UIView alloc] init];
//    topArrowView.frame = (CGRect){87, 5, 10, 10};
//    topArrowView.backgroundColor = [UIColor blackColor];
//    topArrowView.transform = CGAffineTransformMakeRotation(M_PI_4);
//    [self.menuView addSubview:topArrowView];
//    
//    UIView *menuBackgroundView = [[UIView alloc] init];
//    menuBackgroundView.frame = (CGRect){10, 10, 100, 88};
//    menuBackgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.90];
//    menuBackgroundView.layer.cornerRadius = 5.0;
//    menuBackgroundView.clipsToBounds = YES;
//    [self.menuView addSubview:menuBackgroundView];
    
//    NSArray *itemTitleArray = @[@"回复", @"收藏"];
//    NSArray *itemImageArray = @[@"icon_reply", @"icon_fav"];
//    
//    @weakify(self);
//    void (^buttonHandleBlock)(NSInteger index) = ^(NSInteger index) {
//        @strongify(self);
//        
//        if (index == 0) {
//            
//            [self.toolBarView showReplyViewWithQuotes:nil animated:YES];
//            
//        }
//        
//        if (index == 1) {
//            
//            self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
//            self.HUD.removeFromSuperViewOnHide = YES;
//            [self.view addSubview:self.HUD];
//            [self.HUD show:YES];
//            
//            [[V2DataManager manager] favTopicWithTopicId:self.model.topicId success:^(NSString *message) {
//                @strongify(self);
//                
//                UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
//                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//                self.HUD.customView = imageView;
//                self.HUD.mode = MBProgressHUDModeCustomView;
//                self.HUD.labelText = @"已收藏";
//                [self.HUD hide:YES afterDelay:0.6];
//                
//            } failure:^(NSError *error) {
//                @strongify(self);
//                
//                UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
//                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//                self.HUD.customView = imageView;
//                self.HUD.mode = MBProgressHUDModeCustomView;
//                self.HUD.labelText = @"Failed";
//                [self.HUD hide:YES afterDelay:0.6];
//                
//            }];
//            
//        }
//        
//        [self hideMenuAnimated:NO];
//    };
    
//    for (int i = 0; i < 2; i ++) {
//        V2TopicToolBarItemView *item = [[V2TopicToolBarItemView alloc] init];
//        item.itemTitle = itemTitleArray[i];
//        item.itemImage = [UIImage imageNamed:itemImageArray[i]];
//        item.alpha = 1.0;
//        item.buttonPressedBlock = ^{
//            buttonHandleBlock(i);
//        };
//        item.frame = (CGRect){0, 44 * i, item.width, item.height};
//        item.backgroundColorNormal = [UIColor clearColor];
//        [menuBackgroundView addSubview:item];
//    }
//    
    // Handles
    @weakify(self);
    [self.menuBackgroundButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        [self hideMenuAnimated:YES];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configureBlocks {
    
    @weakify(self);
    
    self.getTopicBlock = ^{
        @strongify(self);
        
        return [[V2DataManager manager] getTopicWithTopicId:self.model.topicId success:^(V2TopicModel *model) {
            @strongify(self);
            self.model = model;
            
        } failure:^(NSError *error) {
            ;
        }];
        
    };
    
    self.getReplyListBlock = ^(NSInteger page) {
        @strongify(self);
        
        return [[V2DataManager manager] getReplyListWithTopicId:self.model.topicId success:^(V2ReplyList *list) {
            @strongify(self);
            
            self.replyList = list;
            [self endLoadMore];
            
        } failure:^(NSError *error) {
            
            [self endLoadMore];
            
        }];
        
    };
    
    self.replyCreateBlock = ^(NSString *content) {
        @strongify(self);
        
        [self naviBeginRefreshing];
        
        return [[V2DataManager manager] replyCreateWithTopicId:self.model.topicId content:content success:^(V2ReplyModel *model) {
            @strongify(self);
            
            [self naviEndRefreshing];

            [[NSNotificationCenter defaultCenter] postNotificationName:kReplySuccessNotification object:nil];
            
            self.sc_navigationItem.rightBarButtonItem = self.addBarItem;
            [self.toolBarView clearTextView];
            
            // update State Count
            NSInteger replyCount = [self.model.topicReplyCount integerValue] + 1;
            self.model.topicReplyCount = [NSString stringWithFormat:@"%ld", (long)replyCount];
            [[V2TopicStateManager manager] saveStateForTopicModel:self.model];

            [self beginLoadMore];
            
        } failure:^(NSError *error) {
            
            [self naviEndRefreshing];

            [[NSNotificationCenter defaultCenter] postNotificationName:kReplySuccessNotification object:nil];
            UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"回复失败" message:nil];
            [alertView bk_setCancelBlock:^{
                ;
            }];
            [alertView show];
            
        }];
        
    };

    self.topicCreateBlock = ^(NSString *content, NSString *title) {
        @strongify(self);
        
        [self naviBeginRefreshing];
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
        return [[V2DataManager manager] topicCreateWithNodeName:self.nodeModel.nodeName title:title content:content success:^(NSString *message) {
            @strongify(self);
            
            [self naviEndRefreshing];
            self.create = NO;
            self.toolBarView.create = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kReplySuccessNotification object:nil];
            
            self.sc_navigationItem.rightBarButtonItem = self.addBarItem;
            [self.toolBarView clearTextView];
            
            V2TopicModel *topicModel = [[V2TopicModel alloc] init];
            topicModel.topicId = message;
            topicModel.topicNode = self.nodeModel;
            self.model = topicModel;
            
            self.getTopicBlock();
            [self beginLoadMore];
            
        } failure:^(NSError *error) {
            @strongify(self);
            [self naviEndRefreshing];

            [[NSNotificationCenter defaultCenter] postNotificationName:kReplySuccessNotification object:nil];
            UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"发帖失败" message:nil];
            [alertView bk_setCancelBlock:^{
                ;
            }];
            [alertView show];

        }];
        
    };

    self.loadMoreBlock = ^{
        @strongify(self);
        
        self.getReplyListBlock(1);
        
    };
    
}

- (void)configureGestures {
    
    @weakify(self);
    self.edgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self);
        
        if (state == UIGestureRecognizerStateBegan) {
            
            self.toolBarView.locationStart = location;
        
        }
        if (state == UIGestureRecognizerStateChanged) {
            
            self.toolBarView.locationChanged = location;
            
        }
        if (state == UIGestureRecognizerStateEnded) {
            
            CGPoint velocity = [(UIPanGestureRecognizer *)sender velocityInView:self.view];

            [self.toolBarView setLocationEnd:location velocity:velocity];
            
        }
        
    }];
    
    self.edgePanRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:self.edgePanRecognizer];
    
}

- (void)configureNotifications {
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kShowReplyTextViewNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        
        self.sc_navigationItem.rightBarButtonItem = self.doneBarItem;
        
        [self updateNaviBarStatus];

        __block UIImage *screenImage = [self.view re_screenshot];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIColor *blurColor = [UIColor colorWithWhite:0.98 alpha:0.87f];
            if (kCurrentTheme == V2ThemeNight) {
                blurColor = [UIColor colorWithWhite:0.028 alpha:0.870];
            }
            screenImage = [screenImage re_applyBlurWithRadius:4.3 tintColor:blurColor saturationDeltaFactor:2.0 maskImage:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                
                self.toolBarView.blurredBackgroundImage = screenImage;
                
            });
            
        });

    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kHideReplyTextViewNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        
        self.sc_navigationItem.rightBarButtonItem = self.addBarItem;
        
    }];
    
//    [[NSNotificationCenter defaultCenter] addObserverForName:kTakeScreenShootNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
//    }];
    
}

#pragma mark - Data Methods

- (void)setModel:(V2TopicModel *)model {
    _model = model;
    
    self.sc_navigationItem.title = model.topicTitle;
    if (model.topicTitle && self.titleTextField) {
        if (self.titleTextField) {
            [self.titleTextField removeFromSuperview];
            self.titleTextField = nil;
        }
    }
    
    self.nodeModel = model.topicNode;
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    if (self.model.topicReplyCount) {
        [[V2TopicStateManager manager] saveStateForTopicModel:self.model];
    }
    self.model.state = [[V2TopicStateManager manager] getTopicStateWithTopicModel:self.model];
    
}

- (void)setNodeModel:(V2NodeModel *)nodeModel {
    _nodeModel = nodeModel;
    
    self.nodeNameLabel.text = self.nodeModel.nodeTitle;
    
}

- (void)setReplyList:(V2ReplyList *)replyList {
    
    BOOL isFirstSet = (_replyList == nil);
    _replyList = replyList;
    
    if (isFirstSet) {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
    
//    if (replyList.list.count > 0) {
//        self.view.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.000];
//    }
//
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    
//    NSLog(@"offsetY:   %.f", scrollView.contentOffsetY);
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    
    self.isDragging = YES;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];

    if (scrollView.contentOffsetY < - UIView.sc_navigationBarHeight + 36) {
        self.isDragging = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.contentInsetTop = UIView.sc_navigationBarHeight;
        } completion:^(BOOL finished) {
            if (!decelerate) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.tableView.contentInsetTop = UIView.sc_navigationBarHeight - 36;
                }];
            }
        }];
    } else {
        self.isDragging = NO;
        self.tableView.contentInsetTop = UIView.sc_navigationBarHeight - 36;
    }
    
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        return self.replyList.list.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return [V2TopicTitleCell getCellHeightWithTopicModel:self.model];
                break;
            case 1:
                return [V2TopicInfoCell getCellHeightWithTopicModel:self.model];
                break;
            case 2:
                return [V2TopicBodyCell getCellHeightWithTopicModel:self.model];
                break;
            default:
                break;
        }
    }
    
    if (indexPath.section == 1) {
        V2ReplyModel *model = self.replyList.list[indexPath.row];
        return [V2TopicReplyCell getCellHeightWithReplyModel:model];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *titleCellIdentifier = @"titleCellIdentifier";
    V2TopicTitleCell *titleCell = (V2TopicTitleCell *)[tableView dequeueReusableCellWithIdentifier:titleCellIdentifier];
    if (!titleCell) {
        titleCell = [[V2TopicTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:titleCellIdentifier];
        titleCell.navi = self.navigationController;
    }
    
    static NSString *infoCellIdentifier = @"infoCellIdentifier";
    V2TopicInfoCell *infoCell = (V2TopicInfoCell *)[tableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
    if (!infoCell) {
        infoCell = [[V2TopicInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoCellIdentifier];
        infoCell.navi = self.navigationController;
    }

    static NSString *bodyCellIdentifier = @"bodyCellIdentifier";
    V2TopicBodyCell *bodyCell = (V2TopicBodyCell *)[tableView dequeueReusableCellWithIdentifier:bodyCellIdentifier];
    if (!bodyCell) {
        bodyCell = [[V2TopicBodyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bodyCellIdentifier];
        bodyCell.navi = self.navigationController;
    }
    
    static NSString *replyCellIdentifier = @"replyCellIdentifier";
    V2TopicReplyCell *replyCell = (V2TopicReplyCell *)[tableView dequeueReusableCellWithIdentifier:replyCellIdentifier];
    if (!replyCell) {
        replyCell = [[V2TopicReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:replyCellIdentifier];
        replyCell.navi = self.navigationController;
    }

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return [self configureTitleCellWithCell:titleCell IndexPath:indexPath];
                break;
            case 1:
                return [self configureInfoCellWithCell:infoCell IndexPath:indexPath];
                break;
            case 2:
                return [self configureBodyCellWithCell:bodyCell IndexPath:indexPath];
                break;
            default:
                break;
        }
    }
    
    if (indexPath.section == 1) {
        return [self configureReplyCellWithCell:replyCell IndexPath:indexPath];
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        V2ReplyModel *model = self.replyList.list[indexPath.row];
        
        self.actionSheet = [[SCActionSheet alloc] sc_initWithTitles:@[model.replyCreator.memberName] customViews:nil buttonTitles:@"回复", @"感谢", nil];
        
        @weakify(self);
        [self.actionSheet sc_setButtonHandler:^{
            @strongify(self);
            
            SCQuote *quote = [[SCQuote alloc] init];
            quote.string = model.replyCreator.memberName;
            quote.type = SCQuoteTypeUser;
            
            [self sc_setNavigationBarHidden:NO animated:YES];
            [self.toolBarView showReplyViewWithQuotes:@[quote] animated:YES];
            
        } forIndex:0];
        
        [self.actionSheet sc_setButtonHandler:^{
            @strongify(self);

            [self thankReplyActionWithReplyId:model.replyId];
            
        } forIndex:1];

        [self.actionSheet sc_show:YES];
        
    }
    
}

#pragma mark - Configure TableCell

- (V2TopicTitleCell *)configureTitleCellWithCell:(V2TopicTitleCell *)cell IndexPath:(NSIndexPath *)indexPath {
    
    cell.model = self.model;
    
    return cell;
}

- (V2TopicInfoCell *)configureInfoCellWithCell:(V2TopicInfoCell *)cell IndexPath:(NSIndexPath *)indexPath {
    
    cell.model = self.model;

    return cell;
}

- (V2TopicBodyCell *)configureBodyCellWithCell:(V2TopicBodyCell *)cell IndexPath:(NSIndexPath *)indexPath {
    
    cell.model = self.model;
    
    @weakify(self);
    [cell setReloadCellBlock:^{
        @strongify(self);
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
    }];
    
    return cell;
}

- (V2TopicReplyCell *)configureReplyCellWithCell:(V2TopicReplyCell *)cell IndexPath:(NSIndexPath *)indexPath {
    
    V2ReplyModel *model = self.replyList.list[indexPath.row];
    cell.model = model;
    cell.selectedReplyModel = self.selectedReplyModel;
    cell.replyList = self.replyList;
    
    @weakify(self);
    [cell setReloadCellBlock:^{
        @strongify(self);
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
    }];

    [cell setLongPressedBlock:^{
        @strongify(self);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSelectMemberNotification object:model];
        self.selectedReplyModel = model;
        
//        if (self.actionSheet.isShowing) {
//            return ;
//        }
//        
//        V2ReplyModel *model = self.replyList.list[indexPath.row];
//        self.actionSheet = [[SCActionSheet alloc] sc_initWithTitle:model.replyCreator.memberName customView:nil buttonTitles:@"复制", @"查看回复", nil];
//        [self.actionSheet sc_setButtonHandler:^{
//            @strongify(self);
//            
//        } forIndex:0];
//        [self.actionSheet sc_show:YES];

    }];
    
    return cell;
}

#pragma mark - Actions

- (void)favTopic {
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
    
    @weakify(self);
    [self getTokenWithBlock:^(NSString *token) {
        @strongify(self);
        
        [[V2DataManager manager] topicFavWithTopicId:self.model.topicId token:token success:^(NSString *message) {
            @strongify(self);
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            self.HUD.customView = imageView;
            self.HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.labelText = @"已收藏";
            [self.HUD hide:YES afterDelay:0.6];

        } failure:^(NSError *error) {
            @strongify(self);
            
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            self.HUD.customView = imageView;
            self.HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.labelText = @"Failed";
            [self.HUD hide:YES afterDelay:0.6];
        }];
        
    }];
    
}

- (void)thankTopic {
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
    
    @weakify(self);
    [self getTokenWithBlock:^(NSString *token) {
        @strongify(self);
        
        [[V2DataManager manager] topicThankWithTopicId:self.model.topicId token:token success:^(NSString *message) {
            @strongify(self);
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            self.HUD.customView = imageView;
            self.HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.labelText = @"已感谢";
            [self.HUD hide:YES afterDelay:0.6];
            
        } failure:^(NSError *error) {
            @strongify(self);
            
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            self.HUD.customView = imageView;
            self.HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.labelText = @"Failed";
            [self.HUD hide:YES afterDelay:0.6];
        }];
        
    }];
    
}

- (void)ignoreTopic {
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
    
    @weakify(self);
    [[V2DataManager manager] topicIgnoreWithTopicId:self.model.topicId success:^(NSString *message) {
        @strongify(self);
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.HUD.customView = imageView;
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.labelText = @"已忽略";
        [self.HUD hide:YES afterDelay:0.6];
        
        [self.HUD setCompletionBlock:^{
            @strongify(self);
            
            [self.navigationController popViewControllerAnimated:YES];

            [self bk_performBlock:^(id obj) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kIgnoreTopicSuccessNotification object:self.model];
            } afterDelay:0.6];
            
        }];
        
    } failure:^(NSError *error) {
        @strongify(self);
        
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.HUD.customView = imageView;
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.labelText = @"忽略失败";
        [self.HUD hide:YES afterDelay:0.6];
    }];
    
}

- (void)openWithWeb {
    
    V2WebViewController *webVC = [[V2WebViewController alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://v2ex.com/t/%@", self.model.topicId];
    webVC.url = [NSURL URLWithString:urlString];
    [self.navigationController pushViewController:webVC animated:YES];

}

- (void)thankReplyActionWithReplyId:(NSString *)replyId {
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
    
    @weakify(self);
    [self getTokenWithBlock:^(NSString *token) {
        @strongify(self);
        
        [[V2DataManager manager] replyThankWithReplyId:replyId token:token success:^(NSString *message) {
            @strongify(self);
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            self.HUD.customView = imageView;
            self.HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.labelText = @"已感谢";
            [self.HUD hide:YES afterDelay:0.6];
            
        } failure:^(NSError *error) {
            @strongify(self);
            
            UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            self.HUD.customView = imageView;
            self.HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.labelText = @"感谢失败";
            [self.HUD hide:YES afterDelay:0.6];
        }];
        
    }];
    
}

- (void)shareToTwitter {
    
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSString *shareString = [NSString stringWithFormat:@"#V2EX %@ https://www.v2ex.com/t/%@ ", self.model.topicTitle, self.model.topicId];
    [composeViewController setInitialText:shareString];
    
    composeViewController.completionHandler = ^(SLComposeViewControllerResult result){
        
        switch (result)
        {
            case SLComposeViewControllerResultDone:
                break;
            case SLComposeViewControllerResultCancelled:
                break;
            default:
                break;
        }
        
    };
    
    [self presentViewController:composeViewController
                       animated:NO
                     completion:nil];

}

- (void)shareToWeibo {
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
    
    @weakify(self);
    
    NSString *shareWeboString = [NSString stringWithFormat:@"#V2EX# %@ https://www.v2ex.com/t/%@", self.model.topicTitle, self.model.topicId];
    
    [[SCWeiboManager manager] sendWeiboWithText:shareWeboString Success:^(NSDictionary *responseDict) {
        @strongify(self);
        
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.HUD.customView = imageView;
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.labelText = @"分享成功";
        [self.HUD hide:YES afterDelay:0.6];

    } failure:^(NSError *error) {
        @strongify(self);

        UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.HUD.customView = imageView;
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.labelText = @"分享失败";
        [self.HUD hide:YES afterDelay:0.6];

    }];

}

- (void)shareToWeixinWithScene:(enum WXScene)scene {
    
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:self.model.topicCreator.memberAvatarNormal] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        UIImage *avatarImage;
        if (finished && image) {
            avatarImage = image;
        } else {
            avatarImage = [UIImage imageNamed:@"icon"];
        }
        NSString *shareContent;
        if (self.model.topicContent.length > 200) {
            shareContent = [self.model.topicContent substringToIndex:150];
        } else {
            shareContent = self.model.topicContent;
        }
        [[SCWeixinManager manager] shareWithWXScene:scene
                                              Title:self.model.topicTitle
                                               link:[NSString stringWithFormat:@"https://www.v2ex.com/t/%@", self.model.topicId]
                                        description:shareContent
                                              image:avatarImage];
    }];
    
    
}

- (void)getTokenWithBlock:(void (^)(NSString *token))block {
    
    if (self.token) {
        block(self.token);
    } else {
        @weakify(self);
        [[V2DataManager manager] getTopicTokenWithTopicId:self.model.topicId success:^(NSString *token) {
            @strongify(self);
            self.token = token;
            block(token);
        } failure:^(NSError *error) {
            block(nil);
        }];
    }
    
}

#pragma mark - Peek And Pop

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    
    UIPreviewAction *openAction = [UIPreviewAction actionWithTitle:@"打开" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        V2TopicViewController *vc = (V2TopicViewController *)previewViewController;
        
        V2TopicViewController *topicVC = [[V2TopicViewController alloc] init];
        topicVC.model = vc.model;
        [AppDelegate.currentNavigationController pushViewController:topicVC animated:YES];
    }];
    
    UIPreviewAction *openWithWebAction = [UIPreviewAction actionWithTitle:@"用 Safari 打开" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
        V2TopicViewController *vc = (V2TopicViewController *)previewViewController;
        
        V2WebViewController *webVC = [[V2WebViewController alloc] init];
        NSString *urlString = [NSString stringWithFormat:@"https://v2ex.com/t/%@", vc.model.topicId];
        webVC.url = [NSURL URLWithString:urlString];
        [AppDelegate.currentNavigationController pushViewController:webVC animated:YES];
        
    }];
    
    return @[openAction, openWithWebAction];
    
}

#pragma mark - Private Methods

- (void)showMenuAnimated:(BOOL)animated {
    
    if (self.isMenuShowing) {
        return;
    }
    
    self.isMenuShowing = YES;
    self.edgePanRecognizer.enabled = NO;
    
    if (animated) {
        self.menuView.origin = (CGPoint){220, 20};
        self.menuView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.menuView.alpha = 1.0;
            self.menuView.transform = CGAffineTransformIdentity;
            self.menuView.frame = (CGRect){200, UIView.sc_navigationBarHeight, 130, 118};
        } completion:^(BOOL finished) {
            self.menuContainView.userInteractionEnabled = YES;
        }];
    } else {
        self.menuView.alpha = 1.0;
        self.menuView.transform = CGAffineTransformIdentity;
        self.menuView.frame = (CGRect){200, UIView.sc_navigationBarHeight, 130, 118};
        self.menuContainView.userInteractionEnabled = YES;
    }
    
}

- (void)hideMenuAnimated:(BOOL)animated {
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.menuView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.menuContainView.userInteractionEnabled = NO;
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.menuView.transform = CGAffineTransformMakeScale(0.3, 0.3);
            self.menuView.origin = (CGPoint){260, UIView.sc_navigationBarHeight};
            
        } completion:^(BOOL finished) {
            self.menuView.transform = CGAffineTransformIdentity;
            self.menuView.frame = (CGRect){200, UIView.sc_navigationBarHeight, 130, 118};
            self.isMenuShowing = NO;
            self.edgePanRecognizer.enabled = YES;
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            self.menuView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.menuContainView.userInteractionEnabled = NO;
            self.isMenuShowing = NO;
            self.edgePanRecognizer.enabled = YES;
        }];
    }
    
}

- (void)updateNaviBarStatus {
    
    if ((!self.toolBarView.isContentEmpty && self.titleTextField.text.length > 0) || (!self.isCreate && !self.toolBarView.isContentEmpty)) {
        self.doneBarItem.enabled = YES;
    } else {
        self.doneBarItem.enabled = NO;
    }
    
}


#pragma mark - Picker Image

- (void)pickImageFrom:(V2ImagePickerSourceType)type {
    
    @weakify(self);
    
    void (^imageHandleBlock)(UIImage *originalImage, ALAssetRepresentation *asset) = ^(UIImage *originalImage,  ALAssetRepresentation *asset){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @strongify(self);
            
            __block UIImage *image = originalImage;

            if (type == V2ImagePickerSourceTypeCamera) {
                UIImageWriteToSavedPhotosAlbum(originalImage,self,nil,nil);
                image = [SCImageUploader scaleAndRotateImage:originalImage];
                if (originalImage.size.width > 600) {
                    image = [image scaleByFactor:600.0f/image.size.width];
                }
            }
            
//            uint8_t *imageBuffer = (uint8_t*)malloc(8);
//            NSUInteger bufferedLength = [asset getBytes:imageBuffer fromOffset:0.0 length:8 error:nil];
//            NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferedLength freeWhenDone:YES];
//            
//            
//            if (AnimatedGifDataIsValid(imageData) && asset) {  // gif Image
//                
//                uint8_t *buffer = (uint8_t*)malloc((NSUInteger)asset.size);
//                NSUInteger buffered = [asset getBytes:buffer fromOffset:0.0 length:(NSUInteger)asset.size error:nil];
//                NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
////                [self.addedDataDict setObject:data forKey:[NSString stringWithFormat:@"%p", image]];
//                
//            } else {
//                if (originalImage.size.width > 600) {
//                    image = [originalImage scaleByFactor:600.0f/originalImage.size.width];
//                }
//                
//                if (type == V2ImagePickerSourceTypeCamera) {
//                    image = [UpYun scaleAndRotateImage:image];
//                }
//            }

            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                
                self.imageUploader = [[SCImageUploader alloc] initWithImage:image compelete:^(NSURL *url, BOOL finished) {
                    
                    if (finished) {
                        
                        [self.toolBarView addImageWithURL:url];
                        
                    }
                    
                }];
                
                [self.imageUploader sc_show:YES];
                
            });
            
        });
    };
    
    switch (type) {
        case V2ImagePickerSourceTypeCamera: {
            
#if !TARGET_IPHONE_SIMULATOR
            BlockImagePickerController *cameraPicker = [[BlockImagePickerController alloc] initWithCameraSourceType:UIImagePickerControllerSourceTypeCamera onFinishingBlock:^(UIImagePickerController *picker, NSDictionary *info, UIImage *originalImage, UIImage *editedImage) {
                imageHandleBlock(originalImage, nil);
                [picker dismissViewControllerAnimated:YES completion:^{
                }];
            } onCancelingBlock:^(UIImagePickerController *picker) {
                [picker dismissViewControllerAnimated:YES completion:^{
                }];
            }];
            [self presentViewController:cameraPicker animated:YES completion:^{
            }];
#endif
            
        }
            break;
        case V2ImagePickerSourceTypePhotoLibrary: {
            BlockImagePickerController *cameraPicker = [[BlockImagePickerController alloc] initWithCameraSourceType:UIImagePickerControllerSourceTypePhotoLibrary onFinishingBlock:^(UIImagePickerController *picker, NSDictionary *info, UIImage *originalImage, UIImage *editedImage) {
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
                         resultBlock:^(ALAsset *asset) {
                             ALAssetRepresentation *representation = [asset defaultRepresentation];
                             imageHandleBlock(originalImage, representation);
                             [picker dismissViewControllerAnimated:YES completion:nil];
                         }
                        failureBlock:^(NSError *error) {
                            [picker dismissViewControllerAnimated:YES completion:nil];
                        }
                 ];
                
            } onCancelingBlock:^(UIImagePickerController *picker) {
                [picker dismissViewControllerAnimated:YES completion:nil];
            }];
            [self presentViewController:cameraPicker animated:YES completion:^{
            }];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Class Methods

//static BOOL AnimatedGifDataIsValid(NSData *data) {
//    if (data.length > 4) {
//        const unsigned char * bytes = [data bytes];
//        
//        return bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46;
//    }
//    
//    return NO;
//}

@end
