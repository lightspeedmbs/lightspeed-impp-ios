//
//  HXAnRoomWallViewController.m
//  Impp
//
//  Created by 雷翊廷 on 2015/7/16.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXAnRoomWallViewController.h"
#import "HXUserAccountManager.h"
#import "HXAnSocialManager.h"
#import "HXAppUtility.h"
#import "HXLoadingView.h"
#import "HXPostTableViewCell.h"
#import "HXCommentViewController.h"
#import "HXCreatePostViewController.h"
#import "HXPost+Additions.h"
#import "HXImageDetailViewController.h"
#import "HXIMManager.h"
#import "ChatUtil.h"
#import "UserUtil.h"
#import "MessageUtil.h"
#import "AnRoomUtil.h"
#import "HXAnRoom+Additions.h"
#import "LightspeedCredentials.h"

#import "UIColor+CustomColor.h"
#import "PostUtil.h"
#import "CoreDataUtil.h"
#import "NotificationCenterUtil.h"

#import <CoreData/CoreData.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "KVNProgress.h"

#define POST_PAGE_SIZE 20
#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width
@interface HXAnRoomWallViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate,NSFetchedResultsControllerDelegate>
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
@property (strong, nonatomic) UIButton *joinOrLeaveRoomButton;
@property (strong, nonatomic) UIView *jolView;
@property (strong, nonatomic) UILabel *descriptionContent;
@property (strong, nonatomic) UILabel *descriptionTitle;
@property (strong, nonatomic) UIView *descriptionView;
@property (strong, nonatomic) UIBarButtonItem *chatRoomBarButton;
@property (strong, nonatomic) UIButton *button;

@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@property BOOL isLoadingMore;
@property BOOL noMoreToLoad;
@property int pageNum;
@property BOOL m_bRefreshing;
@property BOOL isInCircle;
@property BOOL isAnRoomMode;
@end

@implementation HXAnRoomWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.friendUserIdList = [[HXAnSocialManager manager]getFriendUserIds];
    [self fetchPostFromDB];
    [self fetchWallData:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchWallData:) name:RefreshWall object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLike:) name:UpdateLike object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchRoomInfo];
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

- (id)initWithWallInfoInGroupMode:(NSMutableDictionary *)wallInfo
{
    self = [super init];
    if (self) {
        self.wallInfo = wallInfo;
        self.contentOffsetDictionary = [NSMutableDictionary dictionary];
        self.hidesBottomBarWhenPushed = YES;
        self.isAnRoomMode = YES;
        [self initView];
        [self initNavigationBar];
        
    }
    
    return self;
}


