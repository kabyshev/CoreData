//
//  Lecturer+CoreDataProperties.h
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 02.07.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Lecturer.h"

NS_ASSUME_NONNULL_BEGIN

@interface Lecturer (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) Course *course;

@end

NS_ASSUME_NONNULL_END
