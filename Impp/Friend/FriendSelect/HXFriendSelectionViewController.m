//
//  HXFriendSelectionViewController.m
//  Impp
//
//  Created by Herxun on 2015/4/1.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXFriendSelectionViewController.h"
#import "HXAppUtility.h"
#import "HXUserAccountManager.h"
#import "HXChatViewController.h"
#import "HXUser+Additions.h"
#import "UserUtil.h"
#import "ChatUtil.h"
#import "MessageUtil.h"
#import "HXIMManager.h"
#import "HXTabBarViewController.h"
#import "UIColor+CustomColor.h"
#import "HXCustomTableViewCell.h"
#import <CoreData/CoreData.h>

#define VIEW_WIDTH self.view.frame.size.width
@interface HXFriendSelectionViewController ()<UITableViewDataSource, UITableViewDelegate, HXIMManagerTopicDelegate,
NSFetchedResultsControllerDelegate,UISearchBarDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSMutableArray *friendsFilterArray;
@property (strong, nonatomic) NSMutableArray *selectedFriendsArray;
@property (strong, nonatomic) NSMutableDictionary *tempChatInfo;
@property (strong, nonatomic) UISearchBar *friendSearchBar;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UIBarButtonItem *finishBarButton;
@property (strong, nonatomic) HXChat *topicSession;
@end

@implementation HXFriendSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initNavigationBar];
    [self fetchFriendsList];
}

#pragma mark - Init UI

- (id)initWithTopicSession:(HXChat *)topicSession
{
    self = [super init];
    if (self) {
        self.topicSession = topicSession;
    }
    return self;
}

- (void)initView
{
    self.tempChatInfo = [[NSMutableDictionary alloc]initWithCapacity:0];
    self.view.backgroundColor = [UIColor color5];
    /* search bar */
    self.friendSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f,0, VIEW_WIDTH, 44.0f)];
    [self.friendSearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.friendSearchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.friendSearchBar setTranslucent:NO];
    [self.friendSearchBar setShowsCancelButton:NO];
    self.friendSearchBar.delegate = self;
    self.friendSearchBar.tintColor = [UIColor color11];
    self.friendSearchBar.placeholder = NSLocalizedString(@"search_by_name", nil);
    [self.view addSubview:self.friendSearchBar];
    
    /* tableView */
    CGRect frame = self.view.frame;
    frame.size.height -= 64 + self.friendSearchBar.frame.size.height;
    frame.origin.y = self.friendSearchBar.frame.origin.y + self.friendSearchBar.frame.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:self.tableView];
    [self.tableView setEditing:YES];
    /* contacts */
    self.friendsArray = [[NSMutableArray alloc]initWithCapacity:0];
    
}

- (void)initNavigationBar
{
    [HXAppUtility initNavigationTitle:NSLocalizedString(@"create_group_chat", nil) barTintColor:[UIColor color1] withViewController:self];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:34/2];
    [cancelButton sizeToFit];
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    [self.navigationItem setLeftBarButtonItem:cancelBarButton];
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton addTarget:self action:@selector(finishButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [finishButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    finishButton.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:34/2];
    [finishButton sizeToFit];
    self.finishBarButton = [[UIBarButtonItem alloc] initWithCustomView:finishButton];
}

#pragma mark - Listener

