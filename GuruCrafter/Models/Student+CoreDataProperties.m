//
//  Student+CoreDataProperties.m
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 03.07.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Student+CoreDataProperties.h"
#import "Course.h"

@implementation Student (CoreDataProperties)

@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic score;
@dynamic courses;
@dynamic lecturingCourses;

@end
