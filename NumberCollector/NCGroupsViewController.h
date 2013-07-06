//
//  NCGroupViewController.h
//  NumberCollector
//
//  Created by Duncan Cunningham on 7/6/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NCGroupsViewControllerDelegate <NSObject>

- (void)didDismissPresentedViewController;

@end

@interface NCGroupsViewController : UIViewController


@property (nonatomic, weak) id<NCGroupsViewControllerDelegate> delegate;

@end
