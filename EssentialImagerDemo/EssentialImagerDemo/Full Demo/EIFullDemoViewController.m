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

#import "EIFullDemoViewController.h"

@interface EIFullDemoViewController ()

@end

@implementation EIFullDemoViewController

@synthesize summaryLabel;
@synthesize buttonWithImage;
@synthesize buttonWithBackgroundImage;
@synthesize imageViewWithRoundedCorners;
@synthesize layerMaskedCircleImageView;
@synthesize imageMaskedRadialGradientImageView;
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
    self.buttonWithImage = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 120, 120)];
    buttonWithImage.layer.cornerRadius = 20.0f;
    buttonWithImage.layer.borderColor = [UIColor blueColor].CGColor;
    buttonWithImage.layer.borderWidth = 1.0f;
    [buttonWithImage setImage:[UIImage imageNamed:@"Icon.png"] forState:UIControlStateNormal];
    [buttonWithImage addTarget:self action:@selector(presentPhotoPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonWithImage];
    
    // show how a button looks with returned image set as background button image without resizing
    self.buttonWithBackgroundImage = [[UIButton alloc] initWithFrame:CGRectMake(160, 10, 120, 120)];
    buttonWithBackgroundImage.layer.cornerRadius = 20.0f;
    buttonWithBackgroundImage.layer.borderColor = [UIColor blueColor].CGColor;
    buttonWithBackgroundImage.layer.borderWidth = 1.0f;
    [buttonWithBackgroundImage setBackgroundImage:[UIImage imageNamed:@"Icon.png"] forState:UIControlStateNormal];
    [buttonWithBackgroundImage addTarget:self action:@selector(presentPhotoPicker) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonWithBackgroundImage];
    
    
    self.summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, 280, 30)];
    summaryLabel.font = [summaryLabel.font fontWithSize:11];
    summaryLabel.numberOfLines = 0;
    summaryLabel.text = @"Select one of the 2 buttons above to add an image from the picker.";
    [self.view addSubview:summaryLabel];
    
    
    // displaying the image in a rounded rect
    UIImageView *backingViewForRoundedCorner = [[UIImageView alloc] initWithFrame:CGRectMake(20, 180, 120, 120)];
    backingViewForRoundedCorner.layer.cornerRadius = 20.0f;
    backingViewForRoundedCorner.clipsToBounds = YES;
    [self.view addSubview:backingViewForRoundedCorner];
    
    self.imageViewWithRoundedCorners = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    imageViewWithRoundedCorners.backgroundColor = [UIColor lightGrayColor];
    [backingViewForRoundedCorner addSubview:imageViewWithRoundedCorners];
    
    
    // displaying the image in a circle by using a shape layer
    // layer fill color controls the masking
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    UIBezierPath *layerPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(1, 1, 118, 118)];
    maskLayer.path = layerPath.CGPath;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    // use another view for clipping so that when the image size changes, the masking layer does not need to be repositioned
    UIView *clippingViewForLayerMask = [[UIView alloc] initWithFrame:CGRectMake(160, 180, 120, 120)];
    clippingViewForLayerMask.layer.mask = maskLayer;
    clippingViewForLayerMask.clipsToBounds = YES;
    [self.view addSubview:clippingViewForLayerMask];
    
    self.layerMaskedCircleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    layerMaskedCircleImageView.backgroundColor = [UIColor lightGrayColor];
    [clippingViewForLayerMask addSubview:layerMaskedCircleImageView];
    
    
    // displaying the image in a radial gradient by using a png mask
    // image alpha channel controls the masking
    CALayer *imageMaskLayer = [CALayer layer];
    UIImage *pattern = [UIImage imageNamed:@"pattern.png"];
    imageMaskLayer.contents = (__bridge id)pattern.CGImage;
    imageMaskLayer.frame = CGRectMake(0, 0, pattern.size.width, pattern.size.height);
    
    // use another view for clipping so that when the image size changes, the masking layer does not need to be repositioned
    UIView *clippingViewForLayerImageMask = [[UIView alloc] initWithFrame:CGRectMake(20, 310, 120, 120)];
    clippingViewForLayerImageMask.layer.mask = imageMaskLayer;
    clippingViewForLayerImageMask.clipsToBounds = YES;
    [self.view addSubview:clippingViewForLayerImageMask];
    
    self.imageMaskedRadialGradientImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    imageMaskedRadialGradientImageView.backgroundColor = [UIColor lightGrayColor];
    [clippingViewForLayerImageMask addSubview:imageMaskedRadialGradientImageView];
    
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
        
        __weak EIFullDemoViewController *weakController = self;
        [imagePickerDelegate setImagePickerCompletionBlock:^(UIImage *pickerImage) {
            
            __strong EIFullDemoViewController *strongController = weakController;
            
            NSLog(@"logical size is %f:%f scale %f", pickerImage.size.width, pickerImage.size.height, pickerImage.scale);
            
            // Use display size to constrain resizing
            // 120 is the logical display size
            UIImage *resizedImage = [pickerImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(120, 120) interpolationQuality:kCGInterpolationDefault];
            
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
    [buttonWithBackgroundImage setBackgroundImage:aImage forState:UIControlStateNormal];
    
    imageViewWithRoundedCorners.image = bImage;
    imageViewWithRoundedCorners.frame = CGRectMake(0, 0, bImage.size.width, bImage.size.height);
    imageViewWithRoundedCorners.center = CGPointMake(imageViewWithRoundedCorners.superview.frame.size.width/2, imageViewWithRoundedCorners.superview.frame.size.height/2);
    
    layerMaskedCircleImageView.image = bImage;
    layerMaskedCircleImageView.frame = CGRectMake(0, 0, bImage.size.width, bImage.size.height);
    layerMaskedCircleImageView.center = CGPointMake(layerMaskedCircleImageView.superview.frame.size.width/2, layerMaskedCircleImageView.superview.frame.size.height/2);
    
    imageMaskedRadialGradientImageView.image = bImage;
    imageMaskedRadialGradientImageView.frame = CGRectMake(0, 0, bImage.size.width, bImage.size.height);
    imageMaskedRadialGradientImageView.center = CGPointMake(layerMaskedCircleImageView.superview.frame.size.width/2, layerMaskedCircleImageView.superview.frame.size.height/2);
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
