//
//  UIImage+SV.m
//  tripaccounting
//
//  Created by 沈 威 on 15/2/28.
//  Copyright (c) 2015年 Shen Wei. All rights reserved.
//

#import "UIImage+SV.h"
#import <math.h>
#import <CommonCrypto/CommonDigest.h>

#define matrix 5
#define matrix2 3
int imageWidth;
int imageHeight;
uint32_t *rgbImageBuf;
uint32_t * rgbImageBuf2;
CGFloat maxtH,mintH,maxtV,mintV;
int matrixV;
typedef struct ColorARGB
{
    uint8_t a;
    uint8_t b;
    uint8_t g;
    uint8_t r;
} ColorARGB;

typedef struct ColorHVS
{
    int h;
    int v;
    int s;
} ColorHVS;
@implementation UIImage (SV)

@dynamic transMaxV,transMaxH,transMinH,transMinV;

static NSString *cache_path()
{
    static NSString *cache_path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache_path = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"image"];
    });
    return cache_path;
}
+(NSString*)imageFileName:(NSString*)aFileName
{
    NSString* tmpStr;
    NSArray *strarray = [aFileName componentsSeparatedByString:@"/"];
    
    if ([strarray  count] >= 1) {
        NSUInteger c = [strarray  count]-1;
        tmpStr = strarray[c];
    }
    else
        tmpStr = aFileName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString* str = [[NSMutableString alloc] initWithCapacity:300];
    [str appendString:documentsDirectory];
    [str appendString:@"/"];
    [str appendString:tmpStr];
    
    return str;
}
+ (NSString *) md5:(NSString *)str
{
    if(str == nil || str.length < 5)
    {
        return nil;
    }
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
+ (UIImage *)getImageWithUrlStringForImage:(NSString *)imageString{
    
    
    if ([imageString containsString:@"cdwin"]) {
        return [UIImage imageNamed:@"logo"];
    }
    NSString* fileName = [UIImage md5:imageString];
    fileName = [UIImage imageFileName:fileName];
    
    __block UIImage* image = [UIImage imageWithContentsOfFile:fileName];
    if(image == nil)
    {
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageString]];
        image= [UIImage imageWithData:data];
        [image savedWithName:fileName];
        NSLog(@"%@",imageString);
        
        
    }
    else
    {
        NSLog(@"read from cache...4");
    }
    
    return image;
}
-(void) savedWithName:(NSString*) aFileName
{
    
    NSString* tmpStr = [UIImage imageFileName:aFileName];
    
    
    BOOL result = [UIImagePNGRepresentation(self)writeToFile:tmpStr  atomically:YES];
    
    if (result) {
        NSLog(@"saved");
    }
    else
    {
        NSLog(@"not saved");
    }
}
+(UIImage*) GetSavedImageWithName:(NSString*) aFileName
{
    
    NSString* tmpStr;
    NSArray *strarray = [aFileName componentsSeparatedByString:@"/"];
    
    if ([strarray  count] >= 1) {
        NSUInteger c = [strarray  count]-1;
        tmpStr = strarray[c];
    }
    else
        tmpStr = aFileName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableString* str = [[NSMutableString alloc] initWithCapacity:300];
    [str appendString:documentsDirectory];
    [str appendString:@"/"];
    [str appendString:tmpStr];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL success = [fileManager fileExistsAtPath:str];
    
    NSData *dataToWrite = nil;
    
    UIImage* image = nil;
    
    if(!success)
    {
        return nil;
    }
    else
    {
        dataToWrite = [[NSData alloc] initWithContentsOfFile:str];
        image = [[UIImage alloc] initWithData:dataToWrite];
    }
    return image;
}

