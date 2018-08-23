//Automatically generated code by "Happy Coding"
//Free donwload the App from :
//https://itunes.apple.com/us/app/ui-code/id1259075639?ls=1&mt=8
//
#import <UIKit/UIKit.h>


@class MNISTVC;
@protocol MNISTVCDelegate <NSObject>

-(void)updateMNISTVC:(MNISTVC*)vc WithDic:(NSDictionary*)dic;


-(void)changeMNISTVC:(MNISTVC*)vc WithName:(NSString*)name andValue:(CGFloat)value;

@end
@interface MNISTVC : UIViewController
{
    CGFloat offsetY;
    CGFloat keyBoardHieght;
}
@property (nonatomic,weak) id <MNISTVCDelegate> delegate;

@property (nonatomic,strong) UIImageView * nImageView;

@property (nonatomic,strong) UILabel * numberLabel;

@property (nonatomic,strong) UILabel * v3Label;

@property (nonatomic,strong) UISlider * indexSlider;

@property (nonatomic,strong) UILabel * minLabel;

@property (nonatomic,strong) UILabel * maxLabel;
-(void)refreshFromDiction:(NSDictionary*)dic;
-(NSDictionary*)configSetting;
@end
