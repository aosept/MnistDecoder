//
//  MnistDecoder.h
//  MLPractice
//
//  Created by 威 沈 on 07/08/2018.
//  Copyright © 2018 ShenWei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MnistDecoder : NSObject

@property(nonatomic,assign) int count;
@property(nonatomic,assign) int labelCount;
@property(nonatomic,assign) int imageRow;
@property(nonatomic,assign) int imageCol;
-(void)decodeMinstImage:(NSString*)fileName;
-(uint8_t*)imageDataOfIndex:(int)index;

-(void)decodeMinstLabel:(NSString*)fileName;
-(uint8_t)labelDataOfIndex:(int)index;
@end
