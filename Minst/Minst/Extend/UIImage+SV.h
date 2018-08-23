
//
//  UIImage+SV.h
//  tripaccounting
//
//  Created by 沈 威 on 15/2/28.
//  Copyright (c) 2015年 Shen Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (SV)
-(UIImage*)matrixToImage:(NSArray*)matrixArray;
+(UIImage*)arrayToImage:(uint8_t*)array with:(int)imageH and:(int)imageW;
+(UIImage*)matrixToImage:(const float**)array withH:(int)imageH andW:(int)imageW;
+ (UIImage *)getImageWithUrlStringForImage:(NSString *)imageString;
+(UIImage*) GetSavedImageWithName:(NSString*) aFileName;
+(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
+(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
+(UIImage *) miniImageWithContentsOfCacheFile:(NSString*)filePath;
- (UIImage *)fixOrientation;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFitToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillToSize:(CGSize)newSize;
@property (nonatomic,assign) float transMaxH;
@property (nonatomic,assign) float transMaxV;
@property (nonatomic,assign) float transMinH;
@property (nonatomic,assign) float transMinV;

//+(UIImage*) GetSavedImageWithName:(NSString*) aFileName;
+(UIImage *) imageCompressForHeight:(UIImage *)sourceImage targetHeight:(CGFloat)defineHeight;
//+(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
//+(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
//+(UIImage *) miniImageWithContentsOfCacheFile:(NSString*)filePath;
+(UIImage *)ImageWithContentsOfOriginFile:(NSString*)filePath;
+(NSString*)imageFileName:(NSString*)aFileName;
//- (UIImage *)fixOrientation;

- (UIImage *) imageBgTransparentWith:(CGFloat)transMaxH :(CGFloat)transMinH :(CGFloat)transMaxV :(CGFloat)transMinV;

- (UIImage *) imageBgTransparentWithRadiur:(int)r;
- (NSDictionary *) imageGridCalcolate;
@end
@protocol MImageViewDelegate <NSObject>
@optional
-(void)locationChanged:(CGPoint)p;
-(void)drawLocation:(CGPoint)p with:(CGPoint)color;
@end
@interface MImageView :UIImageView
@property(nonatomic,weak) id <MImageViewDelegate> delegate;
-(void)leftUpCornerEliminate;
-(void)rightUpCornerEliminate;
-(void)calculateGrid;
@end
