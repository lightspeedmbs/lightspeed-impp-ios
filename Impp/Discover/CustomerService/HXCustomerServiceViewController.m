//
//  HXCustomerServiceViewController.m
//  Impp
//
//  Created by Tim on 4/27/15.
//  Copyright (c) 2015 hsujahhu. All rights reserved.
//

#import "HXCustomerServiceViewController.h"
#import "HXAppUtility.h"
#import "UIColor+CustomColor.h"
#import "HXCustomTableViewCell.h"
#import "ApiCaller.h"
#import "LightspeedCredentials.h"
#import "HXChatViewController.h"
#import "HXIMManager.h"
#import "HXUserAccountManager.h"
#import "HXCustomButton.h"
#import "HXAnSocialManager.h"
#import "UILabel+customLabel.h"
#import "KVNProgress.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height
#define CS_SEARCH_SOCIAL_KEY @"users/query.json"

@interface HXCustomerServiceViewController () <UITableViewDataSource, UITableViewDelegate> //, HXClientStatusDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *customerServiceArray;
@property (strong, nonatomic) NSMutableDictionary *clientStatusDict;
@property (strong, nonatomic) UIView *tableEmptyView;
@end

@implementation HXCustomerServiceViewController

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
    [HXAppUtility initNavigationTitle:NSLocalizedString(@"vip_Customer_helpDesk", nil) barTintColor:[UIColor color1] withViewController:self];
//    [HXAppUtility initNavigationTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo"]]
//                             barTintColor:[UIColor color1]
//                                tintColor:[UIColor color5]
//                       withViewController:self];
}

- (void)initData
{
    [KVNProgress show];
    self.view.userInteractionEnabled = NO;
    self.customerServiceArray = [[NSMutableArray alloc] initWithCapacity:0];
    [[HXAnSocialManager manager] sendRequest:CS_SEARCH_SOCIAL_KEY
                                      method:AnSocialManagerGET
                                      params:@{@"key": LIGHTSPEED_APP_KEY, @"custom_fields": @{@"type": @"representative"}}
                                     success:^(NSDictionary *response) {
                                         if (response[@"response"][@"users"])
                                         {
                                             NSMutableArray *muteUsers = [[NSMutableArray alloc] initWithCapacity:0];
                                             @try {
                                                 for (id user in response[@"response"][@"users"]) {
                                                     if ([user isKindOfClass:[NSDictionary class]]) {
                                                         [muteUsers addObject:user];
                                                     }
                                                 }
                                             }
                                             @catch (NSException *exception) {
                                                 
                                             }
                                             [self.customerServiceArray addObjectsFromArray:muteUsers];
                                             if (!_customerServiceArray.count) {
                                                 if (!self.tableEmptyView) {
                                                     [self addEmptyPage];
                                                 }
                                                 
                                             }else{
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     if (self.tableEmptyView) {
                                                         [self.tableEmptyView removeFromSuperview];
                                                     }
                                                });
                                             }
                                             
                                             
//                                             [HXIMManager manager].clientStatusDelegate = self;
                                             [self updateClientStatus];
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [KVNProgress dismiss];
                                                 self.view.userInteractionEnabled = YES;
                                                 [self.tableView reloadData];
                                             });
                                         }
                                     } failure:^(NSDictionary *response) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [KVNProgress dismiss];
                                             self.view.userInteractionEnabled = YES;
                                         });
                                     }];
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
                                                     title:self.customerServiceArray[indexPath.row][@"customFields"][@"name"]
                                                  photoUrl:nil
                                                     image:[UIImage imageNamed:@"friend_default"]
                                                badgeValue:0
                                                     style:HXCustomCellStyleDefault];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSNumber *unreadCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"unreadSocialNoticeCount"];
    [cell updateBadgeNumber:[unreadCount integerValue]];
    
    HXCustomButton *rejectButton = (HXCustomButton *)[cell viewWithTag:1];
    if (!rejectButton)
    {
        rejectButton = [[HXCustomButton alloc]initWithTitle:NSLocalizedString(@"offline", nil) titleColor:[UIColor redColor] backgroundColor:[UIColor color5]];
        CGRect frame = rejectButton.frame;
        frame.origin = CGPointMake(SCREEN_WIDTH - frame.size.width*3/2 - 15, cell.center.y - frame.size.height/2);
        rejectButton.frame = frame;
        [cell addSubview:rejectButton];
        rejectButton.tag = 1;
        rejectButton.userInteractionEnabled = NO;
    }
    
    HXCustomButton *approveButton = (HXCustomButton *)[cell viewWithTag:2];
    if (!approveButton)
    {
        approveButton = [[HXCustomButton alloc]initWithTitle:NSLocalizedString(@"online", nil) titleColor:[UIColor color3] backgroundColor:[UIColor color5]];
        //    frame = approveButton.frame;
        //    frame.origin = CGPointMake(rejectButton.frame.origin.x - frame.size.width - 6, cell.center.y - frame.size.height/2);
        //    approveB utton.frame = frame;
        approveButton.frame = rejectButton.frame;
        [cell addSubview:approveButton];
        approveButton.tag = 2;
        approveButton.userInteractionEnabled = NO;
    }
    @try {
        if ([self.customerServiceArray[indexPath.row] isKindOfClass:[NSDictionary class]])
        {
            if ([self.clientStatusDict[self.customerServiceArray[indexPath.row][@"clientId"]] isEqualToString:@"YES"])
            {
                approveButton.alpha = 1;
                rejectButton.alpha = 0;
            }
            else
            {
                approveButton.alpha = 0;
                rejectButton.alpha = 1;
            }
        }
    }
    @catch (NSException *exception) {
        approveButton.alpha = 0;
        rejectButton.alpha = 1;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        NSString *clientId = self.customerServiceArray[indexPath.row][@"clientId"];
        HXChatViewController *chatVc;
        if (clientId.length)
            chatVc = [[HXIMManager manager] getChatViewWithTargetClientId:clientId
                                                           targetUserName:self.customerServiceArray[indexPath.row][@"username"]
                                                          currentUserName:[HXUserAccountManager manager].userName];
        [self.navigationController pushViewController:chatVc animated:YES];
    }
    @catch (NSException *exception) {
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

- (void)updateClientStatus
{
    NSMutableSet *clientSet = [[NSMutableSet alloc] initWithCapacity:0];
    for (NSUInteger index = 0; index < self.customerServiceArray.count; index++) {
        NSDictionary *client = self.customerServiceArray[index];
        @try {
            [clientSet addObject:client[@"clientId"]];
        }
        @catch (NSException *exception) {
            continue;
        }
    }
    if (clientSet.count)
    {
        [[HXIMManager manager] getStatusForClients:clientSet
                                           success:^(NSDictionary *clientsStatus) {
                                               if (clientsStatus.count) {
                                                   if (!self.clientStatusDict)
                                                       self.clientStatusDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                                                   if ([clientsStatus allKeys].count)
                                                   {
                                                       for (NSString *key in [clientsStatus allKeys])
                                                       {
                                                           self.clientStatusDict[key] = clientsStatus[key];
                                                       }
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [self.tableView reloadData];
                                                       });
                                                   }
                                               }
                                           } failure:^(ArrownockException *exception) {
                                               
                                           }];

    }
}

