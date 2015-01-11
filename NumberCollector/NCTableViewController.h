//
//  NCViewController.h
//  NumberCollector
//
//  Created by Duncan Cunningham on 4/13/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

#import "NCGroupsViewController.h"

/**
 Main TableViewController for the list of contacts
 */
@interface NCTableViewController : UITableViewController <UITableViewDataSource,
                                                          UITableViewDelegate,
                                                          ABPersonViewControllerDelegate,
                                                          NCGroupsViewControllerDelegate>

@end
