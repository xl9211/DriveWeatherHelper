//
//  TBRouteWeatherViewController.h
//  DriveWeatherHelper
//
//  Created by xulin on 01/12/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

#define kDBFilename @"dwh.sqlite3"

@interface TBRouteWeatherViewController : UIViewController <BMKSearchDelegate, BMKMapViewDelegate>
{
    NSMutableDictionary *routeInfo;
    NSString *srcOp;
    NSInteger nowOpStep;
    UIAlertView *waitAlert;
    
    BMKMapView *mapView;
    BMKSearch *mapSearch;
}

@property (strong, nonatomic) NSMutableDictionary *routeInfo;
@property (strong, nonatomic) BMKSearch *mapSearch;
@property (strong, nonatomic) NSString *srcOp;
@property (strong, nonatomic) UIAlertView *waitAlert;
@property (strong, nonatomic) IBOutlet BMKMapView *mapView;

- (void)searchRoute;
- (NSInteger)getCityWeather:(NSString *)cityCode weatherInfo:(NSDictionary **)info;
- (NSString *)dataFilePath;
- (void)showWeather:(NSMutableDictionary*)step;
- (void)parseAddr;
- (IBAction)save:(id)sender;
- (IBAction)share:(id)sender;
- (void)weatherViewDidStartLoad;
- (void)weatherViewDidFinishLoad;

@end
