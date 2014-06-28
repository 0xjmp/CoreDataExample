//
//  GGTableViewController.m
//  CoreData
//
//  Created by Jake Peterson on 6/27/14.
//  Copyright (c) 2014 GumGum Inc. All rights reserved.
//

#import "GGTableViewController.h"
#import <CoreData/CoreData.h>
#import "GGManagedObjectContext.h"
#import "Photo.h"

@interface GGTableViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *resultsController;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation GGTableViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.tableView = [[UITableView alloc] init];
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.view addSubview:self.tableView];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:[GGManagedObjectContext shared]];
        [request setEntity:entity];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                     managedObjectContext:[GGManagedObjectContext shared]
                                                                       sectionNameKeyPath:nil
                                                                                cacheName:nil];
        self.resultsController.delegate = self;
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"HH-MM-ss"];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPhoto)];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchPhotos];
    
    self.tableView.frame = self.view.bounds;
}

#pragma mark - Actions

- (void)addPhoto
{
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:[GGManagedObjectContext shared]];
    photo.url = [self.dateFormatter stringFromDate:[NSDate date]];
    photo.createdAt = [NSDate date];
    [[GGManagedObjectContext shared] saveContext];
}

- (void)fetchPhotos
{
    NSError *error = nil;
    BOOL success = [self.resultsController performFetch:&error];
    if (error)
    {
        NSLog(@"Error fetching results controller %@", error);
    }
    else
    {
//        NSAssert(success, @"Fetching results must succeed");
        NSLog(@"Fetched %ld objects", (unsigned long)self.resultsController.fetchedObjects.count);
    }
}

#pragma mark - UITableView dataSource/delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *className = NSStringFromClass([UITableViewCell class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:className];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:className];
    
    Photo *photo = [self.resultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.url;
    
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

@end
