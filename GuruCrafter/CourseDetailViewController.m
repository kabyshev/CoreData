//
//  GroupsDetailViewController.m
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 26.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "CourseDetailViewController.h"
#import "StudentDetailViewController.h"
#import "StudentListViewController.h"
#import "LecturersListViewController.h"
#import "CourseCell.h"
#import "Course.h"
#import "Student.h"

#define shearIndex [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section - 1]
#define lectureCell 1

static const NSInteger labelCounts = 3;
static NSString* labels[] = {
    @"Course name", @"Subject", @"Sector"
};

@interface CourseDetailViewController ()

@property (nonatomic, strong) NSMutableArray *dataFromTextFields;
@property (nonatomic, assign) BOOL infoEditing;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end

@implementation CourseDetailViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataFromTextFields = [NSMutableArray array];
    for (int i = 0; i < labelCounts; i++) {
        [self.dataFromTextFields addObject:@""];
    }
    
    if (!self.addNewCourse) {
        self.navigationItem.title = self.course.name;
    }
    else
        self.navigationItem.title = @"New Course";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)dealloc {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}

#pragma mark - CoreData Methods

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* description = [NSEntityDescription entityForName:@"Student"
                                                   inManagedObjectContext:self.managedObjectContext];
    if (self.course) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"courses CONTAINS %@", self.course];
        [fetchRequest setPredicate:predicate];
    }
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [self.course removeStudentsObject:[self.fetchedResultsController objectAtIndexPath:shearIndex]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, localizedDescription: %@, userInfo: %@", error, [error localizedDescription], [error userInfo]);
            abort();
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return labelCounts + lectureCell + 1;
    }
    else if ([self.course.students count] > 0) {
        return [self.course.students count] + 1;
    }
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"CourseDetailCell";
    static NSString *deleteIdentifier = @"deleteIdentifier";
    static NSString *studentIdentifier = @"studentCell";
    static NSString *lectuterIdentifier = @"lecturerCell";
    
    if (indexPath.section == 1) { // if it's section for students
        if (indexPath.row == 0) {
            CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:deleteIdentifier];
            if (!cell) {
                cell = [[CourseCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:deleteIdentifier];
            }
            [cell.deleteButton setTitle:@"Add students to this course" forState:UIControlStateNormal];
            [cell.deleteButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
            return cell;
        }
        
        CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:studentIdentifier]; // print students in this course
        if (!cell) {
            cell = [[CourseCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:identifier];
        }
        Student *student = [self.fetchedResultsController objectAtIndexPath:shearIndex];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        cell.scoreLabel.text = [NSString stringWithFormat:@"%1.2f", [student.score floatValue]];
        
        return cell;
    }
    
    if (indexPath.row == 3 && indexPath.section == 0) {
        CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:lectuterIdentifier];
        if (!cell) {
            cell = [[CourseCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:lectuterIdentifier];
        }
        NSString *lecturerName = [NSString stringWithFormat:@"%@ %@",
                                  self.course.lecturer.firstName, self.course.lecturer.lastName];
        if (self.course.lecturer) {
            cell.teacherName.text = lecturerName;
        }
        else
            cell.teacherName.text = @"Choose lecturer";
        
        return cell;
    }

    if (indexPath.row != labelCounts + lectureCell) {
        CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[CourseCell alloc] initWithStyle:UITableViewCellStyleValue1
                                     reuseIdentifier:identifier];
        }
        cell.label.text = labels[indexPath.row];
        switch (indexPath.row) {
            case 0:
                cell.textField.text = self.course.name;
                break;
                
            case 1:
                cell.textField.text = self.course.subject;
                break;
                
            case 2:
                cell.textField.text = self.course.sector;
                break;
                
            case 3:
                cell.textField.text = [NSString stringWithFormat:@"%@ %@", self.course.lecturer.firstName,
                                                                           self.course.lecturer.lastName];
                break;
        }
        return cell;
    }
    
    CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:deleteIdentifier];
    if (!cell) {
        cell = [[CourseCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:deleteIdentifier];
    }
    if (self.addNewCourse) {
        [cell.deleteButton setTitle:@"Add new course" forState:UIControlStateNormal];
        [cell.deleteButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        return [NSString stringWithFormat:@"Students signed to this course: %ld", [self.course.students count]];
    }
    else return @"Course Info";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && indexPath.row) { // segue ONLY for students list
        [self performSegueWithIdentifier:@"showStudentInfo" sender:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([[segue identifier] isEqualToString:@"showStudentInfo"]) {
        
        Student *student = [self.fetchedResultsController objectAtIndexPath:shearIndex];
        StudentDetailViewController *vc = [segue destinationViewController];
        
        vc.addNewStudent = NO;
        vc.student = student;
    }
    else if ([[segue identifier] isEqualToString:@"addStudentToCourse"]) {
        
        UINavigationController *nc = [segue destinationViewController];
        StudentListViewController *vc = (StudentListViewController *)[nc topViewController];
        vc.studentsInCourse = [NSMutableArray arrayWithArray:[self.course.students allObjects]];
        vc.course = self.course;
    }
    else if ([[segue identifier] isEqualToString:@"chooseLecturer"]) {
        UINavigationController *nc = [segue destinationViewController];
        LecturersListViewController *vc = (LecturersListViewController *)[nc topViewController];
        vc.course = self.course;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIView *cellView = (UIView *)[textField superview];
    UITableViewCell *cell = (UITableViewCell *)[cellView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.dataFromTextFields[indexPath.row] = textField.text;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.infoEditing || self.addNewCourse)
        return YES;
    else return NO;
}

#pragma mark - Actions

- (IBAction)actionAddOrDelete:(UIButton *)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    if (self.addNewCourse) {
        NSManagedObject* object =
        [NSEntityDescription insertNewObjectForEntityForName:@"Course"
                                      inManagedObjectContext:self.managedObjectContext];
        [object setValue:self.dataFromTextFields[0] forKey:@"name"];
        [object setValue:self.dataFromTextFields[1] forKey:@"subject"];
        [object setValue:self.dataFromTextFields[2] forKey:@"sector"];
        
    }
    else if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"addStudentToCourse" sender:self];
    }
    else {
        [self.managedObjectContext deleteObject:self.course];
    }
    [[DataManager sharedManager] saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionEdit:(UIBarButtonItem *)sender {
    self.navigationItem.rightBarButtonItem = self.saveButton;
    self.infoEditing = YES;
}

- (IBAction)actionSave:(UIBarButtonItem *)sender {
    
    if (![self.dataFromTextFields[0] isEqual:@""])
        [self.course setValue:self.dataFromTextFields[0] forKey:@"name"];
    if (![self.dataFromTextFields[1] isEqual:@""])
        [self.course setValue:self.dataFromTextFields[1] forKey:@"subject"];
    if (![self.dataFromTextFields[2] isEqual:@""])
        [self.course setValue:self.dataFromTextFields[2] forKey:@"sector"];
    
    [[DataManager sharedManager] saveContext];
    self.infoEditing = NO;
    [self.navigationController popViewControllerAnimated:YES];
    if (!self.addNewCourse) {
        [self.tableView reloadData];
    }
}

#pragma mark - Table Updates

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    if (indexPath)
        indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section + 1];
    if (newIndexPath)
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section + 1];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.row == 0 || indexPath.section == 0) {
        return NO;
    }
    return YES;
}

/*
- (NSIndexPath *)findIndexPathForButton:(UIButton *)sender {
    UIView *tempView = sender;
    while (![tempView isKindOfClass:[UITableViewCell class]]) {
        tempView = tempView.superview;
    }
    
    UITableViewCell *chosingCell = (UITableViewCell *)tempView;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:chosingCell];
    
    return indexPath;
}*/

@end
