//
//  ImageCropper.h
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/9/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageManipulator : NSObject

+ (UIImage *)shrinkImageToIconSize:(UIImage *)inputImage;

@end
