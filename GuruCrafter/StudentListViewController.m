//
//  StudentListViewController.m
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 28.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "StudentListViewController.h"
#import "Student.h"
#import "Course.h"
#import "DataManager.h"

@interface StudentListViewController () <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, strong) NSMutableSet *removedStudents;
@property (nonatomic, strong) NSMutableSet *selectedStudents;

@end

@implementation StudentListViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add students";
    self.saveButton.enabled = NO;
    self.removedStudents = [NSMutableSet set];
    self.selectedStudents = [NSMutableSet set];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CoreData Methods

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description = [NSEntityDescription entityForName:@"Student"
                                                   inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:description];
    [fetchRequest setFetchBatchSize:30];
    
    NSSortDescriptor* firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName"
                                                                        ascending:YES];
    NSSortDescriptor* lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName"
                                                                       ascending:YES];
    [fetchRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.saveButton.enabled = YES;
    
    Student *student = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *chosenCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.studentsInCourse containsObject:student]) {
        chosenCell.accessoryType = UITableViewCellAccessoryNone;
        [self.removedStudents addObject:student];
        [self.studentsInCourse removeObject:student];
    }
    else {
        chosenCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.studentsInCourse addObject:student];
        [self.selectedStudents addObject:student];
        [self.removedStudents removeObject:student];
    }
}

#pragma mark - Help Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Student *student = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.2f", [student.score floatValue]];
    
    if ([self.studentsInCourse containsObject:student]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Actions

- (IBAction)actionCancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSave:(UIBarButtonItem *)sender {

    NSMutableSet *controlSet = [NSMutableSet set];
    [controlSet addObjectsFromArray:[self.selectedStudents allObjects]];
    [controlSet addObjectsFromArray:[self.removedStudents allObjects]];

    for (Student *student in controlSet) {
        if ([self.removedStudents containsObject:student]) {
            [self.course removeStudentsObject:student];
        }
        else {
            [self.course addStudentsObject:student];
        }
    }
    [[DataManager sharedManager] saveContext];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
