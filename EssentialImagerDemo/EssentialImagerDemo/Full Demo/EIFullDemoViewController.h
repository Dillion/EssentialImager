/*
 
 File: EIDemoViewController.h
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

#import <UIKit/UIKit.h>

@interface EIFullDemoViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UIButton *buttonWithImage;
@property (nonatomic, strong) UIButton *buttonWithBackgroundImage;

@property (nonatomic, strong) UIImageView *imageViewWithRoundedCorners;
@property (nonatomic, strong) UIImageView *layerMaskedCircleImageView;
@property (nonatomic, strong) UIImageView *imageMaskedRadialGradientImageView;

@property (nonatomic, strong) EIImagePickerDelegate *imagePickerDelegate;

- (void)presentPhotoPicker;
- (void)setOriginalImage:(UIImage *)aImage resizedImage:(UIImage *)bImage;

@end
