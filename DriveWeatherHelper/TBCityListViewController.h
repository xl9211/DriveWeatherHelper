//
//  TBCityListViewController.h
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDBFilename @"dwh.sqlite3"

@interface TBCityListViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    UITableView *tableView;
    UISearchBar *searchBar;
    NSMutableDictionary *cityList;
    UITextField *selectedCity;
    UITextField *selectedProvince;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableDictionary *cityList;
@property (strong, nonatomic) UITextField *selectedCity;
@property (strong, nonatomic) UITextField *selectedProvince;

- (NSString *)dataFilePath;
- (void)readDataFromDB:(NSString *)searchText;

@end
