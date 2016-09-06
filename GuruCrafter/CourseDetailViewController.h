//
//  CourseDetailViewController.h
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 26.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "CourseViewController.h"

@interface CourseDetailViewController : CourseViewController

@property (nonatomic, assign) BOOL addNewCourse;
@property (nonatomic, strong) Course *course;


@end
