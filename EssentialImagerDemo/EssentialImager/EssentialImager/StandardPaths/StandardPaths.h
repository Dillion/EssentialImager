/*
 
 File: StandardPaths.h
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


#import <Foundation/Foundation.h>
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#endif


#ifndef UI_USER_INTERFACE_IDIOM
#define UI_USER_INTERFACE_IDIOM() UIUserInterfaceIdiomDesktop

typedef enum
{
    UIUserInterfaceIdiomPhone,
    UIUserInterfaceIdiomPad,
    UIUserInterfaceIdiomDesktop
}
UIUserInterfaceIdiom;

#endif

#ifndef __IPHONE_OS_VERSION_MAX_ALLOWED
#define SP_SCREEN_SCALE() ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]? [[NSScreen mainScreen] backingScaleFactor]: 1.0f)
#else
#define SP_SCREEN_SCALE() ([UIScreen mainScreen].scale)
#endif

@interface NSFileManager (StandardPaths)

- (NSString *)publicDataPath;
- (NSString *)privateDataPath;
- (NSString *)cacheDataPath;
- (NSString *)offlineDataPath;
- (NSString *)temporaryDataPath;
- (NSString *)resourcePath;

- (NSString *)pathForPublicFile:(NSString *)file;
- (NSString *)pathForPrivateFile:(NSString *)file;
- (NSString *)pathForCacheFile:(NSString *)file;
- (NSString *)pathForOfflineFile:(NSString *)file;
- (NSString *)pathForTemporaryFile:(NSString *)file;
- (NSString *)pathForResource:(NSString *)file;

- (NSString *)normalizedPathForFile:(NSString *)fileOrPath;

- (void)createFoldersIfRequired:(NSString *)folderPath;

@end


@interface NSString (StandardPaths)

- (NSString *)stringByAppendingInterfaceIdiomSuffix;
- (NSString *)stringByDeletingInterfaceIdiomSuffix;
- (NSString *)interfaceIdiomSuffix;
- (UIUserInterfaceIdiom)interfaceIdiom;

- (NSString *)stringByAppendingScaleSuffix;
- (NSString *)stringByDeletingScaleSuffix;
- (NSString *)scaleSuffix;
- (CGFloat)scale;

- (NSString *)stringByAppendingHDSuffix;
- (NSString *)stringByDeletingHDSuffix;
- (NSString *)HDSuffix;
- (BOOL)isHD;

@end