- (void)finishButtonTapped
{
    
    
    
    NSMutableArray *selectedItems = [[NSMutableArray alloc]initWithCapacity:0];
    NSMutableArray *selectedClientIds = [[NSMutableArray alloc]initWithCapacity:0];
    NSMutableString* topicName = [[NSMutableString alloc] init];
    
    /* add currentUser */
    HXUser *currentUser = [HXUserAccountManager manager].userInfo;
    [topicName setString:currentUser.userName];
    [selectedClientIds addObject:currentUser.clientId];
    [selectedItems addObject:currentUser];
    [self.topicSession addUsersObject:currentUser];
    for (HXUser *user in self.selectedFriendsArray)
    {
        [selectedItems addObject:user];
        [selectedClientIds addObject:user.clientId];
        [topicName appendString:[NSString stringWithFormat:@", %@",user.userName]];
        if (self.topicSession) {
            [self.topicSession addUsersObject:user];
        }
    }
    
    [self.tempChatInfo setObject:selectedItems forKey:@"users"];
    [self.tempChatInfo setObject:topicName forKey:@"title"];
    NSSet *clientIds = [NSSet setWithArray:selectedClientIds];
    
    if (self.topicSession){
        [[[HXIMManager manager]anIM] addClients:clientIds toTopicId:self.topicSession.topicId success:^(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp) {
            NSLog(@"AnIM addClients successful");
        } failure:^(ArrownockException *exception) {
            NSLog(@"AnIm addClients failed, error : %@", exception.getMessage);
        }]; 
        NSError *error;
        if (![[CoreDataUtil sharedContext] save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [[[HXIMManager manager]anIM] createTopic:topicName withOwner:currentUser.clientId withClients:clientIds success:^(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp) {
            [self anIMDidCreateTopic:topicId];
        } failure:^(ArrownockException *exception) {
            NSLog(@"AnIm createTopic failed, error : %@", exception.getMessage);
        }];
    }
    
}

- (void)cancelButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Fetch Friends Method

- (void)fetchFriendsList
{
    NSError* error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    if (self.friendsArray == nil) {
        self.friendsArray = [[NSMutableArray alloc]initWithCapacity:0];
    }
    [self.friendsArray removeAllObjects];
    
    if ([HXUserAccountManager manager].userId) {
        for (int i = 0; i < self.fetchedResultsController.fetchedObjects.count; i++) {
            HXUser* user = self.fetchedResultsController.fetchedObjects[i];
            
            //Do not fetch current user data
            if (![user.clientId isEqualToString:[HXUserAccountManager manager].clientId])
                [self.friendsArray addObject:user];
            
            
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.friendsFilterArray = [self.friendsArray mutableCopy];
        [self.tableView reloadData];
    });
}


#pragma mark HXIMManager topic delegate method

- (void)anIMDidCreateTopic:(NSString *)topicId
{
    [self.tempChatInfo setObject:topicId forKey:@"topicId"];
    
    HXChat *topicChatSession = [ChatUtil createChatSessionWithUser:[NSSet setWithArray:self.tempChatInfo[@"users"]]
                                                           topicId:topicId
                                                         topicName:self.tempChatInfo[@"title"]
                                                   currentUserName:[HXUserAccountManager manager].userInfo.userName
                                                topicOwnerClientId:[HXUserAccountManager manager].userInfo.clientId];
    
    HXChatViewController *chatVc = [[HXChatViewController alloc]initWithChatInfo:topicChatSession setTopicMode:YES];
    HXTabBarViewController *vc = (HXTabBarViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    vc.selectedIndex = 1;
    UINavigationController *chVc = [vc.viewControllers objectAtIndex:1];
    
    [chVc pushViewController:chatVc animated:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Datasource

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

    return self.friendsFilterArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"friendSelectCell";
    
    HXCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    HXUser *user;
    user = self.friendsFilterArray[indexPath.row];
    
    if (cell == nil)
    {
        cell = [[HXCustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier title:user.userName photoUrl:user.photoURL image:[UIImage imageNamed:@"friend_default"] badgeValue:0 style:HXCustomCellStyleDefault];
    }else{
        [cell reuseCellWithTitle:user.userName photoUrl:user.photoURL image:[UIImage imageNamed:@"friend_default"] badgeValue:0];
    }
    
    if ([self.selectedFriendsArray containsObject:user]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.friendSearchBar resignFirstResponder];
    
    HXUser *user;
    user = self.friendsFilterArray[indexPath.row];
    [self deSelectUser:user];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.friendSearchBar resignFirstResponder];
    
    HXUser *user;
    user = self.friendsFilterArray[indexPath.row];
    [self selectUser:user];
    
}

#pragma mark - Helper
- (void)selectUser:(HXUser *)user
{
    if (self.selectedFriendsArray == nil) {
        self.selectedFriendsArray = [[NSMutableArray alloc]initWithCapacity:0];
    }
    
    [self.selectedFriendsArray addObject:user];
    
    if ([self.selectedFriendsArray count])
        self.navigationItem.rightBarButtonItem = self.finishBarButton;
    else
        self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)deSelectUser:(HXUser *)user
{
    if ([self.selectedFriendsArray containsObject:user]) {
        [self.selectedFriendsArray removeObject:user];
    }
    
    if ([self.selectedFriendsArray count])
        self.navigationItem.rightBarButtonItem = self.finishBarButton;
    else
        self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([[HXAppUtility removeWhitespace:searchText] isEqualToString:@""]) {
        self.friendsFilterArray = [self.friendsArray mutableCopy];
    }else{
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"userName contains[c] %@", searchText];
        NSArray *filterfriends = [[self.friendsArray filteredArrayUsingPredicate:resultPredicate]mutableCopy];
        self.friendsFilterArray = [filterfriends mutableCopy];
    }
   
    [self.tableView reloadData];
    
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.friendSearchBar resignFirstResponder];
    [self.tableView reloadData];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HXUser"
                                              inManagedObjectContext:[CoreDataUtil sharedContext]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    if (self.topicSession) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                    @"NOT(self IN %@) AND self IN %@",
                                    self.topicSession.users ,[HXUserAccountManager manager].userInfo.friends ]];
    }else{
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:
                                    @"self IN %@",
                                    [HXUserAccountManager manager].userInfo.friends]];
    }
    
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userName"
                                                                   ascending:YES];
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



@end
