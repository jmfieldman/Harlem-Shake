//
//  AppDelegate.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "AppDelegate.h"
#import "VideoListViewController.h"
#import "TestCameraViewController.h"

void uncaughtExceptionHandler(NSException *exception) {
	[Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	/* Debug */
	Timing_MarkStartTime();
	
	/* Flurry */
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[Flurry startSession:FLURRY_KEY];
	
	/* Initialize FB session - From FB SDK sample */
	if (!OptionsModel.sharedInstance.fbsession.isOpen) {
		// create a fresh session object
		OptionsModel.sharedInstance.fbsession = [[FBSession alloc] initWithPermissions:@[@"publish_stream", @"video_upload"]];

		// if we don't have a cached token, a call to open here would cause UX for login to
		// occur; we don't want that to happen unless the user clicks the login button, and so
		// we check here to make sure we have a token before calling open
		if (OptionsModel.sharedInstance.fbsession.state == FBSessionStateCreatedTokenLoaded) {
			// even though we had a cached token, we need to login to make the session usable
			[OptionsModel.sharedInstance.fbsession openWithCompletionHandler:^(FBSession *session,
																			   FBSessionState status,
																			   NSError *error) {
            }];
        }
    }
	
	
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[VideoListViewController sharedInstance]];
	//self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TestCameraViewController alloc] init]];
	[self.window makeKeyAndVisible];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	
	/* Paranoid; save all data structures */
	[PersistentDictionary saveAllDictionaries];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
	/* FB app switching handler */
	[OptionsModel.sharedInstance.fbsession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	
	/* Paranoid; save all data structures */
	[PersistentDictionary saveAllDictionaries];
	
	/* Close FB session */
	[OptionsModel.sharedInstance.fbsession close];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
	// attempt to extract a token from the url
	return [OptionsModel.sharedInstance.fbsession handleOpenURL:url];
}

@end
