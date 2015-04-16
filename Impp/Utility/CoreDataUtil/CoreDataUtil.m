//
//  CoreDataUtil.m
//  IMChat
//
//  Created by Herxun on 2015/1/15.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//
#import <CoreData/CoreData.h>
#import "CoreDataUtil.h"

@interface CoreDataUtil()
+ (NSURL *)applicationDocumentsDirectory;
+ (NSURL *)applicationCacheDirectory;
@end

@implementation CoreDataUtil

#pragma mark - Get
+(int)getCountWithEntityName:(NSString *)name{
    NSManagedObjectContext *context = [self sharedContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    return (int)[context countForFetchRequest:request error:nil];
}

+(int)getCountWithEntityName:(NSString *)name
                   predicate:(NSPredicate *)predicate{
    NSManagedObjectContext *context = [self sharedContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    return (int)[context countForFetchRequest:request error:nil];
}

+(NSArray *)getWithEntityName:(NSString *)name
                    predicate:(NSPredicate *)predicate{
    NSManagedObjectContext *context = [self sharedContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    return [context executeFetchRequest:request error:nil];
}

+(NSArray *)getWithEntityName:(NSString *)name
                    predicate:(NSPredicate *)predicate
                   properties:(NSArray *)properties{
    NSManagedObjectContext *context = [self sharedContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:properties];
    return [context executeFetchRequest:request error:nil];
}


#pragma mark - Delete
+(void)deleteObject:(id)object {
    [[self sharedContext] deleteObject:(NSManagedObject *)object];
    [[self sharedContext] save:nil];
}

+(void)deleteAllWithEntityName:(NSString *)name {
    NSManagedObjectContext *context = [self sharedContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setIncludesPropertyValues:NO];
    for (NSManagedObject *object in [context executeFetchRequest:request error:nil]) {
        [context deleteObject:object];
    }
    NSError* error;
    [context save:&error];
    if (error) {
#ifdef DEBUG
        abort();
#endif
    }
}

+(void)deleteAllWithEntityName:(NSString *)name
                     predicate:(NSPredicate *)predicate {
    NSManagedObjectContext *context = [self sharedContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:name
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setIncludesPropertyValues:NO];
    for (NSManagedObject *object in [context executeFetchRequest:request error:nil]) {
        [context deleteObject:object];
    }
    [context save:nil];
}


#pragma mark - Singleton
+(id)sharedContext {
    static NSManagedObjectContext *context;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // create model
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Impp"
                                                  withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        // create coordinator
        NSURL *persistentStorestoreURLDoc = [[CoreDataUtil applicationDocumentsDirectory] URLByAppendingPathComponent:@"Impp.sqlite"];
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:persistentStorestoreURLDoc options:nil error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        
        
        // create context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
    });
    
    return context;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
