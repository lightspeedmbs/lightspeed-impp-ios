//
//  HXCommentViewController.m
//  Impp
//
//  Created by hsujahhu on 2015/4/8.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXCommentViewController.h"
#import "HXAnSocialManager.h"
#import "HXAppUtility.h"
#import "HXUserAccountManager.h"
#import "HXIMManager.h"
#import "HXCommentView.h"
#import "HXCommentTableViewCell.h"
#import "HXComment+Additions.h"

#import "UIColor+CustomColor.h"

#import "CommentUtil.h"
#import "UserUtil.h"
#import "PostUtil.h"

#import <CoreData/CoreData.h>
#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width

@interface HXCommentViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,HXCommentViewDelegate>
@property (strong, nonatomic) NSMutableArray *commentsArray;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *postInfo;
@property (strong, nonatomic) HXCommentView *commentView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property BOOL isReplyUserMode;
@property (strong, nonatomic) NSIndexPath *replyTargetUserIndex;
@end

@implementation HXCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self fetchCommentData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - Initialize

- (id)initWithPostInfo:(NSMutableDictionary *)postInfo
{
    self = [super init];
    if (self) {
        self.postInfo = postInfo;
        self.commentsArray = [[NSMutableArray alloc]initWithCapacity:0];
        [self initNavigationBar];
        [self initView];
        [self fetchPostFromDB];
    }
    
    return self;
}

- (void)initNavigationBar
{
    [HXAppUtility initNavigationTitle:NSLocalizedString(@"留言", nil) barTintColor:[UIColor color3] withViewController:self];
}

- (void)initView
{
    CGRect frame;
    self.view.backgroundColor = [UIColor color5];
    
    self.commentView = [[HXCommentView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 44)];
    self.commentView.delegate = self;
    frame = self.commentView.frame;
    frame.origin.y = self.view.frame.size.height - self.commentView.bounds.size.height - 64;
    self.commentView.frame = frame;
    [self.view addSubview:self.commentView];
    
    
    /* tableView */
    frame = self.view.frame;
    frame.size.height -= 64 + self.commentView.frame.size.height;
    frame.origin.y = 0;
    self.tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:self.commentView];
}

#pragma mark - Fetch Method
- (void)fetchPostFromDB
{
    NSError* error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    [self.commentsArray removeAllObjects];
    
    for (int i = 0; i < self.fetchedResultsController.fetchedObjects.count; i++) {
        HXComment *comment = self.fetchedResultsController.fetchedObjects[i];
        [self.commentsArray addObject:comment];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        if (!self.commentsArray.count) {
//            [self fetchCommentData];
//        }
        [self fetchCommentData];
        [self.tableView reloadData];
    });
}

- (void)fetchCommentData
{
    NSDictionary *params = @{@"object_type": @"Post",
                             @"object_id": self.postInfo[@"id"],
                             @"page": @(1),
                             @"limit": @(99)};
    
    [[HXAnSocialManager manager] sendRequest:@"comments/query.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response){
        
        NSLog(@"fetch data :%@",[response description]);
        NSArray* comments = response[@"response"][@"comments"];
        [self.commentsArray removeAllObjects];
        
        for (NSDictionary *commentDic in comments){
            HXComment *comment = [CommentUtil saveCommentToDB:commentDic postId:self.postInfo[@"id"]];
           [self.commentsArray addObject:comment];
        }
        
        //self.commentsArray = [comments mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }failure:^(NSDictionary *response){
        NSLog(@"fail to fetch data :%@",[response description]);
    }];
    
}

#pragma mark - HXCommentView Delegate

