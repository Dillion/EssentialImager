//
//  EIOperationManager.m
//  EssentialImagerDemo
//
//  Created by Dillion Tan on 16/4/13.
//
//

#import "EIOperationManager.h"

@implementation EIOperationManager

@synthesize storageQueue;
@synthesize storageOperationDictionary;

+ (EIOperationManager *)defaultManager
{
	static dispatch_once_t pred = 0;
    __strong static id _defaultManager = nil;
    dispatch_once(&pred, ^{
        _defaultManager = [[self alloc] init];
    });
    return _defaultManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        storageQueue = [[NSOperationQueue alloc] init];
        storageOperationDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

// assume we are saving PNG
- (void)saveImage:(UIImage *)image toPath:(NSString *)pathString withBlock:(void(^)(BOOL success))block
{
    if (![storageOperationDictionary objectForKey:pathString]) {
        __block UIImage *imageToSave = image;
        
        NSBlockOperation *writeBlockOperation = [[NSBlockOperation alloc] init];
        __weak NSBlockOperation *weakSelf = writeBlockOperation;
        
        [writeBlockOperation addExecutionBlock:^{
            NSData *imageData = UIImagePNGRepresentation(imageToSave);
            
            if (!weakSelf.isCancelled) {
                
                [imageData writeToFile:pathString atomically:YES];
                
                if (!weakSelf.isCancelled) {
                    [storageOperationDictionary removeObjectForKey:pathString];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(YES);
                    });
                } else {
                    block(NO);
                }
            } else {
                block(NO);
            }
        }];
        
        [storageOperationDictionary setObject:writeBlockOperation forKey:pathString];
        
        [storageQueue addOperation:writeBlockOperation];
    } else { // already queued for writing
        block(NO);
    }
}

@end
