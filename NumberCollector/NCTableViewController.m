//
//  NCViewController.m
//  NumberCollector
//
//  Created by Duncan Cunningham on 4/13/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import "NCTableViewController.h"
#import "NCContact.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface NCTableViewController ()

@property (nonatomic,strong) NSMutableArray* contacts;
@property (nonatomic,strong) NSMutableArray* dates;
@property (nonatomic,strong) NSMutableArray* groupCounts;
@property (nonatomic,strong) NSString* lastDate;
@property (nonatomic) ABAddressBookRef addressBook;

@end

@implementation NCTableViewController

@synthesize contacts = _contacts;
@synthesize dates = _dates;
@synthesize lastDate = _lastDate;
@synthesize groupCounts = _groupCounts;
@synthesize addressBook = _addressBook;

- (NSMutableArray*)contacts
{
    if( _contacts == Nil )
    {
        _contacts = [[NSMutableArray alloc] init];
    }
    
    return _contacts;
}

- (NSMutableArray*)dates
{
    if( _dates == Nil )
    {
        _dates = [[NSMutableArray alloc] init];
    }
    
    return _dates;
}

- (NSMutableArray*)groupCounts
{
    if( _groupCounts == Nil )
    {
        _groupCounts = [[NSMutableArray alloc] init];
    }
    
    return _groupCounts;
}

- (NSString*)lastDate
{
    if( _lastDate == Nil )
    {
        _lastDate = [[NSString alloc] init];
    }
    
    return _lastDate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.addressBook = ABAddressBookCreate();
    
    __block BOOL accessGranted = NO;
    
    // we're on iOS 6
    if( ABAddressBookRequestAccessWithCompletion != NULL )
    { 
        dispatch_semaphore_t sema = dispatch_semaphore_create( 0 );
        
        ABAddressBookRequestAccessWithCompletion( self.addressBook, ^( bool granted, CFErrorRef error ) {
            accessGranted = granted;
            dispatch_semaphore_signal( sema );
            });
        
        dispatch_semaphore_wait( sema, DISPATCH_TIME_FOREVER );
    }
    // we're on iOS 5 or older
    else
    {
        accessGranted = YES;
    }
    
    if( self.addressBook )
    {
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( self.addressBook );
        
        NSString* date = Nil;
        NSInteger groupCount = 0;
        for (int i = 0; i < CFArrayGetCount( allPeople ); i++)
        {
            ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue( ref, kABPersonPhoneProperty );
            
            if( ABMultiValueGetCount( phoneNumbers ) > 0 )
            {
                NCContact* contact = [[NCContact alloc] init];
                contact.recordId = ABRecordGetRecordID( ref );
                
                contact.phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex( phoneNumbers, 0 );
                NSLog( @"Phone Number: %@", contact.phoneNumber );
            
                CFRelease( phoneNumbers );
                
                CFStringRef firstName = ABRecordCopyValue( ref, kABPersonFirstNameProperty );
                CFStringRef lastName = ABRecordCopyValue( ref, kABPersonLastNameProperty );
                CFStringRef company = ABRecordCopyValue( ref, kABPersonOrganizationProperty );
                
                if( firstName )
                {
                    NSLog( @"First Name: %@", firstName );
                    contact.firstName = (__bridge_transfer NSString*)firstName;
                }
                
                if( lastName )
                {
                    NSLog( @"Last Name: %@", lastName );
                    contact.lastName = (__bridge_transfer NSString*)lastName;
                }
                
                if( company )
                {
                    NSLog( @"Company: %@", company );
                    contact.company = (__bridge_transfer NSString*)company;
                }
                
                NSDate* creationDate = (__bridge_transfer NSDate*)ABRecordCopyValue( ref, kABPersonCreationDateProperty );
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                
                date = [formatter stringFromDate:creationDate];
                
                NSLog( @"Creation Date: %@", date );
                
                
                if( [self.lastDate compare:date] != NSOrderedSame )
                {
                    self.lastDate = date;
                    [self.dates addObject:date];
                    
                    if( groupCount != 0 )
                    {
                        [self.groupCounts addObject:[NSNumber numberWithInteger:groupCount]];
                        groupCount = 0;
                    }

                    groupCount++;
                }
                else
                {
                    groupCount++;
                }
                
                contact.creationDate = self.lastDate;
                
                [self.contacts addObject:contact];
            }
        }
        
        [self.groupCounts addObject:[NSNumber numberWithInteger:groupCount]];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.groupCounts objectAtIndex:section] intValue];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dates count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dates objectAtIndex:section];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = 0;
    NSInteger section = [indexPath section];
    
    for( int i = 0; i < section; ++i )
    {
        row = row + [[self.groupCounts objectAtIndex:i] intValue];
    }
    
    NCContact* contact = [self.contacts objectAtIndex:row + [indexPath row]];
    
    if( [contact.firstName length] > 0 )
    {        
        if( [contact.lastName length] > 0 )
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",contact.firstName,contact.lastName];
        }
        else
        {
            cell.textLabel.text = contact.firstName;
        }
    }
    else if( [contact.company length] > 0 )
    {
        cell.textLabel.text = contact.company;
    }
    else
    {
        cell.textLabel.text = contact.phoneNumber;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = 0;
    NSInteger section = [indexPath section];
    
    for( int i = 0; i < section; ++i )
    {
        row = row + [[self.groupCounts objectAtIndex:i] intValue];
    }
    
    NCContact* contact = [self.contacts objectAtIndex:row + [indexPath row]];
    
    ABRecordRef ref = ABAddressBookGetPersonWithRecordID(self.addressBook, contact.recordId );
    
    if( ref )
    {
        // Need to add checks to make sure the record Id
        // didn't change for the contact
        
        ABPersonViewController *view = [[ABPersonViewController alloc] init];
        
        view.personViewDelegate = self;
        view.displayedPerson = ref;
        
        [self presentViewController:view animated:YES completion:NULL];
    }
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return NO;
}

@end
