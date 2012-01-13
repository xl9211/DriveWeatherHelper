//
//  TBRouteWeatherViewController.m
//  DriveWeatherHelper
//
//  Created by xulin on 01/12/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TBRouteWeatherViewController.h"
#import "BMapKit.h"
#import "SBJson.h"

@implementation TBRouteWeatherViewController

@synthesize routeInfo;
@synthesize mapSearch;

- (void)dealloc
{
    [routeInfo release];
    [mapSearch release];
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

#pragma mark - Baidu Map Operation

- (void)searchRoute
{
    mapSearch = [[BMKSearch alloc]init];
    mapSearch.delegate = self;
    
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = [routeInfo valueForKey:@"city_from"];
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = [routeInfo valueForKey:@"city_to"];
    [mapSearch drivingSearch:start.name startNode:start endCity:end.name endNode:end];
    [start release];
    [end release];
}

- (void)onGetDrivingRouteResult:(BMKPlanResult*)result errorCode:(int)error
{
    NSMutableDictionary *detailInfo = [routeInfo valueForKey:@"detail_info"];
    if (detailInfo != nil)
    {
        [detailInfo release];
        detailInfo = nil;
    }
    detailInfo = [[NSMutableDictionary alloc] init];
    
    NSInteger planNum = [result.plans count]; 
    if (planNum > 0)
    {
        BMKRoutePlan *routePlan= [result.plans objectAtIndex:0];
        NSInteger routeNum = [routePlan.routes count];
        if (routeNum > 0)
        {
            BMKRoute *route = [routePlan.routes objectAtIndex:0];
            NSInteger stepNum = [route.steps count];
            if (stepNum > 0)
            {
                for (NSInteger stepIndex = 0; stepIndex < stepNum; stepIndex++) 
                {
                    //BMKStep *step = [route.steps objectAtIndex:stepIndex];
                    [self getCityWeather:nil weatherInfo:nil];               
                }
            }
        }
        
    }
    else
    {
    }
}

#pragma mark - Weather Operation

- (NSInteger)getCityWeather:(NSString *)cityCode weatherInfo:(NSDictionary *)info
{
    /*NSURL *url = [NSURL URLWithString:@"http://www.weather.com.cn/data/sk/101010100.html"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) 
    {
        NSString *response = [request responseString];
    }*/
    
    return 0;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    BMKMapView *mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.view = mapView;
    [mapView release];
    
    if ([routeInfo valueForKey:@"detail_info"] == nil)
    {
        [self searchRoute];
    }
    else
    {
        // Direct to show
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.routeInfo = nil;
    self.mapSearch = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
