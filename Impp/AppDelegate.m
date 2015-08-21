//
//  AppDelegate.m
//  Impp
//
//  Created by hsujahhu on 2015/3/17.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "AppDelegate.h"
#import "AnPush.h"
#import "HXTabBarViewController.h"
#import "LightspeedCredentials.h"
#import "UIColor+CustomColor.h"
#import "MessageUtil.h"
#import "UserUtil.h"
#import "HXIMManager.h"
#import "HXUserAccountManager.h"
#import "HXTabBarViewController.h"
#import "HXLoginSignupViewController.h"
#import "KVNProgress.h"
#import "HXAppUtility.h"
#import   <TestinAgent/TestinAgent.h>

@interface AppDelegate () <AnPushDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [NSThread sleepForTimeInterval:3.0];
    
    [self registerPushNotification];
    
    self.window.backgroundColor = [UIColor color1];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"unreadFriendRequestCount"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"unreadFriendRequestCount"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"unreadSocialNoticeCount"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"unreadSocialNoticeCount"];
    }
    
    NSDictionary *lastUsed = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"lastLoggedInUser"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    
    HXTabBarViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HXTabBarViewController"];
    self.window.rootViewController = vc;
    if (lastUsed) {
        [HXUserAccountManager manager].userInfo = [UserUtil getHXUserByUserId:lastUsed[@"userId"]];
        [[HXUserAccountManager manager] userSignedInWithId:lastUsed[@"userId"] name:lastUsed[@"userName"] clientId:lastUsed[@"clientId"]];
//        HXTabBarViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HXTabBarViewController"];
//        
//        self.window.rootViewController = vc;
    }else{
        //UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.window.rootViewController];
        self.loginView = [mainStoryboard instantiateViewControllerWithIdentifier:@"HXLoginSignupView" ] ;
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:_loginView animated:NO completion:nil];
    }
    
    KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
    configuration.circleStrokeForegroundColor = [HXAppUtility hexToColor:0x5CB5B5 alpha:1];
    configuration.circleSize = 55.0f;
    [KVNProgress setConfiguration:configuration];
    
    // Testin APM
    if(TESTIN_APM_ID) {
        [TestinAgent init:TESTIN_APM_ID channel:@"" config:[TestinConfig defaultConfig]];
    }
    return YES;
}

- (void) registerPushNotification
{
    [AnPush registerForPushNotification:(UIRemoteNotificationTypeAlert|
                                         UIRemoteNotificationTypeBadge|
                                         UIRemoteNotificationTypeSound)];
}

#pragma mark - Lightspeed push-notification registration result handler
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [AnPush setup:LIGHTSPEED_APP_KEY deviceToken:deviceToken secure:YES];
    [[AnPush shared] enable];
    
    if([[HXIMManager manager] clientId])
    {
        [[[HXIMManager manager]anIM] bindAnPushService:[[AnPush shared] getAnID] appKey:LIGHTSPEED_APP_KEY clientId:[[HXIMManager manager] clientId] success:^{
            NSLog(@"AnIM bindAnPushService successful");
        } failure:^(ArrownockException *exception) {
            NSLog(@"AnIm bindAnPushService failed, error : %@", exception.getMessage);
        }];
    }
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // only perform the action associated with this noitification if we're being brought to the foreground
    // by the user swiping the notification or otherwise triggering it's action.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if (application.applicationState == UIApplicationStateActive)
    {
        
    }else if (application.applicationState == UIApplicationStateInactive)
    {
        NSLog(@"Notification revieced!!! ================\n%@", userInfo);
        HXTabBarViewController *vc = (HXTabBarViewController*) self.window.rootViewController;
        [HXIMManager manager].remoteNotificationInfo = [userInfo mutableCopy];
        
        [self resetTabBarViews];
        if (vc.selectedIndex != 1) {
            vc.selectedIndex = 1;
        }
    }
}

- (void)resetTabBarViews {
    HXTabBarViewController *tabBarController = (HXTabBarViewController *)self.window.rootViewController;
    for(UIViewController *foo in tabBarController.viewControllers) {
        if([foo isKindOfClass:[UINavigationController class]]) {
            UINavigationController *bar = (UINavigationController*)foo;
            [bar popToRootViewControllerAnimated:NO];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if ([[HXIMManager manager].clientId length]) {
        [HXIMManager manager].isAppEnterBackground = YES;
        [[HXIMManager manager].anIM disconnect];
//        [[AnPush shared]setBadge:(int)[MessageUtil getAllUnreadCount] success:^{
//            NSLog(@"AnPush setBadge successful.");
//        } failure:^(ArrownockException *exception) {
//            NSLog(@"AnPush failed to setBadge, error: %@", exception.getMessage);
//        }];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([[HXIMManager manager].clientId length]) {
        [HXIMManager manager].isAppEnterBackground = YES;
        [[HXIMManager manager].anIM disconnect];
//        [[AnPush shared]setBadge:(int)[MessageUtil getAllUnreadCount] success:^{
//            NSLog(@"AnPush setBadge successful.");
//        } failure:^(ArrownockException *exception) {
//            NSLog(@"AnPush failed to setBadge, error: %@", exception.getMessage);
//        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[HXIMManager manager].clientId length]) {
        [HXIMManager manager].isAppEnterBackground = NO;
        [[HXIMManager manager].anIM connect:[HXIMManager manager].clientId];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if ([[HXIMManager manager].clientId length]) {
        [HXIMManager manager].isAppEnterBackground = YES;
        [[HXIMManager manager].anIM disconnect];
    }
}

@end
