//
//  NCViewController.m
//  NumberCollector
//
//  Created by Duncan Cunningham on 4/13/13.
//  Copyright (c) 2013 Duncan Cunningham. All rights reserved.
//

#import "NCTableViewController.h"
#import "NCContact.h"
#import "NCGroupsManager.h"
#import "NCGroupsViewController.h"
#import "MBProgressHUD.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface NCTableViewController ()

@property (nonatomic) ABAddressBookRef addressBook;
@property (nonatomic) BOOL addressBookAccess;
@property (nonatomic,strong) NSMutableDictionary* contacts;
@property (nonatomic,strong) NSArray* dates;
@property (nonatomic,strong) PullToRefreshView* pullView;

@end

@implementation NCTableViewController

@synthesize addressBook = _addressBook;
@synthesize addressBookAccess = _addressBookAccess;
@synthesize contacts = _contacts;
@synthesize dates = _dates;
@synthesize pullView = _pullView;
@synthesize selectedGroup = _selectedGroup;

- (NSMutableDictionary*)contacts
{
    if( _contacts == Nil )
    {
        _contacts = [[NSMutableDictionary alloc] init];
    }
    
    return _contacts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Give user the chance to see the launch image
    sleep( 1 );
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(reloadFromNotificatonCenter:)
                                          name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // Check if group setting is present, if not set to default
    if( [NCGroupsManager getGroup] == GROUP_INV )
    {
        [NCGroupsManager setGroup:GROUP_DEFAULT];
    }
    
    self.pullView = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    [self.pullView setDelegate:self];
    [self.tableView addSubview:self.pullView];
    
    self.addressBook = ABAddressBookCreateWithOptions( NULL, NULL );
    
    __block BOOL accessGranted = NO;
    
    // We're on iOS 6
    if( ABAddressBookRequestAccessWithCompletion != NULL )
    { 
        dispatch_semaphore_t sema = dispatch_semaphore_create( 0 );
        
        ABAddressBookRequestAccessWithCompletion( self.addressBook, ^( bool granted, CFErrorRef error ) {
            accessGranted = granted;
            dispatch_semaphore_signal( sema );
            });
        
        dispatch_semaphore_wait( sema, DISPATCH_TIME_FOREVER );
    }
    // We're on iOS 5 or older
    else
    {
        accessGranted = YES;
    }
    
    self.addressBookAccess = accessGranted;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if( [self isViewLoaded] && self.view.window )
    {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate* date = [self.dates objectAtIndex:section];
    return [[self.contacts objectForKey:date] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dates count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSDate* date = [self.dates objectAtIndex:section];
    
    return [formatter stringFromDate:date];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if( cell == nil )
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = [indexPath row];;
    NSInteger section = [indexPath section];
    
    NSDate* date = [self.dates objectAtIndex:section];
    NSMutableArray* contacts = [self.contacts objectForKey:date];
    
    NCContact* contact = [contacts objectAtIndex:row];
    
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
    else if( [contact.lastName length] > 0 )
    {
        cell.textLabel.text = contact.lastName;
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
    NSInteger row = [indexPath row];;
    NSInteger section = [indexPath section];
    
    NSDate* date = [self.dates objectAtIndex:section];
    NSMutableArray* contacts = [self.contacts objectForKey:date];
    
    NCContact* contact = [contacts objectAtIndex:row];
    
    ABRecordRef ref = ABAddressBookGetPersonWithRecordID( self.addressBook, contact.recordId );
    
    if( ref )
    {
        // Need to add checks to make sure the record Id
        // didn't change for the contact
        
        ABPersonViewController *view = [[ABPersonViewController alloc] init];
        
        view.personViewDelegate = self;
        view.displayedPerson = ref;
        
        [self.navigationController pushViewController:view animated:YES];
    }
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return YES;
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadContactHistory];
        [self.tableView reloadData];
        [self.pullView finishedLoading];
    });
}

