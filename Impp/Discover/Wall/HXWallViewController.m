//
//  HXWallViewController.m
//  Impp
//
//  Created by Herxun on 2015/4/8.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXWallViewController.h"
#import "HXUserAccountManager.h"
#import "HXAnSocialManager.h"
#import "HXAppUtility.h"
#import "HXLoadingView.h"
#import "HXPostTableViewCell.h"
#import "HXCommentViewController.h"
#import "HXCreatePostViewController.h"
#import "HXPost+Additions.h"
#import "HXImageDetailViewController.h"

#import "LightspeedCredentials.h"

#import "UIColor+CustomColor.h"
#import "PostUtil.h"
#import "CoreDataUtil.h"
#import "NotificationCenterUtil.h"

#import <CoreData/CoreData.h>
#import <SDWebImage/UIImageView+WebCache.h>

#define POST_PAGE_SIZE 20
#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width
@interface HXWallViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate,NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSMutableDictionary *wallInfo;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *postArray;
@property (strong, nonatomic) UIImageView *imagePullToRefresh;
@property (strong, nonatomic) UIActivityIndicatorView *refreshIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *friendUserIdList;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UILabel *userNameLabel;

@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@property BOOL isLoadingMore;
@property BOOL noMoreToLoad;
@property int pageNum;
@property BOOL m_bRefreshing;
@end

@implementation HXWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.friendUserIdList = [[HXAnSocialManager manager]getFriendUserIds];
    [self fetchPostFromDB];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchWallData:) name:RefreshWall object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLike:) name:UpdateLike object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

// for iOS8 ...
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewWillLayoutSubviews{
    self.navigationController.navigationBar.backItem.backBarButtonItem
    =[[UIBarButtonItem alloc] initWithTitle:@""
                                      style:UIBarButtonItemStylePlain
                                     target:self
                                     action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Initialize

- (id)initWithWallInfo:(NSMutableDictionary *)wallInfo
{
    self = [super init];
    if (self) {
        self.wallInfo = wallInfo;
        self.contentOffsetDictionary = [NSMutableDictionary dictionary];
        self.hidesBottomBarWhenPushed = YES;
        [self initView];
        [self initNavigationBar];
    }
    
    return self;
}

- (void)initView
{
    self.postArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    self.view.backgroundColor = [UIColor color5];
    
    /* tableView */
    CGRect frame = self.view.frame;
    frame.size.height -= 64;
    frame.origin.y = 0;
    self.tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [HXAppUtility hexToColor:0xe3e3e3 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.tableView];
    
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]; //(0, 58.0f/2 + 16.0f/2, 0, 0)];
    [self.tableView addSubview:refreshView];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(fetchWallData:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [refreshView addSubview:self.refreshControl];
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH , 104)];
    self.headerView.backgroundColor = [UIColor color1];
    
    self.photoImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_default"]];
    self.photoImageView.frame = CGRectMake((SCREEN_WIDTH - 54)/2, 15, 54, 54);
    self.photoImageView.layer.cornerRadius = 54/2;
    self.photoImageView.clipsToBounds = YES;
    self.photoImageView.userInteractionEnabled = YES;
    [self.headerView addSubview:self.photoImageView];
    
    if (![[HXUserAccountManager manager].userInfo.photoURL isEqualToString:@""]){
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:[HXUserAccountManager manager].userInfo.photoURL]
                         options:0
                        progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                           if (image) {
                               self.photoImageView.image = image;
                               self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
                           }
                           
                       }];
    }
    
    self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   self.photoImageView.frame.size.height + self.photoImageView.frame.origin.y + 6,SCREEN_WIDTH, 16)];
    [self.userNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.userNameLabel setFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:16]];
    [self.userNameLabel setTextColor:[UIColor whiteColor]];
    self.userNameLabel.text = [HXUserAccountManager manager].userInfo.userName;
    self.userNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:self.userNameLabel];
   
}

- (void)initNavigationBar
{
    [HXAppUtility initNavigationTitle:NSLocalizedString(@"朋友圈", nil) barTintColor:[UIColor color3] withViewController:self];

    UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(postButtonTapped)];
    [self.navigationItem setRightBarButtonItem:createBarButton];
}

#pragma mark - Listener

- (void)refreshListener
{
    NSLog(@"--- Refresh ---");
    NSNotification *notice = [[NSNotification alloc]initWithName:@"refreshWallData" object:@"notShowLoadingView" userInfo:nil];
    
    [self fetchWallData:notice];
    
}

