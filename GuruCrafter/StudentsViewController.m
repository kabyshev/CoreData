//
//  StudentsViewController.m
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 24.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "StudentsViewController.h"
#import "StudentDetailViewController.h"
#import "StudentCell.h"

@interface StudentsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation StudentsViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    NSEntityDescription* description = [NSEntityDescription entityForName:@"Student"
                                                   inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:description];
    [fetchRequest setFetchBatchSize:30];
    
    NSSortDescriptor* firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName"
                                                                        ascending:YES];
    NSSortDescriptor* lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName"
                                                                       ascending:YES];
    [fetchRequest setSortDescriptors:@[firstNameDescriptor, lastNameDescriptor]];
    
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

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"Cell";
    StudentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[StudentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:identifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Student *student = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    StudentDetailViewController *vc = [segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"showStudents"]) {
        vc.addNewStudent = NO;
        vc.student = student;
    }
    
    else if ([[segue identifier] isEqualToString:@"addNewStudent"]) {
        vc.addNewStudent = YES;
        vc.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Help Methods

- (void)configureCell:(StudentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Student *student = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.studentName.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([student.lecturingCourses count] > 0) {
        cell.studentName.textColor = [UIColor blueColor];
        cell.studentScore.text = @"L";
    } else {
        cell.studentName.textColor = [UIColor blackColor];
        cell.studentScore.text = [NSString stringWithFormat:@"%1.2f", [student.score floatValue]];
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
