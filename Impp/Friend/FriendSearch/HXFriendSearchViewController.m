//
//  HXFriendSearchViewController.m
//  Impp
//
//  Created by Herxun on 2015/3/31.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXFriendSearchViewController.h"
#import "HXAppUtility.h"
#import "UIColor+CustomColor.h"
#import "UILabel+customLabel.h"
#import "UIFont+customFont.h"
#import "HXAnSocialManager.h"
#import "UIView+Toast.h"
#import "HXCustomButton.h"
#import "UserUtil.h"
#import "HXCustomTableViewCell.h"
#import "HXUserAccountManager.h"
#import "HXIMManager.h"
#import "HXFriendProfileViewController.h"
#import "HXUser+Additions.h"
#import "UIColor+CustomColor.h"

#define VIEW_WIDTH self.view.frame.size.width
@interface HXFriendSearchViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, HXCustomCellSearchDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *usersArray;
@property (strong, nonatomic) UISearchBar* searchBar;
@end

@implementation HXFriendSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.searchBar resignFirstResponder];
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
    }
    return self;
}

- (void)initData
{
    self.usersArray = [[NSMutableArray alloc]initWithCapacity:0];
}

- (void)initView
{
    /* search bar */
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f,0.0f, VIEW_WIDTH, 44.0f)];
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.searchBar setTranslucent:NO];
    [self.searchBar setShowsCancelButton:NO];
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor color11];
    self.searchBar.placeholder = NSLocalizedString(@"請輸入好友名稱並按下搜尋", nil);
    [self.view addSubview:self.searchBar];
    
    /* tableView */
    CGRect frame = self.view.frame;
    frame.size.height -= 64 + self.searchBar.frame.size.height;
    frame.origin.y = self.searchBar.frame.origin.y + self.searchBar.frame.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

- (void)initNavigationBar
{
    [HXAppUtility initNavigationTitle:NSLocalizedString(@"加入新好友", nil) barTintColor:[UIColor color1] withViewController:self];
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
    return self.usersArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"friendSearchCell";
    
    HXCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    HXUser *user = self.usersArray[indexPath.row];
    
    if (cell == nil)
    {
        cell = [[HXCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier title:user.userName photoUrl:user.photoURL image:[UIImage imageNamed:@"friend_default"] badgeValue:0 style:HXCustomCellStyleSearch];
    }else{
        [cell reuseCellWithTitle:user.userName photoUrl:user.photoURL image:[UIImage imageNamed:@"friend_default"] badgeValue:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    [cell setButtonTag:indexPath.row];
    
    if ([UserUtil checkFriendRelationshipWithCliendId:user.clientId]) {
        
        [cell showLabelWithTitle:NSLocalizedString(@"已是好友", nil)];
        
    }else if ([UserUtil checkFollowRelationshipWithCliendId:user.clientId]){
        
        [cell updateTitle:NSLocalizedString(@"已送邀請", nil) TitleColor:[UIColor color1]];
        [cell setButtonDisable];
        
    }else{
        [cell updateTitle:NSLocalizedString(@"加入好友", nil) TitleColor:[UIColor color3]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - HXCustomCell search delegate

- (void)customCellButtonTapped:(UIButton *)sender
{
    HXUser *user = self.usersArray[sender.tag];
    HXCustomButton *button = (HXCustomButton *)sender;
    [button updateTitle:NSLocalizedString(@"已送邀請", nil) TitleColor:[UIColor color1]];
    button.enabled = NO;
    NSDictionary *params = @{@"user_id":[HXUserAccountManager manager].userId,
                             @"target_user_id":user.userId};
    
    [[HXAnSocialManager manager]sendRequest:@"friends/requests/send.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        NSLog(@"success log: %@",[response description]);
        
    } failure:^(NSDictionary* response){
        
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
    
    params = @{@"user_id":[HXUserAccountManager manager].userId,
               @"target_user_id":user.userId};
    
    [[HXAnSocialManager manager]sendRequest:@"friends/add.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        NSLog(@"success log: %@",[response description]);
        
        HXUser *user = [UserUtil saveUserIntoDB:response[@"response"][@"friend"]];
        [UserUtil updatedUserFollowsWithCurrentUser:[HXUserAccountManager manager].userInfo targetUser:user];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeImppToast:NSLocalizedString(@"發送好友請求成功", nil) navigationBarHeight:64];
        });
    } failure:^(NSDictionary* response){
        
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
    
    [[HXIMManager manager] sendFriendRequestMessageWithClientId:user.clientId targetUserName:user.userName];
    
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:searchBar.text forKey:@"username"];
    
    [[HXAnSocialManager manager]sendRequest:@"users/search.json" method:AnSocialManagerGET params:params success:^(NSDictionary* response){
        NSLog(@"success log: %@",[response description]);
        NSMutableArray *tempUsersArray = [response[@"response"][@"users"] mutableCopy];
    
        
        /* To sync with server*/
        [self.usersArray removeAllObjects];
        
        for (NSDictionary *user in tempUsersArray)
        {
            
            NSDictionary *reformedUser = [UserUtil reformUserInfoDic:user];
            
            HXUser *hxUser = [UserUtil getHXUserByUserId:reformedUser[@"userId"]];
            
            if (hxUser == nil) {
                hxUser = [HXUser initWithDict:reformedUser];
            }else{
                //update
                [hxUser setValuesFromDict:reformedUser];
            }
            
            if (![hxUser.clientId isEqualToString:[HXIMManager manager].clientId]) {
                [self.usersArray addObject:hxUser];
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
       
    } failure:^(NSDictionary* response){
        
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
