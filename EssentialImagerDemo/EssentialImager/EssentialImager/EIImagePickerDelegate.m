/*
 
 File: EIImagePickerDelegate.m
 Abstract: ARC-ed image picker delegate with blocks
 
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

#import "EIImagePickerDelegate.h"

@interface EIImagePickerDelegate ()

@end

@implementation EIImagePickerDelegate

@synthesize imagePicker;
@synthesize pickerCompletionBlock;
@synthesize pickerCancelBlock;

- (id)init
{
    self = [super init];
    if (self) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        // configure source type just before presenting
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)presentFromController:(UIViewController *)aController withSourceType:(UIImagePickerControllerSourceType)sourceType
{
    // media types is still image by default, so we don't need to change it here
    imagePicker.sourceType = sourceType;
    [aController presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [aPicker dismissModalViewControllerAnimated:YES];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (image && pickerCompletionBlock) {
        pickerCompletionBlock(image);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)aPicker
{
    [aPicker dismissModalViewControllerAnimated:YES];
    
    if (pickerCancelBlock) {
        pickerCancelBlock();
    }
}

- (void)setImagePickerCompletionBlock:(void (^)(UIImage *))block
{
    self.pickerCompletionBlock = block;
}

- (void)setImagePickerCancelBlock:(void (^)(void))block
{
    self.pickerCancelBlock = block;
}

@end
