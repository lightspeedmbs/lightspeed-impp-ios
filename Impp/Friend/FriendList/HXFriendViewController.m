//
//  HXFriendViewController.m
//  Impp
//
//  Created by hsujahhu on 2015/3/17.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXFriendViewController.h"
#import "HXIMManager.h"
#import "HXUser+Additions.h"
#import "HXUserAccountManager.h"
#import "HXAnSocialManager.h"
#import "CoreDataUtil.h"
#import "UserUtil.h"
#import "ChatUtil.h"
#import "HXFriendProfileViewController.h"
#import "HXChat+Additions.h"
#import "HXFriendRequestViewController.h"
#import "HXFriendSelectionViewController.h"
#import "HXChatViewController.h"
#import "HXAppUtility.h"
#import "NotificationCenterUtil.h"
#import "UIColor+CustomColor.h"
#import "MessageUtil.h"
#import "HXFriendSearchViewController.h"
#import "HXCustomTableViewCell.h"
#import <CoreData/CoreData.h>

#define STATUS_BAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define VIEW_WIDTH self.view.frame.size.width
#define STATIC_CELL_ARRAY @[@"新的朋友",@"群組聊天"];
#define ADD_FRIEND_REQUEST @"_ADD_FRIEND_REQUEST_"
#define FRIEND_REQUEST_APPROVE @"_FRIEND_REQUEST_APPROVE_"
#define FRIEND_REQUEST_REJECT @"_FRIEND_REQUEST_REJECT_"

@interface HXFriendViewController ()<UITableViewDataSource, UITableViewDelegate ,UIActionSheetDelegate, UISearchBarDelegate, UISearchDisplayDelegate, HXIMManagerTopicDelegate, HXCustomCellDefaultDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSMutableArray *topicsArray;
@property (strong, nonatomic) NSMutableArray *friendsFilterArray;
@property (strong, nonatomic) NSMutableArray *topicsFilterArray;
@property (strong, nonatomic) UISearchBar* contactSearchBar;
@property (strong, nonatomic) UISearchDisplayController* searchController;
@end

@implementation HXFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init
    [self initData];
    [self initView];
    [self initNavigationBar];
    
    /* Fix search bar frame bug */
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateList) name:RefreshFriendList object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self updateList];
}

- (void)viewWillDisappear:(BOOL)animated
{

}

- (void)initData
{
    self.topicsArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.friendsArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.topicsFilterArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.friendsFilterArray = [[NSMutableArray alloc]initWithCapacity:0];
}

- (void)initView
{
    
    /* search bar */
    self.contactSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f,0.0f,VIEW_WIDTH, 44.0f)];
    [self.contactSearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.contactSearchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.contactSearchBar setTranslucent:NO];
    [self.contactSearchBar setShowsCancelButton:NO];
    self.contactSearchBar.delegate = self;
    self.contactSearchBar.tintColor = [UIColor color11];
    self.contactSearchBar.placeholder = NSLocalizedString(@"搜尋好友和群組", nil);
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:NSLocalizedString(@"取消", nil)];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor color2]];
    [self.view addSubview:self.contactSearchBar];
    
    /* search controller */
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.contactSearchBar contentsController:self];
    
    [self.searchController setValue:[NSNumber numberWithInt:UITableViewStyleGrouped]
                             forKey:@"_searchResultsTableViewStyle"];
    self.searchController.searchResultsTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.searchController.searchResultsTitle = @"沒有結果";
    [self setSearchController:self.searchController];
    [self.searchController setDelegate:self];
    [self.searchController setSearchResultsDelegate:self];
    [self.searchController setSearchResultsDataSource:self];
    
    /* tableView */
    CGRect frame = self.view.frame;
    frame.size.height -= 64 + self.contactSearchBar.frame.size.height + self.tabBarController.tabBar.frame.size.height;
    frame.origin.y = self.contactSearchBar.frame.origin.y + self.contactSearchBar.frame.size.height;
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
    
    UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createButtonTapped)];
    [self.navigationItem setRightBarButtonItem:createBarButton];
}

#pragma mark - Listener

