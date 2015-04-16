//
//  HXCreatePostViewController.m
//  Impp
//
//  Created by hsujahhu on 2015/4/9.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXCreatePostViewController.h"
#import "HXAppUtility.h"
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
#define SCREEN_WIDTH [[UIScreen mainScreen] applicationFrame].size.width

static NSString *photoCellIdentifier = @"PhotoCell";

@interface HXCreatePostViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,
UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UIActionSheetDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *photosArray;
@property (strong, nonatomic) NSMutableArray *photoUrlsArray;
@property (strong, nonatomic) UIView *textBg;
@property (strong, nonatomic) UITapGestureRecognizer *messageTextViewTap;
@property (strong, nonatomic) SZTextView *messageTextView;
@property (strong, nonatomic) HXLoadingView *load;
@end

@implementation HXCreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photosArray = [[NSMutableArray alloc]initWithCapacity:0];
    [self initData];
    [self initView];
    [self initNavigationBar];
    
}

- (void)initData
{
    self.photosArray = [[NSMutableArray alloc]initWithCapacity:0];
    self.photoUrlsArray = [[NSMutableArray alloc]initWithCapacity:0];
    

    [self.photosArray addObject:[UIImage imageNamed:@"compose_bu"]];
    

}

- (void)initView
{
    self.view.backgroundColor = [UIColor color5];
    
    CGRect frame;
    self.messageTextViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageTextViewTapped)];
    self.messageTextView = [[SZTextView alloc]initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 200)];
    self.messageTextView.textColor = [UIColor color11];
    self.messageTextView.placeholder = NSLocalizedString(@"撰寫貼文...", nil);
    self.messageTextView.placeholderTextColor = [UIColor color8];
    self.messageTextView.font = [UIFont fontWithName:@"STHeitiTC-Light" size:16];
    self.messageTextView.backgroundColor = [UIColor clearColor];//[[UIColor redColor]colorWithAlphaComponent:0.3];
    self.messageTextView.editable = YES;
    self.messageTextView.delegate = self;

    
    self.textBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30 + self.messageTextView.frame.size.height)];
    self.textBg.backgroundColor = [UIColor clearColor];//[[UIColor grayColor]colorWithAlphaComponent:0.5];
    [self.view addSubview:self.textBg];
    [self.textBg addSubview:self.messageTextView];
    
    UIView *seperatedLine = [[UIView alloc]initWithFrame:CGRectMake(0,self.textBg.frame.size.height-1,SCREEN_WIDTH,1)];
    seperatedLine.backgroundColor = [UIColor color8];
    [self.textBg addSubview:seperatedLine];
    
    
    frame = self.view.frame;
    frame.size.height -= self.textBg.frame.size.height + 15 + 64;
    frame.size.width -= 30;
    frame.origin.y = self.textBg.frame.size.height + 15;
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
    [HXAppUtility initNavigationTitle:NSLocalizedString(@"新增貼文", nil) barTintColor:[UIColor color1] withViewController:self];
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton addTarget:self action:@selector(finishButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [finishButton setTitle:NSLocalizedString(@"發佈", nil) forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [finishButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
    finishButton.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:34/2];
    [finishButton sizeToFit];
    UIBarButtonItem *finishBarButton = [[UIBarButtonItem alloc] initWithCustomView:finishButton];
    [self.navigationItem setRightBarButtonItem:finishBarButton];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
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
    [self.messageTextView resignFirstResponder];
}

- (void)finishButtonTapped
{
    [self.messageTextView resignFirstResponder];
    
    self.load = [[HXLoadingView alloc]initLoadingView];
    [self.view addSubview:self.load];
    
    [self.photoUrlsArray removeAllObjects];
    
    // lastObject is tapped button
    if (self.photosArray.count > 1) {
        for (int i= 0; i < self.photosArray.count - 1; i++) {
            [self uploadPhotoToServer:self.photosArray[i] Success:^(NSDictionary* response){
                
                [self.photoUrlsArray addObject:[response[@"response"][@"photo"][@"url"] mutableCopy]];
                if (self.photoUrlsArray.count == self.photosArray.count - 1) {
                    [self createPost];
                }
            } failure:^(NSDictionary* response){
                
            }];
        }
    }else if (![[HXAppUtility removeExtraWhitespace:self.messageTextView.text] isEqualToString:@""]){
        [self createPost];
    }
    
}

- (void)createPost
{
    
    NSMutableDictionary *params = [@{@"title":@"_EMPTY_",
                                     @"type":@"normal",
                                     @"user_id":[HXUserAccountManager manager].userId,
                                     @"wall_id":LIGHTSPEED_WALL_ID,
                                     @"content":self.messageTextView.text}mutableCopy];
    if (self.photosArray.count > 1) {
        
        NSString *photoUrls = [self.photoUrlsArray componentsJoinedByString:@","];
        NSDictionary *customData = @{@"photoUrls":photoUrls};
        [params setObject:customData forKey:@"custom_fields"];
    }
    
    [[HXAnSocialManager manager]sendRequest:@"posts/create.json" method:AnSocialManagerPOST params:params success:^(NSDictionary *response){
        NSLog(@"post data :%@",[response description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.load loadCompleted];
            [self successPost];
        });
        
    } failure:^(NSDictionary *response){
        [self.load removeFromSuperview];
        NSLog(@"fail to post data :%@",[response description]);
    }];
}

- (void)successPost
{
    [[NSNotificationCenter defaultCenter]postNotificationName:RefreshWall object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate
-(void) textViewDidChange:(UITextView *)textView
{
    if ([HXAppUtility removeWhitespace:textView.text].length)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else if(self.photosArray.count <= 1)
        self.navigationItem.rightBarButtonItem.enabled = NO;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.collectionView addGestureRecognizer:self.messageTextViewTap];
}

#pragma mark - collection view data source

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosArray.count;
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
        [self.messageTextView resignFirstResponder];
        
        NSString *button1 = NSLocalizedString(@"拍攝照片", nil);
        NSString *button2 = NSLocalizedString(@"選取照片", nil);
    
        NSString *cancelTitle = NSLocalizedString(@"取消", nil);
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
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"取消", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelBarButtonTapped)];
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
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.collectionView reloadData];
}

@end
