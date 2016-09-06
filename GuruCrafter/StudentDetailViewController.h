//
//  StudentDetailViewController.h
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 25.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "CoreDataViewController.h"
@class Student;

@interface StudentDetailViewController : CoreDataViewController

@property (nonatomic, strong) Student *student;
@property (nonatomic, assign) BOOL addNewStudent;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end
