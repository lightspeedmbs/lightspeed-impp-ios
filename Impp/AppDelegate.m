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

@interface AppDelegate () <AnPushDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.window.backgroundColor = [UIColor color1];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"unreadFriendRequestCount"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"unreadFriendRequestCount"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"unreadSocialNoticeCount"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"unreadSocialNoticeCount"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registerPushNotification)
                                                 name:@"connect"
                                               object:nil];
    
    NSDictionary *lastUsed = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"lastLoggedInUser"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    if (lastUsed) {
        [HXUserAccountManager manager].userInfo = [UserUtil getHXUserByUserId:lastUsed[@"userId"]];
        [[HXUserAccountManager manager] userSignedInWithId:lastUsed[@"userId"] name:lastUsed[@"userName"] clientId:lastUsed[@"clientId"]];
        HXTabBarViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"HXTabBarViewController"];
        
        self.window.rootViewController = vc;
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
    [AnPush setup:LIGHTSPEED_APP_KEY deviceToken:deviceToken delegate:self secure:YES];
    [[AnPush shared] register:@[ @"_IMPP_DEFAULT_" ] overwrite:YES];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
}

#pragma mark - AnPushDelegate functions
- (void)didRegistered:(NSString *)anid withError:(NSString *)error
{
    NSLog(@"Arrownock didRegistered\nError: %@", error);
    if (error && ![error isEqualToString:@""])
    {
        NSLog(@"LSIM AppDelegate, AnPush failed to register, error: %@", error);
    }
    else if (!anid || [anid isEqualToString:@""])
    {
        NSLog(@"LSIM AppDelegate, AnPush failed to register, invalid Lightspeed ID");
    }
    else
    {
        /* use the anId to bind AnIM & AnPush */
        [[[HXIMManager manager]anIM] bindAnPushService:anid appKey:LIGHTSPEED_APP_KEY deviceType:AnPushTypeiOS];
    }
}

- (void)didUnregistered:(BOOL)success withError:(NSString *)error
{
    NSLog(@"Unregistration success: %@\nError: %@", success? @"YES" : @"NO", error);
    if (!success)
    {
        /* do nothing */
    }
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
        if (vc.selectedIndex != 0) {
            vc.selectedIndex = 0;
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
        //[[AnPush shared]setBadge:(int)[MessageUtil getAllUnreadCount]];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([[HXIMManager manager].clientId length]) {
        [HXIMManager manager].isAppEnterBackground = YES;
        [[HXIMManager manager].anIM disconnect];
        //[[AnPush shared]setBadge:(int)[MessageUtil getAllUnreadCount]];
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
