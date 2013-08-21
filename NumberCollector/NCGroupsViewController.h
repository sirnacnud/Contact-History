//
//  NCGroupViewController.h
//  NumberCollector
//
//  Created by Duncan Cunningham on 7/6/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NCGroupsManager.h"

/**
 Protocol for handling the ViewController
 */
@protocol NCGroupsViewControllerDelegate <NSObject>

/**
 Selected group
 */
@property (nonatomic) ContactGroup selectedGroup;

- (void)didDismissPresentedViewController;

@end

@interface NCGroupsViewController : UIViewController

/**
 The NCGroupsViewControllerDelegate
 */
@property (nonatomic, weak) id<NCGroupsViewControllerDelegate> delegate;

@end