- (void)initView
{

    self.postArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.view.backgroundColor = [UIColor color5];
    
    
    
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH , 142)];
    self.headerView.backgroundColor = [UIColor color1];
    
    self.photoImageView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 54)/2, 15, 54, 54)];
    self.photoImageView.layer.cornerRadius = 54/2;
    self.photoImageView.clipsToBounds = YES;
    self.photoImageView.userInteractionEnabled = YES;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.headerView addSubview:self.photoImageView];
    
    self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   self.photoImageView.frame.size.height + self.photoImageView.frame.origin.y + 6,SCREEN_WIDTH, 16)];
    [self.userNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.userNameLabel setFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:16]];
    [self.userNameLabel setTextColor:[UIColor whiteColor]];
    
    self.userNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:self.userNameLabel];
    _isInCircle = NO;
    self.joinOrLeaveRoomButton = [[UIButton alloc]initWithFrame:CGRectMake(1, 1, 92, 26)];
    for (NSString *userid in _wallInfo[@"users"]) {
        if ([userid isEqualToString:[HXUserAccountManager manager].userId]) {
            _isInCircle = YES;
            break;
        }
    }
    if (_isInCircle) {
        [self.joinOrLeaveRoomButton setTitle:NSLocalizedString(@"leave_room", nil)  forState:UIControlStateNormal];
        //[self.joinOrLeaveRoomButton setTitle:@"join" forState:UIControlStateSelected];
    }else{
        [self.joinOrLeaveRoomButton setTitle:NSLocalizedString(@"join",nil) forState:UIControlStateNormal];
        //[self.joinOrLeaveRoomButton setTitle:@"leave" forState:UIControlStateSelected];
    }
    
    [self.joinOrLeaveRoomButton addTarget:self action:@selector(joinOrLeaveRoomButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.joinOrLeaveRoomButton.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:13];
    [self.joinOrLeaveRoomButton.titleLabel setTextColor:[UIColor color5]];
    self.joinOrLeaveRoomButton.backgroundColor = [UIColor color1];
    self.joinOrLeaveRoomButton.layer.cornerRadius = 2;
    self.joinOrLeaveRoomButton.clipsToBounds = YES;
    
    
    self.jolView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-40-7, self.userNameLabel.frame.origin.y+self.userNameLabel.frame.size.height+12, 80+14, 28)];
    self.jolView.backgroundColor = [UIColor color5];
    self.jolView.layer.cornerRadius = 2;
    self.jolView.clipsToBounds = YES;
    [self.jolView addSubview:self.joinOrLeaveRoomButton];
    [self.headerView addSubview:self.jolView];
    
    
    _descriptionTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH-30, 12)];
    _descriptionTitle.text = NSLocalizedString(@"group_description", nil) ;
    [_descriptionTitle setTextColor:[UIColor color1]];
    [_descriptionTitle setFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:12]];
    
    
    
    
    _descriptionContent = [[UILabel alloc] initWithFrame:CGRectMake(15, _descriptionTitle.frame.size.height+21, SCREEN_WIDTH-30, MAXFLOAT)];
    //_descriptionContent.translatesAutoresizingMaskIntoConstraints = NO;
    _descriptionContent.numberOfLines = 0;
    [_descriptionContent setLineBreakMode:NSLineBreakByWordWrapping];
    [_descriptionContent setFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:14]];
    _descriptionContent.text = self.wallInfo[@"roomDescription"];
    [_descriptionContent sizeToFit];
    CGFloat h = _descriptionContent.frame.size.height;
    [_descriptionContent setFrame:CGRectMake(15, _descriptionTitle.frame.size.height+21, SCREEN_WIDTH-30, h)];
    //NSLog(@"frame = %f",_descriptionContent.frame.origin.y);
    
    
    self.descriptionView = [[UIView alloc]initWithFrame:CGRectMake(0, 142, SCREEN_WIDTH, 48+_descriptionContent.frame.size.height)];
    self.descriptionView.backgroundColor = [UIColor color5];
    [_descriptionView addSubview:_descriptionTitle];
    [_descriptionView addSubview:_descriptionContent];

    NSLog(@"_descriptionView height: %f",_descriptionView.frame.size.height);
    
    
    [self.headerView addSubview:self.descriptionView];
    //CGFloat y = self.headerView.frame.origin.y;
    
    //[self.headerView sizeToFit];
    //CGFloat height =self.headerView.frame.size.height;
    [self.headerView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 142+48+_descriptionContent.frame.size.height)];
    
    
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
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.tableView];
    
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]; //(0, 58.0f/2 + 16.0f/2, 0, 0)];
    [self.tableView addSubview:refreshView];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(fetchWallData:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [refreshView addSubview:self.refreshControl];
    
    if (_isAnRoomMode) {
        self.userNameLabel.text = self.wallInfo[@"roomName"];
        if ([[self.wallInfo objectForKey:@"photoUrl"] isEqualToString:@""]){
            self.photoImageView.image = nil;
            self.photoImageView.backgroundColor = [UIColor color6];
            
        }else{
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadWithURL:[NSURL URLWithString:[self.wallInfo objectForKey:@"photoUrl"]]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (image) {
                                       self.photoImageView.image = image;
                                       
                                   }else{
                                       self.photoImageView = nil;
                                   }
                               });
                               
                           }];
        }
        
    }else{
        self.userNameLabel.text = self.wallInfo[@"userName"];
        if (![[HXUserAccountManager manager].userInfo.photoURL isEqualToString:@""]){
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadWithURL:[NSURL URLWithString:[HXUserAccountManager manager].userInfo.photoURL]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   self.photoImageView.image = image;
                               });
                               
                           }];
        }
        
    }
    
    
}

