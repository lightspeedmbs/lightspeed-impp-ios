//
//  HXChatViewController.m
//  IMChat
//
//  Created by Jefferson on 2015/1/8.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXChatViewController.h"
#import "HXAppUtility.h"
#import "HXComposeView.h"
#import "AnIMMessage.h"
#import "HXMapViewController.h"
#import "HXVoiceRecordView.h"
#import "MessageUtil.h"
#import "HXMessage+Additions.h"
#import "CoreDataUtil.h"
#import "NotificationCenterUtil.h"
#import "ChatUtil.h"
#import "UserUtil.h"
#import "HXUser+Additions.h"
#import "HXMessageTableViewCell.h"
#import "UIColor+CustomColor.h"
#import "HXAnLiveViewController.h"
#import "HXFriendSelectionViewController.h"
#import "HXIMManager.h"
#import "HXImageDetailViewController.h"
#import "HXLoadingView.h"
#import "HXAnSocialManager.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#define NAV_BAR_HEIGHT 0
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface HXChatViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSFetchedResultsControllerDelegate,UIViewControllerTransitioningDelegate,UIActionSheetDelegate, UIAlertViewDelegate, HXIMManagerChatDelegate,HXIMManagerTopicDelegate,HXComposeViewDelegate, HXVoiceRecordViewDelegate,HXMessageCellDelegate>
@property (strong, nonatomic) HXChat *chatInfo;
@property (strong, nonatomic) HXUser *targetUser;
@property (strong, nonatomic) HXComposeView *composeView;
@property (strong, nonatomic) NSString *targetTopicId;
@property (strong, nonatomic) NSString *targetClientId;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong, nonatomic) NSMutableSet *sendingMsgSet;
@property (strong, nonatomic) NSMutableSet *readMsgSet;
@property (strong, nonatomic) NSMutableSet *remoteReadMsgSet;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) AVAudioPlayer* voicePlayer;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UITextField * alertTextField;
@property (strong, nonatomic) NSString *currentUserName;
@property BOOL isTopicMode;
@property CGFloat keyboardHeight;
@end

@implementation HXChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _keyboardHeight = 0;
    [self fetchChatHistory];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showReadAck:)
                                                 name:@"ReceiveRemoteReadAck"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSaveMessageToLocal:)
                                                 name:SaveMessageToLocal object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSaveTopicMessageToLocal:)
                                                 name:SaveTopicMessageToLocal object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetOfflineTopicMessage)
                                                 name:GetOfflineTopicMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetOfflineChatMessage)
                                                 name:GetOfflineChatMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishVideoAudioCall:)
                                                 name:FinishVideoAudioCall object:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initNavigationBar];
    [HXIMManager manager].chatDelegate = self;
    [HXIMManager manager].topicDelegate = self;
    
    
    if (self.isTopicMode) {
        [[[HXIMManager manager]anIM] addClients:[NSSet setWithObject:[HXIMManager manager].clientId] toTopicId:self.chatInfo.topicId];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.composeView resignFirstResponder];
}

-(void)viewWillLayoutSubviews{
    [self updateNavigationBarItem:nil];
}

#pragma mark initialized Method

- (id)initWithChatInfo:(HXChat *)chatInfo setTopicMode:(BOOL)isTopicMode
{
    self = [super init];
    if (self)
    {
        self.hidesBottomBarWhenPushed = YES;
        self.chatInfo = chatInfo;
        self.isTopicMode = isTopicMode;
        self.messagesArray = [[NSMutableArray alloc] initWithCapacity:0];
        self.sendingMsgSet = [[NSMutableSet alloc] initWithCapacity:0];
        self.readMsgSet = [[NSMutableSet alloc] initWithCapacity:0];
        if (!isTopicMode) {
            self.targetClientId = self.chatInfo.targetClientId;
        }else {
            self.targetTopicId = self.chatInfo.topicId;
        }
        self.currentUserName = [UserUtil getHXUserByClientId:[HXIMManager manager].clientId].userName;
        [self initView];
        [self initNavigationBar];
    }
    return self;
}

