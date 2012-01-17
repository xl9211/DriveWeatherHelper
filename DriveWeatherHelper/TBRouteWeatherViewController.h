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

@interface TBRouteWeatherViewController : UIViewController 
<UIActionSheetDelegate, BMKSearchDelegate, BMKMapViewDelegate>
{
    NSMutableDictionary *routeInfo;
    NSString *srcOp;
    NSInteger nowOpStep;
    UIAlertView *waitAlert;
    NSArray *provinceList;
    CGPoint addWeatherPoint;
    UIBarButtonItem *saveButton;
    NSMutableArray *annotations;
    BOOL addOp;
    
    BMKMapView *mapView;
    BMKSearch *mapSearch;
}

@property (strong, nonatomic) NSMutableDictionary *routeInfo;
@property (strong, nonatomic) BMKSearch *mapSearch;
@property (strong, nonatomic) NSString *srcOp;
@property (strong, nonatomic) UIAlertView *waitAlert;
@property (strong, nonatomic) IBOutlet BMKMapView *mapView;
@property (strong, nonatomic) NSArray *provinceList;
@property (strong, nonatomic) UIBarButtonItem *saveButton;
@property (strong, nonatomic) NSMutableArray *annotations;

- (void)searchRoute;
- (NSInteger)getCityWeather:(NSString *)cityCode weatherInfo:(NSMutableDictionary *)info;
- (NSString *)dataFilePath;
- (void)parseAddr;
- (IBAction)save:(id)sender;
- (IBAction)update:(id)sender;
- (void)dataDidStartLoad:(NSString *)msg;
- (void)dataDidFinishLoad;
- (void)nextAddr;
- (void)showAddWeatherMenu:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)updateDataToDB;
- (void)addWeather;
- (void)showWeather:(NSMutableDictionary *)step;
- (void)updateWeather:(NSMutableDictionary *)step;

@end
