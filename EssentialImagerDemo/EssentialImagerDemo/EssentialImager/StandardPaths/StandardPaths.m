/*
 
 File: StandardPaths.m
 Abstract: Modified to add folder creation function, move scale
 define to header
 
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
//  StandardPaths.h
//
//  Version 1.2
//
//  Created by Nick Lockwood on 10/11/2011.
//  Copyright (C) 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from either of these locations:
//
//  http://charcoaldesign.co.uk/source/cocoa#standardpaths
//  https://github.com/nicklockwood/StandardPaths
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import "StandardPaths.h"
#include <sys/xattr.h>

@implementation NSFileManager (StandardPaths)

- (NSString *)publicDataPath
{
    @synchronized ([NSFileManager class])
    {
        static NSString *path = nil;
        if (!path)
        {
            //user documents folder
            path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            
            //retain path
            path = [[NSString alloc] initWithString:path];
        }
        return path;
    }
}

- (NSString *)privateDataPath
{
    @synchronized ([NSFileManager class])
    {
        static NSString *path = nil;
        if (!path)
        {
            //application support folder
            path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
            
#ifndef __IPHONE_OS_VERSION_MAX_ALLOWED
            
            //append application name on Mac OS
            NSString *identifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
            path = [path stringByAppendingPathComponent:identifier];
            
#endif
            
            //create the folder if it doesn't exist
            if (![self fileExistsAtPath:path])
            {
                [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            
            //retain path
            path = [[NSString alloc] initWithString:path];
        }
        return path;
    }
}

- (NSString *)cacheDataPath
{
    @synchronized ([NSFileManager class])
    {
        static NSString *path = nil;
        if (!path)
        {
            //cache folder
            path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            
#ifndef __IPHONE_OS_VERSION_MAX_ALLOWED
            
            //append application bundle ID on Mac OS
            NSString *identifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
            path = [path stringByAppendingPathComponent:identifier];
            
#endif
            
            //create the folder if it doesn't exist
            if (![self fileExistsAtPath:path])
            {
                [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            
            //retain path
            path = [[NSString alloc] initWithString:path];
        }
        return path;
    }
}

- (NSString *)offlineDataPath
{
    static NSString *path = nil;
    if (!path)
    {
        //offline data folder
        path = [[self privateDataPath] stringByAppendingPathComponent:@"Offline Data"];
        
        //create the folder if it doesn't exist
        if (![self fileExistsAtPath:path])
        {
            [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        if (&NSURLIsExcludedFromBackupKey && [NSURL instancesRespondToSelector:@selector(setResourceValue:forKey:error:)])
        {
            //use iOS 5.1 method to exclude file from backp
            NSURL *URL = [NSURL fileURLWithPath:path isDirectory:YES];
            [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:NULL];
        }
        else   
        {
            //use the iOS 5.0.1 mobile backup flag to exclude file from backp
            u_int8_t b = 1;
            setxattr([path fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
        }

        //retain path
        path = [[NSString alloc] initWithString:path];
    }
    return path;
}

- (NSString *)temporaryDataPath
{
    static NSString *path = nil;
    if (!path)
    {
        //temporary directory (shouldn't change during app lifetime)
        path = NSTemporaryDirectory();
        
        //apparently NSTemporaryDirectory() can return nil in some cases
        if (!path)
        {
            path = [[self cacheDataPath] stringByAppendingPathComponent:@"Temporary Files"];
        }
        
        //retain path
        path = [[NSString alloc] initWithString:path];
    }
    return path;
}

- (NSString *)resourcePath
{
    static NSString *path = nil;
    if (!path)
    {
        //bundle path
        path = [[NSString alloc] initWithString:[[NSBundle mainBundle] resourcePath]];
    }
    return path;
}

- (NSString *)pathForPublicFile:(NSString *)file
{
	return [[self publicDataPath] stringByAppendingPathComponent:file];
}

- (NSString *)pathForPrivateFile:(NSString *)file
{
    return [[self privateDataPath] stringByAppendingPathComponent:file];
}

- (NSString *)pathForCacheFile:(NSString *)file
{
    return [[self cacheDataPath] stringByAppendingPathComponent:file];
}

- (NSString *)pathForOfflineFile:(NSString *)file
{
    return [[self offlineDataPath] stringByAppendingPathComponent:file];
}

- (NSString *)pathForTemporaryFile:(NSString *)file
{
    return [[self temporaryDataPath] stringByAppendingPathComponent:file];
}

- (NSString *)pathForResource:(NSString *)file
{
    return [[self resourcePath] stringByAppendingPathComponent:file];
}

- (NSString *)normalizedPathForFile:(NSString *)fileOrPath
{
    @synchronized ([NSFileManager class])
    {
        //set up cache
        static NSCache *cache = nil;
        if (cache == nil)
        {
            cache = [[NSCache alloc] init];
        }
        
        //convert to absolute path
        NSString *path = fileOrPath;
        if (![path isAbsolutePath])
        {
            path = [[self resourcePath] stringByAppendingPathComponent:path];
        }
        
        //check cache
        NSString *cacheKey = path;
        BOOL cachable = [path hasPrefix:[self resourcePath]];
        if (cachable)
        {
            NSString *_path = [cache objectForKey:cacheKey];
            if (_path)
            {
                return [_path length]? _path: nil;
            }
        }
                    
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
        {
            //check for HD version
            NSString *_path = [path stringByAppendingHDSuffix];
            if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
            {
                path = _path;
            }
            else if ([[_path pathExtension] isEqualToString:@"png"])
            {
                //check for HiDPI tiff file
                _path = [[_path stringByDeletingPathExtension] stringByAppendingPathExtension:@"tiff"];
                if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
                {
                    path = _path;
                }
            }
            
            //check for scaled version
            if (SP_SCREEN_SCALE() > 1.0f)
            {
                NSString *_path = [path stringByAppendingScaleSuffix];
                if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
                {
                    path = _path;
                }
            }
        }
        else if (SP_SCREEN_SCALE() > 1.0f)
        {
            //check for HD version
            NSString *_path = [path stringByAppendingHDSuffix];
            if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
            {
                path = _path;
            }
            else
            {
                //check for scaled version
                NSString *_path = [path stringByAppendingScaleSuffix];
                if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
                {
                    path = _path;
                }
            }
        }
        
        //check for ipad/iphone version
        NSString *_path = [path stringByAppendingInterfaceIdiomSuffix];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
        {
            path = _path;
        }
        else if ([[_path pathExtension] isEqualToString:@"png"])
        {
            //check for HiDPI tiff file
            _path = [[_path stringByDeletingPathExtension] stringByAppendingPathExtension:@"tiff"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
            {
                path = _path;
            }
        }
        
        if ([[path pathExtension] isEqualToString:@"png"])
        {
            //check for HiDPI tiff file
            NSString *_path = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"tiff"];
            if ([[NSFileManager defaultManager] fileExistsAtPath:_path])
            {
                path = _path;
            }
        }
        else if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            //file doesn't exist
            path = nil;
        }
        
        //add to cache
        if (cachable)
        {
            [cache setObject:path ?: @"" forKey:cacheKey];
        }
                    
        //return path
        return path;
    }
}

- (void)createFoldersIfRequired:(NSString *)folderPath
{
    BOOL isDir;
    
    if (![self fileExistsAtPath:folderPath isDirectory:&isDir] && isDir)
    {
        [self createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

@end


@implementation NSString (StandardPaths)

- (NSString *)stringByAppendingInterfaceIdiomSuffix
{
    NSString *suffix = @"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        suffix = @"~iphone";
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        suffix = @"~ipad";
    }
    else
    {
        suffix = @"~mac";
    }
    NSString *extension = [self pathExtension];
    NSString *path = [[self stringByDeletingPathExtension] stringByAppendingString:suffix];
    return [extension length]? [path stringByAppendingPathExtension:extension]: path;
}

- (NSString *)stringByDeletingInterfaceIdiomSuffix
{
    NSString *suffix = [self interfaceIdiomSuffix];
    if ([suffix length])
    {
        NSString *extension = [self pathExtension];
        NSString *path = [self stringByDeletingPathExtension];
        path = [path substringToIndex:[path length] - [suffix length]];
        return [extension length]? [path stringByAppendingPathExtension:extension]: path;
    }
    return self;
}

- (NSString *)interfaceIdiomSuffix
{
    NSString *path = [self stringByDeletingPathExtension];
    for (NSString *suffix in [NSArray arrayWithObjects:@"~iphone", @"~ipad", @"~mac", nil])
    {
        if ([path hasSuffix:suffix]) return suffix;
    }
    return @"";
}

- (UIUserInterfaceIdiom)interfaceIdiom
{
    NSString *suffix = [self interfaceIdiomSuffix];
    if ([suffix isEqualToString:@"~ipad"])
    {
        return UIUserInterfaceIdiomPad;
    }
    else if ([suffix isEqualToString:@"~iphone"])
    {
        return UIUserInterfaceIdiomPhone;
    }
    return UI_USER_INTERFACE_IDIOM();
}

- (NSString *)stringByAppendingScaleSuffix
{
    if (SP_SCREEN_SCALE() > 1.0f)
    {
        NSString *extension = [self pathExtension];
        NSString *deviceSuffix = [self interfaceIdiomSuffix];
        NSString *scaleSuffix = [NSString stringWithFormat:@"@%ix", (int)SP_SCREEN_SCALE()];
        NSString *path = [[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix];
        path = [path stringByAppendingFormat:@"%@%@", scaleSuffix, deviceSuffix];
        return [extension length]? [path stringByAppendingPathExtension:extension]: path;
    }
    return self;
}

- (NSString *)stringByDeletingScaleSuffix
{
    NSString *scaleSuffix = [self scaleSuffix];
    if ([scaleSuffix length])
    {
        NSString *extension = [self pathExtension];
        NSString *deviceSuffix = [self interfaceIdiomSuffix];
        NSString *path = [[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix];
        path = [[path substringToIndex:[path length] - [scaleSuffix length]] stringByAppendingString:deviceSuffix];
        return [extension length]? [path stringByAppendingPathExtension:extension]: path;
    }
    return self;
}

- (NSString *)scaleSuffix
{
    //note: this isn't very robust as it only handles single-digit integer scales
    //for the forseeable future though, it's unlikely that we'll have to worry about that
    NSString *path = [[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix];
    if ([path length] >= 3)
    {
        NSString *scaleSuffix = [path substringFromIndex:[path length] - 3];
        if ([[scaleSuffix substringToIndex:1] isEqualToString:@"@"] &&
            [[scaleSuffix substringFromIndex:2] isEqualToString:@"x"])
        {
            return scaleSuffix;
        }
    }
    return @"";
}

- (CGFloat)scale
{
    NSString *scaleSuffix = [self scaleSuffix];
    if ([scaleSuffix length])
    {
        return [[scaleSuffix substringWithRange:NSMakeRange(1, 1)] floatValue];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [self isHD])
    {
        return 2.0f;
    }
    return 1.0f;
}

- (NSString *)stringByAppendingHDSuffix
{
    if (SP_SCREEN_SCALE() > 1.0f || UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone)
    {
        NSString *extension = [self pathExtension];
        NSString *deviceSuffix = [self interfaceIdiomSuffix];
        NSString *scaleSuffix = [self scaleSuffix];
        NSString *path = [[[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix] stringByDeletingScaleSuffix];
        path = [path stringByAppendingFormat:@"-hd%@%@", scaleSuffix, deviceSuffix];
        return [extension length]? [path stringByAppendingPathExtension:extension]: path;
    }
    return self;
}

- (NSString *)stringByDeletingHDSuffix
{
    NSString *HDSuffix = [self HDSuffix];
    if ([HDSuffix length])
    {
        NSString *extension = [self pathExtension];
        NSString *deviceSuffix = [self interfaceIdiomSuffix];
        NSString *scaleSuffix = [self scaleSuffix];
        NSString *path = [[[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix] stringByDeletingScaleSuffix];
        path = [path substringToIndex:[path length] - [HDSuffix length]];
        path = [path stringByAppendingFormat:@"%@%@", scaleSuffix, deviceSuffix];
        return [extension length]? [path stringByAppendingPathExtension:extension]: path;
    }
    return self;
}

- (NSString *)HDSuffix
{
    NSString *path = [[[self stringByDeletingPathExtension] stringByDeletingInterfaceIdiomSuffix] stringByDeletingScaleSuffix];
    if ([path hasSuffix:@"-hd"])
    {
        return @"-hd";
    }
    return @"";
}

- (BOOL)isHD
{
    return [[self HDSuffix] length] > 0;
}

@end