- (void)initView
{
    CGRect frame;
    
    self.view.backgroundColor = [HXAppUtility hexToColor:0xf2f2f2 alpha:1];
    
    self.composeView = [[HXComposeView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.composeView.delegate = self;
    frame = self.composeView.frame;
    frame.origin.y = self.view.frame.size.height -frame.size.height -64;
    self.composeView.frame = frame;
    self.composeView.isTopicMode = self.isTopicMode;
    [self.view addSubview:self.composeView];
    
    frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height -= self.composeView.frame.size.height +64;
    self.tableView = [[UITableView alloc] initWithFrame:frame
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTapped)];
    [self.tableView addGestureRecognizer:tap];
    
    [self.view addSubview:self.tableView];
    [self.view bringSubviewToFront:self.composeView];
    
}

- (void)initNavigationBar
{
    NSString *title = self.isTopicMode ? [NSString stringWithFormat:@"%@(%d)",self.chatInfo.topicName,(int)self.chatInfo.users.count+1] : self.chatInfo.targetUserName;
    [HXAppUtility initNavigationTitle:title
                         barTintColor:[UIColor color1]
                   withViewController:self];
    
    if (self.isTopicMode == YES) {
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editButton addTarget:self action:@selector(editButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [editButton setTitle:NSLocalizedString(@"編輯", nil) forState:UIControlStateNormal];
        [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [editButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        editButton.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:34/2];
        [editButton sizeToFit];
        UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        [self.navigationItem setRightBarButtonItem:editBarButton];
    }
}

- (void)initLocationManager
{
    if (!self.locationManager)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = 50;  // triggers update when moving over 10 meters
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
    }
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Listener

- (void)backBarButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableViewTapped
{
    [self.composeView textFieldResignFirstResponder];
}

- (void)editButtonTapped
{
    [self.composeView textFieldResignFirstResponder];
    
    NSString *button1 = NSLocalizedString(@"編輯群組名稱", nil);
    NSString *button2 = NSLocalizedString(@"邀請成員", nil);
    NSString *button3 = NSLocalizedString(@"退出群組", nil);
    
    if (self.chatInfo.topicOwner && [self.chatInfo.topicOwner.clientId isEqualToString:[HXIMManager manager].clientId]) {
       button3 = NSLocalizedString(@"刪除並解散群組", nil);
    }
    
    NSString *cancelTitle = NSLocalizedString(@"取消", nil);
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:button1, button2, button3, nil];
    [actionSheet showInView:self.view];
}

#pragma mark - UIActionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
        case 0: {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"編輯群組名稱", nil)
                                                             message:NSLocalizedString(@"請輸入這個群組的名稱", nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                                   otherButtonTitles:NSLocalizedString(@"儲存", nil),nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            self.alertTextField = [alert textFieldAtIndex:0];
            [alert show];
            
            break;
        }
        case 1: {
            HXFriendSelectionViewController *vc = [[HXFriendSelectionViewController alloc]initWithTopicSession:self.chatInfo];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
        case 2: {
            NSString *clientId = [HXIMManager manager].clientId;
            
            if (self.chatInfo.topicOwner && [self.chatInfo.topicOwner.clientId isEqualToString:[HXIMManager manager].clientId]) {
                [[[HXIMManager manager]anIM] removeTopic:self.targetTopicId];
                [UserUtil removeTopic:self.chatInfo from:clientId];
                [ChatUtil deleteChat:self.chatInfo];
            }else{
                [[[HXIMManager manager]anIM] removeClients:[NSSet setWithObject:clientId] fromTopicId:self.targetTopicId];
                [ChatUtil deleteChatHistory:self.chatInfo];
                [UserUtil removeTopic:self.chatInfo from:clientId];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && ![[HXAppUtility removeWhitespace:self.alertTextField.text] isEqualToString:@""])
    {
        //update DB
        self.chatInfo.topicName = self.alertTextField.text;
        [HXAppUtility initNavigationTitle:self.alertTextField.text
                             barTintColor:[UIColor color1]
                       withViewController:self];
        NSError *error;
        [[CoreDataUtil sharedContext] save:&error];
        if (error) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        if (self.chatInfo.topicOwner) {
            [[[HXIMManager manager]anIM] updateTopic:self.chatInfo.topicId withName:self.alertTextField.text withOwner:self.chatInfo.topicOwner.clientId];
        }
        
    }
}

#pragma mark - Save DB call back

- (void)didSaveMessageToLocal:(NSNotification *)notice
{
    [self updateNavigationBarItem:nil];
    
    if (self.isTopicMode) return;
    NSString *msgId = notice.object;
    if ([self.readMsgSet containsObject:msgId]) {
        [MessageUtil updateMessageReadAckByMessageId:msgId];
        [self.readMsgSet removeObject:msgId];
    }
    
}

- (void)didSaveTopicMessageToLocal:(NSNotification *)notice
{
    [self updateNavigationBarItem:nil];
    
    if (!self.isTopicMode) return;
    NSString *msgId = notice.object;
    if ([self.readMsgSet containsObject:msgId]) {
        [MessageUtil updateMessageReadAckByMessageId:msgId];
        [self.readMsgSet removeObject:msgId];
    }
    
}

#pragma mark - Get Offline Message

- (void)didGetOfflineTopicMessage
{
    if (!self.isTopicMode) return;
    [self fetchChatHistory];
    [self updateNavigationBarItem:nil];
}

- (void)didGetOfflineChatMessage
{
    if (self.isTopicMode) return;
    [self fetchChatHistory];
    [self updateNavigationBarItem:nil];
}

#pragma mark - Finish Video Audio Call
-(void)didFinishVideoAudioCall:(NSNotification *)notice
{
    NSDictionary *dic = notice.object;
    if ([self.targetClientId isEqualToString:dic[@"clientId"]] && [HXIMManager manager].anLiveCallStr) {
        [self sendMessage:[NSString stringWithFormat:@"[%@%@]",[HXIMManager manager].anLiveCallStr,dic[@"duration"]]];
        [HXIMManager manager].anLiveCallStr = nil;
    }
}

#pragma mark - IMManager Delegate

- (void)anIMDidAddClientsWithException:(NSString *)exception
{
    if (!exception)
    {
        
        //handle topic mode
    }
}

- (void)anIMMessageSent:(NSString *)messageId
{
    [self.sendingMsgSet removeObject:messageId];
    [self.tableView reloadData];
}

- (void)anIMSendReturnedException:(NSString *)exception messageId:(NSString *)messageId
{
    [self.sendingMsgSet removeObject:messageId];
    //handle fail sending
}

- (void)anIMDidReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp customMessage:(HXMessage *)customMessage
{
    if (self.isTopicMode) {
        
        if (![topicId isEqualToString:self.chatInfo.topicId])
            return;
    }else{
        if (![from isEqualToString:self.chatInfo.targetClientId])
            return;
        if (![topicId isEqualToString:@""])
            return;
    }

    [self addTimeMessageWithTimestamp:timestamp];
    [self.messagesArray addObject:customMessage];
    [[[HXIMManager manager]anIM] sendReadACK:messageId toClients:[NSSet setWithObject:from]];
    
    [self.readMsgSet addObject:messageId];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.tableView reloadData];
        if (self.messagesArray.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    });
    
}

- (void)anIMDidReceiveBinaryData:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp customMessage:(HXMessage *)customMessage
{
    if (self.isTopicMode) {
        
        if (![topicId isEqualToString:self.chatInfo.topicId])
            return;
    }else{
        if (![from isEqualToString:self.chatInfo.targetClientId])
            return;
        if (![topicId isEqualToString:@""])
            return;
    }
    
    [self addTimeMessageWithTimestamp:timestamp];
    [self.messagesArray addObject:customMessage];
    [[[HXIMManager manager]anIM] sendReadACK:messageId toClients:[NSSet setWithObject:from]];
    
    [self.readMsgSet addObject:messageId];
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.tableView reloadData];
        if (self.messagesArray.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    });
}

