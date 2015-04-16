//
//  HXLoginSignupViewController.m
//  Impp
//
//  Created by hsujahhu on 2015/3/17.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXLoginSignupViewController.h"
#import "HXAnSocialManager.h"
#import "HXLoadingView.h"
#import "HXUserAccountManager.h"
#import "UIView+Toast.h"
#import "UserUtil.h"
#import "UIColor+CustomColor.h"

#define SCREEN_WIDTH self.view.frame.size.width
#define SCREEN_HEIGHT self.view.frame.size.height

@interface HXLoginSignupViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) UITextField *userNameText;
@property (strong, nonatomic) UITextField *passwordText;
@end

@implementation HXLoginSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
    dispatch_queue_t myBackgroundQ = dispatch_queue_create("backgroundDelayQueue", NULL);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(delay, myBackgroundQ, ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userNameText becomeFirstResponder];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.userNameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
}

- (void)initView
{
    self.view.backgroundColor = [UIColor color1];
    CGRect frame;
    
    UIImageView *loginLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_logo"]];
    frame = loginLogo.frame;
    frame.origin.y = SCREEN_HEIGHT *.18;
    frame.size.width = SCREEN_WIDTH *.52;
    frame.size.height = SCREEN_WIDTH*.52 * loginLogo.image.size.height/loginLogo.image.size.width;
    frame.origin.x = (SCREEN_WIDTH - frame.size.width)/2;
    loginLogo.frame = frame;
    [self.view addSubview:loginLogo];
    
    UIView *textBg = [[UIView alloc]initWithFrame:CGRectMake(30, loginLogo.frame.size.height + loginLogo.frame.origin.y + 44,
                                                             SCREEN_WIDTH - 60, 38*2)];
    textBg.backgroundColor = [UIColor color5];
    textBg.layer.cornerRadius = 2;
    UIView *seperatedLine = [[UIView alloc]initWithFrame:CGRectMake(0,textBg.frame.size.height/2-0.5,textBg.frame.size.width,0.5)];
    seperatedLine.backgroundColor = [UIColor color8];
    [textBg addSubview:seperatedLine];
    [self.view addSubview:textBg];
    
    UITapGestureRecognizer *returnKeyBoardTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnKeyBoardTapped)];
    [self.view addGestureRecognizer:returnKeyBoardTap];
    
    self.userNameText = [[UITextField alloc]initWithFrame:CGRectMake(10,0, textBg.frame.size.width-20, 38)];
    self.userNameText.textAlignment = NSTextAlignmentLeft;
    self.userNameText.delegate = self;
    self.userNameText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.userNameText.autocorrectionType = UITextAutocorrectionTypeNo;
    self.userNameText.backgroundColor = [UIColor clearColor];
    self.userNameText.keyboardType = UIKeyboardTypeDefault;
    self.userNameText.returnKeyType = UIReturnKeyNext;
    self.userNameText.tintColor = [UIColor color2];
    self.userNameText.placeholder = NSLocalizedString(@"用戶名稱", nil);
    [textBg addSubview:self.userNameText];
    
    self.passwordText = [[UITextField alloc]initWithFrame:CGRectMake(10,38, textBg.frame.size.width-20, 38)];
    self.passwordText.textAlignment = NSTextAlignmentLeft;
    self.passwordText.delegate = self;
    self.passwordText.secureTextEntry = YES;
    self.passwordText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordText.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordText.backgroundColor = [UIColor clearColor];
    self.passwordText.returnKeyType = UIReturnKeyDone;
    self.passwordText.tintColor = [UIColor color2];
    self.passwordText.placeholder = NSLocalizedString(@"密碼", nil);
    [textBg addSubview:self.passwordText];
    
    CGFloat bWidth = (SCREEN_WIDTH - 60 - 6)/2;
    /* signup button */
    UIButton* signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signUpButton addTarget:self action:@selector(signUpButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [signUpButton setTitle:NSLocalizedString(@"註冊", nil) forState:UIControlStateNormal];
    [signUpButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    signUpButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    signUpButton.backgroundColor = [UIColor color3];
    signUpButton.layer.cornerRadius = 2;
    signUpButton.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:14];
    signUpButton.frame = CGRectMake(30, textBg.frame.size.height + textBg.frame.origin.y + 10, bWidth, 36);
    [self.view addSubview:signUpButton];
    
    /* login button */
    UIButton* loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton addTarget:self action:@selector(loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setTitle:NSLocalizedString(@"登入", nil) forState:UIControlStateNormal];
    [loginButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    loginButton.backgroundColor = [UIColor color2];
    loginButton.layer.cornerRadius = 2;
    loginButton.titleLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:14];
    loginButton.frame = CGRectMake(signUpButton.frame.origin.x + signUpButton.frame.size.width + 6,
                                   textBg.frame.size.height + textBg.frame.origin.y + 10, bWidth, 36);
    [self.view addSubview:loginButton];
    
    
}

#pragma mark - Listener

