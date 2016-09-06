//
//  LecturersListViewController.h
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 01.07.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import "CoreDataViewController.h"

@interface LecturersListViewController : CoreDataViewController

@property (nonatomic, strong) Student *lecturer;
@property (nonatomic, strong) Course *course;

@end
