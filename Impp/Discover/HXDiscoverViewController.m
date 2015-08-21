//
//  HXDiscoverViewController.m
//  Impp
//
//  Created by Herxun on 2015/3/30.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXDiscoverViewController.h"
#import "HXAppUtility.h"
#import "HXWallViewController.h"
#import "HXUserAccountManager.h"
#import "HXCustomTableViewCell.h"
#import "NotificationCenterUtil.h"
#import "UIColor+CustomColor.h"
#import "HXAnDeskViewController.h"
#import "HXRoomViewController.h"
#import "MessageUtil.h"
//#import "HXCustomerServiceViewController.h"

@interface HXDiscoverViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *discoverArray;
@property ( nonatomic) NSInteger unreadMessageCount;
@end

@implementation HXDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self initNavigationBar];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(reloadTableView)
                                                name:UpdateFriendCircleBadge
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(reloadTableView)
                                                name:@"updateMessageUnreadCount"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(reloadTableView)
                                                name:SaveMessageToLocal
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(reloadTableView)
                                                name:SaveTopicMessageToLocal
                                              object:nil];

}

#pragma mark - Initialize

- (void)initView
{
    /* tableView */
    CGRect frame = self.view.frame;
    frame.size.height -= 64;
    frame.origin.y = 0;
    self.tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

- (void)initNavigationBar
{
    [HXAppUtility initNavigationTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo"]]
                             barTintColor:[UIColor color1]
                                tintColor:[UIColor color5]
                       withViewController:self];
}

- (void)initData
{
    self.discoverArray = [@[NSLocalizedString(@"timeline", nil)] mutableCopy];
    
    //群組 by lei
    [self.discoverArray addObject:NSLocalizedString(@"rooms", nil)];
    [self.discoverArray addObject:NSLocalizedString(@"helpdesk", nil)];
    [self.discoverArray addObject:NSLocalizedString(@"chat", nil)];
    
    [self.discoverArray addObject:NSLocalizedString(@"we_media", nil)];
    [self.discoverArray addObject:NSLocalizedString(@"announcement", nil)];
}

#pragma mark - Table view delegate method

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return self.discoverArray.count;
    else if (section == 1)
        return 1;
    else
        return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"discoverCell";
    
    HXCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        if (indexPath.section == 0)
        {
            switch (indexPath.row) {
                case 0:
                    cell = [[HXCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                                 title:self.discoverArray[indexPath.row]
                                                              photoUrl:nil
                                                                 image:[UIImage imageNamed:@"explore_timeline"]
                                                            badgeValue:0
                                                                 style:HXCustomCellStyleDefault];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    
                    break;
                
                case 1:
                    cell = [[HXCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                                 title:self.discoverArray[indexPath.row]
                                                              photoUrl:nil
                                                                 image:[UIImage imageNamed:@"explore_room"]
                                                            badgeValue:0
                                                                 style:HXCustomCellStyleDefault];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                
                case 2:
                    cell = [[HXCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                                 title:self.discoverArray[indexPath.row]
                                                              photoUrl:nil
                                                                 image:[UIImage imageNamed:@"explore_desk"]
                                                            badgeValue:0
                                                                 style:HXCustomCellStyleDefault];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case 3:
                    cell = [[HXCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                                 title:self.discoverArray[indexPath.row]
                                                              photoUrl:nil
                                                                 image:[UIImage imageNamed:@"explore_chat"]
                                                            badgeValue:0
                                                                 style:HXCustomCellStyleDefault];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case 4:
                    cell = [[HXCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                                 title:self.discoverArray[indexPath.row]
                                                              photoUrl:nil
                                                                 image:[UIImage imageNamed:@"explore_media"]
                                                            badgeValue:0
                                                                 style:HXCustomCellStyleDefault];
                    cell.userInteractionEnabled = NO;
                    [cell.textLabel setAlpha:0.3];
                    break;
                
                case 5:
                    cell = [[HXCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                       reuseIdentifier:cellIdentifier
                                                                 title:self.discoverArray[indexPath.row]
                                                              photoUrl:nil
                                                                 image:[UIImage imageNamed:@"explore_board"]
                                                            badgeValue:0
                                                                 style:HXCustomCellStyleDefault];
                    cell.userInteractionEnabled = NO;
                    [cell.textLabel setAlpha:0.3];
                    break;
                default:
                    break;
            }
 
        }

    }

    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    NSNumber *unreadCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"unreadSocialNoticeCount"];
//    [cell updateBadgeNumber:[unreadCount integerValue]];
    if (indexPath.row == 3) {
        [cell updateBadgeNumber:[MessageUtil getAllUnreadCount]];
    }else if (indexPath.row == 0){
        [cell updateBadgeNumber:[unreadCount integerValue]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"unreadSocialNoticeCount"];
                HXWallViewController *vc = [[HXWallViewController alloc]initWithWallInfo:[[HXUserAccountManager manager].userInfo.toDict mutableCopy]];
                [self.navigationController pushViewController:vc animated:YES];
                [self reloadTableView];
                
                break;
            }
            //群組 by lei
            case 1:
            {
                //[[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"unreadSocialNoticeCount"];
                HXRoomViewController *vc = [[HXRoomViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
                [self reloadTableView];
                
                break;
            }
            
            case 2:
            {
                
                [self.navigationController pushViewController:[[HXAnDeskViewController alloc] init] animated:YES];
                
                break;
            }
                
            case 3:
            {
                [self.tabBarController setSelectedIndex:1];
                break;
            }
                
            default:
                break;
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reloadTableView
{
    if (self.navigationController.viewControllers.count > 1) {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"unreadSocialNoticeCount"];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
