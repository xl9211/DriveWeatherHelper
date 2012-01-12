//
//  TBAppDelegate.h
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDBFilename @"dwh.sqlite3"

@class BMKMapManager;

@interface TBAppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *navController;
    BMKMapManager *_mapManager;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet UINavigationController *navController;
//@property (strong, nonatomic) BMKMapManager *_mapManager;

- (NSString *)dataFilePath;

@end
