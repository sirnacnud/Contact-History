//
//  NCGroupsTableViewController.m
//  NumberCollector
//
//  Created by Duncan Cunningham on 7/6/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import "NCGroupsTableViewController.h"

#import "NCGroupsViewController.h"
#import "NCGroupsManager.h"

@interface NCGroupsTableViewController ()

/**
 Currently checked group row
 */
@property (nonatomic,strong) NSIndexPath* checkedRow;

@end

@implementation NCGroupsTableViewController

/**
 Handles when a row is selected in the TableView
 @param tableView TableView
 @param indexPath IndexPath for selected row
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 0 && [self.checkedRow compare:indexPath] != NSOrderedSame )
    {
        UITableViewCell* newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell* oldCell = [tableView cellForRowAtIndexPath:self.checkedRow];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        
        self.checkedRow = indexPath;
        
        ContactGroup group;
        
        if( indexPath.row == 0 )
        {
            group = GROUP_DEFAULT;
        }
        else
        {
            group = GROUP_ALL;
        }
        
        NCGroupsViewController* parentViewController = (NCGroupsViewController*)self.parentViewController;
        parentViewController.delegate.selectedGroup = group;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

/**
 Gets the cell of a row in the TableView
 @param tableView TableView
 @param indexPath IndexPath describing the row
 @returns The cell for the row
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if( indexPath.section == 0 )
    {
        ContactGroup currentGroup = [NCGroupsManager getGroup];
        
        if( ( currentGroup == GROUP_DEFAULT && indexPath.row == 0 ) ||
           ( currentGroup == GROUP_ALL && indexPath.row == 1 ) )
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.checkedRow = indexPath;
        }
    }
    
    return cell;
}

@end
