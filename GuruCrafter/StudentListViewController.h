//
//  StudentListViewController.h
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 28.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "StudentsViewController.h"
@class Student, Course;

@interface StudentListViewController : CoreDataViewController

@property (nonatomic, strong) Student *student;
@property (nonatomic, strong) Course *course;
@property (nonatomic, strong) NSMutableArray *studentsInCourse;

@end