- (void)initNavigationBar
{

    [HXAppUtility initNavigationTitle:@"" barTintColor:[UIColor color3] withViewController:self];

    
    if (_isInCircle) {
        _button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setImage:[UIImage imageNamed:@"chat_barButton"] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(chatRoomButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_button setFrame:CGRectMake(0, 0, 22, 19)];
        _chatRoomBarButton = [[UIBarButtonItem alloc] initWithCustomView:_button];
        UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(postButtonTapped)];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:createBarButton, _chatRoomBarButton,nil]];
    }

    
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
    if (_isAnRoomMode) {
        HXCreatePostViewController *vc = [[HXCreatePostViewController alloc]initInGroupMode:_wallInfo[@"anRoomId"]];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        HXCreatePostViewController *vc = [[HXCreatePostViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    
}

-(void)chatRoomButtonTapped{

    [self.navigationItem setRightBarButtonItems:nil];
    _button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [_button setImage:[UIImage imageNamed:@"chat_barButton"] forState:UIControlStateNormal];
    //[_button addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
    [_button setFrame:CGRectMake(0, 0, 22, 19)];
    _chatRoomBarButton = [[UIBarButtonItem alloc] initWithCustomView:_button];
    UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(postButtonTapped)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:createBarButton, _chatRoomBarButton,nil]];

    
    HXChat *topicChatSession;
    topicChatSession = [ChatUtil getChatSessionByTopicId:self.wallInfo[@"topicId"]];
    if (topicChatSession==nil) {
        [[[HXIMManager manager]anIM] getTopicInfo:self.wallInfo[@"topicId"] success:^(NSString *topicId, NSString *topicName, NSString *owner, NSSet *parties, NSDate *createdDate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MessageUtil updatedTopicSessionWithUsers:parties topicId:topicId topicName:topicName topicOwner:nil];

                HXChat *ChatSession = [ChatUtil getChatSessionByTopicId:topicId];
                HXChatViewController *chatVc = [[HXChatViewController alloc]initInGroupModeWithChatInfo:ChatSession setRoomInfo:self.wallInfo];
                
                [self.navigationItem setRightBarButtonItems:nil];
                _button =  [UIButton buttonWithType:UIButtonTypeCustom];
                [_button setImage:[UIImage imageNamed:@"chat_barButton"] forState:UIControlStateNormal];
                [_button addTarget:self action:@selector(chatRoomButtonTapped) forControlEvents:UIControlEventTouchUpInside];
                [_button setFrame:CGRectMake(0, 0, 22, 19)];
                _chatRoomBarButton = [[UIBarButtonItem alloc] initWithCustomView:_button];
                UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(postButtonTapped)];
                [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:createBarButton, _chatRoomBarButton,nil]];

                [self.navigationController pushViewController:chatVc animated:YES];
                
            });
        } failure:^(ArrownockException *exception) {
            NSLog(@"AnIm getTopicInfo failed, error : %@", exception.getMessage);
        }];

    }else{

        
        [self.navigationItem setRightBarButtonItems:nil];
        _button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setImage:[UIImage imageNamed:@"chat_barButton"] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(chatRoomButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_button setFrame:CGRectMake(0, 0, 22, 19)];
        _chatRoomBarButton = [[UIBarButtonItem alloc] initWithCustomView:_button];
        UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(postButtonTapped)];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:createBarButton, _chatRoomBarButton,nil]];
        
        HXChatViewController *chatVc = [[HXChatViewController alloc]initInGroupModeWithChatInfo:topicChatSession setRoomInfo:self.wallInfo];
        [self.navigationController pushViewController:chatVc animated:YES];
    }
    
    
    
    
    
    
    
    
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
        temp[@"user"] = [hxPost.postOwner.toDict mutableCopy];
        //[temp addEntriesFromDictionary:[hxPost.postOwner.toDict mutableCopy]];
        [self.postArray addObject:temp];
        //[self.postArray addObject:hxPost.toDict];
        
    }
    //r[self filterOutAnRoomChat];
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
    NSDictionary *circleid;
    NSDictionary *params;
    
    circleid = @{@"circle_id":_wallInfo[@"anRoomId"]};
    params = @{@"custom_fields":circleid,
               @"page":[NSNumber numberWithInt:_pageNum],
               @"limit":@POST_PAGE_SIZE,
               @"sort": @"-created_at"};
    
    [[HXAnSocialManager manager]sendRequest:@"posts/query.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"fetch data :%@",[response description]);
            [self.postArray removeAllObjects];
            NSMutableArray *newPosts = [response[@"response"][@"posts"] mutableCopy];
            if (newPosts.count) {
                self.pageNum++;
                [self fetchLikes:newPosts];
                
                for (NSDictionary *post in newPosts){
                    HXPost* hxPost = [PostUtil savePostToDB:post];
                    NSMutableDictionary *temp = [hxPost.toDict mutableCopy];
                    temp[@"user"] = [hxPost.postOwner.toDict mutableCopy];
                    [self.postArray addObject:temp];
                }
                
                //[self.postArray addObjectsFromArray:newPosts];
                
                if (newPosts.count < POST_PAGE_SIZE) self.noMoreToLoad = YES;
            }else
                self.noMoreToLoad = YES;
            
            
            
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
    NSDictionary *circleid;
    NSDictionary *params;
    
    circleid = @{@"circle_id":_wallInfo[@"anRoomId"]};
    params = @{@"wall_id":circleid,
               @"page":[NSNumber numberWithInt:_pageNum],
               @"limit":@POST_PAGE_SIZE,
               @"sort": @"-created_at"};
    

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
                temp[@"user"] = [hxPost.postOwner.toDict mutableCopy];

                [self.postArray addObject:temp];
            }
            
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

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return self.headerView;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0.5;
//}

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
    if (_isInCircle) {
        return self.noMoreToLoad ? self.postArray.count : self.postArray.count + 1;
    }
    else
        return 0;
    
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
    
    HXPostTableViewCell *cell = [[HXPostTableViewCell alloc]initWithRoomPostInfo:self.postArray[indexPath.row] reuseIdentifier:cellIdentifier];
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
                                :@"circle_id == %@"
                                ,_wallInfo[@"anRoomId"]]];
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

