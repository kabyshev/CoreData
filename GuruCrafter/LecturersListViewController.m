//
//  LecturersListViewController.m
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 01.07.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "LecturersListViewController.h"
#import "Student.h"
#import "Course.h"

@interface LecturersListViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) NSMutableArray *selectedCells;
@property (nullable, nonatomic, retain) Student *selectedLecturer;

@end

@implementation LecturersListViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add a lecturer";
    self.saveButton.enabled = NO;
    self.selectedCells = [NSMutableArray array];
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
    
    Student *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UITableViewCell *chosenCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.selectedCells count] == 1 && ![chosenCell isEqual:[self.selectedCells firstObject]]) {
        for (UITableViewCell *cell in self.selectedCells) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [self.selectedCells removeAllObjects];
        [self.selectedCells addObject:chosenCell];
        self.selectedLecturer = person;
        chosenCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else if ([chosenCell isEqual:[self.selectedCells firstObject]] || [self.course.lecturer isEqual:person]){
        
        self.selectedLecturer = nil;
        chosenCell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedCells removeAllObjects];
    }
    else {
        chosenCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedCells addObject:chosenCell];
        self.selectedLecturer = person;
    }
}

#pragma mark - Help Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Student *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.2f", [person.score floatValue]];

    if ([self.course.lecturer isEqual:person]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //[self.selectedCells addObject:cell];
    } else cell.accessoryType = UITableViewCellAccessoryNone;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (IBAction)actionCancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSave:(UIBarButtonItem *)sender {
    
    if (self.selectedLecturer) {
        [self.course setLecturer:self.selectedLecturer];
        [self.course removeStudentsObject:self.selectedLecturer];
    } else {
        [self.course setLecturer:nil];
    }

    [[DataManager sharedManager] saveContext];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
