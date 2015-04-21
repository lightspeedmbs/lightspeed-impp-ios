//
//  HXFriendRequestViewController.m
//  Impp
//
//  Created by hsujahhu on 2015/3/19.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXFriendRequestViewController.h"
#import "HXAnSocialManager.h"
#import "HXUserAccountManager.h"
#import "HXAppUtility.h"
#import "HXFriendRequestTableViewCell.h"
#import "HXIMManager.h"
#import "HXUser+Additions.h"
#import "NotificationCenterUtil.h"
#import "UIColor+CustomColor.h"
#import "UIView+Toast.h"
#import "UserUtil.h"

@interface HXFriendRequestViewController ()<UITableViewDataSource, UITableViewDelegate, HXFriendRequestTableViewCellDelegate>
@property (strong, nonatomic) NSMutableArray *friendRequestsArray;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation HXFriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{

}

-(void)viewWillLayoutSubviews{
    self.navigationController.navigationBar.backItem.backBarButtonItem
    =[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回", nil)
                                      style:UIBarButtonItemStylePlain
                                     target:self
                                     action:nil];
}

#pragma mark - Initialize

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        [self initData];
        [self initView];
        [self initNavigationBar];
        [self fetchFriendRequest];
    }
    return self;
}

- (void)initData
{
    self.friendRequestsArray = [[NSMutableArray alloc]initWithCapacity:0];
}

- (void)initView
{
    /* tableView */
    CGRect frame = self.view.frame;
    frame.size.height -= 64;
    frame.origin.y = 0;
    self.tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

- (void)initNavigationBar
{
    [HXAppUtility initNavigationTitle:NSLocalizedString(@"好友請求", nil) barTintColor:[UIColor color1] withViewController:self];
}

#pragma mark - fetch Data

- (void)fetchFriendRequest
{
    NSDictionary *params = @{@"to_user_id":[HXUserAccountManager manager].userId,
                             @"status":@"pending"};
    
    [[HXAnSocialManager manager]sendRequest:@"friends/requests/list.json" method:AnSocialManagerGET params:params success:^(NSDictionary* response){
        NSLog(@"success log: %@",[response description]);
        NSArray *friendRequests = response[@"response"][@"friendRequests"];
        for (NSDictionary *friendRequest in friendRequests)
        {
            NSMutableDictionary *request = [friendRequest[@"from"] mutableCopy];
            [request setObject:friendRequest[@"status"] forKey:@"status"];
            [request setObject:friendRequest[@"id"] forKey:@"requestId"];
            [self.friendRequestsArray addObject:request];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(NSDictionary* response){
        
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
}

#pragma mark - Listener

- (void)cancelButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view delegate method

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
    return self.friendRequestsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"friendRequestCell";
    HXFriendRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[HXFriendRequestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:cellIdentifier
                                                         userInfo:self.friendRequestsArray[indexPath.row]];
        cell.delegate = self;
    }else {
        [cell reuseCellWithUserInfo:self.friendRequestsArray[indexPath.row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.row)
    {
            
    }
}

#pragma mark - Friend request delegate

- (void)didApproveButtonTappedWithRequestId:(NSString *)requestId targetClientId:(NSString *)clientId targetUserId:(NSString *)userId
{
    NSDictionary *params = @{@"request_id":requestId};
    
    [[HXAnSocialManager manager]sendRequest:@"friends/requests/approve.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        //NSLog(@"success log: %@",[response description]);
    
    
    } failure:^(NSDictionary* response){
        
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
    
    params = @{@"user_id":[HXUserAccountManager manager].userId,
               @"target_user_id":userId};
    
    [[HXAnSocialManager manager]sendRequest:@"friends/add.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        NSLog(@"success log: %@",[response description]);
        
        NSDictionary *friendInfo = response[@"response"][@"friend"];
        HXUser * friend = [UserUtil saveUserIntoDB:friendInfo];
        [UserUtil updatedUserFriendsWithCurrentUser:[HXUserAccountManager manager].userInfo targetUser:friend];
        [[NSNotificationCenter defaultCenter] postNotificationName:RefreshFriendList object:nil];
        
    } failure:^(NSDictionary* response){
        
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
    
    [[HXIMManager manager] sendFriendRequestApprovedMessageWithClientId:clientId];
}

- (void)didRejectButtonTappedWithRequestId:(NSString *)requestId
{
    NSDictionary *params = @{@"request_id":requestId};
    
    [[HXAnSocialManager manager]sendRequest:@"friends/requests/reject.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        NSLog(@"success log: %@",[response description]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeImppToast:NSLocalizedString(@"拒絕好友請求成功", nil) navigationBarHeight:64];
        });
        
    } failure:^(NSDictionary* response){
        
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