-(void)joinOrLeaveRoomButtonPressed{
    if (self.isInCircle == NO) {
        [self joinAnRoom];
        
    }else{
        [self leaveAnRoom];
    }
}

-(void)joinAnRoom{
    NSDictionary *params = @{
                             @"circle_id": _wallInfo[@"anRoomId"],
                             @"add_user_ids":[HXUserAccountManager manager].userId};
    self.joinOrLeaveRoomButton.userInteractionEnabled = NO;
    
    [[HXAnSocialManager manager]sendRequest:@"circles/update.json" method:AnSocialManagerPOST params:params success:^(NSDictionary *response){
        NSLog(@"added %@ into %@",[HXUserAccountManager manager].userName,_wallInfo[@"anRoomId"]);
        NSLog(@"circles/update.json response: %@",response);
        

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.joinOrLeaveRoomButton setTitle:NSLocalizedString(@"leave_room", nil) forState:UIControlStateNormal];
            self.joinOrLeaveRoomButton.userInteractionEnabled = YES;
            [AnRoomUtil saveRoomToDB:response[@"response"][@"circle"]];

            _wallInfo = [[AnRoomUtil getRoomByRoomId:response[@"response"][@"circle"][@"id"]].toDict mutableCopy];

            self.isInCircle = YES;
            [self.tableView reloadData];
            UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"chat_barButton"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(chatRoomButtonTapped)forControlEvents:UIControlEventTouchUpInside];
            [button setFrame:CGRectMake(0, 0, 22, 19)];
            UIBarButtonItem *chatRoomBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
            UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(postButtonTapped)];
            [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:createBarButton, chatRoomBarButton,nil]];
        });
        
    } failure:^(NSDictionary *response){
        NSLog(@"failed to add into circle :%@",[response description]);
        [self.joinOrLeaveRoomButton setTitle:NSLocalizedString(@"join", nil) forState:UIControlStateNormal];
        self.joinOrLeaveRoomButton.userInteractionEnabled = YES;
    }];
    
    [[[HXIMManager manager]anIM] addClients:[NSSet setWithObject:[HXIMManager manager].clientId] toTopicId:_wallInfo[@"topicId"] success:^(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp) {
        NSLog(@"added %@ into %@",[HXIMManager manager].clientId,_wallInfo[@"topicId"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableSet *userInSession = [[NSMutableSet alloc]initWithCapacity:0];
            
            [[[HXIMManager manager]anIM] getTopicInfo:topicId success:^(NSString *topicId, NSString *topicName, NSString *owner, NSSet *parties, NSDate *createdDate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableSet *usersInTopic = [[NSMutableSet alloc]initWithCapacity:0];
                    for (NSString *userClientId in parties) {
                        HXUser *user = [UserUtil getHXUserByClientId:userClientId];
                        if (user) {
                            [usersInTopic addObject:user];
                        }
                        else{
                            HXUser *unknown = [HXUser initWithDict:@{@"clientId":userClientId,
                                                                     @"userName":@"unknown"}];
                            [usersInTopic addObject:unknown];
                        }
                    }
                    HXChat *topicChatSession = [ChatUtil createChatSessionWithUser:usersInTopic
                                                                           topicId:self.wallInfo[@"topicId"]
                                                                         topicName:self.wallInfo[@"roomName"]
                                                                   currentUserName:[HXUserAccountManager manager].userInfo.userName
                                                                topicOwnerClientId:nil];
                    if (![userInSession containsObject:[HXUserAccountManager manager].userInfo]) {
                        [topicChatSession addUsersObject:[HXUserAccountManager manager].userInfo];
                    }
                });
                
            } failure:^(ArrownockException *exception) {
                NSLog(@"getTopicInfo failed: %@",exception);
            }];
            

        });
        
    } failure:^(ArrownockException *exception) {
        NSLog(@"added %@ into %@",[HXIMManager manager].clientId,_wallInfo[@"topicId"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSMutableSet *userInSession = [[NSMutableSet alloc]initWithCapacity:0];
            //                    for (NSString *userid in _wallInfo[@"users"]) {
            //                        HXUser *userInTopic = [UserUtil getHXUserByUserId:userid];
            //                        [userInSession addObject:userInTopic];
            //                    }
            //                    HXChat *topicChatSession = [ChatUtil createChatSessionWithUser:nil
            //                                                               topicId:self.wallInfo[@"topicId"]
            //                                                             topicName:self.wallInfo[@"roomName"]
            //                                                       currentUserName:[HXUserAccountManager manager].userInfo.userName
            //                                                    topicOwnerClientId:@"_ANROOM_"];
            
        });
    }];
    
    
    
}

