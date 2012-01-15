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
#import "TBRouteWeatherViewController.h"
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

- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kDBFilename];
}

- (IBAction)search:(id)sender
{
    if (self.cityFrom.text == nil ||
        self.provinceFrom.text == nil) 
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示" 
                              message:@"请输入出发城市"
                              delegate:self 
                              cancelButtonTitle:@"确定" 
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    else if(self.cityTo.text == nil ||
            self.provinceTo == nil) 
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示" 
                              message:@"请输入到达城市"
                              delegate:self 
                              cancelButtonTitle:@"确定" 
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    else
    {
        TBRouteWeatherViewController *routeWeatherViewController = [[TBRouteWeatherViewController alloc]
                                                                    initWithNibName:@"TBRouteWeatherViewController"
                                                                    bundle:nil];
        
        NSMutableDictionary *routeInfo = [[NSMutableDictionary alloc] init];
        [routeInfo setObject:cityFrom.text forKey:@"cityFrom"];
        [routeInfo setObject:provinceFrom.text forKey:@"provinceFrom"];
        [routeInfo setObject:cityTo.text forKey:@"cityTo"];
        [routeInfo setObject:provinceTo.text forKey:@"provinceTo"];
        NSMutableArray *stepInfo = [[NSMutableArray alloc] init];
        [routeInfo setObject:stepInfo forKey:@"stepInfo"];
        
        routeWeatherViewController.routeInfo = routeInfo;
        routeWeatherViewController.srcOp = @"search";
        [self.navigationController pushViewController:routeWeatherViewController animated:YES];
    }
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
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"取消"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.title = @"添加线路";
    [cancelButton release];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"搜索"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(search:)];
    self.navigationItem.rightBarButtonItem = searchButton;
    [searchButton release];
    
    /*self.cityFrom.text = nil;
    self.provinceFrom.text = nil;
    self.cityTo.text = nil;
    self.provinceTo.text = nil;*/
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
