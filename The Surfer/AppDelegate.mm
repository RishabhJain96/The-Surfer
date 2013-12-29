//
//  AppDelegate.m
//  SIFTOpenCVSearcher
//
//  Created by Rishabh Jain on 8/11/13.
//  Copyright (c) 2013 Rishabh Jain. All rights reserved.
//

#import "AppDelegate.h"
#import <opencv2/opencv.hpp>

using namespace cv;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL firstLaunch = [defaults boolForKey:@"fLaunch"];
    
    if (!firstLaunch) {
        [defaults setBool:true forKey:@"fLaunch"];
        //BOOL fix = [defaults boolForKey:@"fLaunch"];
        [defaults synchronize];
        // write db files first
        NSString *output = [[self applicationDocumentsDirectory] stringByAppendingString:[NSString stringWithFormat:@"dbFinalF.yml"]];
        FileStorage f;
        f.open(output.UTF8String, FileStorage::WRITE);
        f << "CreatedBy" << "RishabhVineet"; // write junk for first line...
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [NSString stringWithFormat:@"%@/", basePath];
}

@end
