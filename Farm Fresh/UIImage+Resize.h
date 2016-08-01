//
//  Resize.h
//  Farm Fresh
//
//  Created by Randall Rumple on 5/15/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (Resize)

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)size;

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *)cropImageWithInfo:(NSDictionary *)info;
@end
