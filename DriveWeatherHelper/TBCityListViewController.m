//
//  TBCityListViewController.m
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TBCityListViewController.h"
#import <sqlite3.h>

@implementation TBCityListViewController

@synthesize tableView;
@synthesize searchBar;
//@synthesize provinceList;
@synthesize cityList;
@synthesize selectedCity;
@synthesize selectedProvince;

- (void)dealloc
{
    [cityList release];
    [selectedCity release];
    [selectedProvince release];
    [searchBar release];
    [tableView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)readDataFromDB:(NSString *)searchText
{
    cityList = [[NSMutableDictionary alloc] init];
    
    sqlite3 *database;
    const char *db_path = [[self dataFilePath] UTF8String];
    if (sqlite3_open(db_path, &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
	
    NSString *query = nil;
    if (searchText == nil || searchText == @"") 
    {
        query = [[NSString alloc] initWithString:@"select city, province from city_info"];
    }
    else
    {
        query = [[NSString alloc] initWithFormat:@"select city, province from city_info where city like '%%%@%%'", searchText];
    }
    
    sqlite3_stmt *statement;
    NSInteger ret = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (ret == SQLITE_OK) 
    {
		while (sqlite3_step(statement) == SQLITE_ROW) 
        {
			char *cityData = (char *)sqlite3_column_text(statement, 0);
            char *provinceData = (char *)sqlite3_column_text(statement, 1);
			NSString *city = [[NSString alloc] initWithUTF8String:cityData];
            NSString *province = [[NSString alloc] initWithUTF8String:provinceData];
            
            NSMutableArray *value = [cityList objectForKey:province];
            if (value == nil)
            {
                value = [[NSMutableArray alloc] init];
                [cityList setObject:value forKey:province];
            }
            [value addObject:city];
            
			[city release];
            [province release];
		}
		sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    
    [query release];
}

#pragma mark - View lifecycle

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kDBFilename];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self readDataFromDB:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
    self.selectedCity = nil;
    self.selectedProvince = nil;
    self.cityList = nil;
    self.searchBar = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Search Bar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSString *searchText = [self.searchBar text];
    NSString *newSearchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
    [self readDataFromDB:newSearchText];
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self readDataFromDB:nil];
    [self.tableView reloadData];
	[self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *newSearchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [self readDataFromDB:newSearchText];
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[self.cityList allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *province = [[self.cityList allKeys] objectAtIndex:section];
    return [[self.cityList objectForKey:province] count];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    NSString *province = [[self.cityList allKeys] objectAtIndex:section];
    return province;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault 
                 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSString *province = [[self.cityList allKeys] objectAtIndex:section];
    cell.textLabel.text = [[self.cityList objectForKey:province] objectAtIndex:row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSString *province = [[self.cityList allKeys] objectAtIndex:section];
    NSString *city = [[self.cityList objectForKey:province] objectAtIndex:row];
    
    self.selectedCity.text = city;
    self.selectedProvince.text = province;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
