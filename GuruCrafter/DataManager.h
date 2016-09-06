//
//  DataManager.h
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 23.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Student, Course;

@interface DataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataManager *)sharedManager; // singleton method

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)generateAndAddStudents;
- (Student *)addRandomStudent;
- (Course *)addCourseWithName:(NSString*) name;

- (void)printAllObjects;
- (void)showStudents;

@end
