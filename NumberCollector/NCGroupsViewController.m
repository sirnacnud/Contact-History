//
//  NCGroupViewController.m
//  NumberCollector
//
//  Created by Duncan Cunningham on 7/6/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import "NCGroupsViewController.h"

@interface NCGroupsViewController ()

@end

@implementation NCGroupsViewController

@synthesize delegate = _delegate;

/**
 Called when the done button is clicked
 @param sender
 @returns action
 */
- (IBAction)hitDone:(id)sender
{
    [self.delegate didDismissPresentedViewController];
}


@end
