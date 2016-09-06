//
//  GroupsViewController.m
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 26.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "CourseViewController.h"
#import "Course.h"
#import "CourseDetailViewController.h"

@interface CourseViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation CourseViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CoreData Methods

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"Course"
                                                   inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:description];
    
    NSSortDescriptor* name = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                         ascending:YES];
    [fetchRequest setSortDescriptors:@[name]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Course *group = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", group.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld stud.", [group.students count]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:identifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //StudentDetailViewController* vc = [[StudentDetailViewController alloc] init];
    //[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    CourseDetailViewController *vc = [segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"showCourseInfo"]) {
        vc.course = course;
        
    }
    else if ([[segue identifier] isEqualToString:@"addCourse"]) {
        
        vc.navigationItem.rightBarButtonItem = nil;
        vc.addNewCourse = YES;
    }
}

#pragma mark - Actions

- (IBAction)actionEdit:(UIBarButtonItem *)sender {
    [self.tableView setEditing:YES animated:YES];
    self.navigationItem.leftBarButtonItem = self.doneButton;
}

- (IBAction)actionDoneButton:(UIBarButtonItem *)sender {
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = self.editButton;
}

@end
