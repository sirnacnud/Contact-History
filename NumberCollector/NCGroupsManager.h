//
//  NCGroupsManager.h
//  Number Collector
//
//  Created by Duncan Cunningham on 7/6/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Different contact groups the user can select
 */
typedef enum contactGroup
{
    GROUP_DEFAULT,
    GROUP_ALL,
    
    GROUP_INV
} ContactGroup;

/**
 Manages which group of contacts is selected
 */
@interface NCGroupsManager : NSObject

+ (ContactGroup)getGroup;
+ (void)setGroup:(ContactGroup)group;

@end