#pragma mark - Fetch Chat History in DB
- (void)fetchChatHistory
{
    NSError* error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    [self.messagesArray removeAllObjects];
    
    for (int i = 0; i < self.fetchedResultsController.fetchedObjects.count; i++) {
        HXMessage* message = self.fetchedResultsController.fetchedObjects[i];
        
        /* send read ACK */
        if (![message.from isEqualToString:self.chatInfo.currentClientId] && ![message.readACK integerValue]) {
            [MessageUtil updateMessageReadAckByMessageId:message.msgId];
            [[[HXIMManager manager]anIM] sendReadACK:message.msgId toClients:[NSSet setWithObject:message.from]];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        HXMessage *lastMessage = [self.messagesArray lastObject];
        NSDate *date1timestamp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[lastMessage.timestamp doubleValue]/1000];
        NSString *date1 = [NSString stringWithString:[dateFormatter stringFromDate:date1timestamp]];
        
        NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[message.timestamp doubleValue]/1000];
        NSString *date2 = [dateFormatter stringFromDate:updatetimestamp];
        if (![date1 isEqualToString:date2])
        {
            if ([[date2 substringToIndex:4] integerValue] > 2010)
            {
                [self.messagesArray addObject:[self customTimeMessageWithYear:[date2 substringToIndex:4]
                                                                        month:[date2 substringWithRange:NSMakeRange(4, 2)]
                                                                         date:[date2 substringFromIndex:6]]];
            }
        }
        [self.messagesArray addObject:message];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if (self.messagesArray.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    });
}

