//
//  TBRouteListViewController.h
//  DriveWeatherHelper
//
//  Created by xulin on 01/11/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBAddRouteViewController;

@interface TBRouteListViewController : UIViewController
{
    TBAddRouteViewController *addRouteViewController;
    UINavigationController *navController;
}

@property (strong, nonatomic) TBAddRouteViewController *addRouteViewController;
@property (strong, nonatomic) IBOutlet UINavigationController *navController;

- (IBAction)addRoute:(id)sender;

@end
