//
//  GGManagedObjectContext.m
//  CoreData
//
//  Created by Jake Peterson on 6/27/14.
//  Copyright (c) 2014 GumGum Inc. All rights reserved.
//

#import "GGManagedObjectContext.h"
#import <UIKit/UIKit.h>

@interface GGManagedObjectContext ()
@property (strong, nonatomic) NSManagedObjectModel *model;
@end

@implementation GGManagedObjectContext

static GGManagedObjectContext *_sharedContext = nil;

+ (GGManagedObjectContext *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedContext = [[GGManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    });
    
    return _sharedContext;
}

- (id)initWithConcurrencyType:(NSManagedObjectContextConcurrencyType)ct
{
    self = [super initWithConcurrencyType:ct];
    if (self)
    {
        [self setPersistentStoreCoordinator:self.storeCoordinator];
    }
    
    return self;
}

- (void)saveContext
{
    NSError *error = nil;
    if ([self hasChanges] && ![self save:&error])
    {
        NSLog(@"Managed object context error %@, %@", error, error.userInfo);
#ifdef DEBUG
        abort();
#endif
    }
}

- (NSManagedObjectModel *)model
{
    if (_model != nil) {
        return _model;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreData" withExtension:@"momd"];
    _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _model;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)storeCoordinator
{
    if (_storeCoordinator != nil) {
        return _storeCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreData.sqlite"];
    
    NSError *error = nil;
    _storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
    if (![_storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Persistent store coordinater error: %@, %@", error, [error userInfo]);
#ifdef DEBUG
        abort();
#endif
    }
    
    return _storeCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
