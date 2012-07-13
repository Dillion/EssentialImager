/*
 
 File: NSData+Storage.m
 Abstract: Modified to add retrieval of image from file url and
 set scale based on suffix
 
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
//  NSData+Storage.m
//  storage
//
//  Created by Andrew Sliwinski on 6/24/12.
//  Copyright (c) 2012 DIY, Co. All rights reserved.
//

#import "NSData+Storage.h"
#import "EDStorageManager.h"

@implementation NSData (Storage)

+ (UIImage *)imageFromFile:(NSString *)filePath
{
    float scale = [filePath scale];
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]];
    
    if (!imageData)  {
        NSLog(@"file at %@ does not contain valid data", filePath);
        return nil;
    }
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    if (!image) {
        NSLog(@"could not initialize image from data");
        return nil;
    }
    
    return [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
}

- (void)persistToCacheWithExtension:(NSString *)extension success:(void (^)(NSURL *, NSUInteger))success failure:(void (^)(NSError *))failure
{
    [[EDStorageManager sharedInstance] persistData:self withExtension:extension toLocation:kDirectoryCache success:^(NSURL *url, NSUInteger size) {
        success(url, size);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)persistToTempWithExtension:(NSString *)extension success:(void (^)(NSURL *, NSUInteger))success failure:(void (^)(NSError *))failure
{
    [[EDStorageManager sharedInstance] persistData:self withExtension:extension toLocation:kDirectoryTemporary success:^(NSURL *url, NSUInteger size) {
        success(url, size);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)persistToDocumentsWithExtension:(NSString *)extension success:(void (^)(NSURL *, NSUInteger))success failure:(void (^)(NSError *))failure
{
    [[EDStorageManager sharedInstance] persistData:self withExtension:extension toLocation:kDirectoryPublic success:^(NSURL *url, NSUInteger size) {
        success(url, size);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end
