//
//  CoreDataViewController.h
//  GuruCrafter
//
//  Created by Maxim Kabyshev on 23.06.16.
//  Copyright © 2016 Maxim Kabyshev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DataManager.h"

@interface CoreDataViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
//- (void)insertNewObjectforEntityKey:(NSString *)key;

@end

