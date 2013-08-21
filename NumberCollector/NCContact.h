//
//  NCContact.h
//  NumberCollector
//
//  Created by Duncan Cunningham on 4/13/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

/**
 Simple class containing all the information for a contact
 */
@interface NCContact : NSObject

/**
 First name of the contact
 */
@property (nonatomic,strong) NSString* firstName;

/**
 Last name of the contact
 */
@property (nonatomic,strong) NSString* lastName;

/**
 Company name for the contact (can be empty)
 */
@property (nonatomic,strong) NSString* company;

/**
 Phone number for the contact
 */
@property (nonatomic,strong) NSString* phoneNumber;

/**
 Record ID from the address book for the contact
 */
@property (nonatomic) ABRecordID recordId;

@end
