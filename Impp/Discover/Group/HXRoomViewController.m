//
//  HXGroupViewController.m
//  Impp
//
//  Created by 雷翊廷 on 2015/7/9.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXRoomViewController.h"
#import "HXAppUtility.h"
#import "HXIMManager.h"
#import "UIColor+CustomColor.h"
#import "UIFont+customFont.h"
#import "HXRoomCollectionViewCell.h"
#import "HXAnSocialManager.h"
#import "HXCreateRoomViewController.h"
#import "HXAnRoomWallViewController.h"
#import "HXAnRoom+Additions.h"
#import "HXLoadingView.h"
#import "AnRoomUtil.h"
#import "CoreDataUtil.h"
#import "NotificationCenterUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UILabel+customLabel.h"
#import "KVNProgress.h"

#define VIEW_WIDTH self.view.frame.size.width
#define VIEW_HEIGHT self.view.frame.size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] applicationFrame].size.height
#define POST_PAGE_SIZE 50

@interface HXRoomViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    CGRect cellRec;
    
}
@property (strong,nonatomic) UICollectionView *groupCollectionView;
@property (strong,nonatomic) NSMutableArray *roomsArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UIView *tableEmptyView;
@property int pageNum;
@property BOOL noMoreToLoad;
@end

@implementation HXRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.

    [self initNavigationBar];
    [self initView];
    [self initData];
    [self fetchRoomData:nil];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchRoomData:) name:RefreshRoom object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchRoomsFromDB) name:@"reloadData" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [self fetchRoomsFromDB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    self.roomsArray = [[NSMutableArray alloc]initWithCapacity:0];
}

- (void)initView
{
    [self.view addSubview:self.groupCollectionView];
    
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]; //(0, 58.0f/2 + 16.0f/2, 0, 0)];
    [self.groupCollectionView addSubview:refreshView];
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(fetchRoomData:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [refreshView addSubview:self.refreshControl];
}

- (void)initNavigationBar
{

    [HXAppUtility initNavigationTitle:NSLocalizedString(@"rooms", nil) barTintColor:[UIColor color1] withViewController:self];
    UIBarButtonItem *createBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createButtonTapped)];
    [self.navigationItem setRightBarButtonItem:createBarButton];
}


- (void) createButtonTapped{
    
    HXCreateRoomViewController *vc = [[HXCreateRoomViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    
}



- (UICollectionView *)groupCollectionView
{
    if (!_groupCollectionView) {
        CGFloat collectionViewHeight = VIEW_HEIGHT - (64 + self.tabBarController.tabBar.frame.size.height-9);
        CGFloat collectionViewWidth =  VIEW_WIDTH;
        cellRec = CGRectMake(29, 9, collectionViewWidth/2-29, collectionViewWidth/2-20);
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(collectionViewWidth/2-29, collectionViewWidth/2-20);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _groupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 , 0, collectionViewWidth, collectionViewHeight) collectionViewLayout:flowLayout];
        _groupCollectionView.delegate = self;
        _groupCollectionView.dataSource = self;
        _groupCollectionView.backgroundColor = [UIColor whiteColor];
        [_groupCollectionView setShowsVerticalScrollIndicator:NO];
        [_groupCollectionView registerClass:[HXRoomCollectionViewCell class] forCellWithReuseIdentifier:@"GroupCell"];
    }
    return _groupCollectionView;
}


#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 2;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.roomsArray.count==0) {
        return 0;
    }else if (self.roomsArray.count%2 ==1 ){
        return (int)self.roomsArray.count/2 + 1;
    }else{
        return (int)self.roomsArray.count/2;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (HXRoomCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    long index = indexPath.section*2+indexPath.item;

    HXRoomCollectionViewCell * collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupCell" forIndexPath:indexPath];
    if (!collectionViewCell) {
        collectionViewCell = [[HXRoomCollectionViewCell alloc] initWithFrame:cellRec];
    }
    
    collectionViewCell.indexPath = indexPath;
    if (index<self.roomsArray.count) {
        NSDictionary *currentRoom = [[NSDictionary alloc]initWithDictionary:self.roomsArray[index]];
        
        collectionViewCell.userInteractionEnabled = YES;
        if ([[currentRoom objectForKey:@"photoUrl"] isEqualToString:@""]){
            
                collectionViewCell.groupImage.image = nil;
                collectionViewCell.groupImage.backgroundColor = [UIColor color6];
            
        }else{

            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadWithURL:[NSURL URLWithString:[currentRoom objectForKey:@"photoUrl"]]
                             options:0
                            progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (image) {
                                       //NSLog(@"currentIndex:%@ \n imageindex:%@",collectionViewCell.indexPath,indexPath);
                                       if (indexPath == collectionViewCell.indexPath) {
                                           collectionViewCell.groupImage.image = image;
                                           collectionViewCell.groupImage.contentMode = UIViewContentModeScaleAspectFill;
                                       }
                                       
                                   }
                               });
                               
                               
                           }];
        }
        collectionViewCell.groupNameLabel.text = [currentRoom objectForKey:@"roomName"];
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            collectionViewCell.groupImage.image = nil;
            collectionViewCell.groupImage.backgroundColor = [UIColor whiteColor];
            collectionViewCell.groupNameLabel.text = @"";
            collectionViewCell.userInteractionEnabled = NO;
        });
        
    }
    
    
    return collectionViewCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    long index = indexPath.section*2+indexPath.item;
    
    //[self deleteGroupWithID:self.roomsArray[index] ];

    NSLog(@"%@",self.roomsArray[index]);
    NSMutableDictionary *passGroup = self.roomsArray[index];
    
    
    HXAnRoomWallViewController *vc = [[HXAnRoomWallViewController alloc]initWithWallInfoInGroupMode:passGroup];
    [self.navigationController pushViewController:vc animated:YES];

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(9, 29, 0, 29);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}


