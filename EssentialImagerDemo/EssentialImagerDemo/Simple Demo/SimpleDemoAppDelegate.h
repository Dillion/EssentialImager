//
//  AppDelegate.h
//  EssentialImager
//
//  Created by Dillion Tan on 9/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EISimpleDemoViewController.h"

@interface SimpleDemoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) EISimpleDemoViewController *rootViewController;

@end
