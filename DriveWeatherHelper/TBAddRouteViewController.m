//
//  TBAddRouteViewController.m
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TBAddRouteViewController.h"
#import "TBCityListViewController.h"

@implementation TBAddRouteViewController

@synthesize tableView;
@synthesize cityFrom;
@synthesize cityTo;

- (void)dealloc
{
    [cityFrom release];
    [cityTo release];
    [tableView release];
    [super dealloc];
}

- (IBAction)cancel:(id)sender
{
    self.cityFrom.text = nil;
    self.cityTo.text = nil;
    [self dismissModalViewControllerAnimated:YES];
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
    DLog(@"test");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
    self.cityFrom = nil;
    self.cityTo = nil;
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
            
            self.cityFrom = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
            self.cityFrom.font = [UIFont boldSystemFontOfSize:14];
            self.cityFrom.clearsOnBeginEditing = NO;
            self.cityFrom.userInteractionEnabled = NO;
            self.cityFrom.placeholder = @"必填";
            [cell.contentView addSubview:self.cityFrom];
            
            break;
        case 1:
            label.text = @"到达城市";
            
            self.cityTo = [[UITextField alloc] initWithFrame:CGRectMake(90, 12, 200, 25)];
            self.cityTo.font = [UIFont boldSystemFontOfSize:14];
            self.cityTo.clearsOnBeginEditing = NO;
            self.cityTo.userInteractionEnabled = NO;
            self.cityTo.placeholder = @"必填";
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
    UITextField *city = [[cell.contentView subviews] objectAtIndex:1];
    
    TBCityListViewController *cityListViewController = [[TBCityListViewController alloc]
                                                        initWithNibName:@"TBCityListViewController" bundle:nil];
    
    cityListViewController.selectedCity = city;
    
    cityListViewController.title = label.text;
    [self.navigationController pushViewController:cityListViewController animated:YES];
}

@end
