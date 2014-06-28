//
//  GGManagedObjectContext.h
//  CoreData
//
//  Created by Jake Peterson on 6/27/14.
//  Copyright (c) 2014 GumGum Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface GGManagedObjectContext : NSManagedObjectContext
@property (strong, nonatomic) NSPersistentStoreCoordinator *storeCoordinator;
+ (GGManagedObjectContext *)shared;
- (void)saveContext;
@end
