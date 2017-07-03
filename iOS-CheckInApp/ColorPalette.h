//
//  ColorPalette.h
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/9/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ColorPalette : NSObject

+ (UIColor *)getFlowhubGrey;
+ (UIColor *)getFlowhubDarkGrey;
+ (UIColor *)getFlowhubBlue;
+ (UIColor *)getFlowhubRed;
+ (UIColor *)getFlowhubEmployeeButtonBorderColor;
+ (UIColor *)getPlaceholderTextColor;
+ (UInt32)getFlowHubBlueRGBHex;

@end