#pragma mark - TableView Delegate Datasource

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    if ([self.messagesArray[indexPath.row] isKindOfClass:[NSMutableDictionary class]]) {
        
        CGFloat timeLabelY = indexPath.row ? 0 : 20/2;
        return 24/2 + 20/2 + timeLabelY;
        
    }else{
        HXMessage *message = self.messagesArray[indexPath.row];
        NSString *ownerName = [message.from isEqualToString:self.chatInfo.currentClientId]
        ? nil : message.senderName;

        return [HXMessageTableViewCell cellHeightForOwnerName:ownerName
                                                      message:message.message
                                                  messageType:message.type
                                                        image:message.content] + 20/2;

    }
    return 70;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    if ([self.messagesArray[indexPath.row] isKindOfClass:[NSMutableDictionary class]])
    {
        UITableViewCell *dateCell = [tableView dequeueReusableCellWithIdentifier:@"dateCell"];
        if (!dateCell) {
            dateCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCell"];
        }
        dateCell.selectionStyle = UITableViewCellSelectionStyleNone;
        dateCell.backgroundColor = [UIColor clearColor];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = [NSString stringWithFormat:@"%@.%@.%@", self.messagesArray[indexPath.row][@"year"], self.messagesArray[indexPath.row][@"month"], self.messagesArray[indexPath.row][@"date"]];
        timeLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:24.0f/2];
        timeLabel.textColor = [HXAppUtility hexToColor:0x58595b alpha:1];
        timeLabel.numberOfLines = 1;
        [timeLabel sizeToFit];
        CGFloat timeLabelY = indexPath.row ? 0 : 20/2;
        timeLabel.frame = CGRectMake(self.view.frame.size.width/2 - timeLabel.frame.size.width/2 , timeLabelY, timeLabel.frame.size.width, timeLabel.frame.size.height);
        
        [[dateCell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [dateCell.contentView addSubview:timeLabel];
        return dateCell;
    }else
    {
        static NSString *cellIdentifier = @"chatCell";
        HXMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        HXMessage *message = self.messagesArray[indexPath.row];
        
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"clientId == %@", message.from];
        NSArray *users = [[[self.chatInfo.users allObjects] filteredArrayUsingPredicate:resultPredicate]mutableCopy];
        HXUser *remoteUser = [users firstObject];
        
        NSString *photoUrl = remoteUser ? remoteUser.photoURL : nil;
        NSString *ownerName = [message.from isEqualToString:self.chatInfo.currentClientId]
        ? nil : message.senderName;
        

        // read ack
        if (self.remoteReadMsgSet) {
            if ([self.remoteReadMsgSet count]){
                if ([self.remoteReadMsgSet containsObject:message.msgId]) {
                    message.readACK = @(YES);
                    self.messagesArray[indexPath.row] = message;
                    [self.remoteReadMsgSet removeObject:message.msgId];
                }
            }
        }
        
        
        if (cell == nil) {
            //NSLog(@"%@",[[HXImageStore imageStore] imageUrlForKey:message.from]);
            cell = [[HXMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:cellIdentifier
                                                      OwnerName:ownerName
                                          profileImageUrlString:photoUrl
                                                        message:message.message
                                                           date:message.timestamp
                                                           type:message.type
                                                          image:message.content
                                                        readACK:[message.readACK integerValue]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.delegate = self;
            cell.tappedTag = indexPath.row;
            
        }else{
            //NSLog(@"%@",[[HXImageStore imageStore] imageUrlForKey:message.from]);
            [cell reuseCellWithOwnerName:ownerName
                            profileImage:[UIImage imageNamed:@"friend_default"]
                   profileImageUrlString:photoUrl
                                 message:message.message
                                    date:message.timestamp
                                    type:message.type
                                   image:message.content
                                 readACK:[message.readACK integerValue]];
            cell.tappedTag = indexPath.row;
        }
    
        
        return cell;
    }

}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{

}

#pragma mark - HXMessageCell Delegate

- (void)messageCellImageTapped:(NSInteger)index
{
    [self.composeView textFieldResignFirstResponder];
    
    HXMessage *message = self.messagesArray[index];
    
    if ([message.type isEqualToString:@"image"]) {
        
        HXImageDetailViewController *vc = [[HXImageDetailViewController alloc]initWithImage:[UIImage imageWithData:message.content] imageUrl:message.fileURL mode:@"modal"];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
        
    }else if ([message.type isEqualToString:@"record"]){
        
        [self playVoiceWithData:message.content];
    }else if ([message.type isEqualToString:@"location"]){
        
        HXMapViewController *mapVc = [[HXMapViewController alloc]init];
        mapVc.fLatitude = [message.latitude floatValue];
        mapVc.fLongitude = [message.longitude floatValue];
        [self.navigationController pushViewController:mapVc animated:YES];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized))
    {
        [self sendLocationMessage];
    }
    if (IS_OS_8_OR_LATER) {
        [self sendLocationMessage];
    }
}

