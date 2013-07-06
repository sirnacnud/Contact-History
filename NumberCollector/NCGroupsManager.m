//
//  NCGroupsManager.m
//  Number Collector
//
//  Created by Duncan Cunningham on 7/6/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import "NCGroupsManager.h"

#define GROUP_KEY       @"group"
#define DEFAULT_VALUE   @"default"
#define ALL_VALUE       @"all"

@implementation NCGroupsManager

+ (ContactGroup)getGroup
{
    ContactGroup group = GROUP_INV;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* currentGroup = [defaults stringForKey:GROUP_KEY];
    
    if( currentGroup != nil )
    {
        if( [currentGroup compare:DEFAULT_VALUE] == NSOrderedSame )
        {
            group = GROUP_DEFAULT;
        }
        else if( [currentGroup compare:ALL_VALUE] == NSOrderedSame )
        {
            group = GROUP_ALL;
        }
    }
    
    return group;
}

+ (void)setGroup:(ContactGroup)group
{
    if( group != GROUP_INV )
    {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
        NSString* groupValue;
        
        if( group == GROUP_DEFAULT )
        {
            groupValue = DEFAULT_VALUE;
        }
        else if( group == GROUP_ALL )
        {
            groupValue = ALL_VALUE;
        }
        
        [defaults setObject:groupValue forKey:GROUP_KEY];
        [defaults synchronize];
    }
}
@end