- (void)backBarButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)postButtonTapped
{
    HXCreatePostViewController *vc = [[HXCreatePostViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];

}

#pragma mark fetch Data Method

- (void)fetchPostFromDB
{
    NSError* error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    [self.postArray removeAllObjects];
    
    for (int i = 0; i < self.fetchedResultsController.fetchedObjects.count; i++) {
        HXPost *hxPost = self.fetchedResultsController.fetchedObjects[i];
        NSMutableDictionary *temp = [hxPost.toDict mutableCopy];
        [temp addEntriesFromDictionary:[hxPost.postOwner.toDict mutableCopy]];
        [self.postArray addObject:temp];
        [self.postArray addObject:hxPost.toDict];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self fetchWallData:nil];
    });
}

- (void)fetchWallData:(NSNotification *)notice
{

    HXLoadingView *load = [[HXLoadingView alloc]initLoadingView];
    
    self.pageNum = 1;
    self.noMoreToLoad = NO;
    NSDictionary *params = @{@"wall_id":LIGHTSPEED_WALL_ID,
                             @"page":[NSNumber numberWithInt:_pageNum],
                             @"limit":@POST_PAGE_SIZE,
                             @"sort": @"-created_at",
                             @"user_id":self.friendUserIdList};

    
    [[HXAnSocialManager manager]sendRequest:@"posts/query.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response){
        
        NSLog(@"fetch data :%@",[response description]);
        [self.postArray removeAllObjects];
        NSMutableArray *newPosts = [response[@"response"][@"posts"] mutableCopy];
        if (newPosts.count) {
            self.pageNum++;
            [self fetchLikes:newPosts];
            
            for (NSDictionary *post in newPosts){
                HXPost* hxPost = [PostUtil savePostToDB:post];
                NSMutableDictionary *temp = [hxPost.toDict mutableCopy];
                [temp addEntriesFromDictionary:[hxPost.postOwner.toDict mutableCopy]];
                [self.postArray addObject:temp];
            }
            
            //[self.postArray addObjectsFromArray:newPosts];
            
            if (newPosts.count < POST_PAGE_SIZE) self.noMoreToLoad = YES;
        }else
            self.noMoreToLoad = YES;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [load removeFromSuperview];
            
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        });
        
    } failure:^(NSDictionary *response){
        
        [load removeFromSuperview];
        NSLog(@"fail to fetch data :%@",[response description]);
    }];
}

- (void)loadMoreWallData
{
    NSDictionary *params = @{@"wall_id":LIGHTSPEED_WALL_ID,
                             @"page":[NSNumber numberWithInt:_pageNum],
                             @"limit":@POST_PAGE_SIZE,
                             @"sort": @"-created_at",
                             @"user_id":self.friendUserIdList};
    
    [[HXAnSocialManager manager]sendRequest:@"posts/query.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response){
        
        NSLog(@"fetch data :%@",[response description]);
        self.isLoadingMore = NO;
        
        NSMutableArray *newPosts = [response[@"response"][@"posts"] mutableCopy];
        if (newPosts.count) {
            self.pageNum++;
            [self fetchLikes:newPosts];
            
            for (NSDictionary *post in newPosts){
                HXPost* hxPost = [PostUtil savePostToDB:post];
                NSMutableDictionary *temp = [hxPost.toDict mutableCopy];
                [temp addEntriesFromDictionary:[hxPost.postOwner.toDict mutableCopy]];
                [self.postArray addObject:temp];
            }
            //[self.postArray addObjectsFromArray:newPosts];
            
        }else
            self.noMoreToLoad = YES;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } failure:^(NSDictionary *response){
        self.isLoadingMore = NO;
        
        NSLog(@"fail to fetch data :%@",[response description]);
    }];
}

