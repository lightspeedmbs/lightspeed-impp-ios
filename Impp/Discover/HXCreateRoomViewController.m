//
//  HXCreatePostViewController.m
//  Impp
//
//  Created by hsujahhu on 2015/4/9.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXCreateRoomViewController.h"
#import "HXAppUtility.h"
#import "ChatUtil.h"
#import "HXAnSocialManager.h"
#import "AnSocialFile.h"
#import "HXUserAccountManager.h"
#import "SZTextView.h"
#import "HXLoadingView.h"
#import "LightspeedCredentials.h"
#import "NotificationCenterUtil.h"
#import "UIColor+CustomColor.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>
#import "HXIMManager.h"
#import "UIView+Toast.h"
#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width

static NSString *photoCellIdentifier = @"PhotoCell";

@interface HXCreateRoomViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,
UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UIActionSheetDelegate,UITextFieldDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *photosArray;
@property (strong, nonatomic) NSMutableArray *photoUrlsArray;

@property (strong, nonatomic) NSMutableArray *photoIdArray;

@property (strong, nonatomic) UIView *textBg;
@property (strong, nonatomic) UIView *textViewBg;
@property (strong, nonatomic) UITapGestureRecognizer *messageTextViewTap;
@property (strong, nonatomic) SZTextView *anRoomDescriptionTextView;
@property (strong, nonatomic) UITextField *anRoomNameTextField;

@property (strong, nonatomic) HXLoadingView *load;
@property BOOL iscallingAPI;
@end

@implementation HXCreateRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photosArray = [[NSMutableArray alloc]initWithCapacity:0];
    [self initData];
    [self initView];
    [self initNavigationBar];
    
}

- (void)initData
{
    _iscallingAPI = NO;
    self.photosArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.photoUrlsArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.photoIdArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    [self.photosArray addObject:[UIImage imageNamed:@"compose_bu"]];
    
    
}

- (void)initView
{
    self.view.backgroundColor = [UIColor color5];
    
    
    self.messageTextViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageTextViewTapped)];

    self.anRoomNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 31)];
    self.anRoomNameTextField.textColor = [UIColor color11];
    self.anRoomNameTextField.placeholder = NSLocalizedString(@"group_name...", nil);
    //self.anRoomNameTextField.placeholderTextColor = [UIColor color8];
    self.anRoomNameTextField.font = [UIFont fontWithName:@"STHeitiTC-Light" size:16];
    self.anRoomNameTextField.backgroundColor = [UIColor clearColor];//[[UIColor redColor]colorWithAlphaComponent:0.3];
    //self.anRoomNameTextField.editable = YES;
    self.anRoomNameTextField.delegate = self;
    
    self.textBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30 + self.anRoomNameTextField.frame.size.height)];
    self.textBg.backgroundColor = [UIColor clearColor];//[[UIColor grayColor]colorWithAlphaComponent:0.5];
    [self.view addSubview:self.textBg];
    [self.textBg addSubview:self.anRoomNameTextField];
    
    self.anRoomDescriptionTextView = [[SZTextView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 52)];
    self.anRoomDescriptionTextView.textColor = [UIColor color11];
    self.anRoomDescriptionTextView.placeholder = NSLocalizedString(@"group_description...", nil);
    self.anRoomDescriptionTextView.placeholderTextColor = [UIColor color8];
    self.anRoomDescriptionTextView.font = [UIFont fontWithName:@"STHeitiTC-Light" size:16];
    self.anRoomDescriptionTextView.backgroundColor = [UIColor clearColor];//[[UIColor redColor]colorWithAlphaComponent:0.3];
    self.anRoomDescriptionTextView.editable = YES;
    self.anRoomDescriptionTextView.delegate = self;
    
    self.textViewBg = [[UIView alloc]initWithFrame:CGRectMake(0, self.textBg.frame.size.height, SCREEN_WIDTH, 30 + self.anRoomDescriptionTextView.frame.size.height)];
    self.textViewBg.backgroundColor = [UIColor clearColor];//[[UIColor grayColor]colorWithAlphaComponent:0.5];
    [self.view addSubview:self.textViewBg];
    [self.textViewBg addSubview:self.anRoomDescriptionTextView];
    
    
    UIView *seperatedLine = [[UIView alloc]initWithFrame:CGRectMake(0,self.textBg.frame.size.height-1,SCREEN_WIDTH,1)];
    seperatedLine.backgroundColor = [UIColor color8];
    [self.textBg addSubview:seperatedLine];
    
    UIView *seperatedLine2 = [[UIView alloc]initWithFrame:CGRectMake(0,71,SCREEN_WIDTH,1)];
    seperatedLine2.backgroundColor = [UIColor color8];
    [self.textViewBg addSubview:seperatedLine2];
    
    CGRect frame;
    frame = self.view.frame;
    frame.size.height -= self.textBg.frame.size.height + self.textViewBg.frame.size.height + 15 + 64;
    frame.size.width -= 30;
    frame.origin.y = self.textBg.frame.size.height + self.textViewBg.frame.size.height + 15;
    frame.origin.x = 15;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(frame.size.width/4 - 2,frame.size.width/4 -2);
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 2;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:photoCellIdentifier];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    
}

