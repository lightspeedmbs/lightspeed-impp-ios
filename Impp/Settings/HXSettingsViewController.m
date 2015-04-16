//
//  HXSettingsViewController.m
//  Impp
//
//  Created by hsujahhu on 2015/3/17.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXSettingsViewController.h"
#import "HXAppUtility.h"
#import "HXUserAccountManager.h"
#import "UIColor+CustomColor.h"
#import "HXCustomButton.h"
#import "AnSocialFile.h"
#import "HXAnSocialManager.h"
#import "HXLoginSignupViewController.h"
#import "AnSocialPathConstant.h"
#import "HXLoadingView.h"
#import "CoreDataUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MobileCoreServices/UTCoreTypes.h>
#define SCREEN_WIDTH self.view.frame.size.width
#define SCREEN_HEIGHT self.view.frame.size.height

@interface HXSettingsViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) NSData *photo;
@end

@implementation HXSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initNavigationBar];
}

- (void)initNavigationBar
{
    [HXAppUtility initNavigationTitleView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo"]]
                             barTintColor:[UIColor color1]
                                tintColor:[UIColor color5]
                       withViewController:self];
}

- (void)initView
{
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped)];
    self.photoImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"friend_default"]];
    self.photoImageView.frame = CGRectMake((SCREEN_WIDTH - 138)/2, SCREEN_HEIGHT *.1, 138, 138);
    self.photoImageView.layer.cornerRadius = 138/2;
    self.photoImageView.clipsToBounds = YES;
    self.photoImageView.layer.masksToBounds = YES;
    self.photoImageView.userInteractionEnabled = YES;
    [self.photoImageView addGestureRecognizer:photoTap];
    [self.view addSubview:self.photoImageView];
    
    if ([HXUserAccountManager manager].photoUrl){
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:[HXUserAccountManager manager].photoUrl]
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
                                                                   self.photoImageView.frame.size.height + self.photoImageView.frame.origin.y + 15,SCREEN_WIDTH, 28)];
    [self.userNameLabel setBackgroundColor:[UIColor clearColor]];
    [self.userNameLabel setFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:28]];
    [self.userNameLabel setTextColor:[UIColor color1]];
    self.userNameLabel.text = [HXUserAccountManager manager].userInfo.userName;
    self.userNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.userNameLabel];
    
    HXCustomButton *logoutButton = [[HXCustomButton alloc]initWithTitle:NSLocalizedString(@"登出", nil) titleColor:[UIColor color1] backgroundColor:[UIColor color5]];
    [logoutButton addTarget:self action:@selector(logoutButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    CGRect frame;
    frame = logoutButton.frame;
    frame.origin.x = (SCREEN_WIDTH - logoutButton.frame.size.width)/2;
    frame.origin.y = self.userNameLabel.frame.size.height + self.userNameLabel.frame.origin.y + 30;
    logoutButton.frame = frame;
    [self.view addSubview:logoutButton];
    
}

#pragma mark - Listener

- (void)logoutButtonTapped
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [[HXUserAccountManager manager]userSignedOut];
    HXLoginSignupViewController *lgVc = [[HXLoginSignupViewController alloc]init];
    [UIApplication sharedApplication].keyWindow.rootViewController = lgVc;
}

- (void)photoTapped
{
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
        //NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        imagePicker.allowsEditing = YES;
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
        cameraRollPicker.navigationBar.barTintColor = [UIColor color3];
        cameraRollPicker.delegate = self;
        cameraRollPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:cameraRollPicker.sourceType];
        cameraRollPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        cameraRollPicker.allowsEditing = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:cameraRollPicker animated:YES completion:nil];
        });
        
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([info objectForKey:@"UIImagePickerControllerEditedImage"])
    {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        /* resize the image */
        if (image.size.width > 150)
        {
            CGFloat fWidth = 150;
            CGFloat fHeight = fWidth * image.size.height / image.size.width;
            
            CGFloat scale = [[UIScreen mainScreen] scale];
            UIGraphicsBeginImageContext(CGSizeMake(fWidth*scale, fHeight*scale));
            CGRect frame = CGRectMake(0.0f, 0.0f, fWidth*scale, fHeight*scale);
            
            [image drawInRect:frame];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        float fCompressionRatio = 1.0f;
        NSData* imageData = UIImageJPEGRepresentation(image, fCompressionRatio);
        
        NSInteger nSizeLimit = 100 * 1024;
        while ([imageData length] > nSizeLimit)
        {
            fCompressionRatio = fCompressionRatio*0.6;
            imageData = UIImageJPEGRepresentation(image, fCompressionRatio);
        }
        self.photo = imageData;
        [self changeProfilePhoto:self.photo];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
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

#pragma mark - Helper
- (void)changeProfilePhoto:(NSData *)image
{
    if (!self.photo)return;
    self.photoImageView.image = [UIImage imageWithData:image];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    HXLoadingView *load = [[HXLoadingView alloc]initLoadingView];
    [self.view addSubview:load];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[HXUserAccountManager manager].userInfo.userId forKey:@"user_id"];

    AnSocialFile *imageFile = [AnSocialFile createWithFileName:@"photo"
                                                              data:self.photo];
    [params setObject:imageFile forKey:@"photo"];

    
    [[HXAnSocialManager manager]sendRequest:USERS_UPDATE method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        
        NSLog(@"success log: %@",[response description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [load loadCompleted];
            
            if (response[@"response"][@"user"][@"photo"]) {
                NSString *photoUrl = response[@"response"][@"user"][@"photo"][@"url"];
                [HXUserAccountManager manager].userInfo.photoURL = photoUrl;
                NSError *error;
                [[CoreDataUtil sharedContext] save:&error];
                if (error) {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
            }
            
        });
        
        
    }failure:^(NSDictionary* response){
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
        
        if ([response objectForKey:@"meta"]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"無法更改"
                                                            message:@"出現一點問題"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好"
                                                  otherButtonTitles:nil, nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [load loadCompleted];
                [alert show];
            });
        }
        
    }];
}

- (void)cancelBarButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
