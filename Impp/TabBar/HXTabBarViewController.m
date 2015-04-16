//
//  HXTabBarViewController.m
//  IMChat
//
//  Created by Herxun on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXTabBarViewController.h"
#import "MessageUtil.h"
#import "UIColor+CustomColor.h"
#import "NotificationCenterUtil.h"

@interface HXTabBarViewController ()
@property (strong, nonatomic) UIImageView *badge;
@property (strong, nonatomic) UILabel *unreadCountLabel;
@property (strong, nonatomic) UITabBarItem *tabBarItem1;
@property (strong, nonatomic) UITabBarItem *tabBarItem2;
@property (strong, nonatomic) UITabBarItem *tabBarItem3;
@property (strong, nonatomic) UITabBarItem *tabBarItem4;
@end

@implementation HXTabBarViewController
@synthesize tabBarItem1, tabBarItem2, tabBarItem3, tabBarItem4;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateUnreadCount)
                                                name:@"updateMessageUnreadCount"
                                              object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateUnreadCount)
                                                name:SaveMessageToLocal
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateUnreadCount)
                                                name:SaveTopicMessageToLocal
                                              object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateUnreadCount)
                                                name:DeleteChatHistory
                                              object:nil];
    
    [self initTabbar];
    
}

- (void)updateUnreadCount
{
    NSInteger bageNumber = [MessageUtil getAllUnreadCount];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:bageNumber];
    
    if (bageNumber)
        tabBarItem1.badgeValue = [NSString stringWithFormat:@"%ld",(long)bageNumber];
    else
        tabBarItem1.badgeValue = nil;

}

- (void)showChatHistoryPage
{
    if (self.selectedIndex != 1)
        self.selectedIndex = 1;
}

- (void)initTabbar
{
    UITabBarController *tabBarController = self;
    UITabBar *tabBar = tabBarController.tabBar;
    tabBar.selectedImageTintColor = [UIColor color3];
    tabBar.barTintColor = UIBarButtonItemStylePlain;

    
    tabBarItem1 = [tabBar.items objectAtIndex:0];
    tabBarItem2 = [tabBar.items objectAtIndex:1];
    tabBarItem3 = [tabBar.items objectAtIndex:2];
    tabBarItem4 = [tabBar.items objectAtIndex:3];
    
    tabBarItem1.title = NSLocalizedString(@"聊天", nil);
    [tabBarItem1 setImage:[[UIImage imageNamed:@"tab01"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [tabBarItem1 setSelectedImage:[[UIImage imageNamed:@"tab01"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    NSInteger bageNumber = [MessageUtil getAllUnreadCount];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:bageNumber];
    
    if (bageNumber)
        tabBarItem1.badgeValue = [NSString stringWithFormat:@"%ld",(long)bageNumber];
    else
        tabBarItem1.badgeValue = nil;
    
    tabBarItem2.title = NSLocalizedString(@"好友", nil);
    [tabBarItem2 setImage:[[UIImage imageNamed:@"tab02"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [tabBarItem2 setSelectedImage:[[UIImage imageNamed:@"tab02"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    tabBarItem3.title = NSLocalizedString(@"發現", nil);
    [tabBarItem3 setImage:[[UIImage imageNamed:@"tab03"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [tabBarItem3 setSelectedImage:[[UIImage imageNamed:@"tab03"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    tabBarItem4.title = NSLocalizedString(@"設定", nil);
    [tabBarItem4 setImage:[[UIImage imageNamed:@"tab04"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [tabBarItem4 setSelectedImage:[[UIImage imageNamed:@"tab04"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
