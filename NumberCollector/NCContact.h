//
//  NCContact.h
//  NumberCollector
//
//  Created by Duncan Cunningham on 4/13/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface NCContact : NSObject

@property (nonatomic,strong) NSString* firstName;
@property (nonatomic,strong) NSString* lastName;
@property (nonatomic,strong) NSString* company;
@property (nonatomic,strong) NSString* phoneNumber;
@property (nonatomic,strong) NSString* creationDate;
@property (nonatomic) NSInteger dateGroup;
@property (nonatomic) ABRecordID recordId;

@end
