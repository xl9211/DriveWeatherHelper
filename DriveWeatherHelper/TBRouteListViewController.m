//
//  TBRouteListViewController.m
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TBRouteListViewController.h"
#import "TBAddRouteViewController.h"
#import "TBRouteWeatherViewController.h"
#import "SBJson.h"
#import <sqlite3.h>

@implementation TBRouteListViewController

@synthesize tableView;
@synthesize addRouteViewController;
@synthesize navController;
@synthesize routeList;

- (void)dealloc
{
    [tableView release];
    [addRouteViewController release];
    [navController release];
    [routeList release];
    [super dealloc];
}

- (IBAction)addRoute:(id)sender
{    
    self.addRouteViewController = [[TBAddRouteViewController alloc]
                                   initWithNibName:@"TBAddRouteViewController" bundle:nil];
    [self presentModalViewController:self.navController animated:YES];
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

- (void)readDataFromDB
{
    if (self.routeList != nil)
    {
        [self.routeList release];
        self.routeList = nil;
    }
    
    self.routeList = [[NSMutableArray alloc] init];
    
    sqlite3 *database;
    const char *db_path = [[self dataFilePath] UTF8String];
    if (sqlite3_open(db_path, &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
	
    NSString *query = @"select * from route_info  order by id desc";
    sqlite3_stmt *statement;
    int ret = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (ret == SQLITE_OK) 
    {
		while (sqlite3_step(statement) == SQLITE_ROW) 
        {
			char *cityFromData = (char *)sqlite3_column_text(statement, 1);
            char *provinceFromData = (char *)sqlite3_column_text(statement, 2);
            char *cityToData = (char *)sqlite3_column_text(statement, 3);
            char *provinceToData = (char *)sqlite3_column_text(statement, 4);
            char *detailInfoData = (char *)sqlite3_column_text(statement, 5);
            
			NSString *cityFrom = [[NSString alloc] initWithUTF8String:cityFromData];
            NSString *provinceFrom = [[NSString alloc] initWithUTF8String:provinceFromData];
            NSString *cityTo = [[NSString alloc] initWithUTF8String:cityToData];
            NSString *provinceTo = [[NSString alloc] initWithUTF8String:provinceToData];
            NSMutableDictionary *detailInfo = nil;
            if (detailInfoData != nil)
            {
                NSString *detailInfoTmp = [[NSString alloc] initWithUTF8String:detailInfoData];
                SBJsonParser *parser = [[SBJsonParser alloc] init];  
                NSError * error = nil;  
                detailInfo = [parser objectWithString:detailInfoTmp error:&error];  
            }
            else
            {
                detailInfo = [[NSMutableDictionary alloc] init];
            }

            NSMutableDictionary *routeInfo = [[NSMutableDictionary alloc] init];
            [routeInfo setObject:cityFrom forKey:@"city_from"];
            [routeInfo setObject:provinceFrom forKey:@"province_from"];
            [routeInfo setObject:cityTo forKey:@"city_to"];
            [routeInfo setObject:provinceTo forKey:@"province_to"];
            [routeInfo setObject:detailInfo forKey:@"detail_info"];
            
            [self.routeList addObject:routeInfo];
        
			[cityFrom release];
            [provinceFrom release];
            [cityTo release];
            [provinceTo release];
            [detailInfo release];
		}
		sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kDBFilename];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self readDataFromDB];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
    self.addRouteViewController = nil;
    self.navController = nil;
    self.routeList = nil;
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
    return [self.routeList count];
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
    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [[self.routeList objectAtIndex:row] valueForKey:@"city_from"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSUInteger row = [indexPath row];
    
    TBRouteWeatherViewController *routeWeatherViewController = [[TBRouteWeatherViewController alloc]
                                                                initWithNibName:@"TBRouteWeatherViewController"
                                                                bundle:nil];
    
    routeWeatherViewController.routeInfo = [routeList objectAtIndex:row];
    
    [self.navigationController pushViewController:routeWeatherViewController animated:YES];
}

@end