- (void)reloadContactHistory
{
    if( self.addressBook )
    {
        [self.contacts removeAllObjects];
        
        ContactGroup currentGroup = [NCGroupsManager getGroup];
        
        CFArrayRef allPeople;
        
        if( currentGroup == GROUP_DEFAULT )
        {
            ABRecordRef defaultSource = ABAddressBookCopyDefaultSource( self.addressBook );
            allPeople = ABAddressBookCopyArrayOfAllPeopleInSource( self.addressBook, defaultSource );
        }
        else
        {
            allPeople = ABAddressBookCopyArrayOfAllPeople( self.addressBook );
        }
        
        int numberOfPeople = CFArrayGetCount( allPeople );
        
        CFMutableArrayRef allPeopleMutable = CFArrayCreateMutableCopy( kCFAllocatorDefault, numberOfPeople, allPeople );
        
        CFRelease( allPeople );
        
        NSMutableArray* dates = [[NSMutableArray alloc] init];
        
        for( int i = 0; i < numberOfPeople; i++ )
        {
            ABRecordRef ref = CFArrayGetValueAtIndex( allPeopleMutable, i );
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue( ref, kABPersonPhoneProperty );
            
            if( ABMultiValueGetCount( phoneNumbers ) > 0 )
            {
                NCContact* contact = [[NCContact alloc] init];
                contact.recordId = ABRecordGetRecordID( ref );
                
                contact.phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex( phoneNumbers, 0 );
                
                CFRelease( phoneNumbers );
                
                CFStringRef firstName = ABRecordCopyValue( ref, kABPersonFirstNameProperty );
                CFStringRef lastName = ABRecordCopyValue( ref, kABPersonLastNameProperty );
                CFStringRef company = ABRecordCopyValue( ref, kABPersonOrganizationProperty );
                
                if( firstName )
                {
                    contact.firstName = (__bridge_transfer NSString*)firstName;
                }
                
                if( lastName )
                {
                    contact.lastName = (__bridge_transfer NSString*)lastName;
                }
                
                if( company )
                {
                    contact.company = (__bridge_transfer NSString*)company;
                }
                
                NSDate* creationDate = (__bridge_transfer NSDate*)ABRecordCopyValue( ref, kABPersonCreationDateProperty );
                
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setTimeStyle:NSDateFormatterNoStyle];
                
                NSString* dateString = [formatter stringFromDate:creationDate];
                NSDate* shortenedDate = [formatter dateFromString:dateString];
                
                NSMutableArray* dateGroup = [self.contacts objectForKey:shortenedDate];
                
                if( !dateGroup )
                {
                    dateGroup = [[NSMutableArray alloc] init];
                    [self.contacts setObject:dateGroup forKey:shortenedDate];
                    [dates addObject:shortenedDate];
                }
                
                [dateGroup addObject:contact];
            }
        }
        
        [dates sortUsingSelector:@selector(compare:)];
        self.dates = [[dates reverseObjectEnumerator] allObjects];
        
        CFRelease( allPeopleMutable );
    }
}

- (void)refreshContactHistory
{
    if( self.addressBookAccess )
    {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";

        self.tableView.userInteractionEnabled = NO;

        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self reloadContactHistory];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pullView refreshLastUpdatedDate];
                [self.tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                self.tableView.userInteractionEnabled = YES;
            });
        });
    }
    else
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                    message:@"Enable Contact Permissions Under Settings -> Privacy -> Contacts"
                                                    delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
        [message show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"Groups"] )
    {
        NCGroupsViewController* viewController = segue.destinationViewController;
        viewController.delegate = self;
    }
}

- (void)didDismissPresentedViewController
{
    if( self.selectedGroup != [NCGroupsManager getGroup] )
    {
        [NCGroupsManager setGroup:self.selectedGroup];
        [self refreshContactHistory];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

 -(void)reloadFromNotificatonCenter:(NSNotification *)notification
{
    [self refreshContactHistory];
}

@end
