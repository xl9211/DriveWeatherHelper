//
//  TBRouteListViewController.m
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TBRouteListViewController.h"
#import "TBAddRouteViewController.h"

@implementation TBRouteListViewController

@synthesize addRouteViewController;
@synthesize navController;

- (void)dealloc
{
    [addRouteViewController release];
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
    self.addRouteViewController = nil;
    self.navController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
