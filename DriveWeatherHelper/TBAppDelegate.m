//
//  TBAppDelegate.m
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TBAppDelegate.h"
#import "BMapKit.h"
#import "TBRouteListViewController.h"

@implementation TBAppDelegate

@synthesize window = _window;
@synthesize navController;
@synthesize mapManager;

- (NSString *)appKey
{
    return @"4f178cd55270153136000003";
}

- (void)dealloc
{
    [_window release];
    [navController release];
    [mapManager release];
    [super dealloc];
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kDBFilename];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor whiteColor];
    [MobClick setDelegate:self reportPolicy:REALTIME];
    
    mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [mapManager start:@"CA33F5A831637C35FB29B7996FD20BB644B6071B" generalDelegate:nil];
    if (!ret)
    {
        DLog(@"Manager start failed!");
    }
    
    NSString *dbPath = [self dataFilePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) 
    {    
        NSString *backupDBPath = [[NSBundle mainBundle] pathForResource:@"dwh" ofType:@"sqlite3"];  
        
        if (backupDBPath == nil)
        {
            return NO;  
        } 
        else 
        {  
            BOOL copiedBackupDB = [[NSFileManager defaultManager] 
                                   copyItemAtPath:backupDBPath 
                                   toPath:dbPath 
                                   error:nil];  
            if (!copiedBackupDB) 
            {
                return NO;  
            }  
        }  
    }
    
    TBRouteListViewController *routeListViewController = [[TBRouteListViewController alloc]
                                                        initWithNibName:@"TBRouteListViewController" bundle:nil];
	
	UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:routeListViewController];
	self.navController = navigationController;
    
    [self.window addSubview:navController.view];
    [self.window makeKeyAndVisible];
    
    [navigationController release];
	[routeListViewController release];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
