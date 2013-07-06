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

- (IBAction)hitDone:(id)sender
{
    [self.delegate didDismissPresentedViewController];
}


@end