#pragma mark HXComposeView Delegate

- (void)composeViewWillChangeHeight:(CGFloat)height
{
    CGRect frame = self.tableView.frame;
    frame.size.height += height;
    self.tableView.frame = frame;
}

- (void)sendMessage:(NSString *)message
{
    if (![[HXAppUtility removeWhitespace:message] length])return;
    
    NSString *msgId;
    NSString *notificationAlert = [NSString stringWithFormat:@"%@ : %@",self.currentUserName,message];
    NSDictionary *customData = @{@"name":self.currentUserName,
                                 @"notification_alert":notificationAlert};
    if (!self.isTopicMode) {
        NSSet *clientId = [NSSet setWithObject:self.targetClientId];
        msgId = [[[HXIMManager manager]anIM] sendMessage:message
                                              customData:customData
                                               toClients:clientId
                                          needReceiveACK:YES];
    }else{
        msgId = [[[HXIMManager manager]anIM] sendMessage:message
                                              customData:customData
                                               toTopicId:self.targetTopicId
                                          needReceiveACK:YES];
    }
    
    NSNumber *timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMTextMessage
                                                            msgId:msgId
                                                          topicId:self.targetTopicId ? self.targetTopicId : @""
                                                          message:message
                                                          content:nil
                                                         fileType:@"text"
                                                             from:[HXIMManager manager].clientId
                                                       customData:customData
                                                        timestamp:timestamp];
    
    [self wrapMessageToSend:[MessageUtil anIMMessageToHXMessage:customMessage]];
    

    if (!self.isTopicMode) {
        [MessageUtil saveChatMessageIntoDB:@[customMessage] withTargetClientId:self.targetClientId];
    }else{
        [MessageUtil saveTopicMessageIntoDB:@[customMessage]];
    }
    
    
    
}

- (void)takePhotoTapped
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        imagePicker.showsCameraControls = YES;
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)selectPhotoTapped
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController* cameraRollPicker = [[UIImagePickerController alloc] init];
        cameraRollPicker.navigationBar.barTintColor = [UIColor color1];
        cameraRollPicker.delegate = self;
        cameraRollPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraRollPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        cameraRollPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        cameraRollPicker.allowsEditing = NO;
        [self.navigationController presentViewController:cameraRollPicker animated:YES completion:nil];
    }
}

- (void)recordVoiceTapped
{
    HXVoiceRecordView *vrView = [[HXVoiceRecordView alloc]initWithFrame:self.view.bounds];
    vrView.delegate = self;
    [self.view addSubview:vrView];
}

- (void)shareLocationTapped
{
   [self performSelectorOnMainThread:@selector(initLocationManager) withObject:nil waitUntilDone:NO];
}

- (void)videoCallTapped
{
    NSLog(@"Ringing ...");
    [HXIMManager manager].anLiveCallStr = NSLocalizedString(@"視訊通話", nil);
    
    [[AnLive shared] videoCall:self.targetClientId
                         video:YES
              notificationData:nil
                       success:^(NSString *sessionId) {
                           // 视频通话请求建立成功，正在等待对方应答
                           NSLog(@"Waiting for target client to answer the call...");
                           
                           HXAnLiveViewController *anLiveVC = [[HXAnLiveViewController alloc] initWithClientName:self.chatInfo.targetUserName clientPhotoImageUrl:nil mode:AnLiveVideoCall role:AnLiveCaller];
                           anLiveVC.transitioningDelegate = self;
                           anLiveVC.modalPresentationStyle = UIModalPresentationCustom;
                           
                           [self presentViewController:anLiveVC animated:YES completion:nil];
                           
                       } failure:^(ArrownockException *exception) {
                           // 视频通话建立失败
                           //                                       [self stopRingtone];    //停止呼叫铃音
                           NSLog(@"Call failed, stop ringing ...");
                       }];
    
}