- (void)anIMDidGetClientsStatus:(NSDictionary *)clientsStatus exception:(NSString *)exception
{
    if (!self.clientStatusDict)
        self.clientStatusDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    if ([clientsStatus allKeys].count)
    {
        for (NSString *key in [clientsStatus allKeys])
        {
            self.clientStatusDict[key] = clientsStatus[key];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

-(void) addEmptyPage{
    dispatch_async(dispatch_get_main_queue(), ^{
        _tableEmptyView = [[UIView alloc]initWithFrame:self.tableView.bounds];
        //        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptypage2"]];
        //        [tempImageView setFrame:CGRectMake(SCREEN_WIDTH/2-30, 135, 72, 60)];
        //        tempImageView.contentMode = UIViewContentModeScaleAspectFit;
        //
        UILabel *emptyLabel = [UILabel labelWithFrame:CGRectMake(0, SCREEN_HEIGHT * 0.23,SCREEN_WIDTH, 15)
                                                 text:NSLocalizedString(@"no_customer_representatives", nil)
                                        textAlignment:NSTextAlignmentCenter
                                            textColor:[UIColor color8]
                                                 font:[UIFont fontWithName:@"STHeitiTC-Light" size:15]
                                        numberOfLines:1];
        [emptyLabel setFrame:CGRectMake(SCREEN_WIDTH/2-emptyLabel.frame.size.width/2, SCREEN_HEIGHT * 0.3 - 8, emptyLabel.frame.size.width, 16)];
        //[tableEmptyView addSubview:tempImageView];
        [_tableEmptyView addSubview:emptyLabel];
        
        [self.view addSubview: _tableEmptyView];
    });

}
@end