- (void)createButtonTapped
{
    NSString *button1 = NSLocalizedString(@"加入新好友", nil);
    NSString *button2 = NSLocalizedString(@"新增群組聊天", nil);
    
    NSString *cancelTitle = NSLocalizedString(@"取消", nil);
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:button1, button2, nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIActionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
        case 0: {
            HXFriendSearchViewController *vc = [[HXFriendSearchViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1: {
            HXFriendSelectionViewController *vc = [[HXFriendSelectionViewController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Fetch Method

- (void)updateList
{
    [HXUserAccountManager manager].userInfo = [UserUtil getHXUserByClientId:[HXIMManager manager].clientId];
    self.topicsArray = [[[HXUserAccountManager manager].userInfo.topics allObjects]mutableCopy];
    self.topicsArray = [[self.topicsArray sortedArrayUsingComparator:(NSComparator)^(HXChat* obj1, HXChat* obj2){
        NSString *lastName1 = obj1.topicName;
        NSString *lastName2 = obj2.topicName;
        return [lastName1 compare:lastName2]; }] mutableCopy];
    
    self.friendsArray = [[[HXUserAccountManager manager].userInfo.friends allObjects]mutableCopy];
    self.friendsArray = [[self.friendsArray sortedArrayUsingComparator:(NSComparator)^(HXUser* obj1, HXUser* obj2){
        NSString *lastName1 = obj1.userName;
        NSString *lastName2 = obj2.userName;
        return [lastName1 compare:lastName2]; }] mutableCopy];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view delegate method

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchController.searchResultsTableView)
    {
        switch(section)
        {
            case 0: return (self.topicsFilterArray.count) ? 56 : 0.5;
            case 1: return (self.friendsFilterArray.count) ? 56 : 0.5;
            default:return 0;
        };
    }
    else
    {
        switch(section)
        {
            case 0: return 36;
            case 1: return 56;
            case 2: return 56;
            default:return 0;
        };
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchController.searchResultsTableView)
    {
        return 2;
    }
    else
    {
        return 3;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchController.searchResultsTableView) {
        switch(section)
        {
            case 0: return (self.topicsFilterArray.count) ? NSLocalizedString(@"群組列表", nil) : @"";
            case 1: return (self.friendsFilterArray.count) ? NSLocalizedString(@"好友列表", nil) : @"";
            default:return nil;
        };
    }else{
        switch(section)
        {
            case 0: return @"";
            case 1: return NSLocalizedString(@"群組列表", nil);
            case 2: return NSLocalizedString(@"好友列表", nil);
            default:return nil;
        };
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchController.searchResultsTableView)
    {
        switch(section)
        {
            case 0: return self.topicsFilterArray.count;
            case 1: return self.friendsFilterArray.count;
            default:return 0;
        };
    }
    else
    {
        switch(section)
        {
            case 0: return 1;
            case 1: return self.topicsArray.count;
            case 2: return self.friendsArray.count;
            default:return 0;
        };
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"friendListCell";
    
    HXCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSString *title;
    UIImage *image;
    NSString *photoUrl;
    NSInteger badgeValue = 0;
    if (tableView == self.searchController.searchResultsTableView) {
        
        if (indexPath.section == 0) {
            HXChat *topic = self.topicsFilterArray[indexPath.row];
            title = [NSString stringWithFormat:@"%@ (%d)",topic.topicName,(int)topic.users.count + 1];
            image = [UIImage imageNamed:@"friend_group"];
        }else{
            HXUser *user = self.friendsFilterArray[indexPath.row];
            title = user.userName;
            image = [UIImage imageNamed:@"friend_default"];
            photoUrl = user.photoURL;
        }
        
    }else{
        
        if (indexPath.section == 0){
            
            title = NSLocalizedString(@"好友請求", nil);
            image = [UIImage imageNamed:@"friend_request"];
            NSNumber *unreadCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"unreadFriendRequestCount"];
            badgeValue = [unreadCount integerValue];
            
        }else if (indexPath.section == 1){
            NSArray *tests = self.topicsArray;
            HXChat *chat = tests[indexPath.row];
            title = [NSString stringWithFormat:@"%@ (%d)",chat.topicName,(int)chat.users.count + 1];
            image = [UIImage imageNamed:@"friend_group"];
            
        }else {
            HXUser *user = self.friendsArray[indexPath.row];
            title = user.userName;
            image = [UIImage imageNamed:@"friend_default"];
            photoUrl = user.photoURL;
        }
    }
        
    if (cell == nil)
    {
        cell = [[HXCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier
                                                      title:title
                                                   photoUrl:photoUrl
                                                      image:image
                                                 badgeValue:badgeValue
                                                      style:HXCustomCellStyleDefault];
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        [cell reuseCellWithTitle:title photoUrl:photoUrl image:image badgeValue:badgeValue];
    }
    cell.defaultDelegate = self;
    [cell setIndexValue:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (tableView == self.searchController.searchResultsTableView) {
            
            //[self.contactSearchBar resignFirstResponder];
            [self.searchController setActive:NO animated:YES];
            HXChat *topicSession = self.topicsFilterArray[indexPath.row];
            HXChatViewController *chatVc = [[HXChatViewController alloc]initWithChatInfo:topicSession setTopicMode:YES];
            [self.navigationController pushViewController:chatVc animated:YES];
            
        }else{
            if (indexPath.row == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"unreadFriendRequestCount"];
                HXFriendRequestViewController *vc = [[HXFriendRequestViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        
    }else if (indexPath.section == 1){
        
        if (tableView == self.searchController.searchResultsTableView) {
            [self.searchController setActive:NO animated:YES];
            HXUser *user = self.friendsFilterArray[indexPath.row];

            [self showFriendProfile:user];
        }else{
            HXChat *topicSession = self.topicsArray[indexPath.row];
            HXChatViewController *chatVc = [[HXChatViewController alloc]initWithChatInfo:topicSession setTopicMode:YES];
            [self.navigationController pushViewController:chatVc animated:YES];
        }
        
    }else if (indexPath.section == 2){
        
        HXUser *user = self.friendsArray[indexPath.row];

        [self showFriendProfile:user];
    }
}

#pragma mark - HXCustomCell default delegate

- (void)customCellPhotoTapped:(NSUInteger)index
{
//    HXFriendProfileViewController *vc = [[HXFriendProfileViewController alloc]initWithUserInfo:self.friendsArray[index]];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
//    [self presentViewController:nav animated:YES completion:nil];
//    NSLog(@"%d",(int)index);
}

#pragma mark - UISearchDisplayDelegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"userName contains[c] %@", searchText];
    self.friendsFilterArray = [[self.friendsArray filteredArrayUsingPredicate:resultPredicate]mutableCopy];
    
    resultPredicate = [NSPredicate predicateWithFormat:@"topicName contains[c] %@", searchText];
    self.topicsFilterArray = [[self.topicsArray filteredArrayUsingPredicate:resultPredicate]mutableCopy];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.contactSearchBar scopeButtonTitles]
                                      objectAtIndex:[self.contactSearchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Helper

- (void)showFriendProfile:(HXUser *)user
{
    HXFriendProfileViewController *vc = [[HXFriendProfileViewController alloc]initWithUserInfo:user withViewController:self];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