- (void)audioCallTapped
{
    [HXIMManager manager].anLiveCallStr = NSLocalizedString(@"語音通話", nil);
    
    [[AnLive shared] voiceCall:self.targetClientId
              notificationData:nil
                       success:^(NSString *sessionId){
                           
                           // 视频通话请求建立成功，正在等待对方应答
                           NSLog(@"Waiting for target client to answer the call...");
                           
                           HXAnLiveViewController *anLiveVC = [[HXAnLiveViewController alloc] initWithClientName:self.chatInfo.targetUserName clientPhotoImageUrl:nil mode:AnLiveAudioCall role:AnLiveCaller];
                           anLiveVC.transitioningDelegate = self;
                           anLiveVC.modalPresentationStyle = UIModalPresentationCustom;
                           
                           [self presentViewController:anLiveVC animated:YES completion:nil];
                           
                       }failure:^(ArrownockException *exception){
                           
                           // 视频通话建立失败
                           //                                       [self stopRingtone];    //停止呼叫铃音
                           NSLog(@"Call failed, stop ringing ...");
                       }];
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        
        UIImage* image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
        NSLog(@"I got the photo!!!");
        
        [self showSendingImage:image];
        
    }

}
#pragma mark - Navigation Method
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController.navigationItem setTitle:@""];
    viewController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    viewController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"取消", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelBarButtonTapped)];
    viewController.navigationItem.rightBarButtonItem = cancelButton;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)cancelBarButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark AnIM Send Message Method

- (void)sendLocationMessage
{
    float fLat = self.locationManager.location.coordinate.latitude;
    float fLong = self.locationManager.location.coordinate.longitude;
    NSString *notificationAlert = [NSString stringWithFormat:NSLocalizedString(@"%@ 向您傳送了位置訊息", nil),self.currentUserName];
    NSDictionary *customData = @{@"location":@{@"latitude":[NSNumber numberWithFloat:fLat],
                                               @"longitude":[NSNumber numberWithFloat:fLong]},
                                 @"name":self.currentUserName,
                                 @"notification_alert":notificationAlert};
    NSString *msgId;
    if (!self.isTopicMode) {
        NSSet *clientId = [NSSet setWithObject:self.targetClientId];
        msgId = [[[HXIMManager manager] anIM] sendMessage:@"[location]"
                                               customData:customData
                                                toClients:clientId
                                           needReceiveACK:YES];
    }else{
        msgId = [[[HXIMManager manager] anIM] sendMessage:@"[location]"
                                               customData:customData
                                                toTopicId:self.targetTopicId
                                           needReceiveACK:YES];
    }
   
    NSNumber *timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMTextMessage
                                                            msgId:msgId
                                                          topicId:self.targetTopicId ? self.targetTopicId : @""
                                                          message:@""
                                                          content:nil
                                                         fileType:@"location"
                                                             from:[HXIMManager manager].clientId
                                                       customData:customData
                                                        timestamp:timestamp];
    
    [self wrapMessageToSend:[MessageUtil anIMMessageToHXMessage:customMessage]];
    
    if (!self.isTopicMode) {
        [MessageUtil saveChatMessageIntoDB:@[customMessage] withTargetClientId:self.targetClientId];
    }else{
        [MessageUtil saveTopicMessageIntoDB:@[customMessage]];
    }
    
}

#pragma mark AnIM Send Binary Data Method

- (void)showSendingImage:(UIImage *)image
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
   // NSData* originalImageData = UIImageJPEGRepresentation(image, 1);
    UIImage *thumbnail = [HXAppUtility thumbnailImage:image];
    NSData* thumbnailData = UIImageJPEGRepresentation(thumbnail, 1);
    
    NSString *notificationAlert = [NSString stringWithFormat:NSLocalizedString(@"%@ 向您傳送了圖片", nil),self.currentUserName];
    NSDictionary *customData = @{@"name":self.currentUserName,
                                 @"notification_alert":notificationAlert};
    NSNumber *timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    
    NSString *timestampStr = [timestamp stringValue];
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMBinaryMessage
                                                            msgId:timestampStr
                                                          topicId:self.targetTopicId ? self.targetTopicId : @""
                                                          message:@""
                                                          content:thumbnailData
                                                         fileType:@"image"
                                                             from:[HXIMManager manager].clientId
                                                       customData:customData
                                                        timestamp:timestamp];
    
    [self wrapMessageToSend:[MessageUtil anIMMessageToHXMessage:customMessage]];
    
    [self sendImageData:image thumbnailData:thumbnailData timestampStr:timestampStr];
    
    if (!self.isTopicMode) {
        [MessageUtil saveChatMessageIntoDB:@[customMessage] withTargetClientId:self.targetClientId];
    }else{
        [MessageUtil saveTopicMessageIntoDB:@[customMessage]];
    }
    
}