- (void)commentButtonTappedWithMessage:(NSString *)message
{
    
    NSMutableDictionary *params = [@{@"content":message,
                                     @"object_type": @"Post",
                                     @"object_id": self.postInfo[@"id"],
                                     @"user_id":[HXUserAccountManager manager].userId}mutableCopy];
    if (self.isReplyUserMode) {
        HXComment *comment = self.commentsArray[self.replyTargetUserIndex.row];
        [params addEntriesFromDictionary:@{@"reply_user_id":comment.commentOwner.userId}];
        self.isReplyUserMode = NO;
        [self.commentView textFieldResignFirstResponder];
        [self.tableView deselectRowAtIndexPath:self.replyTargetUserIndex animated:YES];
        
        /* send notice */
//        [[HXIMManager manager] sendSocialNoticeWithClientId:[NSSet setWithObject:comment.commentOwner.clientId] objectType:@"comment" objectInfo:self.postInfo notificationAlert:[NSString stringWithFormat:@"%@ 回覆你的留言",[HXUserAccountManager manager].userInfo.userName]];
    }
    
    /* send notice */
//    [[HXIMManager manager] sendSocialNoticeWithClientId:[NSSet setWithObject:self.postInfo[@"clientId"]] objectType:@"post" objectInfo:self.postInfo notificationAlert:[NSString stringWithFormat:@"%@ 在你的貼文留言",[HXUserAccountManager manager].userInfo.userName]];
    
    [[HXAnSocialManager manager] sendRequest:@"comments/create.json" method:AnSocialManagerPOST params:params success:^(NSDictionary *response){
        
        NSLog(@"fetch data :%@",[response description]);
        NSDictionary* commentDic = response[@"response"][@"comment"];
        HXComment *comment = [CommentUtil saveCommentToDB:commentDic postId:self.postInfo[@"id"]];
        [self.commentsArray addObject:comment];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[[NSNotificationCenter defaultCenter]postNotificationName:@"refreshWallData" object:nil];
            //[self fetchCommentData];
            [self.commentView textFieldResignFirstResponder];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.commentsArray.count-1 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            //[self.tableView reloadData];
            if (self.commentsArray.count) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.commentsArray.count-1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            
        });
        
    }failure:^(NSDictionary *response){
        NSLog(@"fail to fetch data :%@",[response description]);
    }];
}

#pragma mark - Table View Delegate Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0) {
//        if (self.likesArray.count) {
//            return 50;
//        }else{
//            return [HXCommentTableViewCell heightForCellComment:self.commentsArray[indexPath.row][@"content"]] +1;
//        }
//    }else{
//        NSInteger index = ([self.likesArray count]) ? indexPath.row - 1 :indexPath.row;
//        return [HXCommentTableViewCell heightForCellComment:self.commentsArray[index][@"content"]] +1;
//    }
    HXComment *comment = self.commentsArray[indexPath.row];
    return [HXCommentTableViewCell heightForCellComment:comment.content];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HXCommentTableViewCell *commentCell = [[HXCommentTableViewCell alloc]initWithCommentInfo:self.commentsArray[indexPath.row] reuseIdentifier:@"commentCell"];
    
    return commentCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isReplyUserMode = !self.isReplyUserMode;
    self.replyTargetUserIndex = indexPath;
    
    if (self.isReplyUserMode){
        [self.commentView textFieldBecomeFirstResponder];
    }else{
        [self.commentView textFieldResignFirstResponder];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    
}

#pragma mark - Helper

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.commentView.frame = CGRectMake(self.commentView.frame.origin.x,
                                        self.view.bounds.size.height - kbSize.height - self.commentView.bounds.size.height,
                                        self.commentView.bounds.size.width,
                                        self.commentView.bounds.size.height);
    CGRect frame = self.tableView.frame;
    frame.size.height = self.view.frame.size.height -kbSize.height - self.commentView.frame.size.height;
    self.tableView.frame = frame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.commentView.center = CGPointMake(self.commentView.center.x,
                                          self.commentView.center.y + kbSize.height);
    
    CGRect frame = self.tableView.frame;
    frame.size.height = self.view.frame.size.height - self.commentView.frame.size.height;
    self.tableView.frame = frame;
    
    [UIView commitAnimations];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HXComment"
                                              inManagedObjectContext:[CoreDataUtil sharedContext]];
    
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat
                                :@"parentId == %@"
                                ,self.postInfo[@"id"]]];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:15];
    //[fetchRequest setFetchLimit:15];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created_at"
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
    
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
