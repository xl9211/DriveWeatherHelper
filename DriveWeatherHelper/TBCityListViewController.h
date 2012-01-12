//
//  TBCityListViewController.h
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDBFilename @"dwh.sqlite3"

@interface TBCityListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tableView;
    NSArray *provinceList;
    NSMutableDictionary *cityList;
    UITextField *selectedCity;
    UITextField *selectedProvince;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *provinceList;
@property (strong, nonatomic) NSMutableDictionary *cityList;
@property (strong, nonatomic) UITextField *selectedCity;
@property (strong, nonatomic) UITextField *selectedProvince;

- (NSString *)dataFilePath;

@end