- (void)fetchLikes:(NSArray *)postInfo
{
    for (NSDictionary *post in postInfo)
    {
        if ([[HXUserAccountManager manager].likeDic objectForKey:post[@"id"]]) return;
        
        NSDictionary *params = @{@"object_type": @"Post",
                                 @"object_id": post[@"id"],
                                 @"user_id":[HXUserAccountManager manager].userId};
        
        [[HXAnSocialManager manager]sendRequest:@"likes/query.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response){
            NSLog(@"likes info :%@",[response description]);
            NSLog(@"like Dic: %@",[[HXUserAccountManager manager].likeDic description]);
            @try {
                if ([(NSArray *)response[@"response"][@"likes"] count])
                {
                    NSString *likeId = [response[@"response"][@"likes"] firstObject][@"id"];
                    [[HXUserAccountManager manager].likeDic setObject: likeId forKey:post[@"id"]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }
            @catch (NSException *exception) {
            }
            
        } failure:^(NSDictionary *response){
            NSLog(@"failed to fetch likes info :%@",[response description]);
        }];
    }
}

#pragma mark - Update like

- (void)updateLike:(NSNotification* )notice
{
    NSDictionary *dic = notice.object;
    NSIndexPath *index = dic[@"index"];
    NSMutableDictionary *temp = [self.postArray[index.row] mutableCopy];
    [temp setObject:dic[@"likeCount"] forKey:@"likeCount"];
    self.postArray[index.row] = [temp mutableCopy];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index.row inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height -inset.bottom;
    float h = size.height;
    float reload_distance = -100.0f /2;
    
    // for collectionview
    if ([scrollView isKindOfClass:[UICollectionView class]]){
        CGFloat horizontalOffset = scrollView.contentOffset.x;
        
        UICollectionView *collectionView = (UICollectionView *)scrollView;
        NSInteger index = collectionView.tag;
        self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
    }
    
    
    if (y > h + reload_distance && !_isLoadingMore && !_noMoreToLoad && self.postArray.count >= POST_PAGE_SIZE) {
        NSLog(@" --- LOAD MORE --- ");
        self.isLoadingMore = YES;
        [self loadMoreWallData];
    }
    
}

#pragma mark - Table View Delegate Method

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 104;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.postArray.count) {
        if (self.postArray[indexPath.row][@"content"]) {
            if (self.postArray[indexPath.row][@"customFields"][@"photoUrls"]) {
                
                return [HXPostTableViewCell heightForCellPost:self.postArray[indexPath.row][@"content"] postType:ImageAndTextPost];// + 16/2;
            }else{
                return [HXPostTableViewCell heightForCellPost:self.postArray[indexPath.row][@"content"] postType:TextPost]; //+ 16/2;
            }
        }else
            return [HXPostTableViewCell heightForCellPost:self.postArray[indexPath.row][@"content"] postType:ImagePost]; //+ 16/2;
    }else
        return 100/2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.noMoreToLoad ? self.postArray.count : self.postArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.postArray.count)
    {
        UITableViewCell *lastCell;
        lastCell = [tableView dequeueReusableCellWithIdentifier:@"lastCell"];
        if (lastCell)
        {
            lastCell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIActivityIndicatorView *AIV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            AIV.frame = CGRectMake(self.view.bounds.size.width/2 - AIV.bounds.size.width/2,
                                   30.0f/2,
                                   AIV.bounds.size.width,
                                   AIV.bounds.size.height);
            [AIV startAnimating];
            if (self.postArray.count)
                [lastCell addSubview:AIV];
            return lastCell;
        }
        else
        {
            lastCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lastCell"];
            lastCell.selectionStyle = UITableViewCellSelectionStyleNone;
            lastCell.backgroundColor = [UIColor clearColor];
            UIActivityIndicatorView *AIV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            AIV.frame = CGRectMake(self.view.bounds.size.width/2 - AIV.bounds.size.width/2,
                                   30.0f/2,
                                   AIV.bounds.size.width,
                                   AIV.bounds.size.height);
            [AIV startAnimating];
            if (self.postArray.count)
                [lastCell addSubview:AIV];
            return lastCell;
        }
    }
    
    static NSString *cellIdentifier = @"postCell";

    HXPostTableViewCell *cell = [[HXPostTableViewCell alloc]initWithPostInfo:self.postArray[indexPath.row] reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    [cell setCellIndex:indexPath];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(HXPostTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //for iOS8...
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //if (!self.postArray[indexPath.row][@"customFields"][@"photoUrls"])return;
    if ([cell respondsToSelector:@selector(setCollectionViewDataSourceDelegate: indexPath:)]) {
        [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
        NSInteger index = cell.collectionView.tag;
        
        CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
        [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    }
    
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [(HXIndexedCollectionView *)collectionView indexPath];
    NSArray *collectionViewArray = self.postArray[indexPath.row][@"customFields"][@"photoUrls"];
    return collectionViewArray ? collectionViewArray.count : 0;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSIndexPath *postIndexPath = [(HXIndexedCollectionView *)collectionView indexPath];
    NSArray *collectionViewArray = self.postArray[postIndexPath.row][@"customFields"][@"photoUrls"];
    UIImageView *photo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 108, 108)];
    photo.backgroundColor = [UIColor color5];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[NSURL URLWithString:collectionViewArray[indexPath.item]]
                     options:0
                    progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                       if (image) {
                           photo.image = image;
                           photo.contentMode = UIViewContentModeScaleAspectFill;
                           photo.clipsToBounds = YES;
                       }
                       
                   }];
    [cell addSubview:photo];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *postIndexPath = [(HXIndexedCollectionView *)collectionView indexPath];
    NSArray *collectionViewArray = self.postArray[postIndexPath.row][@"customFields"][@"photoUrls"];
    NSString *imageUrl = collectionViewArray[indexPath.item];
    HXImageDetailViewController *vc = [[HXImageDetailViewController alloc]initWithImage:nil imageUrl:imageUrl mode:@"push"];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HXPost"
                                              inManagedObjectContext:[CoreDataUtil sharedContext]];
    
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat
                                :@"postOwner IN %@ || postOwner == %@"
                                ,[HXUserAccountManager manager].userInfo.friends,[HXUserAccountManager manager].userInfo]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:15];
    //[fetchRequest setFetchLimit:15];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at"
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
    
    return;
}
@end
