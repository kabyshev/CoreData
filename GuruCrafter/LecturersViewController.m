//
//  LecturersViewController.m
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 02.07.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "LecturersViewController.h"
#import "Student.h"
#import "StudentDetailViewController.h"
#import "Course.h"

@interface LecturersViewController ()

@property (nonatomic, strong) NSMutableSet *lecturingCourses;

@end

@implementation LecturersViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //for (Course *course in self.student)
    //self.lecturingCourses = [NSMutableSet setWithSet:<#(nonnull NSSet *)#>];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lecturer != %@", nil];
    [fetchRequest setEntity:description];
    [fetchRequest setFetchBatchSize:30];
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *sectionNameDescriptor =
                    [[NSSortDescriptor alloc] initWithKey:@"subject" ascending:YES]; // error! keypath lecturingCoursesSubjects not found in entity <NSSQLEntity Student id=3>
    
    NSSortDescriptor* firstNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                        ascending:YES];
    //NSSortDescriptor* lastNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName"
                                                                      // ascending:YES];
    [fetchRequest setSortDescriptors:@[sectionNameDescriptor, firstNameDescriptor]];

    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:@"subject"
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    NSMutableString *badSymbols = [[NSMutableString alloc] initWithString:@"#$%^&='\"*(){}[]:;></§±`~\\/|\n"];
    NSCharacterSet *invalidationSet = [NSCharacterSet characterSetWithCharactersInString:badSymbols];
    NSString *newString = [[[sectionInfo name] componentsSeparatedByCharactersInSet:invalidationSet] componentsJoinedByString:@""];
    
//    NSString *testString = [newString substringToIndex:1];
//
//    while ([testString isEqualToString:@" "]) {
//        newString = [newString substringFromIndex:1];
//        testString = [newString substringToIndex:1];
//    }
    
    NSCharacterSet *spaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != ''"];
    NSArray *tempArray = [[newString componentsSeparatedByCharactersInSet:spaces] filteredArrayUsingPredicate:predicate];
    newString = [tempArray componentsJoinedByString:@" "];

    return newString;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"showLecturer" sender:self];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    StudentDetailViewController *vc = [segue destinationViewController];
    
    if ([[segue identifier] isEqualToString:@"showLecturer"]) {
        vc.student = course.lecturer;
    }
}

#pragma mark - Help Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Course *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", course.lecturer.firstName, course.lecturer.lastName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld courses  ", [course.lecturer.lecturingCourses count]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