- (void)returnKeyBoardTapped
{
    [self.userNameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
}

- (void)loginButtonTapped
{
    HXLoadingView *load = [[HXLoadingView alloc]initLoadingView];
    [self.view addSubview:load];
    [self.userNameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:self.userNameText.text forKey:@"username"];
    [params setObject:self.passwordText.text forKey:@"password"];
    
    [[HXAnSocialManager manager]sendRequest:@"users/auth.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        
        NSLog(@"success log: %@",[response description]);
        NSString *userId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
        NSString *clientId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"clientId"];
        NSString *userName = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"username"];
        NSLog(@"User created, user id is: %@", userId);
        NSLog(@"User client id is: %@", clientId);
        
        NSDictionary *user = [[response objectForKey:@"response"] objectForKey:@"user"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [load loadCompleted];
            [self saveUserIntoDB:user];
            [[HXUserAccountManager manager] userSignedInWithId:userId name:userName clientId:clientId];
            dispatch_queue_t myBackgroundQ = dispatch_queue_create("backgroundDelayQueue", NULL);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC);
            dispatch_after(delay, myBackgroundQ, ^(void){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                             bundle: nil];
                    UITabBarController *tbVc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HXTabBarViewController"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [UIApplication sharedApplication].keyWindow.rootViewController = tbVc;
                });
            });
        });
        
    }failure:^(NSDictionary* response){
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
        
        if ([response objectForKey:@"meta"]) {
            if ([response[@"meta"][@"errorCode"]integerValue] == -210000) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [load removeFromSuperview];
                    [self.view makeImppToast:@"can't resolve host" navigationBarHeight:0];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [load removeFromSuperview];
                    [self.view makeImppToast:response[@"meta"][@"message"] navigationBarHeight:0];
                });
            }
            
        }
        
        
    }];
}

- (void)signUpButtonTapped
{
    [self.userNameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    
    if(![self checkTexFieldValid]) return;
    
    HXLoadingView *load = [[HXLoadingView alloc]initLoadingView];
    [self.view addSubview:load];
    
    // Let's create a new Lightspeed anSocial User!
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:self.userNameText.text forKey:@"username"];
    [params setObject:self.passwordText.text forKey:@"password"];
    [params setObject:self.passwordText.text forKey:@"password_confirmation"];
    
    // get talk client ID
    [params setObject:@"true" forKey:@"enable_im"];
    
    
    [[HXAnSocialManager manager]sendRequest:@"users/create.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        
        NSLog(@"success log: %@",[response description]);
        NSString *userId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
        NSString *clientId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"clientId"];
        NSString *userName = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"username"];
        
        NSLog(@"User created, user id is: %@", userId);
        NSLog(@"User client id is: %@", clientId);
        
        NSDictionary *user = [[response objectForKey:@"response"] objectForKey:@"user"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [load loadCompleted];
            [self saveUserIntoDB:user];
            [[HXUserAccountManager manager] userSignedInWithId:userId name:userName clientId:clientId];
            dispatch_queue_t myBackgroundQ = dispatch_queue_create("backgroundDelayQueue", NULL);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC);
            dispatch_after(delay, myBackgroundQ, ^(void){
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                             bundle: nil];
                    UITabBarController *tbVc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HXTabBarViewController"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [UIApplication sharedApplication].keyWindow.rootViewController = tbVc;
                });
            });
        });
        
    }failure:^(NSDictionary* response){
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
        
        if ([response objectForKey:@"meta"]) {
            
            if ([response[@"meta"][@"errorCode"]integerValue] == -210000) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [load removeFromSuperview];
                    [self.view makeImppToast:@"can't resolve host" navigationBarHeight:0];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [load removeFromSuperview];
                    [self.view makeImppToast:response[@"meta"][@"message"] navigationBarHeight:0];
                });
            }
        }
        
    }];
}

- (void)saveUserIntoDB:(NSDictionary *)userInfo
{
    /* save user info into DB */
    NSDictionary *reformedUser = [UserUtil reformUserInfoDic:userInfo];
    HXUser *hxUser = [UserUtil getHXUserByUserId:reformedUser[@"userId"]] ?
    [UserUtil getHXUserByUserId:reformedUser[@"userId"]] : [UserUtil getHXUserByClientId:reformedUser[@"clientId"]];
    
    if (hxUser == nil) {
        hxUser = [HXUser initWithDict:reformedUser];
    }else{
        //update
        [hxUser setValuesFromDict:reformedUser];
    }
    [HXUserAccountManager manager].userInfo = hxUser;
    
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userNameText) {
        [self.passwordText becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - Helper

#pragma mark - Check TexField Method
- (BOOL)checkTexFieldValid
{
    NSMutableArray *errorMessages = [[NSMutableArray alloc]initWithCapacity:0];
    
    NSCharacterSet *validCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"] invertedSet];
    NSString *testedAccountName = [[self.userNameText.text componentsSeparatedByCharactersInSet:validCharSet] componentsJoinedByString:@""];
    
    if (![testedAccountName isEqualToString:self.userNameText.text]) {
        NSString *error = NSLocalizedString(@"您的用戶名稱必須是大小寫的英文字母", nil);
        [errorMessages addObject:error];
    }
    
    NSString *errorMessage = @"";
    if ([errorMessages count]) {
        for (int i = 0; i < errorMessages.count ; i++){
            if (i == 0) {
                errorMessage = [NSString stringWithFormat:@"%@",errorMessages[i]];
            }else
                errorMessage = [NSString stringWithFormat:@"%@\n%@",errorMessage,errorMessages[i]];
        }
        [self.view makeImppToast:errorMessage navigationBarHeight:0];
    }
    
    
    return ![errorMessages count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