- (void)initNavigationBar
{
    [HXAppUtility initNavigationTitle:NSLocalizedString(@"create_group", nil) barTintColor:[UIColor color1] withViewController:self];
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton addTarget:self action:@selector(finishButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [finishButton setTitle:NSLocalizedString(@"create", nil) forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [finishButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
    finishButton.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:34/2];
    [finishButton sizeToFit];
    UIBarButtonItem *finishBarButton = [[UIBarButtonItem alloc] initWithCustomView:finishButton];
    [self.navigationItem setRightBarButtonItem:finishBarButton];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:34/2];
    [cancelButton sizeToFit];
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    [self.navigationItem setLeftBarButtonItem:cancelBarButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Listener

- (void)cancelButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageTextViewTapped
{
    [self.collectionView removeGestureRecognizer:self.messageTextViewTap];
    [self.anRoomDescriptionTextView resignFirstResponder];
    [self.anRoomNameTextField resignFirstResponder];
}

- (void)finishButtonTapped
{

    if (!_iscallingAPI) {
        
        [self.anRoomNameTextField resignFirstResponder];
        [self.anRoomDescriptionTextView resignFirstResponder];
        
        self.load = [[HXLoadingView alloc]initLoadingView];
        [self.view addSubview:self.load];
        

        if (![HXAppUtility removeWhitespace:self.anRoomNameTextField.text].length || ![HXAppUtility removeWhitespace:self.anRoomDescriptionTextView.text].length || self.photosArray.count<2){
            UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.load loadCompleted];
                [displayWindow makeImppToast:NSLocalizedString(@"room_name_description_photo_are_mandatory", nil)  navigationBarHeight:0];
            });
        }else {
            [self.photoUrlsArray removeAllObjects];
            [self.photoIdArray removeAllObjects];
            
            
            // lastObject is tapped button
            if (self.photosArray.count > 1) {
                for (int i= 0; i < self.photosArray.count - 1; i++) {
                    [self uploadPhotoToServer:self.photosArray[i] Success:^(NSDictionary* response){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.photoUrlsArray addObject:[response[@"response"][@"photo"][@"url"] mutableCopy]];
                            [self.photoIdArray addObject:[response[@"response"][@"photo"][@"id"] mutableCopy]];
                            
                            
                            if (self.photoIdArray.count == self.photosArray.count - 1) {
                                [self createGroup];
                            }
                        });
                        
                    } failure:^(NSDictionary* response){
                        
                    }];
                }
            }else if (![[HXAppUtility removeExtraWhitespace:self.anRoomNameTextField.text] isEqualToString:@""]){
                [self createGroup];
            }
        }

    }

}

- (void)createGroup
{
    _iscallingAPI = YES;
    [[[HXIMManager manager]anIM] createTopic:self.anRoomNameTextField.text withClients:[NSSet setWithObject:[HXUserAccountManager manager].clientId] success:^(NSString *topicId, NSNumber *createdTimestamp, NSNumber *updatedTimestamp) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [ChatUtil createChatSessionWithUser:[NSSet setWithObject:[HXUserAccountManager manager].userInfo]  topicId:topicId topicName:self.anRoomNameTextField.text currentUserName:[HXUserAccountManager manager].userName topicOwnerClientId:nil];
            NSLog (@"Create chat room with topic name:%@ and ID:%@",self.anRoomNameTextField.text,topicId);
            NSMutableDictionary *custom_fields = [@{@"topic_id":topicId,
                                                    @"description":self.anRoomDescriptionTextView.text,
                                                    }mutableCopy];
            if (self.photosArray.count > 1) {
                
                NSString *photoUrl = self.photoUrlsArray[0];
                //NSDictionary *customData = @{@"photoUrls":photoUrls};
                [custom_fields setObject:photoUrl forKey:@"photoUrls"];
            }
            
            NSMutableDictionary *params = [@{@"type":@"room",//@"_EMPTY_",
                                             @"custom_fields":custom_fields,
                                             @"user_id":[HXUserAccountManager manager].userId,
                                             @"user_ids":[HXUserAccountManager manager].userId,
                                             //@"wall_id":LIGHTSPEED_WALL_ID,
                                             @"name":self.anRoomNameTextField.text}mutableCopy];
            
            
            [[HXAnSocialManager manager]sendRequest:@"circles/create.json" method:AnSocialManagerPOST params:params success:^(NSDictionary *response){
                NSLog(@"post data :%@",[response description]);

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.load loadCompleted];
                    [self successPost];
                    _iscallingAPI = NO;
                });
                
            } failure:^(NSDictionary *response){
                [self.load removeFromSuperview];
                NSLog(@"fail to post data :%@",[response description]);
            }];

        });
            } failure:^(ArrownockException *exception) {
        NSLog (@"Create chat room failed:%@",exception);
    }];
    
    
    
    
    
    
    
    
}

