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
#import "UILabel+customLabel.h"
#import "KVNProgress.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height
@interface HXFriendRequestViewController ()<UITableViewDataSource, UITableViewDelegate, HXFriendRequestTableViewCellDelegate>
@property (strong, nonatomic) NSMutableArray *friendRequestsArray;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *tableEmptyView;
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
    =[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
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
    [HXAppUtility initNavigationTitle:NSLocalizedString(@"friend_request", nil) barTintColor:[UIColor color1] withViewController:self];
}

#pragma mark - fetch Data

- (void)fetchFriendRequest
{
    NSDictionary *params = @{@"to_user_id":[HXUserAccountManager manager].userId,
                             @"status":@"pending"};
    

    [KVNProgress show];
    self.view.userInteractionEnabled = NO;
    
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
        if (!_friendRequestsArray.count) {
            if (!self.tableEmptyView) {
                [self addEmptyPage];
            }
//            [self addEmptyPage];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.tableEmptyView) {
                    [self.tableEmptyView removeFromSuperview];
                }
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [KVNProgress dismiss];
            self.view.userInteractionEnabled = YES;
        });
    } failure:^(NSDictionary* response){
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
            self.view.userInteractionEnabled = YES;
        });
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
    NSDictionary *params = @{@"request_id":requestId,
                             @"keep_request":@"false"};
    
    [[HXAnSocialManager manager]sendRequest:@"friends/requests/approve.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        //NSLog(@"success log: %@",[response description]);
    
    
    } failure:^(NSDictionary* response){
        
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
    
    params = @{@"user_id":[HXUserAccountManager manager].userId,
               @"target_user_id":userId};
    
    [[HXAnSocialManager manager]sendRequest:@"friends/add.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        NSLog(@"success log: %@",[response description]);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *friendInfo = response[@"response"][@"friend"];
            HXUser * friend = [UserUtil saveUserIntoDB:friendInfo];
            [UserUtil updatedUserFriendsWithCurrentUser:[HXUserAccountManager manager].userInfo targetUser:friend];
            [[NSNotificationCenter defaultCenter] postNotificationName:RefreshFriendList object:nil];

        });
        
    } failure:^(NSDictionary* response){
        
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
    
    [[HXIMManager manager] sendFriendRequestApprovedMessageWithClientId:clientId];
}

- (void)didRejectButtonTappedWithRequestId:(NSString *)requestId
{
    NSDictionary *params = @{@"request_id":requestId,
                             @"keep_request":@"false"
                             };
    
    [[HXAnSocialManager manager]sendRequest:@"friends/requests/reject.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        NSLog(@"success log: %@",[response description]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeImppToast:NSLocalizedString(@"rejected_friend_request", nil) navigationBarHeight:64];
        });
        
    } failure:^(NSDictionary* response){
        
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) addEmptyPage{
    dispatch_async(dispatch_get_main_queue(), ^{
        _tableEmptyView = [[UIView alloc]initWithFrame:self.tableView.bounds];
        
        UILabel *emptyLabel = [UILabel labelWithFrame:CGRectMake(0, SCREEN_HEIGHT * 0.23,SCREEN_WIDTH, 15)
                                                 text:NSLocalizedString(@"no_friend_request", nil)
                                        textAlignment:NSTextAlignmentCenter
                                            textColor:[UIColor color8]
                                                 font:[UIFont fontWithName:@"STHeitiTC-Light" size:15]
                                        numberOfLines:1];
        [emptyLabel setFrame:CGRectMake(SCREEN_WIDTH/2-emptyLabel.frame.size.width/2, SCREEN_HEIGHT * 0.3 - 8, emptyLabel.frame.size.width, 16)];
        //[tableEmptyView addSubview:tempImageView];
        [_tableEmptyView addSubview:emptyLabel];
        
        self.tableView.backgroundView = _tableEmptyView;
    });
    
}


@end
