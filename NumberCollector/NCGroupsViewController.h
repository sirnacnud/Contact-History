//
//  NCGroupViewController.h
//  NumberCollector
//
//  Created by Duncan Cunningham on 7/6/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NCGroupsManager.h"

@protocol NCGroupsViewControllerDelegate <NSObject>

@property (nonatomic) ContactGroup selectedGroup;

- (void)didDismissPresentedViewController;

@end

@interface NCGroupsViewController : UIViewController


@property (nonatomic, weak) id<NCGroupsViewControllerDelegate> delegate;

@end