- (void)fetchGroupWallData
{
    NSDictionary *params = @{@"type": @"room",
                             @"sort":@"-created_at",
                             @"limit": @(99)};
    
    [[HXAnSocialManager manager] sendRequest:@"circles/query.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response){
        
        NSLog(@"fetch data :%@",[response description]);
        NSArray* groups = response[@"response"][@"circles"];
        [self.roomsArray removeAllObjects];
        
        for (NSDictionary *group in groups){
            [self.roomsArray addObject:group];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.groupCollectionView reloadData];
        });
        
    }failure:^(NSDictionary *response){
        NSLog(@"fail to fetch data :%@",[response description]);
    }];
    
}

//-(void)deleteGroupWithID:(NSDictionary*)wall{
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:wall[@"anRoomId"] forKey:@"circle_id"];
//    
//    [[HXAnSocialManager manager] sendRequest:@"circles/delete.json" method:AnSocialManagerPOST params:params success:^
//     (NSDictionary *response) {
//         for (id key in response)
//         {
//             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
//         }
//     } failure:^(NSDictionary *response) {
//         for (id key in response)
//         {
//             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
//         }
//     }];
//
//    [[[HXIMManager manager]anIM] removeTopic:wall[@"topicId"] success:^(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp) {
//        
//            NSLog(@"removed topic: %@",topicId);
//        
//    } failure:^(ArrownockException *exception) {
//        NSLog(@"%@",exception);
//    }
//    ];
//}


- (void)fetchRoomsFromDB
{
    NSError* error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    [self.roomsArray removeAllObjects];
    
    for (int i = 0; i < self.fetchedResultsController.fetchedObjects.count; i++) {
        HXAnRoom *hxAnRoom = self.fetchedResultsController.fetchedObjects[i];
        //NSMutableDictionary *temp = [[hxAnRoom toDict] mutableCopy];
        //[temp addEntriesFromDictionary:[hxAnRoom.postOwner.toDict mutableCopy]];
        //[self.postArray addObject:temp];
        [self.roomsArray addObject:hxAnRoom.toDict];
        
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.groupCollectionView reloadData];
        if (!self.roomsArray.count) {
            if (!self.tableEmptyView) {
                [self addEmptyPage];
            }
            
        }else{
            if (self.tableEmptyView) {
                [self.tableEmptyView removeFromSuperview];
            }
            
        }
        
        
    });
}

- (void)fetchRoomData:(NSNotification *)notice
{
    [KVNProgress show];
    self.view.userInteractionEnabled = NO;
    
    self.pageNum = 1;
    NSDictionary *params;

        params = @{@"type":@"room",
                   @"page":[NSNumber numberWithInt:_pageNum],
                   @"limit":@POST_PAGE_SIZE,
                   @"sort": @"-created_at"};


    [[HXAnSocialManager manager]sendRequest:@"circles/query.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response){

        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"fetch data :%@",[response description]);
            [self.roomsArray removeAllObjects];
            NSMutableArray *newRooms = [response[@"response"][@"circles"] mutableCopy];
            if (newRooms.count) {
                self.pageNum++;
                
                for (NSDictionary *room in newRooms){
                    HXAnRoom* hxAnRoom = [AnRoomUtil saveRoomToDB:room];
                }

                if (newRooms.count < POST_PAGE_SIZE) self.noMoreToLoad = YES;
            }else
                self.noMoreToLoad = YES;

            [KVNProgress dismiss];
            self.view.userInteractionEnabled = YES;
            [self.refreshControl endRefreshing];
            [self fetchRoomsFromDB];
        });
        
    } failure:^(NSDictionary *response){
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
            self.view.userInteractionEnabled = YES;
        });
        
        //[load removeFromSuperview];
        NSLog(@"fail to fetch data :%@",[response description]);
    }];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HXAnRoom"
                                              inManagedObjectContext:[CoreDataUtil sharedContext]];
    
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat
                                :@"type == %@",@"room"]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:15];
    //[fetchRequest setFetchLimit:15];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
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

-(void) addEmptyPage{
    dispatch_async(dispatch_get_main_queue(), ^{
        _tableEmptyView = [[UIView alloc]initWithFrame:self.groupCollectionView.bounds];
        //        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptypage2"]];
        //        [tempImageView setFrame:CGRectMake(SCREEN_WIDTH/2-30, 135, 72, 60)];
        //        tempImageView.contentMode = UIViewContentModeScaleAspectFit;
        //
        UILabel *emptyLabel = [UILabel labelWithFrame:CGRectMake(0, SCREEN_HEIGHT * 0.23,SCREEN_WIDTH, 15)
                                                 text:NSLocalizedString(@"no_rooms_yet", nil)
                                        textAlignment:NSTextAlignmentCenter
                                            textColor:[UIColor color8]
                                                 font:[UIFont fontWithName:@"STHeitiTC-Light" size:15]
                                        numberOfLines:1];
        [emptyLabel setFrame:CGRectMake(SCREEN_WIDTH/2-emptyLabel.frame.size.width/2, SCREEN_HEIGHT * 0.3 - 8, emptyLabel.frame.size.width, 16)];
        //[tableEmptyView addSubview:tempImageView];
        [_tableEmptyView addSubview:emptyLabel];
        
        [self.view addSubview:_tableEmptyView] ;
    });
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
