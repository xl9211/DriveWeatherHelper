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
#import "TBAppDelegate.h"
#import "TBRouteListViewController.h"
#import <sqlite3.h>

@implementation TBRouteWeatherViewController

@synthesize routeInfo;
@synthesize mapSearch;
@synthesize mapView;
@synthesize srcOp;
@synthesize waitAlert;
@synthesize provinceList;

- (void)dealloc
{
    [routeInfo release];
    [mapSearch release];
    [mapView release];
    [srcOp release];
    [waitAlert release];
    [provinceList release];
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

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kDBFilename];
}

- (IBAction)save:(id)sender
{
    NSMutableArray *stepInfo = [routeInfo valueForKey:@"stepInfo"];
    if (nowOpStep == 0 || nowOpStep < [stepInfo count])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示" 
                              message:@"天气数据未获取完整，暂时无法保存。"
                              delegate:self 
                              cancelButtonTitle:@"确定" 
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
    else
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
        
        NSString *query = [[NSString alloc] 
                           initWithFormat:@"select id from route_info where city_from = '%@' and province_from = '%@' and city_to = '%@' and province_to = '%@'",
                           [routeInfo objectForKey:@"cityFrom"],
                           [routeInfo objectForKey:@"provinceFrom"],
                           [routeInfo objectForKey:@"cityTo"],
                           [routeInfo objectForKey:@"provinceTo"]];
        
        sqlite3_stmt *statement;
        NSInteger findCount = 0;
        NSInteger ret = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
        if (ret == SQLITE_OK) 
        {
            while (sqlite3_step(statement) == SQLITE_ROW) 
            {
                findCount++;
            }
            sqlite3_finalize(statement);
        }
        
        if (findCount == 0)
        {
            SBJsonWriter *writer = [[SBJsonWriter alloc] init];  
            NSError * error = nil;
            NSMutableArray *stepInfo = [routeInfo objectForKey:@"stepInfo"];
            NSString *stepInfoStr = [writer stringWithObject:stepInfo error:&error]; 
            
            NSString *insert = [[NSString alloc] 
                                initWithFormat:@"insert into route_info (city_from, province_from, city_to, province_to, step_info) values ('%@', '%@', '%@', '%@', '%@')",
                                [routeInfo objectForKey:@"cityFrom"],
                                [routeInfo objectForKey:@"provinceFrom"],
                                [routeInfo objectForKey:@"cityTo"],
                                [routeInfo objectForKey:@"provinceTo"],
                                stepInfoStr];
            char *errorMsg;
            if (sqlite3_exec(database, [insert UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
            {
                NSAssert1(0, @"Error insertSelecting tables: %s", errorMsg);	
            }
            [insert release];
        }
        
        sqlite3_close(database);
        
        [root readDataFromDB];
        [[root tableView] reloadData];
        
        [root dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)share:(id)sender
{
}

- (void)weatherViewDidStartLoad
{
    if (waitAlert == nil)
    {
        waitAlert = [[UIAlertView alloc] initWithTitle:nil
                                               message:@"正在获取天气数据"
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] 
                                                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityView.frame = CGRectMake(120.f, 48.0f, 37.0f, 37.0f);
        [waitAlert addSubview:activityView];
        [activityView startAnimating];
    }
    [waitAlert show];
}

- (void)weatherViewDidFinishLoad
{
    [waitAlert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - Baidu Map Operation

- (void)searchRoute
{
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = [routeInfo valueForKey:@"cityFrom"];
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = [routeInfo valueForKey:@"cityTo"];
    [mapSearch drivingSearch:start.name startNode:start endCity:end.name endNode:end];
    [start release];
    [end release];
}

- (void)onGetDrivingRouteResult:(BMKPlanResult*)result errorCode:(int)error
{
    [self weatherViewDidStartLoad];
    
    NSMutableArray *stepInfo = [routeInfo valueForKey:@"stepInfo"];
    
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
                    BMKStep *step = [route.steps objectAtIndex:stepIndex];
                    
                    NSMutableDictionary* oneStep = [[NSMutableDictionary alloc] init];
                    NSNumber *latitude = [[NSNumber alloc] initWithDouble:step.pt.latitude];
                    NSNumber *longitude = [[NSNumber alloc] initWithDouble:step.pt.longitude];
                    [oneStep setValue:latitude forKey:@"latitude"];
                    [oneStep setValue:longitude forKey:@"longitude"];
                    [stepInfo addObject:oneStep];
                }
                
                // 开始操作第一个地址
                [self parseAddr];
            }
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"出错了" 
                              message:@"没有你要找的线路"
                              delegate:self 
                              cancelButtonTitle:@"确定" 
                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
}

- (void)parseAddr
{
    [self weatherViewDidStartLoad];
    
    NSMutableArray *stepInfo = [routeInfo valueForKey:@"stepInfo"];
    NSMutableDictionary* oneStep = [stepInfo objectAtIndex:nowOpStep];
    CLLocationCoordinate2D pt;
    pt.latitude = [[oneStep objectForKey:@"latitude"] doubleValue];
    pt.longitude = [[oneStep objectForKey:@"longitude"] doubleValue];
    
    [mapSearch reverseGeocode:pt];
}

- (void)onGetAddrResult:(BMKAddrInfo*)result errorCode:(int)error
{
    NSMutableArray *stepInfo = [routeInfo valueForKey:@"stepInfo"];
    NSInteger stepNum = [stepInfo count];
    
    if (nowOpStep < stepNum)
    {
        NSMutableDictionary* oneStep = [stepInfo objectAtIndex:nowOpStep];
        
        //NSInteger districtStrLen = [result.addressComponent.district length];
        //NSString *district = [result.addressComponent.district substringToIndex:(districtStrLen - 1)];
        NSInteger cityStrLen = [result.addressComponent.city length];
        NSString *city = [result.addressComponent.city substringToIndex:(cityStrLen - 1)];
        NSString *province;
        for (NSInteger index = 0; index < [self.provinceList count]; index++) 
        {
            NSRange range = [result.addressComponent.province 
                             rangeOfString:[self.provinceList objectAtIndex:index]];
            if (range.location != NSNotFound)
            {
                province = [self.provinceList objectAtIndex:index];
                break;
            }
        }
        
        NSString *addr = [[NSString alloc] initWithFormat:@"%@%@%@",
                          result.addressComponent.province,
                          result.addressComponent.city,
                          result.addressComponent.district];
        [oneStep setObject:addr forKey:@"addr"];
        
        sqlite3 *database;
        const char *db_path = [[self dataFilePath] UTF8String];
        if (sqlite3_open(db_path, &database) != SQLITE_OK)
        {
            sqlite3_close(database);
            NSAssert(0, @"Failed to open database");
        }
        
        NSString *query = [[NSString alloc] 
                           initWithFormat:@"select code from city_info where city = '%@' and province = '%@'",
                           city, 
                           province];
        sqlite3_stmt *statement;
        NSInteger ret = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil);
        if (ret == SQLITE_OK) 
        {
            if (sqlite3_step(statement) == SQLITE_ROW) 
            {
                char *codeData = (char *)sqlite3_column_text(statement, 0);
                NSString *code = [[NSString alloc] initWithUTF8String:codeData];
                [oneStep setObject:code forKey:@"cityCode"];
                
                NSMutableDictionary *weather = [[NSMutableDictionary alloc] init];
                [self getCityWeather:code weatherInfo:weather];
                [oneStep removeObjectForKey:@"cityWeather"];
                [oneStep setObject:weather forKey:@"cityWeather"];
                
                [code release];
                [weather release];
            }
            sqlite3_finalize(statement);
        }
        [query release];
        sqlite3_close(database);
        
        [self showWeather:oneStep];
    }
}

- (void)showWeather:(NSMutableDictionary*)step;
{
    NSMutableArray *stepInfo = [routeInfo valueForKey:@"stepInfo"];
    
    if ([step objectForKey:@"cityWeather"] == nil ||
        (nowOpStep > 0 && 
         nowOpStep < [stepInfo count] &&
         [[step objectForKey:@"cityCode"] isEqualToString:[[stepInfo objectAtIndex:(nowOpStep - 1)] objectForKey:@"cityCode"]]))
    {
        [self nextAddr];
    }
    else
    {
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D pt;
        pt.latitude = [[step objectForKey:@"latitude"] doubleValue];
        pt.longitude = [[step objectForKey:@"longitude"] doubleValue];
        annotation.coordinate = pt;
        annotation.title = [step objectForKey:@"addr"];
        annotation.subtitle = [[NSString alloc] initWithFormat:@"%@ %@",
                               [[step objectForKey:@"cityWeather"] objectForKey:@"weather"],
                               [[step objectForKey:@"cityWeather"] objectForKey:@"temp"]];
        
        [mapView addAnnotation:annotation];
    }
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) 
    {
		BMKPinAnnotationView *newAnnotation = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];   
		newAnnotation.pinColor = BMKPinAnnotationColorPurple;   
		newAnnotation.animatesDrop = YES;
		
        [self nextAddr];
        
		return newAnnotation;   
	}

    return nil;
}

- (void)nextAddr
{
    nowOpStep++;
    
    if (srcOp == @"search")
    {
        // 开始操作下一个地址
        NSMutableArray *stepInfo = [routeInfo valueForKey:@"stepInfo"];
        if (nowOpStep < [stepInfo count])
        {
            [self parseAddr];
        }
        else
        {
            [self weatherViewDidFinishLoad];
        }
    }
}

#pragma mark - Weather Operation

- (NSInteger)getCityWeather:(NSString *)cityCode weatherInfo:(NSMutableDictionary *)info
{
    NSURL *url = [NSURL URLWithString:[[NSString alloc] initWithFormat:@"http://m.weather.com.cn/data/%@.html", cityCode]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0]; 
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request 
                                         returningResponse:nil 
                                                     error:&error];
    
    if (data != nil)
    {
        NSString *weatherString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        SBJsonParser *parser = [[SBJsonParser alloc] init];  
        NSError * error = nil;  
        NSDictionary *srcData = [parser objectWithString:weatherString error:&error];
        
        [info setObject:[[srcData objectForKey:@"weatherinfo"] objectForKey:@"temp1"] forKey:@"temp"];
        [info setObject:[[srcData objectForKey:@"weatherinfo"] objectForKey:@"weather1"] forKey:@"weather"];
    }
    else
    {
        DLog(@"Code:%d, domain:%@, localizedDesc:%@", 
             [error code], 
             [error domain], 
             [error localizedDescription]);
    }
    
    return 0;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    provinceList = [[NSArray alloc] initWithObjects:@"北京", @"上海", @"天津", @"重庆", @"黑龙江", @"吉林", 
                    @"辽宁", @"内蒙古", @"河北", @"山西", @"陕西", @"山东", @"新疆", @"西藏", @"青海", @"甘肃", 
                    @"宁夏", @"河南", @"江苏", @"湖北", @"浙江", @"安徽", @"福建", @"江西", @"湖南", @"贵州", 
                    @"四川", @"广东", @"云南", @"广西", @"海南", @"香港", @"澳门", @"台湾", nil];
    
    self.navigationItem.title = @"线路详情";
    if (srcOp == @"search")
    {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"保存"
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        [saveButton release];
    }
    else
    {
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"分享"
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                        action:@selector(share:)];
        self.navigationItem.rightBarButtonItem = shareButton;
        [shareButton release];
    }
    
    mapView.delegate = self;
    mapSearch = [[BMKSearch alloc]init];
    mapSearch.delegate = self;
    
    BMKCoordinateRegion region;
    region.center.latitude = 35.0f;
    region.center.longitude = 110.0f;
    region.span.latitudeDelta = 15.0f;
    region.span.longitudeDelta = 15.0f;
    [mapView setRegion:region];
    
    nowOpStep = 0;
    NSMutableArray *stepInfo = [routeInfo valueForKey:@"stepInfo"];
    NSInteger stepNum = [stepInfo count];
    if (stepNum == 0)
    {
        [self searchRoute];
    }
    else
    {
        for (NSInteger index = 0; index < stepNum; index++) 
        {
            NSMutableDictionary *step = [stepInfo objectAtIndex:index];
            [self showWeather:step];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.routeInfo = nil;
    self.mapSearch = nil;
    self.mapView = nil;
    self.srcOp = nil;
    self.waitAlert = nil;
    self.provinceList = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
