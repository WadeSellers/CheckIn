//
//  ColorPalette.m
//  iOS-CheckInApp
//
//  Created by Alex Moller on 12/9/15.
//  Copyright © 2015 Flowhub. All rights reserved.
//

#import "ColorPalette.h"

@implementation ColorPalette


+ (UIColor *)getFlowhubGrey {
    UIColor *flowhubGrey = [UIColor colorWithRed:33.0f/255.0f
                                             green:36.0f/255.0f
                                              blue:44.0f/255.0f
                                             alpha:1.0f];
    return flowhubGrey;
}

+ (UIColor *)getFlowhubDarkGrey {
  
  UIColor *flowhubDarkGrey = [UIColor colorWithRed:34.0f/255.0f
                                         green:43.0f/255.0f
                                          blue:54.0f/255.0f
                                         alpha:1.0f];
  return flowhubDarkGrey;
}

+ (UIColor *)getFlowhubBlue {
  
  UIColor *flowhubBlue= [UIColor colorWithRed:0.0f/255.0f
                                             green:122.0f/255.0f
                                              blue:255.0f/255.0f
                                             alpha:1.0f];
  return flowhubBlue;
}

+ (UIColor *)getFlowhubRed {

  UIColor *flowhubRed= [UIColor colorWithRed:78.0f/255.0f
                                        green:54.0f/255.0f
                                         blue:58.0f/255.0f
                                        alpha:1.0f];
  return flowhubRed;
}
+ (UIColor *)getFlowhubEmployeeButtonBorderColor {
  
  UIColor *flowhubEmployeeButtonBorderColor = [UIColor colorWithRed:52.0f/255.0f
                                                              green:61.0f/255.0f
                                                               blue:72.0f/255.0f
                                                              alpha:0.5f];
  return flowhubEmployeeButtonBorderColor;
}

+ (UIColor *)getPlaceholderTextColor {

  UIColor *placeholderTextColor = [UIColor colorWithRed:67.0f/255.0f
                                                    green:71.0f/255.0f
                                                    blue:80.0f/255.0f
                                                    alpha:1.0f];
  return placeholderTextColor;
}

+ (UInt32)getFlowHubBlueRGBHex {
  return 0x007AFF;
}


@end
