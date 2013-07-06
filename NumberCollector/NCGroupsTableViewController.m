//
//  NCGroupsTableViewController.m
//  NumberCollector
//
//  Created by Duncan Cunningham on 7/6/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import "NCGroupsTableViewController.h"

#import "NCGroupsManager.h"

@interface NCGroupsTableViewController ()

@property (nonatomic,strong) NSIndexPath* checkedRow;

@end

@implementation NCGroupsTableViewController

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
        
        [NCGroupsManager setGroup:group];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

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