+(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}
+(UIImage*)matrixToImage:(const float**)array withH:(int)imageH andW:(int)imageW
{
    size_t      bytesPerRow = imageW * 4;
    
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    uint32_t *imageBuf;
    imageBuf = (uint32_t *)malloc(imageW * imageH*4);
    
    ColorARGB *ptr;
    for (int row = 0; row < imageH; row++) {
        
        
        
        for (int col =0; col < imageW; col++) {
            
            
            float v = array[row][col]*255;
            
            
            NSInteger pixlPos = row*imageW + col;
            uint32_t *pCurPixel =  &imageBuf[pixlPos];
            ptr = (ColorARGB *)pCurPixel;
            ptr->b = v;
            ptr->g = v;
            ptr->r = v;
            ptr->a = 255;
//            printf("%.2f\t",v);
            
        }
//        printf("\n");
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, imageBuf, bytesPerRow * imageH,ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageW, imageH, 8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    //    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    
    return resultUIImage;
}
+(UIImage*)arrayToImage:(uint8_t*)array with:(int)imageH and:(int)imageW
{

    size_t      bytesPerRow = imageW * 4;
    
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
   
    uint32_t *imageBuf;
    imageBuf = (uint32_t *)malloc(imageW * imageH*4);
    
    ColorARGB *ptr;
    for (int row = 0; row < imageH; row++) {
        
        
        
        for (int col =0; col < imageW; col++) {
            
            
            uint8_t v = array[row*imageW+col];
          
            
            NSInteger pixlPos = row*imageW + col;
            uint32_t *pCurPixel =  &imageBuf[pixlPos];
            ptr = (ColorARGB *)pCurPixel;
            ptr->b = v;
            ptr->g = v;
            ptr->r = v;
            ptr->a = 255;
            
            
        }
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, imageBuf, bytesPerRow * imageH,ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageW, imageH, 8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    //    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    
    return resultUIImage;
}
-(UIImage*) matrixToImage:(NSArray*)matrixArray
{
    NSInteger rowNumber;
    NSInteger colNumber;
    
    if([matrixArray count] < 1)
    {
        return nil;
    }
    rowNumber = [matrixArray count];
    
    NSArray* array = [matrixArray firstObject];
    if(array.count < 1)
    {
        return nil;
    }
    
    colNumber = [array count];
    
    uint32_t *imageBuf;
    imageBuf = (uint32_t *)malloc(colNumber * rowNumber*4);
    
    

    NSInteger imageW = colNumber;
    NSInteger imageH = rowNumber;
    size_t      bytesPerRow = imageW * 4;
    
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(imageBuf, imageW, imageH, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
//    CGContextDrawImage(context, CGRectMake(0, 0, imageW, imageH), self.CGImage);
    

    
    // 遍历像素

    ColorARGB *ptr;
    for (int row = 0; row < imageH; row++) {
        
        NSArray* rowArray = matrixArray[row];
        
        for (int col =0; col < imageW; col++) {
            
            
            CGFloat v;
            if(col < rowArray.count)
            {
                v = [rowArray[col] floatValue]*255;
            }
            else
                v = 0;
            
            NSInteger pixlPos = row*imageW + col;
            uint32_t *pCurPixel =  &imageBuf[pixlPos];
            ptr = (ColorARGB *)pCurPixel;
            ptr->b = v;
            ptr->g = v;
            ptr->r = v;
            ptr->a = 255;
            
            
        }
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, imageBuf, bytesPerRow * imageH,ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageW, imageH, 8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
//    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    
    return resultUIImage;

}
+(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}
+(UIImage*)miniImageWithContentsOfCacheFile:(NSString *)filePath
{
    
    
    NSString*originFileName = [UIImage imageFileName:filePath];
    
    NSString* minFileName = [originFileName stringByAppendingString:@"mini.png"];
    
    
    
    
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:minFileName];
    
    if (fileExists) {
        return [UIImage imageWithContentsOfFile:minFileName];
    }
    UIImage *originImage = [UIImage imageWithContentsOfFile:originFileName];
    
    UIImage *miniImage = [UIImage imageCompressForWidth:originImage targetWidth:160];
    
    BOOL result = [UIImagePNGRepresentation(miniImage)writeToFile:minFileName  atomically:YES];
    
    if (result) {
        return miniImage;
    }
    else
    {
        return nil;
    }
    
}


- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
+ (UIImage *)imageWithImage:(UIImage *)image
          scaledToFitToSize:(CGSize)newSize
{
    //Only scale images down
    if (image.size.width < newSize.width && image.size.height < newSize.height) {
        return [image copy];
    }
    
    //Determine the scale factors
    CGFloat widthScale = newSize.width/image.size.width;
    CGFloat heightScale = newSize.height/image.size.height;
    
    CGFloat scaleFactor;
    
    //The smaller scale factor will scale more (0 < scaleFactor < 1) leaving the other dimension inside the newSize rect
    widthScale < heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
    CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    //Scale the image
    return [UIImage imageWithImage:image scaledToSize:scaledSize inRect:CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height)];
}
+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize
                     inRect:(CGRect)rect
{
    //Determine whether the screen is retina
    if ([[UIScreen mainScreen] scale] == 2.0) {
        UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
    }
    else
    {
        UIGraphicsBeginImageContext(newSize);
    }
    
    //Draw image in provided rect
    [image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Pop this context
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (UIImage *)imageWithImage:(UIImage *)image
         scaledToFillToSize:(CGSize)newSize
{
    //Only scale images down
    if (image.size.width < newSize.width && image.size.height < newSize.height) {
        return [image copy];
    }
    
    //Determine the scale factors
    CGFloat widthScale = newSize.width/image.size.width;
    CGFloat heightScale = newSize.height/image.size.height;
    
    CGFloat scaleFactor;
    
    //The larger scale factor will scale less (0 < scaleFactor < 1) leaving the other dimension hanging outside the newSize rect
    widthScale > heightScale ? (scaleFactor = widthScale) : (scaleFactor = heightScale);
    CGSize scaledSize = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor);
    
    //Create origin point so that the center of the image falls into the drawing context rect (the origin will have negative component).
    CGPoint imageDrawOrigin = CGPointMake(0, 0);
    widthScale > heightScale ?  (imageDrawOrigin.y = (newSize.height - scaledSize.height) * 0.5) :
    (imageDrawOrigin.x = (newSize.width - scaledSize.width) * 0.5);
    
    
    //Create rect where the image will draw
    CGRect imageDrawRect = CGRectMake(imageDrawOrigin.x, imageDrawOrigin.y, scaledSize.width, scaledSize.height);
    
    //The imageDrawRect is larger than the newSize rect, where the imageDraw origin is located defines what part of
    //the image will fall into the newSize rect.
    return [UIImage imageWithImage:image scaledToSize:newSize inRect:imageDrawRect];
}
//+(NSString*)imageFileName:(NSString*)aFileName
//{
//    NSString* tmpStr;
//    NSArray *strarray = [aFileName componentsSeparatedByString:@"/"];
//
//    if ([strarray  count] >= 1) {
//        NSUInteger c = [strarray  count]-1;
//        tmpStr = strarray[c];
//    }
//    else
//        tmpStr = aFileName;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSMutableString* str = [[NSMutableString alloc] initWithCapacity:300];
//    [str appendString:documentsDirectory];
//    [str appendString:@"/"];
//    [str appendString:tmpStr];
//
//    return str;
//}
//+(UIImage*) GetSavedImageWithName:(NSString*) aFileName
//{
//
//    NSString* tmpStr;
//    NSArray *strarray = [aFileName componentsSeparatedByString:@"/"];
//
//    if ([strarray  count] >= 1) {
//        NSUInteger c = [strarray  count]-1;
//        tmpStr = strarray[c];
//    }
//    else
//        tmpStr = aFileName;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSMutableString* str = [[NSMutableString alloc] initWithCapacity:300];
//    [str appendString:documentsDirectory];
//    [str appendString:@"/"];
//    [str appendString:tmpStr];
//
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//
//    BOOL success = [fileManager fileExistsAtPath:str];
//
//    NSData *dataToWrite = nil;
//
//    UIImage* image = nil;
//
//    if(!success)
//    {
//        return nil;
//    }
//    else
//    {
//        dataToWrite = [[NSData alloc] initWithContentsOfFile:str];
//        image = [[UIImage alloc] initWithData:dataToWrite];
//    }
//    return image;
//}
//
//+(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
//    UIImage *newImage = nil;
//    CGSize imageSize = sourceImage.size;
//    CGFloat width = imageSize.width;
//    CGFloat height = imageSize.height;
//    CGFloat targetWidth = size.width;
//    CGFloat targetHeight = size.height;
//    CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
//    if(CGSizeEqualToSize(imageSize, size) == NO){
//        CGFloat widthFactor = targetWidth / width;
//        CGFloat heightFactor = targetHeight / height;
//        if(widthFactor > heightFactor){
//            scaleFactor = widthFactor;
//        }
//        else{
//            scaleFactor = heightFactor;
//        }
//        scaledWidth = width * scaleFactor;
//        scaledHeight = height * scaleFactor;
//        if(widthFactor > heightFactor){
//            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
//        }else if(widthFactor < heightFactor){
//            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
//        }
//    }
//
//    UIGraphicsBeginImageContext(size);
//
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width = scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//    [sourceImage drawInRect:thumbnailRect];
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//
//    if(newImage == nil){
//        NSLog(@"scale image fail");
//    }
//
//    UIGraphicsEndImageContext();
//
//    return newImage;
//
//}

+(UIImage *) imageCompressForHeight:(UIImage *)sourceImage targetHeight:(CGFloat)defineHeight{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetHeight = defineHeight;// height / (width / targetWidth);
    
    CGFloat targetWidth = width/(height/targetHeight);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}

//+(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
//    UIImage *newImage = nil;
//    CGSize imageSize = sourceImage.size;
//    CGFloat width = imageSize.width;
//    CGFloat height = imageSize.height;
//    CGFloat targetWidth = defineWidth;
//    CGFloat targetHeight = height / (width / targetWidth);
//    CGSize size = CGSizeMake(targetWidth, targetHeight);
//    CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
//    if(CGSizeEqualToSize(imageSize, size) == NO){
//        CGFloat widthFactor = targetWidth / width;
//        CGFloat heightFactor = targetHeight / height;
//        if(widthFactor > heightFactor){
//            scaleFactor = widthFactor;
//        }
//        else{
//            scaleFactor = heightFactor;
//        }
//        scaledWidth = width * scaleFactor;
//        scaledHeight = height * scaleFactor;
//        if(widthFactor > heightFactor){
//            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
//        }else if(widthFactor < heightFactor){
//            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
//        }
//    }
//    UIGraphicsBeginImageContext(size);
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width = scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//
//    [sourceImage drawInRect:thumbnailRect];
//
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//    if(newImage == nil){
//        NSLog(@"scale image fail");
//    }
//
//    UIGraphicsEndImageContext();
//
//    CGFloat w,h;
//    w = newImage.size.width;
//    h = newImage.size.height;
//
//    NSLog(@"image:w:%f,h:%f",w,h);
//    return newImage;
//}
+(UIImage *)ImageWithContentsOfOriginFile:(NSString*)filePath
{
    NSString*originFileName = [UIImage imageFileName:filePath];
    
    
    
    
    
    
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:originFileName];
    
    if (fileExists) {
        UIImage *originImage = [UIImage imageWithContentsOfFile:originFileName];
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        UIImage *miniImage = [UIImage imageCompressForWidth:originImage targetWidth:w];
        
        
        return miniImage;
        
    }
    
    return nil;
    
}
//+(UIImage*)miniImageWithContentsOfCacheFile:(NSString *)filePath
//{
//    
//    
//    NSString*originFileName = [UIImage imageFileName:filePath];
//    
//    NSString* minFileName = [originFileName stringByAppendingString:@"mini.png"];
//    
//    
//    
//    
//    
//    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:minFileName];
//    
//    if (fileExists) {
//        return [UIImage imageWithContentsOfFile:minFileName];
//    }
//    UIImage *originImage = [UIImage imageWithContentsOfFile:originFileName];
//    
//    UIImage *miniImage = [UIImage imageCompressForWidth:originImage targetWidth:100];
//    
//    BOOL result = [UIImagePNGRepresentation(miniImage)writeToFile:minFileName  atomically:YES];
//    
//    if (result) {
//        return miniImage;
//    }
//    else
//    {
//        return nil;
//    }
//    
//}
//
//
//- (UIImage *)fixOrientation {
//    
//    // No-op if the orientation is already correct
//    if (self.imageOrientation == UIImageOrientationUp) return self;
//    
//    // We need to calculate the proper transformation to make the image upright.
//    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
//    CGAffineTransform transform = CGAffineTransformIdentity;
//    
//    switch (self.imageOrientation) {
//        case UIImageOrientationDown:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
//            transform = CGAffineTransformRotate(transform, M_PI);
//            break;
//            
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
//            transform = CGAffineTransformRotate(transform, M_PI_2);
//            break;
//            
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
//            transform = CGAffineTransformRotate(transform, -M_PI_2);
//            break;
//    }
//    
//    switch (self.imageOrientation) {
//        case UIImageOrientationUpMirrored:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//            
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//    }
//    
//    // Now we draw the underlying CGImage into a new context, applying the transform
//    // calculated above.
//    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
//                                             CGImageGetBitsPerComponent(self.CGImage), 0,
//                                             CGImageGetColorSpace(self.CGImage),
//                                             CGImageGetBitmapInfo(self.CGImage));
//    CGContextConcatCTM(ctx, transform);
//    switch (self.imageOrientation) {
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            // Grr...
//            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
//            break;
//            
//        default:
//            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
//            break;
//    }
//    
//    // And now we just create a new UIImage from the drawing context
//    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
//    UIImage *img = [UIImage imageWithCGImage:cgimg];
//    CGContextRelease(ctx);
//    CGImageRelease(cgimg);
//    return img;
//}
-(void)findColorFieldAt:(int)searchbeginx :(int)searchbeginy :(int)searchStep
{
    int searchendx = searchbeginx + searchStep;
    int searchendy = searchendx + searchStep;
    
    
    maxtH = 0;
    mintV = 255;
    maxtV = 0;
    mintH = 255;
    
    int MaxCount = 6;
    int changeMinhCount = 0;
    int changeMinvCount = 0;
    int changeMaxhCount = 0;
    int changeMaxvCount = 0;
    
    int pixlPos;
    
    for (int row = searchbeginx; row < imageHeight && row < searchendx; row++) {
        for (int col =searchbeginy; col < imageWidth && col < searchendy; col++) {
            
            pixlPos = row*imageWidth + col;
            uint32_t *pCurPixel =  &rgbImageBuf[pixlPos];
            
            ColorARGB *ptr = (ColorARGB *)pCurPixel;
            
            
            
            
            float maxv = MAX(ptr->r, MAX(ptr->g, ptr->b));
            float minv = MIN(ptr->r, MIN(ptr->g, ptr->b));
            int hv = 0;
            if(maxv == ptr->r)
            {
                hv = ((float)(ptr->g-ptr->b))/(maxv -minv)*60;
            }
            if(maxv == ptr->g)
            {
                hv =  120 + ((float)(ptr->b - ptr->r))/(maxv -minv)*60;
            }
            if(maxv == ptr->b)
            {
                hv =  240 + ((float)(ptr->r - ptr->g))/(maxv -minv)*60;
            }
            
            if (hv < 0)
                hv = hv+ 360;
            
            if(hv > maxtH)
            {
                changeMaxhCount++;
                if(changeMaxhCount > MaxCount)
                {
                    maxtH = hv;
                    changeMaxhCount = 0;
                }
            }
            else
            {
                if(changeMaxhCount > 0)
                    changeMaxhCount --;
            }
            
            
            if(hv < mintH)
            {
                changeMinhCount++;
                if(changeMinhCount > MaxCount)
                {
                    mintH = hv;
                    changeMinhCount = 0;
                }
            }
            else
            {
                if(changeMinhCount > 0)
                    changeMinhCount --;
            }
            
            if(maxv > maxtV)
            {
                changeMaxvCount++;
                if(changeMaxvCount > MaxCount)
                {
                    maxtV = maxv;
                    changeMaxvCount = 0;
                }
            }
            else
            {
                if(changeMaxvCount > 0)
                    changeMaxvCount --;
            }
            
            
            if(maxv < mintV)
            {
                changeMinvCount++;
                if(changeMinvCount > MaxCount)
                {
                    mintV = maxv;
                    changeMinvCount = 0;
                }
            }
            else
            {
                if(changeMinvCount > 0)
                    changeMinvCount --;
            }
            
        }
    }
}
-(uint32_t *)avgColor:(const int)row :(const int) col
{
    int x,y,xend,yend;
    if(matrixV == 0 || matrixV > 200)
    {
        matrixV = matrix;
    }
    x = col - matrixV/2;
    y = row - matrixV/2;
    xend = x+matrixV;
    yend = y+matrixV;
    
    if(x<0)
        x=0;
    if(y<0)
        y=0;
    if(xend >= imageWidth)
        xend = imageWidth-1;
    
    if(yend >= imageHeight)
        yend = imageHeight-1;
    int count = 0;
    
    ColorARGB *ptr;
    int r,g,b;
    r = 0;
    g = 0;
    b = 0;
    
    for (int i = x; i<xend ; i++) {
        for (int j = y; j<yend; j++) {
            count++;
            
            int pPos = i + j*imageWidth;
            uint32_t *tPixel =  &rgbImageBuf[pPos];
            
            ptr = (ColorARGB *)tPixel;
            r += ptr->r;
            g += ptr->g;
            b += ptr->b;
            
        }
    }
    r = r/count;
    b = b/count;
    g = g/count;
    int pixlPos = row*imageWidth + col;
    uint32_t *pCurPixel =  &rgbImageBuf[pixlPos];
    ptr = (ColorARGB *)pCurPixel;
    ptr->b = b;
    ptr->g = g;
    ptr->r = r;
    return pCurPixel;
}
-(void)egdeAvgColor:(const int)row :(const int) col
{
    int x,y,xend,yend;
    
    x = col - matrix2/2;
    y = row - matrix2/2;
    xend = x+matrix2;
    yend = y+matrix2;
    
    if(x<0)
        x=0;
    if(y<0)
        y=0;
    if(xend >= imageWidth)
        xend = imageWidth-1;
    
    if(yend >= imageHeight)
        yend = imageHeight-1;
    int count = 0;
    int r,g,b;
    r = 0;
    g = 0;
    b = 0;
    BOOL findAlpha = NO;
    BOOL findNoAlpha = NO;
    for (int i = x; i<xend ; i++) {
        for (int j = y; j<yend; j++) {
            count++;
            
            int pPos = i + j*imageWidth;
            uint32_t *tPixel =  &rgbImageBuf2[pPos];
            ColorARGB *p = (ColorARGB *)tPixel;
            
            r += p->r;
            g += p->g;
            b += p->b;
            if(p->a == 0)
                findAlpha = YES;
            else
                findNoAlpha = YES;
        }
    }
    
    if(findAlpha)
    {
        r = r/count;
        b = b/count;
        g = g/count;
        int pixlPos = row*imageWidth + col;
        uint32_t *pCurPixel =  &rgbImageBuf2[pixlPos];
        ColorARGB *ptr = (ColorARGB *)pCurPixel;
        ptr->b = b;
        ptr->g = g;
        ptr->r = r;
    }
    
    
}
-(void)partialAlphaEnableWith:(CGFloat)transMaxH :(CGFloat)transMinH :(CGFloat)transMaxV :(CGFloat)transMinV
{
    uint32_t *pCurPtr = rgbImageBuf;
    uint32_t *pCurPtr2 = rgbImageBuf2;
    
    int pixelNum = imageWidth * imageHeight;
    for (int i = 0; i < pixelNum; i++, pCurPtr++,pCurPtr2++){
        
        //        int h =  (i / imageWidth);
        bool shouldFade = false;
        ColorARGB *ptr = (ColorARGB *)pCurPtr;
        ColorARGB *ptr2 = (ColorARGB *)pCurPtr2;
        
        
        
        float maxv = MAX(ptr->r, MAX(ptr->g, ptr->b));
        float minv = MIN(ptr->r, MIN(ptr->g, ptr->b));
        int hv = 0;
        if(maxv == ptr->r)
        {
            hv = ((float)(ptr->g-ptr->b))/(maxv -minv)*60;
        }
        if(maxv == ptr->g)
        {
            hv =  120 + ((float)(ptr->b - ptr->r))/(maxv -minv)*60;
        }
        if(maxv == ptr->b)
        {
            hv =  240 + ((float)(ptr->r - ptr->g))/(maxv -minv)*60;
        }
        
        if (hv < 0)
            hv = hv+ 360;
        
        transMinV = mintV;
        transMinH = mintH;
        transMaxH = maxtH;
        transMaxV = maxtV;
        
        //        if(transMaxH == 0)
        //            transMaxH = 300;
        //
        //        if(transMinH == 0)
        //            transMinH = 180;
        //
        //        if(transMinV == 0)
        //            transMinV = 162;
        //
        //        if(transMaxV == 0)
        //            transMaxV = 255;
        
        if( hv > transMinH && hv < transMaxH && maxv > transMinV)
        {
            shouldFade = true;
        }
        
        if (shouldFade) {
            
            ptr2->a = 0;
            
        }
    }
}
-(NSArray*)mergeNumberArray:(NSArray<NSNumber *>*)array
{
    if (array.count < 1) {
        return array;
    }
    NSArray* oArray = @[array.firstObject];
    
    CGFloat preValue = [array[0] floatValue];
    for (NSInteger i = 1; i< array.count; i++) {
        NSNumber* nValue = array[i];
        
        if (fabs(nValue.floatValue - preValue) > 5) {
            oArray= [oArray arrayByAddingObject:nValue];
            preValue = nValue.floatValue;
        }
        else
        {
            NSInteger j = i+1;
            if(j < array.count)
            {
                NSNumber* nextValue = array[j];
                
                if (fabs(nValue.floatValue - nextValue.floatValue) > 5) {
                    oArray= [oArray arrayByAddingObject:nValue];
                    preValue = nValue.floatValue;
                }
            }
        }
        
    }
    return oArray;
}
- (NSDictionary *) imageGridCalcolate
{
    
    // 分配内存
    //    int top = 100;
    //    int step = 20;
    imageWidth = self.size.width;
    imageHeight = self.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    rgbImageBuf2 = (uint32_t *)malloc(bytesPerRow * imageHeight);
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    context = CGBitmapContextCreate(rgbImageBuf2, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    // 遍历像素
    
    //    uint32_t *pCurPtr = rgbImageBuf;
    //    uint32_t *pCurPtr2 = rgbImageBuf2;
    int pixlPos = 0;
    
    int y = 0;
    
    BOOL goThrough = NO;
    BOOL hasObject = NO;
    
    NSArray* yarray = @[];
    int miny =  imageHeight;
    int maxy = 0;
    for (int row = 0; row < imageHeight; row++) {
        
        int xindex = 0;
        for (int col =0; col < imageWidth; col++) {
            
            pixlPos = row*imageWidth + col;
            uint32_t *pCurPixel =  &rgbImageBuf[pixlPos];
            
            
            
            ColorARGB *ptr = (ColorARGB *)pCurPixel;
            if (ptr->r == 0 && ptr->b == 0 && ptr->g == 0) {
                xindex++;
            }
            if(col == imageWidth-1)
            {
                if (xindex == col) {
                    
                    y = row;
                    
                    //                    NSLog(@"+Y:%d row:%d",y,row);
                    if(goThrough == NO)
                    {
                        //                        NSLog(@"inert %d",y);
                        yarray = [yarray arrayByAddingObject:[NSNumber numberWithInt:y]];
                        miny = MIN(miny, y);
                        maxy = MAX(maxy, y);
                    }
                    goThrough = YES;
                    hasObject = NO;
                }
                else
                {
                    //                    y = row;
                    if(hasObject == NO)
                    {
                        //                        NSLog(@"inert %d",y);
                        yarray = [yarray arrayByAddingObject:[NSNumber numberWithInt:y]];
                        
                        miny = MIN(miny, y);
                        maxy = MAX(maxy, y);
                    }
                    hasObject = YES;
                    goThrough = NO;
                    //                    NSLog(@"-Y:%d row:%d",y,row);
                }
                
            }
            
        }
    }
    
//    yarray = [self mergeNumberArray:yarray];
    
    
    int fromY = 0;
    int toY = 0;
    
    int x = 0;
    
    goThrough = NO;
    hasObject = NO;
    NSArray* gArray = @[];
    
    
    for (NSNumber* yNumber in yarray) {
        toY =yNumber.intValue;
//        NSLog(@"from:%d to %d",fromY,toY);
        NSArray* xarray = @[];
        for (int col =0; col < imageWidth; col++) {
            
            int yindex = 0;
            int yh =   toY - fromY;
            
            for (int row = fromY; row < toY; row++) {
                
                pixlPos = row*imageWidth + col;
                uint32_t *pCurPixel =  &rgbImageBuf[pixlPos];
                
                
                
                ColorARGB *ptr = (ColorARGB *)pCurPixel;
                if (ptr->r == 0 && ptr->b == 0 && ptr->g == 0) {
                    yindex++;
                }
                if(row == toY-1)
                {
                    if (yindex == yh) {
                        x = col;
                        
//                        NSLog(@"+X:%d col:%d",x,col);
                        if(goThrough == NO)
                        {
                            NSLog(@"inert %d",x);
                            xarray = [xarray arrayByAddingObject:[NSNumber numberWithInt:x]];
                        }
                        goThrough = YES;
                        hasObject = NO;
                    }
                    else
                    {
                        //                    y = row;
                        if(hasObject == NO)
                        {
//                            NSLog(@"inert %d",x);
                            xarray = [xarray arrayByAddingObject:[NSNumber numberWithInt:x]];
                        }
                        hasObject = YES;
                        goThrough = NO;
//                        NSLog(@"-X:%d col:%d",x,col);
                    }
                    
                }//if
                
            }//for
        }//for col
        if(xarray.count > 0)
        {
            int i = 0;
            int oldx = 0;
            int oldstepx = 0;
            NSArray* nArray = @[];
            for (NSNumber* xN in xarray) {
                
                if(i>0)
                {
                    int stepx = xN.intValue - oldx;
                    if (oldstepx> stepx && stepx < 3) {
                        
                    }
                    else
                    {
                        if (xN.intValue < imageWidth - 9) {
                            nArray = [nArray arrayByAddingObject:xN];
                        }
                        oldstepx = stepx;
                    }
                    
                }
                else
                {
                    if (xN.intValue < imageWidth - 9) {
                        nArray = [nArray arrayByAddingObject:xN];
                    }
                    
                }
                oldx = xN.intValue;
                i++;
            }
            
            if(nArray.count > 0)
            {
                NSDictionary* subDic =  @{
                                          @"from":[NSNumber numberWithInt:fromY],
                                          @"to":[NSNumber numberWithInt:toY],
                                          @"x":nArray,
                                          };
                
                
                gArray = [gArray arrayByAddingObject:subDic];
            }
            
        }
        
        fromY = toY;
    }
    
    int fromRow = 0;
    int toRow =0;
    
    int fromCol = 0;
    int toCol =0;
    int stepH;
    NSArray* lineObjectsArray = @[];
    for (NSDictionary* xDic in gArray) {
        
        NSArray* xposArray = xDic[@"x"];
        fromRow = [xDic[@"from"] intValue];
        toRow  = [xDic[@"to"] intValue];
        y = fromRow;
        
        NSArray* finalArray = @[];
        
        for (NSNumber* vNumber in xposArray) {
            toCol =vNumber.intValue;
            
            goThrough = NO;
            hasObject = NO;
            
            NSArray* subyarray = @[];
            
            stepH = toCol - fromCol;
            subyarray = [self checkHlineAtRectFrom:fromRow To:toRow From:fromCol to:toCol];
            if (subyarray.count > 1) {
                NSDictionary* tDic = @{
                                       @"fromX":[NSNumber numberWithInt:fromCol],
                                       @"toX":[NSNumber numberWithInt:toCol],
                                       @"fromY":[NSNumber numberWithInt:fromRow],
                                       @"toY":[NSNumber numberWithInt:toRow],
                                       @"lineY":subyarray,
                                       };
                finalArray = [finalArray arrayByAddingObject:tDic];
            }
//            NSLog(@"%@:from:%d to:%d",subyarray,fromCol,toCol);
            fromCol = toCol;
        }//for3
        
        lineObjectsArray = [lineObjectsArray arrayByAddingObject:finalArray];
        
    }
    
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    free(rgbImageBuf);// 创建dataProvider时已提供释放函数，这里不用free
//    NSLog(@"%@",gArray);
    return @{@"h":yarray,
             @"v":gArray,
             @"f":lineObjectsArray,
             };
}

-(NSArray*)checkHlineAtRectFrom:(int)fromRow To:(int)toRow From:(int)fromCol to:(int)toCol
{
    int pixlPos;
    BOOL goThrough = NO;
    BOOL hasObject =NO;
    int stepH = toCol - fromCol;
    int y = fromRow;
    int x = fromCol;
    NSArray* subyarray = @[];
    
    BOOL findFirst = NO;
    for (int row = fromRow; row < toRow+1&&row < imageHeight; row++) {
        
        int xindex = 0;
        int objects = 0;
        for (int col =fromCol; col < toCol; col++) {
            
            pixlPos = row*imageWidth + col;
            uint32_t *pCurPixel =  &rgbImageBuf[pixlPos];
            
            
            
            ColorARGB *ptr = (ColorARGB *)pCurPixel;
            if (ptr->r == 0 && ptr->b == 0 && ptr->g == 0) {
                xindex++;
            }
            else
            {
                objects++;
            }
            if(col == toCol-1)
            {
                if (xindex < stepH) {
                    
                    y = row;
                    
                    
                    
//                    NSLog(@"+Y:%d row:%d",y,row);
                    if(goThrough == NO)
                    {
                        //                        NSLog(@"inert %d",y);
                        subyarray = [subyarray arrayByAddingObject:[NSNumber numberWithInt:row]];
                        
                    }
                    else
                    {
                        if(row == toRow-1)
                        {
                            subyarray = [subyarray arrayByAddingObject:[NSNumber numberWithInt:row]];
                        }
                    }
                    goThrough = YES;
                    hasObject = NO;
                    findFirst = YES;
                }
                else
                {
                    
                    if(hasObject == NO)
                    {
                        //                        NSLog(@"inert %d",y);
                        
                        if (findFirst == YES) {
                            subyarray = [subyarray arrayByAddingObject:[NSNumber numberWithInt:row]];
                        }
                        
                    }
                    else
                    {
                        //                                if(row == toRow-1)
                        //                                {
                        //                                    subyarray = [subyarray arrayByAddingObject:[NSNumber numberWithInt:y]];
                        //                                }
                    }
                    
                    hasObject = YES;
                    goThrough = NO;
//                    NSLog(@"-Y:%d row:%d",y,row);
                }
                
            }//if
            
        }//for1
    }//for2
    
    return subyarray;
}
- (UIImage *) imageBgTransparentWith:(CGFloat)transMaxH :(CGFloat)transMinH :(CGFloat)transMaxV :(CGFloat)transMinV
{
    
    // 分配内存
    //    int top = 100;
    //    int step = 20;
    imageWidth = self.size.width;
    imageHeight = self.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    rgbImageBuf2 = (uint32_t *)malloc(bytesPerRow * imageHeight);
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    context = CGBitmapContextCreate(rgbImageBuf2, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    // 遍历像素
    
    uint32_t *pCurPtr = rgbImageBuf;
    uint32_t *pCurPtr2 = rgbImageBuf2;
    int pixlPos = 0;
    for (int row = 0; row < imageHeight; row++) {
        for (int col =0; col < imageWidth; col++) {
            
            pixlPos = row*imageWidth + col;
            uint32_t *pCurPixel =  &rgbImageBuf[pixlPos];
            
            uint8_t *ptr = (uint8_t *)pCurPixel;
            uint32_t *avgP = [self avgColor:row :col];
            
            
        }
    }
    int searchStep = 120;
    int searchbeginx = 0;
    int searchbeginy = 0;
    int searchendx = searchbeginx + searchStep;
    int searchendy = searchendx + searchStep;
    
    //    CGFloat maxtH,mintH,maxtV,mintV;
    maxtH = 0;
    mintV = 255;
    maxtV = 0;
    mintH = 255;
    
    [self findColorFieldAt:searchbeginx :searchbeginy :searchStep];
    
    searchbeginx = imageWidth-searchStep;
    if (searchbeginx < 0) {
        searchbeginx = 0;
    }
    searchbeginy = 0;
    searchendx = searchbeginx+searchStep;
    searchendy = searchbeginy+searchStep;
    //    [self findColorFieldAt:searchbeginx :searchbeginy :searchStep];
    
    [self partialAlphaEnableWith:transMaxH :transMinH :transMaxV :transMinV];
    
    
    for (int row = 0; row < imageHeight; row++) {
        for (int col =0; col < imageWidth; col++) {
            
            [self egdeAvgColor:row :col];
        }
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf2, bytesPerRow * imageHeight,ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    free(rgbImageBuf);// 创建dataProvider时已提供释放函数，这里不用free
    return resultUIImage;
}

- (ColorHVS) imageWith:(CGPoint)location
{
    
    
    imageWidth = self.size.width;
    imageHeight = self.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    
    // 创建context
    int row = location.y;
    int col = location.x;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    context = CGBitmapContextCreate(rgbImageBuf2, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    
    //    CGFloat maxtH,mintH,maxtV,mintV;
    maxtH = 0;
    mintV = 255;
    maxtV = 0;
    mintH = 255;
    
    
    ColorHVS color =  [self hvsColor:row :col];
    
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return color;
    
    
}
-(ColorHVS) hvsColor:(const int)row :(const int) col
{
    
    
    int x,y,xend,yend;
    ColorHVS color;
    color.h = 0;
    color.s = 0;
    color.v = 0;
    
    if(row < 0 || col < 0)
        return color;
    
    if(row > imageHeight || col > imageWidth)
        return color;
    
    
    x = col - matrix2/2;
    y = row - matrix2/2;
    xend = x+matrix2;
    yend = y+matrix2;
    imageWidth = self.size.width;
    imageHeight = self.size.height;
    if(x<0)
        x=0;
    if(y<0)
        y=0;
    if(xend >= imageWidth)
        xend = imageWidth-1;
    
    if(yend >= imageHeight)
        yend = imageHeight-1;
    int count = 0;
    int r,g,b;
    r = 0;
    g = 0;
    b = 0;
    BOOL findAlpha = NO;
    BOOL findNoAlpha = NO;
    for (int i = x; i<xend ; i++) {
        for (int j = y; j<yend; j++) {
            count++;
            
            int pPos = i + j*imageWidth;
            uint32_t *tPixel =  &rgbImageBuf[pPos];
            ColorARGB *p = (ColorARGB *)tPixel;
            
            r += p->r;
            g += p->g;
            b += p->b;
            if(p->a == 0)
                findAlpha = YES;
            else
                findNoAlpha = YES;
        }
    }
    
    
    r = r/count;
    b = b/count;
    g = g/count;
    int pixlPos = row*imageWidth + col;
    uint32_t *pCurPixel =  &rgbImageBuf[pixlPos];
    ColorARGB *ptr = (ColorARGB *)pCurPixel;
    ptr->b = b;
    ptr->g = g;
    ptr->r = r;
    
    float maxv = MAX(ptr->r, MAX(ptr->g, ptr->b));
    float minv = MIN(ptr->r, MIN(ptr->g, ptr->b));
    int hv = 0;
    if(maxv == ptr->r)
    {
        hv = ((float)(ptr->g-ptr->b))/(maxv -minv)*60;
    }
    if(maxv == ptr->g)
    {
        hv =  120 + ((float)(ptr->b - ptr->r))/(maxv -minv)*60;
    }
    if(maxv == ptr->b)
    {
        hv =  240 + ((float)(ptr->r - ptr->g))/(maxv -minv)*60;
    }
    
    if (hv < 0)
        hv = hv+ 360;
    
    color.h = hv;
    color.v = maxv;
    
    
    
    return color;
}
- (UIImage *) imageBgTransparentWithRadiur:(int)r
{
    
    // 分配内存
    //    int top = 100;
    //    int step = 20;
    matrixV = r;
    imageWidth = self.size.width;
    imageHeight = self.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    context = CGBitmapContextCreate(rgbImageBuf2, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    // 遍历像素
    
    uint32_t *pCurPtr = rgbImageBuf;
    uint32_t *pCurPtr2 = rgbImageBuf2;
    int pixlPos = 0;
    for (int row = 0; row < imageHeight; row++) {
        for (int col =0; col < imageWidth; col++) {
            
            pixlPos = row*imageWidth + col;
            
            [self avgColor:row :col];
            
            
        }
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight,ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    
    return resultUIImage;
}

/** 颜色变化 */
static void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void *)data);
}
@end
@interface MImageView ()
{
    CGPoint touchBeginPoint;
    CGPoint touchEndPoint;
    
    __block CGFloat v;
    __block BOOL moved;
    
    CGFloat indexValue;
    
    CGFloat touchX;
}
@end
@implementation MImageView
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    touchBeginPoint.x = p.x;
    touchBeginPoint.y = p.y;
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    //    CGPoint p = [[touches anyObject] locationInView:self];
    //    CGFloat detx,dety;
    //    detx = p.x - touchBeginPoint.x;
    //    dety = p.y - touchBeginPoint.y;
    //    CGFloat x,y,w,h;
    //    x = self.frame.origin.x;
    //    y = self.frame.origin.y;
    //    w = self.frame.size.width;
    //    h = self.frame.size.height;
    //
    ////    self.frame  = CGRectMake(x+detx, y+dety, w, h);
    //    //    touchBeginPoint.x = p.x;
    //    //    touchBeginPoint.y = p.y;
    //
    //    CGFloat imagew = self.image.size.width;
    //    CGFloat ratio;
    //    CGFloat scale;
    //    if(imagew == 0)
    //    {
    //        ratio = 1.0;
    //        scale = 1.0;
    //    }
    //    else
    //    {
    //        ratio = self.image.size.height/self.image.size.width;
    //        scale = w/imagew;
    //    }
    //
    //    CGPoint location;
    //    location.x = p.x/scale;
    //    location.y = p.y/scale;
    
    
    
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    CGPoint p = [[touches anyObject] locationInView:self];
    CGFloat detx,dety;
    detx = p.x - touchBeginPoint.x;
    dety = p.y - touchBeginPoint.y;
    CGFloat x,y,w,h;
    x = self.frame.origin.x;
    y = self.frame.origin.y;
    w = self.frame.size.width;
    h = self.frame.size.height;
    
    
    CGFloat imagew = self.image.size.width;
    CGFloat ratio;
    CGFloat scale;
    if(imagew == 0)
    {
        ratio = 1.0;
        scale = 1.0;
    }
    else
    {
        ratio = self.image.size.height/self.image.size.width;
        scale = w/imagew;
    }
    
    CGPoint location;
    location.x = p.x/scale;
    location.y = p.y/scale;
    ColorHVS color =  [self.image imageWith:location];
    
    
    
    if([self.delegate respondsToSelector:@selector(drawLocation:with:)])
    {
        CGPoint color_p;
        color_p.x = color.h;
        color_p.y = color.v;
        [self.delegate drawLocation:location with:color_p];
    }
    
}
-(void)calculateGrid
{
    
}
-(void)leftUpCornerEliminate
{
    CGPoint p;
    CGFloat x,y,w,h;
    x = self.frame.origin.x;
    y = self.frame.origin.y;
    w = self.frame.size.width;
    h = self.frame.size.height;
    p.x = w/4.0;
    p.y = h/4.0;
    CGFloat detx,dety;
    detx = 0;
    dety = 0;
    
    CGFloat imagew = self.image.size.width;
    CGFloat ratio;
    CGFloat scale;
    if(imagew == 0)
    {
        ratio = 1.0;
        scale = 1.0;
    }
    else
    {
        ratio = self.image.size.height/self.image.size.width;
        scale = w/imagew;
    }
    
    CGPoint location;
    location.x = p.x/scale;
    location.y = p.y/scale;
    ColorHVS color =  [self.image imageWith:location];
    
    if([self.delegate respondsToSelector:@selector(locationChanged:)])
    {
        location.x = color.h;
        location.y = color.v;
        [self.delegate locationChanged:location];
    }
}
-(void)rightUpCornerEliminate
{
    CGPoint p;
    CGFloat x,y,w,h;
    x = self.frame.origin.x;
    y = self.frame.origin.y;
    w = self.frame.size.width;
    h = self.frame.size.height;
    p.x = 3*w/4.0;
    p.y = h/4.0;
    CGFloat detx,dety;
    detx = 0;
    dety = 0;
    
    
    //    self.frame  = CGRectMake(x+detx, y+dety, w, h);
    //    touchBeginPoint.x = p.x;
    //    touchBeginPoint.y = p.y;
    //    if([self.delegate respondsToSelector:@selector(locationChanged:)])
    //    {
    //        [self.delegate locationChanged:p];
    //    }
    CGFloat imagew = self.image.size.width;
    CGFloat ratio;
    CGFloat scale;
    if(imagew == 0)
    {
        ratio = 1.0;
        scale = 1.0;
    }
    else
    {
        ratio = self.image.size.height/self.image.size.width;
        scale = w/imagew;
    }
    
    CGPoint location;
    location.x = p.x/scale;
    location.y = p.y/scale;
    ColorHVS color =  [self.image imageWith:location];
    
    if([self.delegate respondsToSelector:@selector(locationChanged:)])
    {
        location.x = color.h;
        location.y = color.v;
        [self.delegate locationChanged:location];
    }
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}
@end

