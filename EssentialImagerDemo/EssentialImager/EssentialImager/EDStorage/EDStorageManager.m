/*
 
 File: EDStorageManager.m
 Abstract: Modified to use directory paths from StandardPaths,
 add scale suffix to extension
 
 Copyright (c) 2012 Dillion Tan
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

//
//  EDStorageManager.m
//  storage
//
//  Created by Andrew Sliwinski on 6/23/12.
//  Copyright (c) 2012 DIY, Co. All rights reserved.
//

#import "EDStorageManager.h"
#import "EDStorageOperation.h"

//

@interface EDStorageManager ()
@property (nonatomic, retain) NSOperationQueue *queue;
@end

//

@implementation EDStorageManager

@synthesize queue = _queue;

#pragma mark - Init

+ (EDStorageManager *)sharedInstance
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 2;
    }
    return self;
}

#pragma mark - Public methods

/**
 * Generic persistence adapter for category extensions.
 *
 * @param {id} Data
 * @param {NSString} File extension (e.g. @"jpg")
 * @param {Location} File location (see interface for enum)
 * @param {block} Success block
 * @param {block} Failure block
 *
 * @return {void}
 */
- (void)persistData:(id)data withExtension:(NSString *)ext toLocation:(Location)location success:(void (^)(NSURL *, NSUInteger))success failure:(void (^)(NSError *))failure
{       
    // Create URL
    NSURL *url = [self createAssetFileURLForLocation:location withExtension:ext];
    
    // Perform operation
    EDStorageOperation *operation = [[EDStorageOperation alloc] initWithData:data forURL:url];
    [operation setCompletionBlock:^{
        if (operation.complete)
        {
            success(operation.target, operation.size);
        } else {
            if (operation.error != NULL)
            {
                failure(operation.error);
            } else {
                failure([NSError errorWithDomain:@"com.ed.storage" code:100 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:operation, @"operation", url, @"url", nil]]);
            }
        }
        
        //
        
        [operation setCompletionBlock:nil];     // Force dealloc
    }];
    [self.queue addOperation:operation];
    [operation release];
}

#pragma mark - Private methods

/**
 * Creates an asset file url (path) using location declaration and file extension.
 *
 * @param {Location} ENUM type
 * @param {NSString} Extension (e.g. @"jpg")
 *
 * @return {NSURL}
 */
- (NSURL *)createAssetFileURLForLocation:(Location)location withExtension:(NSString *)extension
{
    NSString *directoryPath = nil;
    NSString *assetName = nil;
    
    switch (location) {
        case kDirectoryPublic:
            directoryPath = [[NSFileManager defaultManager] publicDataPath];
            break;
        case kDirectoryPrivate:
            directoryPath = [[NSFileManager defaultManager] privateDataPath];
            break;
        case kDirectoryCache:
            directoryPath = [[NSFileManager defaultManager] cacheDataPath];
            break;
        case kDirectoryOffline:
            directoryPath = [[NSFileManager defaultManager] offlineDataPath];
            break;
        case kDirectoryTemporary:
            directoryPath = [[NSFileManager defaultManager] temporaryDataPath];
            break;
        case kDirectoryResource:
            directoryPath = [[NSFileManager defaultManager] resourcePath];
            break;
        default:
            [NSException raise:@"Invalid location value" format:@"Location %@ is invalid", location];
            break;
    }
    
    assetName = [NSString stringWithFormat:@"%@.%@", [[NSProcessInfo processInfo]     globallyUniqueString], extension];
    assetName = [assetName stringByAppendingScaleSuffix]; // add scale suffix to extension
    NSString *assetPath     = [directoryPath stringByAppendingPathComponent:assetName];
    
    return [NSURL fileURLWithPath:assetPath];
}

#pragma mark - Dealloc

- (void)releaseObjects
{
    [_queue release]; _queue = nil;
}

- (void)dealloc
{
    [self releaseObjects];
    [super dealloc];
}

@end