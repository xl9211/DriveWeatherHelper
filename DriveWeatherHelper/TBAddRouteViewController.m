//
//  TBAddRouteViewController.m
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TBAddRouteViewController.h"
#import "TBCityListViewController.h"
#import "TBAppDelegate.h"
#import "TBRouteListViewController.h"
#import <sqlite3.h>

@implementation TBAddRouteViewController

@synthesize tableView;
@synthesize cityFrom;
@synthesize provinceFrom;
@synthesize cityTo;
@synthesize provinceTo;

- (void)dealloc
{
    [cityFrom release];
    [provinceFrom release];
    [cityTo release];
    [provinceTo release];
    [tableView release];
    [super dealloc];
}

- (void)clean
{
    self.cityFrom.text = nil;
    self.provinceFrom.text = nil;
    self.cityTo.text = nil;
    self.provinceTo.text = nil;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender
{
    [self clean];
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kDBFilename];
}

- (IBAction)save:(id)sender
{
    TBAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	TBRouteListViewController *root = [delegate.navController.viewControllers objectAtIndex:0];
    
    sqlite3 *database;
    const char *db_path = [[self dataFilePath] UTF8String];
    if (sqlite3_open(db_path, &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *insert = [[NSString alloc] 
                              initWithFormat:@"insert or replace into route_info (city_from, province_from, city_to, province_to) values ('%@', '%@', '%@', '%@')",
                              self.cityFrom.text,
                              self.provinceFrom.text,
                              self.cityTo.text,
                              self.provinceTo.text];
	char *errorMsg;
	if (sqlite3_exec(database, [insert UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
	{
		NSAssert1(0, @"Error insertSelecting tables: %s", errorMsg);	
	}

    sqlite3_close(database);
    
    [root readDataFromDB];
    [[root tableView] reloadData];
    
    [self clean];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
    self.cityFrom = nil;
    self.provinceFrom = nil;
    self.cityTo = nil;
    self.provinceTo = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
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
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
    label.textAlignment = UITextAlignmentRight;
    label.font = [UIFont boldSystemFontOfSize:14];
    [cell.contentView addSubview:label];
    
    NSUInteger row = [indexPath row];
    switch (row) 
    {
        case 0:
            label.text = @"出发城市";
            
            self.provinceFrom = [[UITextField alloc] initWithFrame:CGRectMake(110, 14, 50, 25)];
            self.provinceFrom.font = [UIFont boldSystemFontOfSize:14];
            self.provinceFrom.clearsOnBeginEditing = NO;
            self.provinceFrom.userInteractionEnabled = NO;
            self.provinceFrom.placeholder = @"必填";
            [cell.contentView addSubview:self.provinceFrom];
            
            self.cityFrom = [[UITextField alloc] initWithFrame:CGRectMake(170, 14, 150, 25)];
            self.cityFrom.font = [UIFont boldSystemFontOfSize:14];
            self.cityFrom.clearsOnBeginEditing = NO;
            self.cityFrom.userInteractionEnabled = NO;
            //self.cityFrom.placeholder = @"必填";
            [cell.contentView addSubview:self.cityFrom];
            
            break;
        case 1:
            label.text = @"到达城市";
            
            self.provinceTo = [[UITextField alloc] initWithFrame:CGRectMake(110, 14, 50, 25)];
            self.provinceTo.font = [UIFont boldSystemFontOfSize:14];
            self.provinceTo.clearsOnBeginEditing = NO;
            self.provinceTo.userInteractionEnabled = NO;
            self.provinceTo.placeholder = @"必填";
            [cell.contentView addSubview:self.provinceTo];
            
            self.cityTo = [[UITextField alloc] initWithFrame:CGRectMake(170, 14, 150, 25)];
            self.cityTo.font = [UIFont boldSystemFontOfSize:14];
            self.cityTo.clearsOnBeginEditing = NO;
            self.cityTo.userInteractionEnabled = NO;
            //self.cityTo.placeholder = @"必填";
            [cell.contentView addSubview:self.cityTo];
            
            break;
    }
    
    [label release];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *label = [[cell.contentView subviews] objectAtIndex:0];
    UITextField *province = [[cell.contentView subviews] objectAtIndex:1];
    UITextField *city = [[cell.contentView subviews] objectAtIndex:2];
    
    TBCityListViewController *cityListViewController = [[TBCityListViewController alloc]
                                                        initWithNibName:@"TBCityListViewController" bundle:nil];
    
    cityListViewController.selectedCity = city;
    cityListViewController.selectedProvince = province;
    
    cityListViewController.title = label.text;
    [self.navigationController pushViewController:cityListViewController animated:YES];
}

@end
