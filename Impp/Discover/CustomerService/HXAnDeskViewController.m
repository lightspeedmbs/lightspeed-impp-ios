//
//  HXAnDeskViewController.m
//  Impp
//
//  Created by Tim on 4/29/15.
//  Copyright (c) 2015 hsujahhu. All rights reserved.
//

#import "HXAnDeskViewController.h"
#import "HXAppUtility.h"
#import "UIColor+CustomColor.h"
#import "HXCustomTableViewCell.h"
#import "HXCustomerServiceViewController.h"

@interface HXAnDeskViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *customerServiceArray;

@end

@implementation HXAnDeskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self initNavigationBar];
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
    [HXAppUtility initNavigationTitle:NSLocalizedString(@"customer_service_title", nil) barTintColor:[UIColor color1] withViewController:self];
//    [HXAppUtility initNavigationTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo"]]
//                             barTintColor:[UIColor color1]
//                                tintColor:[UIColor color5]
//                       withViewController:self];
}

- (void)initData
{

    self.customerServiceArray = [@[NSLocalizedString(@"vip_Customer_helpDesk", nil),
                                   NSLocalizedString(@"products", nil),
                                   NSLocalizedString(@"services", nil),
                                   NSLocalizedString(@"contact_us", nil)] mutableCopy];
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
   return self.customerServiceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"discoverCell";
    HXCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[HXCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:cellIdentifier
                                                     title:self.customerServiceArray[indexPath.row]
                                                  photoUrl:nil
                                                     image:[UIImage imageNamed:@"friend_default"]
                                                badgeValue:0
                                                     style:HXCustomCellStyleDefault];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else
    {
        cell.userInteractionEnabled = NO;
        cell.textLabel.enabled = NO;
        cell.detailTextLabel.enabled = NO;
    }
//    NSNumber *unreadCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"unreadSocialNoticeCount"];
//    [cell updateBadgeNumber:[unreadCount integerValue]];
//        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            HXCustomerServiceViewController *vc = [[HXCustomerServiceViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
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