-(void)leaveAnRoom{
    [KVNProgress show];
    self.view.userInteractionEnabled = NO;
    NSDictionary *params = @{
                             @"circle_id": _wallInfo[@"anRoomId"],
                             @"del_user_ids":[HXUserAccountManager manager].userId};
    __block BOOL doneLeavingRoom = NO;
    __block BOOL doneLeavingChat = NO;
    self.joinOrLeaveRoomButton.userInteractionEnabled = NO;
    
    [[HXAnSocialManager manager]sendRequest:@"circles/update.json" method:AnSocialManagerPOST params:params success:^(NSDictionary *response){
        NSLog(@" %@ leaved %@",[HXUserAccountManager manager].userName,_wallInfo[@"anRoomId"]);
        NSLog(@"circles/update.json response: %@",response);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            doneLeavingRoom = YES;
            
            [AnRoomUtil saveRoomToDB:response[@"response"][@"circle"]];
            [_wallInfo removeAllObjects];
            _wallInfo = [[AnRoomUtil getRoomByRoomId:response[@"response"][@"circle"][@"id"]].toDict mutableCopy];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadData" object:nil];

            if (doneLeavingChat) {
                [KVNProgress dismiss];
                self.view.userInteractionEnabled = YES;
                self.joinOrLeaveRoomButton.userInteractionEnabled = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        });
        
    } failure:^(NSDictionary *response){
        NSLog(@"failed to add into circle :%@",[response description]);
        [KVNProgress dismiss];
        self.view.userInteractionEnabled = YES;
        self.joinOrLeaveRoomButton.userInteractionEnabled = YES;
    }];
    
    
    [[[HXIMManager manager]anIM] removeClients:[NSSet setWithObject:[HXIMManager manager].clientId] fromTopicId:_wallInfo[@"topicId"] success:^(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp) {
        NSLog(@"AnIM removeClients successful");

            dispatch_async(dispatch_get_main_queue(), ^{
                self.joinOrLeaveRoomButton.userInteractionEnabled = YES;
                doneLeavingChat = YES;
                NSArray *messsageToRemove = [MessageUtil getMessageByTopicId:_wallInfo[@"topicId"]];
                for (HXMessage *message in messsageToRemove) {
                    [MessageUtil deleteMessage:message];
                }
                HXChat *chatToRemove = [ChatUtil getChatSessionByTopicId:_wallInfo[@"topicId"]];
                if (chatToRemove) {
                    [ChatUtil deleteChatHistory:chatToRemove];
                    [UserUtil removeTopic:chatToRemove from:[HXIMManager manager].clientId];
                    [ChatUtil deleteChat:chatToRemove];
                }
                //[[NSNotificationCenter defaultCenter]postNotificationName:RefreshRoom object:nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:RefreshChatHistory object:nil];
                
                if (doneLeavingChat) {
                    [KVNProgress dismiss];
                    self.view.userInteractionEnabled = YES;
                    self.joinOrLeaveRoomButton.userInteractionEnabled = YES;
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
        
        
    } failure:^(ArrownockException *exception) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"AnIm removeClients failed, error : %@", exception.getMessage);
                [KVNProgress dismiss];
                self.view.userInteractionEnabled = YES;
                self.joinOrLeaveRoomButton.userInteractionEnabled = YES;
//                doneLeavingChat = YES;
//                HXChat *chatToRemove = [ChatUtil getChatSessionByTopicId:_wallInfo[@"topicId"]];
//                if (chatToRemove) {
//                    [ChatUtil deleteChatHistory:chatToRemove];
//                    [ChatUtil deleteChat:chatToRemove];
//                    for (HXUser *user in chatToRemove.users) {
//                        if ([user.clientId isEqualToString:[HXIMManager manager].clientId]) {
//                            [UserUtil removeTopic:chatToRemove from:[HXIMManager manager].clientId];
//                            break;
//                        }
//                    }
//                    
//                }
//                [[NSNotificationCenter defaultCenter]postNotificationName:RefreshRoom object:nil];
//                [self.navigationController popViewControllerAnimated:YES];
            });
        
    }];

}

