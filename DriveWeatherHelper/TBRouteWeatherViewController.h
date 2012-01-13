//
//  TBRouteWeatherViewController.h
//  DriveWeatherHelper
//
//  Created by xulin on 01/12/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface TBRouteWeatherViewController : UIViewController <BMKSearchDelegate>
{
    NSMutableDictionary *routeInfo;
    BMKSearch *mapSearch;
}

@property (strong, nonatomic) NSMutableDictionary *routeInfo;
@property (strong, nonatomic) BMKSearch *mapSearch;

@end
