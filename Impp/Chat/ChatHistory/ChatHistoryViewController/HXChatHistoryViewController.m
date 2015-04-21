//
//  HXChatHistoryViewController.m
//  Impp
//
//  Created by hsujahhu on 2015/3/17.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXChatHistoryViewController.h"
#import "HXAppUtility.h"
#import "HXChatViewController.h"
#import "HXChat+Additions.h"
#import "HXMessage+Additions.h"
#import "HXUser+Additions.h"
#import "UserUtil.h"
#import "ChatUtil.h"
#import "MessageUtil.h"
#import "CoreDataUtil.h"
#import "HXUserAccountManager.h"
#import "NotificationCenterUtil.h"
#import "HXTabBarViewController.h"
#import "HXIMManager.h"
#import "HXChatHistoryTableViewCell.h"
#import "UIColor+CustomColor.h"
#import <CoreData/CoreData.h>
#define VIEW_WIDTH self.view.frame.size.width

@interface HXChatHistoryViewController ()<UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate,UISearchBarDelegate, UISearchDisplayDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *chatHistoryArray;
@property (strong, nonatomic) NSMutableArray *chatHistoryFilterArray;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UISearchBar* searchBar;
@property (strong, nonatomic) UISearchDisplayController* searchController;
@end

@implementation HXChatHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self initNavigationBar];
    
    /* Fix search bar frame bug */
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(fetchChatHistory)
                                                name:RefreshChatHistory
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(showMessageFromNotification:)
                                                name:ShowMessageFromNotificaiton
                                              object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchChatHistory];
}

#pragma mark - Init

- (void)initData
{
    self.chatHistoryArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.chatHistoryFilterArray = [[NSMutableArray alloc]initWithCapacity:0];
}

- (void)initView
{
    CGRect frame;
    
    /* search bar */
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f,0.0f,VIEW_WIDTH, 44.0f)];
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.searchBar setTranslucent:NO];
    [self.searchBar setShowsCancelButton:NO];
    self.searchBar.delegate = self;
    self.searchBar.tintColor = [UIColor color11];
    self.searchBar.placeholder = NSLocalizedString(@"搜尋好友和群組", nil);
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:NSLocalizedString(@"取消", nil)];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor color2]];
    [self.view addSubview:self.searchBar];
    
    /* search controller */
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsTitle = @"沒有結果";
    self.searchController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setSearchController:self.searchController];
    [self.searchController setDelegate:self];
    [self.searchController setSearchResultsDelegate:self];
    [self.searchController setSearchResultsDataSource:self];
    
    frame = self.view.frame;
    frame.origin.y = self.searchBar.frame.size.height + self.searchBar.frame.origin.y;
    frame.size.height -= 64 + self.tabBarController.tabBar.frame.size.height + self.searchBar.frame.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    //self.tableView.backgroundColor = [UIColor clearColor];
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

