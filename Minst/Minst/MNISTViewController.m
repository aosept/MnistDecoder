//
//  MINSTViewController.m
//  MLPractice
//
//  Created by 威 沈 on 07/08/2018.
//  Copyright © 2018 ShenWei. All rights reserved.
//

#import "MNISTViewController.h"
#import "MnistDecoder.h"
#import "UIImage+SV.h"
static float uniform(float min, float max) {
    
    return rand() / (RAND_MAX + 1.0) * (max - min) + min;
}
static float dotproduct(float*w,float*x,float b,int row,int col)
{
    float r = 0;
    for (int i = 0; i< row; i++) {
        for (int j=0; j< col; j++) {
            r += w[i*col + j]*x[i];
        }
    }
    r += b;
    r = fmin(fmax(r/6.0, 0), 1);
    return r;
}
@interface MNISTViewController ()
@property (nonatomic,strong) MnistDecoder* decoder;
@end
@implementation MNISTViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    NSString* fileName = @"train-images";
    self.decoder = [MnistDecoder new];
    [self.decoder decodeMinstImage:fileName];
    
    NSString* labelFileName = @"train-labels";
    [self.decoder decodeMinstLabel:labelFileName];
    
    self.indexSlider.maximumValue = self.decoder.count;
    [self imageOfIndex:0];
    
    NSLog(@"");
}

-(void)sliderDidChanged:(UISlider*)slider
{
    
    if(slider == self.indexSlider)
    {
        
        NSLog(@"indexSlider ChangeValue%f",slider.value);
        [self imageOfIndex:slider.value];
    }
    
}
-(void)imageOfIndex:(int)indexOfM
{
    
    uint8_t* imagedata = [self.decoder imageDataOfIndex:indexOfM];
    int v = [self.decoder labelDataOfIndex:indexOfM];
    

    
    UIImage* image = [UIImage arrayToImage:imagedata with:28 and:28];
    self.nImageView.image = image;
    
    free(imagedata);
    
    self.numberLabel.text = [NSString stringWithFormat:@"%d",v];
    self.maxLabel.text = [NSString stringWithFormat:@"%d/%d",(int)self.indexSlider.value,self.decoder.count];
    printf("\n%d\n",v);
}


@end