- (void)sendImageData:(UIImage *)image thumbnailData:(NSData *)thumbnailData timestampStr:(NSString *)timestampStr
{
    /* resize the image */
    
    UIImage *resizedImage = [HXAppUtility resizedOriginalImage:image maxOffset:480];
    NSData* resizedImageData = UIImageJPEGRepresentation(resizedImage, 1);
    
    NSInteger photoDataIndex = self.messagesArray.count - 1;
    
    HXLoadingView *load = [[HXLoadingView alloc]initLoadingView];
    [self.view addSubview:load];
    
    [[HXAnSocialManager manager] uploadPhotoToServer:resizedImageData Success:^(NSDictionary *response){
        
        NSString *photoUrls = response[@"response"][@"photo"][@"url"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *msgId;
            NSString *notificationAlert = [NSString stringWithFormat:NSLocalizedString(@"%@ 向您傳送了圖片", nil),self.currentUserName];
            NSDictionary *customData = @{@"name":self.currentUserName,
                                         @"type":@"image",
                                         @"url":photoUrls,
                                         @"notification_alert":notificationAlert};
            if (!self.isTopicMode) {
                NSSet *clientId = [NSSet setWithObject:self.targetClientId];
                msgId = [[[HXIMManager manager] anIM] sendBinary:thumbnailData
                                                        fileType:@"image"
                                                      customData:customData
                                                       toClients:clientId
                                                  needReceiveACK:YES];
            }else{
                msgId = [[[HXIMManager manager] anIM] sendBinary:thumbnailData
                                                        fileType:@"image"
                                                      customData:customData
                                                       toTopicId:self.targetTopicId
                                                  needReceiveACK:YES];
                
            }
            HXMessage *imageMessage = [MessageUtil getMessageByMessageId:timestampStr];
            imageMessage.msgId = msgId;
            imageMessage.fileURL = photoUrls;
            
            NSError *error;
            [[CoreDataUtil sharedContext] save:&error];
            if (error) {
                NSLog(@"Whoops, couldn't save image: %@", [error localizedDescription]);
            }
            self.messagesArray[photoDataIndex] = imageMessage;
            
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:photoDataIndex inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            [load loadCompleted];
            
        });
    } failure:^(NSDictionary *response){
        [load removeFromSuperview];
        
    }];
    
}

- (void)sendVoiceData:(NSData *)voice
{
    NSString *msgId;
    NSString *notificationAlert = [NSString stringWithFormat:NSLocalizedString(@"您收到來自 %@ 的聲音訊息", nil),self.currentUserName];
    NSDictionary *customData = @{@"name":self.currentUserName,
                                 @"notification_alert":notificationAlert};
    if (!self.isTopicMode) {
        NSSet *clientId = [NSSet setWithObject:self.targetClientId];
        msgId = [[[HXIMManager manager] anIM] sendBinary:voice
                                                fileType:@"record"
                                              customData:customData
                                               toClients:clientId
                                          needReceiveACK:YES];
    }else{
        msgId = [[[HXIMManager manager] anIM] sendBinary:voice
                                                fileType:@"record"
                                              customData:customData
                                               toTopicId:self.targetTopicId
                                          needReceiveACK:YES];
    }
    
    NSNumber *timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMBinaryMessage
                                                            msgId:msgId
                                                          topicId:self.targetTopicId ? self.targetTopicId : @""
                                                          message:@""
                                                          content:voice
                                                         fileType:@"record"
                                                             from:[HXIMManager manager].clientId
                                                       customData:customData
                                                        timestamp:timestamp];
    
    [self wrapMessageToSend:[MessageUtil anIMMessageToHXMessage:customMessage]];
    
    if (!self.isTopicMode) {
        [MessageUtil saveChatMessageIntoDB:@[customMessage] withTargetClientId:self.targetClientId];
    }else{
        [MessageUtil saveTopicMessageIntoDB:@[customMessage]];
    }

}

#pragma mark Custom Message Object

- (NSMutableDictionary*)customMessageWithMessageId:(NSString *)messageId
                                           Content:(NSData *)binaryData
                                          fileType:(NSString *)fileType
                                           TopicId:(NSString *)topicId
                                           message:(NSString *)text
                                              from:(NSString*)clientId
                                        customData:(NSDictionary *)customData
                                         timestamp:(NSNumber *)timestamp
{
    return [@{@"messagId":messageId ? messageId : [NSNull null],
              @"content":binaryData ? binaryData : [NSNull null],
              @"fileType":fileType ? fileType : [NSNull null],
              @"topicId": topicId ? topicId : [NSNull null],
              @"message": text ? text : [NSNull null],
              @"from": clientId ? clientId : [NSNull null],
              @"customData": customData ? customData : [NSNull null],
              @"timestamp": timestamp ? timestamp : [NSNull null]}mutableCopy];
    
}