#pragma mark - TableView Delegate Datasource

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 74;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchController.searchResultsTableView)
        return self.chatHistoryFilterArray.count;
    else
        return self.chatHistoryArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellIdentifier = @"chatHistoryCell";
    
    HXChat *chatSession;
    
    if (tableView == self.searchController.searchResultsTableView)
        chatSession = self.chatHistoryFilterArray[indexPath.row];
    else
        chatSession = self.chatHistoryArray[indexPath.row];
    
    HXMessage *lastMessage = [ChatUtil getLastMessage:chatSession];
    NSString *lastStr = [MessageUtil configureLastMessage:lastMessage];
    NSInteger unreadCount = [ChatUtil unreadCount:chatSession];

    if (![chatSession.topicId isEqualToString:@""]) {
        NSString *topicName = [NSString stringWithFormat:@"%@ (%d)",chatSession.topicName,(int)chatSession.users.count + 1];
        HXChatHistoryTableViewCell *cell = [[HXChatHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                                             reuseIdentifier:cellIdentifier
                                                                                       title:topicName
                                                                                    subtitle:lastStr
                                                                                   timestamp:lastMessage.timestamp
                                                                                    photoUrl:@""
                                                                            placeholderImage:[UIImage imageNamed:@"friend_group"]
                                                                                  badgeValue:unreadCount];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else{
        NSArray *users = [chatSession.users allObjects];
        NSString *userName;
        NSString *photoUrl;
        for(HXUser *user in users){
            if (![user.userName isEqualToString:[HXUserAccountManager manager].userInfo.userName]) {
                userName = user.userName;
                photoUrl = user.photoURL;
            }
        }
        if (!users.count) {
            HXUser *user = [UserUtil getHXUserByClientId:chatSession.targetClientId];
            userName = user.userName;
            photoUrl = user.photoURL;
            [chatSession addUsersObject:user];
        }
        
        HXChatHistoryTableViewCell *cell = [[HXChatHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                                             reuseIdentifier:cellIdentifier
                                                                                       title:userName
                                                                                    subtitle:lastStr
                                                                                   timestamp:lastMessage.timestamp
                                                                                    photoUrl:photoUrl
                                                                            placeholderImage:[UIImage imageNamed:@"friend_default"]
                                                                                  badgeValue:unreadCount];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    HXChat *chatSession;
    if (tableView == self.searchController.searchResultsTableView)
        chatSession = self.chatHistoryFilterArray[indexPath.row];
    else
        chatSession = self.chatHistoryArray[indexPath.row];
    
    BOOL isTopicMode = [chatSession.topicId isEqualToString:@""] ? NO:YES;
    HXChatViewController *chatVc = [[HXChatViewController alloc]initWithChatInfo:chatSession setTopicMode:isTopicMode];
    [self.navigationController pushViewController:chatVc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        // Remove the row from data model
        NSMutableArray* chatSessions;
        if (tableView == self.searchController.searchResultsTableView)
            chatSessions = self.chatHistoryFilterArray;
        else
            chatSessions = self.chatHistoryArray;
        
        [ChatUtil deleteChatHistory:chatSessions[indexPath.row]];
        [chatSessions removeObjectAtIndex:indexPath.row];
        
        // Request table view to reload
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        [self.tableView reloadData];
    }
}


#pragma mark - Fetch Chat History in DB
- (void)fetchChatHistory
{
    NSError* error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    [self.chatHistoryArray removeAllObjects];
    
    if ([HXUserAccountManager manager].userId) {
        for (int i = 0; i < self.fetchedResultsController.fetchedObjects.count; i++) {
            
            HXChat* chat = self.fetchedResultsController.fetchedObjects[i];
            [self.chatHistoryArray addObject:chat];
        }
    }

    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
    });
}
#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.placeholder = NSLocalizedString(@"請輸入好友或群組名稱", nil);
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.placeholder = NSLocalizedString(@"搜尋好友和群組", nil);
}

#pragma mark - UISearchDisplayDelegate

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"ANY users.UserName contains[c] %@ || topicName contains[c] %@", searchText,searchText];
    self.chatHistoryFilterArray = [[self.chatHistoryArray filteredArrayUsingPredicate:resultPredicate]mutableCopy];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

#pragma mark - Show remote notification chat view

- (void)showMessageFromNotification:(NSNotification *)notice
{
    NSDictionary *noticeInfo = notice.object;
    HXChat *chatSession = noticeInfo[@"chatSession"];
    BOOL isTopicMode = [noticeInfo[@"mode"] isEqualToString:@"topic"] ? YES:NO;
    HXChatViewController *chatVc = [[HXChatViewController alloc]initWithChatInfo:chatSession setTopicMode:isTopicMode];
    [self.navigationController pushViewController:chatVc animated:NO];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HXChat"
                                              inManagedObjectContext:[CoreDataUtil sharedContext]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat
                                :@"currentClientId == %@ && ANY messages != nil",
                                [HXIMManager manager].clientId]];
    //[fetchRequest setPredicate:nil];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedTimestamp"
                                                                   ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[CoreDataUtil sharedContext]
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef DEBUG
        // Do NOT use abort() in product.
        abort();
#endif
    }
    
    return _fetchedResultsController;
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    //[self.tableView reloadData];
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