- (void)filterOutAnRoomChat{
    NSMutableArray *filter = [[NSMutableArray alloc]initWithCapacity:0];
    for (NSDictionary *posts in _postArray) {
        if (![self isObjectAvailable:posts[@"topicId"]]) {
            [filter addObject:posts];
        }
    }
    
    [self.postArray removeObjectsInArray:filter];
}

- (BOOL) isObjectAvailable:(id) data {
    return ((data != nil) && ![data isKindOfClass:[NSNull class]]);
}

-(void)fetchRoomInfo{
    NSDictionary *params = @{
                             @"circle_ids": _wallInfo[@"anRoomId"],
                             };
    [[HXAnSocialManager manager]sendRequest:@"circles/get.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response) {
        NSLog(@"circles/get.json response: %@",response);
        dispatch_async(dispatch_get_main_queue(), ^{
            [AnRoomUtil saveRoomToDB:response[@"response"][@"circles"][0]];
            _wallInfo = nil;
            _wallInfo = [[AnRoomUtil getRoomByRoomId:response[@"response"][@"circles"][0][@"id"]].toDict mutableCopy];
        });
        
    } failure:^(NSDictionary *response) {
        NSLog(@"get room info failed:%@",response);
    }];
    
}

-(void)fetchUserInfoWithId:(NSString*)userId{
    [[HXAnSocialManager manager]sendRequest:@"users/get.json"
                                                  method:AnSocialManagerGET
                                                  params:@{@"user_ids":userId}
                                                 success:^(NSDictionary *response){
                                                     NSLog(@"Got user info :%@",userId);
                                                     NSDictionary *userInfo = response[@"response"][@"users"][0];
                                                     [UserUtil saveUserIntoDB:userInfo];
     

     
                                                 } failure:^(NSDictionary *response){
     
                                                     NSLog(@"fail to get user info !!!!");
     
                                                 }];
}
@end
