//
//  TBRouteListViewController.h
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDBFilename @"dwh.sqlite3"
#define kCityFromTag    1
#define kCityToTag      2

@interface TBRouteListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    UINavigationController *navController;
    UITableViewCell *tvCell;
    NSMutableArray *routeList;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationController *navController;
@property (strong, nonatomic) IBOutlet UITableViewCell *tvCell;
@property (strong, nonatomic) NSMutableArray *routeList;

- (IBAction)addRoute:(id)sender;
- (NSString *)dataFilePath;
- (void)readDataFromDB;

@end
