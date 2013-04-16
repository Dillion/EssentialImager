/*
 
 File: EIDemoViewController.m
 Abstract: Demo Controller to show usage of image picker with blocks,
 and subsequent resizing, saving, clipping and masking of returned image
 
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

#import "EISimpleDemoViewController.h"

@interface EISimpleDemoViewController ()

@end

@implementation EISimpleDemoViewController

@synthesize buttonWithImage;
@synthesize imageViewWithRoundedCorners;
@synthesize imagePickerDelegate;

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
    
    // show how a button looks with returned image set as button image without resizing
    self.buttonWithImage = [[UIButton alloc] initWithFrame:CGRectMake(70, 40, 180, 180)];
    buttonWithImage.layer.cornerRadius = 20.0f;
    buttonWithImage.layer.borderColor = [UIColor blueColor].CGColor;
    buttonWithImage.layer.borderWidth = 1.0f;
    [buttonWithImage setImage:[UIImage imageNamed:@"Icon.png"] forState:UIControlStateNormal];
    [buttonWithImage addTarget:self action:@selector(presentPhotoPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonWithImage];
    
    // displaying the image in a rounded rect
    UIImageView *backingViewForRoundedCorner = [[UIImageView alloc] initWithFrame:CGRectMake(70, 260, 180, 180)];
    backingViewForRoundedCorner.layer.cornerRadius = 20.0f;
    backingViewForRoundedCorner.clipsToBounds = YES;
    [self.view addSubview:backingViewForRoundedCorner];
    
    self.imageViewWithRoundedCorners = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 180, 180)];
    imageViewWithRoundedCorners.backgroundColor = [UIColor lightGrayColor];
    [backingViewForRoundedCorner addSubview:imageViewWithRoundedCorners];
        
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"savedImage"]) { // test cached image
        NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedImage"];
        
        UIImage *cachedImage = [NSData imageFromFile:[[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:urlString]];
        
        if (cachedImage) {
            NSLog(@"logical size is %f:%f scale %f", cachedImage.size.width, cachedImage.size.height, cachedImage.scale);
            
            [self setOriginalImage:[UIImage imageNamed:@"Icon.png"] resizedImage:cachedImage];
        }
    }
    
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

- (void)presentPhotoPicker
{
    if (!imagePickerDelegate) {
        self.imagePickerDelegate = [[EIImagePickerDelegate alloc] init];
        
        __weak EISimpleDemoViewController *weakController = self;
        [imagePickerDelegate setImagePickerCompletionBlock:^(UIImage *pickerImage) {
            
            __strong EISimpleDemoViewController *strongController = weakController;
            
            NSLog(@"logical size is %f:%f scale %f", pickerImage.size.width, pickerImage.size.height, pickerImage.scale);
            
            // Use display size to constrain resizing
            // 120 is the logical display size
            UIImage *resizedImage = [pickerImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(180, 180) interpolationQuality:kCGInterpolationDefault];
            
            // Use uncompressed size to constrain resizing
            //            UIImage *resizedImage = [pickerImage resizedImageWithUncompressedSizeInMB:1.0 interpolationQuality:kCGInterpolationDefault];
            
            NSLog(@"logical size is %f:%f scale %f", resizedImage.size.width, resizedImage.size.height, resizedImage.scale);
            
            [strongController setOriginalImage:pickerImage resizedImage:resizedImage];
            
            // remove the image if previously saved
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"savedImage"]) {
                NSString *cachedFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedImage"];
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:cachedFilePath] error:NULL];
            }
            
            NSString *assetName = [NSString stringWithFormat:@"%@.png", [[NSProcessInfo processInfo]     globallyUniqueString]];
            assetName = [assetName stringByAppendingScaleSuffix]; // add scale suffix to extension
            NSString *assetPath     = [[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:assetName];
            
            // saving synchronously
            //            [UIImagePNGRepresentation(resizedImage) writeToFile:assetPath atomically:NO];
            //            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", assetName] forKey:@"savedImage"];
            
            [[EIOperationManager defaultManager] saveImage:resizedImage toPath:assetPath withBlock:^(BOOL success) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", assetName] forKey:@"savedImage"];
            }];
            
        }];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Camera", nil];
        [actionSheet showInView:self.view];
        
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)setOriginalImage:(UIImage *)aImage resizedImage:(UIImage *)bImage
{
    [buttonWithImage setImage:aImage forState:UIControlStateNormal];
    
    imageViewWithRoundedCorners.image = bImage;
    imageViewWithRoundedCorners.frame = CGRectMake(0, 0, bImage.size.width, bImage.size.height);
    imageViewWithRoundedCorners.center = CGPointMake(imageViewWithRoundedCorners.superview.frame.size.width/2, imageViewWithRoundedCorners.superview.frame.size.height/2);
}

# pragma mark -
# pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [imagePickerDelegate presentFromController:self withSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 1:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [imagePickerDelegate presentFromController:self withSourceType:UIImagePickerControllerSourceTypeCamera];
            }
            break;
        default:
            break;
    }
}

@end
