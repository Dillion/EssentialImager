//
//  EIOperationManager.h
//  EssentialImagerDemo
//
//  Created by Dillion Tan on 16/4/13.
//
//

#import <Foundation/Foundation.h>

@interface EIOperationManager : NSObject

@property (nonatomic, strong) NSOperationQueue *storageQueue;
@property (nonatomic, strong) NSMutableDictionary *storageOperationDictionary;

+ (EIOperationManager *)defaultManager;

- (void)saveImage:(UIImage *)image toPath:(NSString *)pathString withBlock:(void(^)(BOOL success))block;

@end
