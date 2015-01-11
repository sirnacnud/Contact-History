//
//  NCGroupsManager.m
//  Number Collector
//
//  Created by Duncan Cunningham on 7/6/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import "NCGroupsManager.h"

/**
 Keys for user defaults
 */
NSString* const NCGroupsManagerGroupKey = @"group";

/**
 Values for user defaults
 */
NSString* const NCGroupsManagerDefaultValue = @"default";
NSString* const NCGroupsManagerAllValue = @"all";

@implementation NCGroupsManager

/**
 Gets the currently selected contact group
 @returns Currently select contact group
 */
+ (ContactGroup)getGroup
{
    ContactGroup group = GROUP_INV;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* currentGroup = [defaults stringForKey:NCGroupsManagerGroupKey];
    
    if( currentGroup != nil )
    {
        if( [currentGroup compare:NCGroupsManagerDefaultValue] == NSOrderedSame )
        {
            group = GROUP_DEFAULT;
        }
        else if( [currentGroup compare:NCGroupsManagerAllValue] == NSOrderedSame )
        {
            group = GROUP_ALL;
        }
    }
    
    return group;
}

/**
 Sets the currently selected contact group
 @param group Group to set
 */
+ (void)setGroup:(ContactGroup)group
{
    if( group != GROUP_INV )
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
        NSString* groupValue;
        
        if( group == GROUP_DEFAULT )
        {
            groupValue = NCGroupsManagerDefaultValue;
        }
        else if( group == GROUP_ALL )
        {
            groupValue = NCGroupsManagerAllValue;
        }
        
        [defaults setObject:groupValue forKey:NCGroupsManagerGroupKey];
        [defaults synchronize];
    }
}
@end
