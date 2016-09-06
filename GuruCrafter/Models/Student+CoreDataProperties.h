//
//  Student+CoreDataProperties.h
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 03.07.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Student.h"

NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSNumber *score;
@property (nullable, nonatomic, retain) NSSet<Course *> *courses;
@property (nullable, nonatomic, retain) NSSet<Course *> *lecturingCourses;

@end

@interface Student (CoreDataGeneratedAccessors)

- (void)addCoursesObject:(Course *)value;
- (void)removeCoursesObject:(Course *)value;
- (void)addCourses:(NSSet<Course *> *)values;
- (void)removeCourses:(NSSet<Course *> *)values;

- (void)addLecturingCoursesObject:(Course *)value;
- (void)removeLecturingCoursesObject:(Course *)value;
- (void)addLecturingCourses:(NSSet<Course *> *)values;
- (void)removeLecturingCourses:(NSSet<Course *> *)values;

@end

NS_ASSUME_NONNULL_END
