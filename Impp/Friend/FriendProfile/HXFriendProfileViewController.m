//
//  HXFriendProfileViewController.m
//  Impp
//
//  Created by Herxun on 2015/4/10.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXFriendProfileViewController.h"
#import "HXAppUtility.h"
#import "HXUserAccountManager.h"
#import "HXIMManager.h"
#import "HXChatViewController.h"
#import "UIColor+CustomColor.h"
#import "HXCustomButton.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define SCREEN_WIDTH self.view.frame.size.width
#define SCREEN_HEIGHT self.view.frame.size.height

@interface HXFriendProfileViewController ()
@property (strong, nonatomic) HXUser *userInfo;
@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UIViewController *previousVc;
@end

@implementation HXFriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initNavigationBar];
    
}

#pragma mark - Initialize

- (id)initWithUserInfo:(HXUser *)userInfo withViewController:(UIViewController *)vc
{
    self = [super init];
    if (self) {
        self.userInfo = userInfo;
        self.previousVc = vc;
    }
    return self;
}

- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.photoImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_default"]];
    self.photoImageView.frame = CGRectMake((SCREEN_WIDTH - 138)/2, SCREEN_HEIGHT *.1, 138, 138);
    self.photoImageView.layer.cornerRadius = 138/2;
    self.photoImageView.clipsToBounds = YES;
    self.photoImageView.layer.masksToBounds = YES;
    self.photoImageView.userInteractionEnabled = YES;

    [self.view addSubview:self.photoImageView];
    
    if (![self.userInfo.photoURL isEqualToString:@""]){
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:self.userInfo.photoURL]
                         options:0
                        progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                           if (image) {
                               self.photoImageView.image = image;
                               self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
                           }
                           
                       }];
    }
    
    self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   self.photoImageView.frame.size.height + self.photoImageView.frame.origin.y + 15,SCREEN_WIDTH, 28)];
    [self.userNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.userNameLabel setFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:28]];
    [self.userNameLabel setTextColor:[UIColor color1]];
    self.userNameLabel.text = self.userInfo.userName;
    self.userNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.userNameLabel];
    
    HXCustomButton *chatButton = [[HXCustomButton alloc]initWithTitle:@"傳送訊息" titleColor:[UIColor color1] backgroundColor:[UIColor color5]];
    [chatButton addTarget:self action:@selector(chatButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    CGRect frame;
    frame = chatButton.frame;
    frame.origin.x = (SCREEN_WIDTH - chatButton.frame.size.width)/2;
    frame.origin.y = self.userNameLabel.frame.size.height + self.userNameLabel.frame.origin.y + 30;
    chatButton.frame = frame;
    [self.view addSubview:chatButton];
    
    if ([self.userInfo.clientId isEqualToString:[HXIMManager manager].clientId]) {
        chatButton.hidden = YES;
    }
}

- (void)initNavigationBar
{
    [HXAppUtility initNavigationTitle:@"" barTintColor:[UIColor color1] withViewController:self];
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelButtonTapped)];
    [self.navigationItem setLeftBarButtonItem:cancelBarButton];
}

#pragma mark - Listener

- (void)cancelButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)chatButtonTapped
{
    [self dismissViewControllerAnimated:NO completion:nil];
    HXChatViewController *chatVc = [[HXIMManager manager]getChatViewWithTargetClientId:self.userInfo.clientId targetUserName:self.userInfo.userName currentUserName:[HXUserAccountManager manager].userName];
    [self.previousVc.navigationController pushViewController:chatVc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
