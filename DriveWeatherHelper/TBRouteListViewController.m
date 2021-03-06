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
@synthesize navController;
@synthesize routeList;
@synthesize tvCell;

- (void)dealloc
{
    [tableView release];
    [navController release];
    [routeList removeAllObjects];
    [routeList release];
    [tvCell release];
    [super dealloc];
}

- (IBAction)add:(id)sender
{
    TBAddRouteViewController *addRouteViewController = [[TBAddRouteViewController alloc]
                                                        initWithNibName:@"TBAddRouteViewController" bundle:nil];
	
	UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:addRouteViewController];
	self.navController = navigationController;
    
	[self presentModalViewController:self.navController animated:YES];
	[navigationController release];
	[addRouteViewController release];
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

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kDBFilename];
}

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
	
    NSString *query = @"select * from route_info order by id desc";
    sqlite3_stmt *statement;
    int ret = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
    if (ret == SQLITE_OK) 
    {
		while (sqlite3_step(statement) == SQLITE_ROW) 
        {
            int idData = sqlite3_column_int(statement, 0);
			char *cityFromData = (char *)sqlite3_column_text(statement, 1);
            char *provinceFromData = (char *)sqlite3_column_text(statement, 2);
            char *cityToData = (char *)sqlite3_column_text(statement, 3);
            char *provinceToData = (char *)sqlite3_column_text(statement, 4);
            char *stepInfoData = (char *)sqlite3_column_text(statement, 5);
            
            NSNumber *id = [[NSNumber alloc] initWithInt:idData];
			NSString *cityFrom = [[NSString alloc] initWithUTF8String:cityFromData];
            NSString *provinceFrom = [[NSString alloc] initWithUTF8String:provinceFromData];
            NSString *cityTo = [[NSString alloc] initWithUTF8String:cityToData];
            NSString *provinceTo = [[NSString alloc] initWithUTF8String:provinceToData];
            NSMutableArray *stepInfo = nil;
            if (stepInfoData != nil)
            {
                NSString *stepInfoTmp = [[NSString alloc] initWithUTF8String:stepInfoData];
                SBJsonParser *parser = [[SBJsonParser alloc] init];  
                NSError * error = nil;  
                stepInfo = [parser objectWithString:stepInfoTmp error:&error];
            }
            else
            {
                stepInfo = [[NSMutableArray alloc] init];
            }
            
            NSMutableDictionary *routeInfo = [[NSMutableDictionary alloc] init];
            [routeInfo setObject:id forKey:@"id"];
            [routeInfo setObject:cityFrom forKey:@"cityFrom"];
            [routeInfo setObject:provinceFrom forKey:@"provinceFrom"];
            [routeInfo setObject:cityTo forKey:@"cityTo"];
            [routeInfo setObject:provinceTo forKey:@"provinceTo"];
            [routeInfo setObject:stepInfo forKey:@"stepInfo"];
            
            [self.routeList addObject:routeInfo];
            
			[cityFrom release];
            [provinceFrom release];
            [cityTo release];
            [provinceTo release];
		}
		sqlite3_finalize(statement);
    }
    sqlite3_close(database);
}

- (void)deleteDataFromDB:(NSInteger)row
{
    sqlite3 *database;
    const char *db_path = [[self dataFilePath] UTF8String];
    if (sqlite3_open(db_path, &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
	
    NSMutableDictionary *routeInfo = [self.routeList objectAtIndex:row];
    NSString *deleteSQL = [[NSString alloc] 
                       initWithFormat:@"delete from route_info where id = %d", 
                       [[routeInfo objectForKey:@"id"] intValue]];
    char *errorMsg;
    if (sqlite3_exec(database, [deleteSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        NSAssert1(0, @"Error insertSelecting tables: %s", errorMsg);	
    }
    [deleteSQL release];
    sqlite3_close(database);
    
    [self.routeList removeObjectAtIndex:row];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                  target:self 
                                  action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.title = @"自驾天气助手";
    [addButton release];
    
    [self readDataFromDB];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
    self.navController = nil;
    self.routeList = nil;
    self.tvCell = nil;
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
    static NSString *routeInfoCellIdentifier = @"RouteInfoCellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:routeInfoCellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RouteInfoCell" owner:self options:nil];
        if ([nib count] > 0) 
        {
            cell = self.tvCell;
        }
        else 
        {
            ALog(@"failed to load CustomCell nib file!");
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundView = [[UIImageView alloc] 
                           initWithImage:[UIImage imageNamed:@"CellBackground.png"]];
    
    NSUInteger row = [indexPath row];
    NSMutableDictionary *routeInfo = [self.routeList objectAtIndex:row];
	
    UILabel *cityFromLabel = (UILabel *)[cell viewWithTag:kCityFromTag];
    cityFromLabel.text = [routeInfo objectForKey:@"cityFrom"];
	
    UILabel *cityToLabel = (UILabel *)[cell viewWithTag:kCityToTag];
    cityToLabel.text = [routeInfo objectForKey:@"cityTo"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    TBRouteWeatherViewController *routeWeatherViewController = [[TBRouteWeatherViewController alloc]
                                                                initWithNibName:@"TBRouteWeatherViewController"
                                                                bundle:nil];
    
    routeWeatherViewController.routeInfo = [routeList objectAtIndex:row];
    routeWeatherViewController.srcOp = @"look";
    [self.navigationController pushViewController:routeWeatherViewController animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        [self deleteDataFromDB:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];        
    }   
}

- (NSString *)tableView:(UITableView *)tableView 
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    return @"删除"; 
}

@end
