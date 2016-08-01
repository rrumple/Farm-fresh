//
//  Resize.m
//  Farm Fresh
//
//  Created by Randall Rumple on 5/15/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius
{
    UIGraphicsBeginImageContext(size);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius] addClip];
    [image drawInRect:rect];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage *)cropImageWithInfo:(NSDictionary *)info
{
    // gets the original image along with it's size.
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    CGSize size = image.size;
    
    // crops the crop rect that the user selected.
    CGRect cropRect = [info[@"UIImagePickerControllerCropRect"] CGRectValue];
    
    // creates a graphics context of the correct size.
    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // checks and corrects the image orientation.
    UIImageOrientation orientation = [image imageOrientation];
    if(orientation == UIImageOrientationUp) {
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        cropRect = CGRectMake(cropRect.origin.x,
                              -cropRect.origin.y,
                              cropRect.size.width,
                              cropRect.size.height);
    }
    else if(orientation == UIImageOrientationRight) {
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextRotateCTM(context, -M_PI/2);
        size = CGSizeMake(size.height, size.width);
        
        cropRect = CGRectMake(cropRect.origin.y,
                              cropRect.origin.x,
                              cropRect.size.height,
                              cropRect.size.width);
    }
    else if(orientation == UIImageOrientationDown) {
        CGContextTranslateCTM(context, size.width, 0);
        CGContextScaleCTM(context, -1, 1);
        
        cropRect = CGRectMake(-cropRect.origin.x,
                              cropRect.origin.y,
                              cropRect.size.width,
                              cropRect.size.height);
    }
    
    // draws the image in the correct place.
    CGContextTranslateCTM(context, -cropRect.origin.x, -cropRect.origin.y);
    CGContextDrawImage(context,
                       CGRectMake(0,0, size.width, size.height),
                       image.CGImage);
    
    // and pull out the cropped image
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

@end
