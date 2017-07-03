//
//  ImageCropper.m
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/9/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import "ImageManipulator.h"

@implementation ImageManipulator

+ (UIImage *)shrinkImageToIconSize:(UIImage *)inputImage {
  
    CGSize newSizeIconImage = CGSizeMake(40.0f, 40.0f);
    UIGraphicsBeginImageContext(newSizeIconImage);
    [inputImage drawInRect:(CGRectMake(0, 0, newSizeIconImage.width, newSizeIconImage.height))];
    UIImage *newCroppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  
    return newCroppedImage;


}
@end