- (void)successPost
{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:RefreshRoom object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
//    if ([HXAppUtility removeWhitespace:self.anRoomNameTextField.text].length && [HXAppUtility removeWhitespace:self.anRoomDescriptionTextView.text].length && self.photosArray.count==2)
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    else
//        self.navigationItem.rightBarButtonItem.enabled = NO;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.collectionView addGestureRecognizer:self.messageTextViewTap];
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoCellIdentifier forIndexPath:indexPath];
    if (indexPath.item == self.photosArray.count - 1) {
        cell.backgroundColor = [UIColor color6];
        UIImage *composeBu = self.photosArray[indexPath.item];
        UIImageView *selectPhoto = [[UIImageView alloc]initWithImage:composeBu];
        CGRect frame;
        frame = selectPhoto.frame;
        frame.origin.x = (cell.frame.size.width - selectPhoto.frame.size.width)/2;
        frame.origin.y = (cell.frame.size.height - selectPhoto.frame.size.height)/2;
        selectPhoto.frame = frame;
        [cell.contentView addSubview:selectPhoto];
        
    }else{
        UIImage *photo = [UIImage imageWithData:self.photosArray[indexPath.item]];
        UIImageView *photoView = [[UIImageView alloc]initWithImage:photo];
        photoView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
        photoView.contentMode = UIViewContentModeScaleAspectFill;
        photoView.clipsToBounds = YES;
        [cell.contentView addSubview:photoView];
    }
    
    return cell;
}

#pragma mark - collection view delegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.photosArray.count - 1) {
        //[self selectPhoto];
        [self.anRoomNameTextField resignFirstResponder];
        
        NSString *button1 = NSLocalizedString(@"camera", nil);
        NSString *button2 = NSLocalizedString(@"choose_a_photo", nil);
        
        NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:button1, button2, nil];
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UIActionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
        case 0: {
            // take photo
            [self takePhoto];
            break;
        }
        case 1: {
            // select photo
            [self selectPhoto];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Pick up Photo Method
- (void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        imagePicker.showsCameraControls = YES;
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
        });
    }
}

- (void)selectPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController* cameraRollPicker = [[UIImagePickerController alloc] init];
        cameraRollPicker.navigationBar.barTintColor = [UIColor color1];
        cameraRollPicker.delegate = self;
        cameraRollPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraRollPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        cameraRollPicker.allowsEditing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:cameraRollPicker animated:YES completion:nil];
        });
        
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        
        UIImage* image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
        NSLog(@"I got the photo!!!");
        
        [self showSelectedPhoto:image];
        
    }
}

#pragma mark - Navigation Method
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController.navigationItem setTitle:@""];
    viewController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    viewController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelBarButtonTapped)];
    viewController.navigationItem.rightBarButtonItem = cancelButton;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)cancelBarButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper

- (void)uploadPhotoToServer:(NSData *)imageData
                    Success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSDictionary *response))failure
{
    AnSocialFile *imageFile = [AnSocialFile createWithFileName:@"photo"
                                                          data:imageData];
    
    NSDictionary *params = @{@"photo":imageFile,
                             @"user_id":[HXUserAccountManager manager].userId};
    
    [[HXAnSocialManager manager]sendRequest:@"photos/create.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        success(response);
        NSLog(@"post data :%@",[response description]);
    }failure:^(NSDictionary* response){
        failure(response);
        NSLog(@"fail to post data :%@",[response description]);
    }];
    
    
    
}

- (void)showSelectedPhoto:(UIImage *)image
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *resizedImage = [HXAppUtility resizedOriginalImage:image maxOffset:960];
    NSData* resizedImageData = UIImageJPEGRepresentation(resizedImage, 0.8);
    
    [self.photosArray insertObject:resizedImageData atIndex:0];
//    if ([HXAppUtility removeWhitespace:self.anRoomNameTextField.text].length && [HXAppUtility removeWhitespace:self.anRoomDescriptionTextView.text].length && self.photosArray.count==2)
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    else
//        self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.collectionView reloadData];
}

#pragma mark - UITextViewDelegate
-(void) textViewDidChange:(UITextView *)textView
{
//    if ([HXAppUtility removeWhitespace:self.anRoomNameTextField.text].length && [HXAppUtility removeWhitespace:self.anRoomDescriptionTextView.text].length && self.photosArray.count==2)
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    else if(self.photosArray.count <= 1)
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    if ([HXAppUtility removeWhitespace:textView.text].length)
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    else if(self.photosArray.count <= 1)
//        self.navigationItem.rightBarButtonItem.enabled = NO;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.collectionView addGestureRecognizer:self.messageTextViewTap];
}
@end
