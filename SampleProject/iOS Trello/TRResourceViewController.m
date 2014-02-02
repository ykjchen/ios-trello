//
//  TRResourceViewController.m
//  iOS Trello
//
//  Created by Joseph Chen on 2/2/14.
//  Copyright (c) 2014 Joseph Chen. All rights reserved.
//

#import "TRResourceViewController.h"

#import "TRManagedObject.h"
#import "TRMember.h"
#import "TRBoard.h"
#import "TRList.h"
#import "TRCard.h"

@interface TRResourceViewController ()

@property (strong, nonatomic) TRManagedObject *managedObject;
@property (strong, nonatomic) NSArray *sections;

@end

@implementation TRResourceViewController

- (id)init
{
    [NSException raise:@"Wrong initializer" format:nil];
    return nil;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    [NSException raise:@"Wrong initializer" format:nil];
    return nil;
}

- (id)initWithManagedObject:(TRManagedObject *)managedObject
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        _managedObject = managedObject;
#if !__has_feature(objc_arc)
        [_managedObject retain];
#endif
    }
    return self;
}

- (NSString *)navigationTitle
{
    if (!self.managedObject) {
        return nil;
    }
    
    NSString *keyPath = [self.class titleKeyPathForManagedObject:self.managedObject];
    
    if (!keyPath) {
        return self.managedObject.entity.name;
    }
    
    return [self.managedObject valueForKey:keyPath];
}

+ (NSString *)titleKeyPathForManagedObject:(TRManagedObject *)managedObject
{
    if (!managedObject) {
        return nil;
    }
    
    NSArray *selectorNames = @[@"name", @"fullName"];
    for (NSString *selectorName in selectorNames) {
        SEL selector = NSSelectorFromString(selectorName);
        if ([managedObject respondsToSelector:selector]) {
            return selectorName;
        }
    }
    
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [self navigationTitle];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Accessors

- (NSArray *)sections
{
    if (!_sections && self.managedObject) {
        // attributes
        NSEntityDescription *entityDescription = [self.managedObject entity];
        NSDictionary *attributesByName = entityDescription.attributesByName;
        NSDictionary *relationshipsByName = entityDescription.relationshipsByName;

        NSMutableArray *sections = [NSMutableArray arrayWithCapacity:relationshipsByName.count + 1];
        
        TRResourceTableSection *attributeSection = [[TRResourceTableSection alloc] init];
        attributeSection.objects = [attributesByName allKeys];
        attributeSection.sectionName = @"Attributes";
        [sections addObject:attributeSection];
#if !__has_feature(objc_arc)
        [attributeSection release];
#endif
        
        for (NSString *relationshipName in [relationshipsByName allKeys]) {
            NSSet *set = [self.managedObject valueForKey:relationshipName];

            TRResourceTableSection *section = [[TRResourceTableSection alloc] init];
            section.relationshipName = relationshipName;
            section.sectionName = relationshipName;
            section.relationship = YES;
            section.objects = [set allObjects];
            if (set.count) {
                id object = [set anyObject];
                section.titleKeyPath = [self.class titleKeyPathForManagedObject:object];
            }
            
            [sections addObject:section];
            
#if !__has_feature(objc_arc)
            [section release];
#endif
        }
        
        _sections = [[NSArray alloc] initWithArray:sections];
    }
    return _sections;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] objects].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections[section] sectionName];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        
#if !__has_feature(objc_arc)
        [cell autorelease];
#endif
    }
    // Configure the cell...
    
    TRResourceTableSection *section = self.sections[indexPath.section];
    id object = section.objects[indexPath.row];
    NSString *title;
    if (section.titleKeyPath) {
        title = [object valueForKeyPath:section.titleKeyPath];
    } else {
        title = object;
    }
    
    cell.textLabel.text = title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showViewControllerForObjectAtIndexPath:indexPath];
}

- (void)showViewControllerForObjectAtIndexPath:(NSIndexPath *)indexPath
{
    TRResourceTableSection *section = self.sections[indexPath.section];
    if (![section isRelationship]) {
        return;
    }
    
    TRManagedObject *managedObject = section.objects[indexPath.row];
    TRResourceViewController *viewController = [[TRResourceViewController alloc] initWithManagedObject:managedObject];
    [self.navigationController pushViewController:viewController animated:YES];
    
#if !__has_feature(objc_arc)
    [viewController release];
#endif
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end

@implementation TRResourceTableSection

@end