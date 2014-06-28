//
//  Photo.h
//  CoreData
//
//  Created by Jake Peterson on 6/27/14.
//  Copyright (c) 2014 GumGum Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSDate *createdAt;

@end
