//
//  NCViewController.h
//  NumberCollector
//
//  Created by Duncan Cunningham on 4/13/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

#import "PullToRefreshView.h"

@interface NCTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, ABPersonViewControllerDelegate, PullToRefreshViewDelegate>

@end
