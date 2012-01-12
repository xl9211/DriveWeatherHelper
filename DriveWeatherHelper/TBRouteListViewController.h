//
//  TBRouteListViewController.h
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDBFilename @"dwh.sqlite3"

@class TBAddRouteViewController;

@interface TBRouteListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    TBAddRouteViewController *addRouteViewController;
    UINavigationController *navController;
    NSMutableArray *routeList;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TBAddRouteViewController *addRouteViewController;
@property (strong, nonatomic) IBOutlet UINavigationController *navController;
@property (strong, nonatomic) NSMutableArray *routeList;

- (IBAction)addRoute:(id)sender;
- (NSString *)dataFilePath;
- (void)readDataFromDB;

@end
