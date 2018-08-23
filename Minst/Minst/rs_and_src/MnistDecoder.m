//
//  MnistDecoder.m
//  MLPractice
//
//  Created by 威 沈 on 07/08/2018.
//  Copyright © 2018 ShenWei. All rights reserved.
//

#import "MnistDecoder.h"
int reverseInt (int i) {
    unsigned char c1, c2, c3, c4;
    
    
    c1 = i & 255;
    c2 = (i >> 8) & 255;
    c3 = (i >> 16) & 255;
    c4 = (i >> 24) & 255;
    
    return ((int)c1 << 24) + ((int)c2 << 16) + ((int)c3 << 8) + c4;
    
};

@interface MnistDecoder()
@property (nonatomic,assign) int startPosistion;
@property (nonatomic,assign) int startLabelPosistion;
@property (nonatomic,assign) int imageSize;
@property(nonatomic,strong) NSData * data;
@property(nonatomic,strong) NSData * labeldata;
@end
@implementation MnistDecoder
-(void)decodeMinstImage:(NSString*)fileName
{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"idx3-ubyte"];
    self.data = [NSData dataWithContentsOfFile:filePath];
    const void* databuffer = self.data.bytes;
    
    const uint8_t * buffer = (uint8_t *)databuffer;
    uint32_t *count =  (uint32_t *)databuffer;
    int c =   count[1];
    
    c = reverseInt(c);
    self.count = c;
    int row = count[2];
    int col = count[3];
    
    
    row = reverseInt(row);
    col = reverseInt(col);
    
    self.imageCol = col;
    self.imageRow = row;
    self.imageSize = row*col;
    self.startPosistion = 16;

    
    
    NSLog(@"%lu",(unsigned long)self.data.length);
}
-(uint8_t*)imageDataOfIndex:(int)index
{
    
    const uint8_t * buffer = (uint8_t *)self.data.bytes;
   
    uint8_t* imagebuffer =  malloc(self.imageSize*sizeof(uint8_t));
    
      int  start = self.imageSize*index+self.startPosistion;
        for (int i = 0; i < self.imageRow; i++) {
            for (int j = 0; j< self.imageCol; j++) {
                uint8_t v = buffer[start+i*self.imageRow + j];
                imagebuffer[i*self.imageRow + j] = v;
//                printf("%d\t",v);
            }
//            printf("\n");
        }
    return imagebuffer;
}
-(void)decodeMinstLabel:(NSString*)fileName
{
    self.startLabelPosistion = 8;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"idx1-ubyte"];
    self.labeldata = [NSData dataWithContentsOfFile:filePath];
    
    const void* databuffer = self.labeldata.bytes;
    uint32_t *count =  (uint32_t *)databuffer;
    int c =   count[1];
    c = reverseInt(c);
    self.labelCount = c;

}
-(uint8_t)labelDataOfIndex:(int)index
{
    const uint8_t * buffer = (uint8_t *)self.labeldata.bytes;

    int  start = index+self.startLabelPosistion;
    uint8_t v = buffer[start];
    return v;
}
@end