- (NSMutableDictionary *)customTimeMessageWithYear:(NSString *)year month:(NSString *)month date:(NSString *)date
{
    return [@{@"timeLabel": @YES,
              @"year": year,
              @"month": month,
              @"date": date} mutableCopy];
}

#pragma mark Helper

- (void)wrapMessageToSend:(HXMessage *)message
{
    
    [self addTimeMessageWithTimestamp:message.timestamp];
    [self.sendingMsgSet addObject:message.msgId];
    [self.messagesArray addObject:message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        if (self.messagesArray.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    });

}

- (void)addTimeMessageWithTimestamp:(NSNumber *)timestamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    HXMessage *lastMessage = [self.messagesArray lastObject];
    NSDate *date1timestamp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[lastMessage.timestamp doubleValue]/1000];
    NSString *date1 = [NSString stringWithString:[dateFormatter stringFromDate:date1timestamp]];
    
    NSDate *updatetimestamp = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[timestamp doubleValue]/1000];
    NSString *date2 = [dateFormatter stringFromDate:updatetimestamp];
    if (![date1 isEqualToString:date2])
    {
        if ([[date2 substringToIndex:4] integerValue] > 2010)
        {
            [self.messagesArray addObject:[self customTimeMessageWithYear:[date2 substringToIndex:4]
                                                                    month:[date2 substringWithRange:NSMakeRange(4, 2)]
                                                                     date:[date2 substringFromIndex:6]]];
        }
    }
}

- (void)playVoiceWithData:(NSData *)voice
{
    NSError* error;
    self.voicePlayer = [[AVAudioPlayer alloc] initWithData:voice error:&error];
    if (error)
        NSLog(@"%@", [error localizedDescription]);
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    if ([self.voicePlayer isPlaying])
        [self.voicePlayer stop];
    else
        [self.voicePlayer play];
}

- (void)showReadAck:(NSNotification *)notice
{
    if (notice.object) {
        
        NSString *msgId = notice.object;
        if (!self.remoteReadMsgSet) {
            self.remoteReadMsgSet = [[NSMutableSet alloc] initWithCapacity:0];
        }
        
        [self.remoteReadMsgSet addObject:msgId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)updateNavigationBarItem:(NSNotification *)notice
{
    
    if (self.readMsgSet.count) {
        NSArray *msgIds = [self.readMsgSet allObjects];
        [self.readMsgSet removeAllObjects];
        [MessageUtil updateMessageReadAckByMessageIds:msgIds];
    }else{
        
        NSInteger count = [MessageUtil getAllUnreadCount];
        NSString *unreadCount = [NSString stringWithFormat:@"(%ld)",(long)count];
        if (count != 0){
            self.navigationController.navigationBar.backItem.backBarButtonItem
            =[[UIBarButtonItem alloc] initWithTitle:unreadCount
                                              style:UIBarButtonItemStylePlain
                                             target:self
                                             action:nil];
        }else{
            self.navigationController.navigationBar.backItem.backBarButtonItem
            =[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"返回", nil)
                                              style:UIBarButtonItemStylePlain
                                             target:self
                                             action:nil];
        }
    }
    
    
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _keyboardHeight = kbSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.composeView.frame = CGRectMake(self.composeView.bounds.origin.x,
                                        self.view.bounds.size.height - kbSize.height - self.composeView.frame.size.height,
                                        self.composeView.frame.size.width,
                                        self.composeView.frame.size.height);
    
    CGRect frame = self.tableView.frame;
    frame.size.height = self.view.frame.size.height- NAV_BAR_HEIGHT -kbSize.height - self.composeView.frame.size.height;
    self.tableView.frame = frame;
    
    if (self.messagesArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    _keyboardHeight = 0;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.composeView.center = CGPointMake(self.composeView.center.x,
                                          self.composeView.center.y + kbSize.height);
    
    CGRect frame = self.tableView.frame;
    frame.size.height = self.view.frame.size.height - NAV_BAR_HEIGHT- self.composeView.frame.size.height;
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HXMessage"
                                              inManagedObjectContext:[CoreDataUtil sharedContext]];
    
    [fetchRequest setIncludesPropertyValues:NO];
    if (!self.isTopicMode) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat
                                    :@"self IN %@"
                                    ,self.chatInfo.messages]];
    }else{
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat
                                    :@"chat.topicId == %@",self.chatInfo.topicId]];
    }
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:15];
    //[fetchRequest setFetchLimit:15];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
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
    // Dispose of any resources that can be recreated.
}


@end
