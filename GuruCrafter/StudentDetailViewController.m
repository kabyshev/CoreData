//
//  StudentDetailViewController.m
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 25.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "StudentDetailViewController.h"
#import "CourseDetailViewController.h"
#import "StudentCell.h"
#import "Student.h"
#import "Course.h"

#define courseIndex [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1]

NS_ENUM(NSUInteger, SectionName) {
    studentSection = 0,
    coursesSection = 1,
    lecturerSection = 2
};

static const NSInteger labelCounts = 3;
static NSString* labels[] = {
    @"First Name", @"Last Name", @"E-mail"
};

@interface StudentDetailViewController ()

@property (nonatomic, strong) NSMutableArray *dataFromTextFields;
@property (nonatomic, assign) BOOL infoEditing;
@property (nonatomic, strong) NSArray *numberOfStudentsInCourses;
@property (nonatomic, strong) NSArray *lecturingCourses;

@end

@implementation StudentDetailViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataFromTextFields = [NSMutableArray array];
    for (int i = 0; i < labelCounts; i++) {
        [self.dataFromTextFields addObject:@""];
    }
    
    if (!self.addNewStudent) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", self.student.firstName, self.student.lastName];
    }
    else self.navigationItem.title = @"New Student";
    
    self.lecturingCourses = [self.student.lecturingCourses allObjects];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark - CoreData Methods

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription* description = [NSEntityDescription entityForName:@"Course"
                                                   inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"students CONTAINS %@", self.student];
    
    [fetchRequest setEntity:description];
    [fetchRequest setFetchBatchSize:30];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:@[nameDescriptor]];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    self.numberOfStudentsInCourses = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case studentSection:
            return labelCounts + 1;
            break;
            
        case coursesSection:
            return [self.student.courses count];
            break;
            
        case lecturerSection:
            return [self.student.lecturingCourses count];
            break;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.student.courses count] == 0 || self.addNewStudent) {
        return 1;
    }
    else if ([self.student.lecturingCourses count] > 0) {
        return 3;
    }
    else return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"DetailCell";
    static NSString *deleteIdentifier = @"deleteIdentifier";
    static NSString *coursesIdentifier = @"coursesIdentifier";
    //static NSString *lecturerIdentifier = @"lecturerIdentifier";
    
    if (indexPath.section == coursesSection) {
        StudentCell *cell = [tableView dequeueReusableCellWithIdentifier:coursesIdentifier];
        
        if (!cell) {
            cell = [[StudentCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:coursesIdentifier];
        }
        Course *course = [self.fetchedResultsController objectAtIndexPath:courseIndex];
        cell.courseName.text = [NSString stringWithFormat:@"%@", course.name];
    
        for (NSInteger i = 0; i < [self.numberOfStudentsInCourses count]; i++) {
            NSString *currentName = [self.numberOfStudentsInCourses[i] name];
            if ([course.name isEqualToString:currentName]) {
                cell.studentsCount.text = [NSString stringWithFormat:@"%ld more stud.",
                                    [[self.numberOfStudentsInCourses[i] students] count] - 1];
            }
        }
        return cell;
    }
    
    if (indexPath.section == lecturerSection) {
        StudentCell *cell = [tableView dequeueReusableCellWithIdentifier:coursesIdentifier];
        
        if (!cell) {
            cell = [[StudentCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:coursesIdentifier];
        }
        
        Course *course = self.lecturingCourses[indexPath.row];
        cell.courseName.text = [NSString stringWithFormat:@"%@", course.name];
        cell.studentsCount.text = [NSString stringWithFormat:@"%ld students", [course.students count]];
    
        return cell;
    }
    
    if (indexPath.row != labelCounts) {
        StudentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[StudentCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:identifier];
        }
        cell.label.text = labels[indexPath.row];
        switch (indexPath.row) {
            case studentSection:
                cell.textField.text = self.student.firstName;
                break;
                
            case coursesSection:
                cell.textField.text = self.student.lastName;
                break;
                
            case lecturerSection:
                cell.textField.text = self.student.email;
                break;
        }
        return cell;
    }
    
    StudentCell *cell = [tableView dequeueReusableCellWithIdentifier:deleteIdentifier];
    if (!cell) {
        cell = [[StudentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:deleteIdentifier];
    }
    if (self.addNewStudent) {
        [cell.deleteButton setTitle:@"Add new student" forState:UIControlStateNormal];
        [cell.deleteButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    }
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == coursesSection) {
        return [NSString stringWithFormat:@"Studying courses: %ld", [self.student.courses count]];
    }
    if (section == lecturerSection) {
        return [NSString stringWithFormat:@"Lecturing courses: %ld", [self.student.lecturingCourses count]];
    }
    if (self.student.firstName && self.student.lastName)
        return @"Student Info";
    else {
        return @"New student";
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == studentSection || indexPath.section == 2) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        if (indexPath.section == coursesSection) {
            [self.student removeCoursesObject:[self.fetchedResultsController objectAtIndexPath:courseIndex]];
        }
        else if (indexPath.section == lecturerSection) {
            [self.student removeLecturingCoursesObject:self.lecturingCourses[indexPath.row]];
        }
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, localizedDescription: %@, userInfo: %@", error, [error localizedDescription], [error userInfo]);
            abort();
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if ([[segue identifier] isEqualToString:@"showCourse"] && indexPath.section == coursesSection) {
        Course *course = [self.fetchedResultsController objectAtIndexPath:courseIndex];
        CourseDetailViewController *vc = [segue destinationViewController];
        vc.course = course;
    }
    else if ([[segue identifier] isEqualToString:@"showCourse"] && indexPath.section == lecturerSection) {
        Course *course = self.lecturingCourses[indexPath.row];
        CourseDetailViewController *vc = [segue destinationViewController];
        vc.course = course;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    UIView *cellView = (UIView *)[textField superview];
    UITableViewCell *cell = (UITableViewCell *)[cellView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.dataFromTextFields[indexPath.row] = textField.text;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.infoEditing || self.addNewStudent)
        return YES;
    else return NO;
}

#pragma mark - Actions

- (IBAction)actionEdit:(UIBarButtonItem *)sender {
    
    self.navigationItem.rightBarButtonItem = self.saveButton;
    self.infoEditing = YES;
}

- (IBAction)actionSave:(UIBarButtonItem *)sender {

    if (![self.dataFromTextFields[0] isEqual:@""])
        [self.student setValue:self.dataFromTextFields[0] forKey:@"firstName"];
    if (![self.dataFromTextFields[1] isEqual:@""])
        [self.student setValue:self.dataFromTextFields[1] forKey:@"lastName"];
    if (![self.dataFromTextFields[2] isEqual:@""])
        [self.student setValue:self.dataFromTextFields[2] forKey:@"email"];
    
    [[DataManager sharedManager] saveContext];
    self.infoEditing = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionAddOrDelete:(UIButton *)sender {
    
    if (self.addNewStudent) {
        NSManagedObject* object =
        [NSEntityDescription insertNewObjectForEntityForName:@"Student"
                                      inManagedObjectContext:self.managedObjectContext];
        [object setValue:self.dataFromTextFields[0] forKey:@"firstName"];
        [object setValue:self.dataFromTextFields[1] forKey:@"lastName"];
        [object setValue:self.dataFromTextFields[2] forKey:@"email"];
    }
    else {
        [self.managedObjectContext deleteObject:self.student];
    }
    [[DataManager sharedManager] saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (indexPath.section == coursesSection) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
    }
    
    UITableView *tableView = self.tableView;
    
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

- (void)deleteAll {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Student"];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    NSError *deleteError = nil;
    [[[DataManager sharedManager] persistentStoreCoordinator] executeRequest:delete
                                                                 withContext:self.managedObjectContext
                                                                       error:&deleteError];
    [[DataManager sharedManager] saveContext];
}

@end