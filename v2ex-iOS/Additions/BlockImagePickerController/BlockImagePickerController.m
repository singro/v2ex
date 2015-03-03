//
//  BlockImagePickerController.m
//  BlockImagePicker
//
//  Created by Wipoo Shinsirikul on 4/12/56 BE.
//  Copyright (c) 2556 Wipoo Shinsirikul. All rights reserved.
//

/***********************************************************************************
 *
 * Copyright (c) 2556 Wipoo Shinsirikul
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************
 *
 * Referencing this project in your AboutBox is appreciated.
 * Please tell me if you use this class so we can cross-reference our projects.
 *
 ***********************************************************************************/

#import "BlockImagePickerController.h"

@interface BlockImagePickerController ()
{
    
}

@property (nonatomic, copy) void (^finishingBlock)(UIImagePickerController *picker, NSDictionary *info, UIImage *originalImage, UIImage *editedImage);
@property (nonatomic, copy) void (^cancelingBlock)(UIImagePickerController *picker);

@end

@implementation BlockImagePickerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (instancetype)initWithCameraSourceType:(UIImagePickerControllerSourceType)source onFinishingBlock:(void (^)(UIImagePickerController *picker, NSDictionary *info, UIImage *originalImage, UIImage *editedImage))finishingBlock onCancelingBlock:(void (^)(UIImagePickerController *picker))cancelingBlock
{
    self = [super init];
    if (self)
    {
        [self setSourceType:source];
        [self setFinishingBlock:finishingBlock];
        [self setCancelingBlock:cancelingBlock];
        [self setDelegate:self];
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.finishingBlock(picker, info, ((UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage]), ((UIImage *)[info objectForKey:UIImagePickerControllerEditedImage]));
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.cancelingBlock(picker);
}

@end
