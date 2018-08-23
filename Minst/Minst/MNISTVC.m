
//Automatically generated code by "Happy Coding"
//Free donwload the App from :
//https://itunes.apple.com/us/app/ui-code/id1259075639?ls=1&mt=8
//




#import "MNISTVC.h"

@interface MNISTVC ()

@end

@implementation MNISTVC

-(UIImageView*)nImageView
{
    if (_nImageView == nil) {
        _nImageView = [UIImageView new];
        _nImageView.backgroundColor = [UIColor whiteColor];
        _nImageView.layer.borderWidth = 0;
        _nImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return _nImageView;
}


-(UILabel*)numberLabel
{
    if (_numberLabel == nil) {
        _numberLabel = [UILabel new];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.adjustsFontSizeToFitWidth = YES;
        _numberLabel.numberOfLines=0;
        _numberLabel.layer.borderWidth = 0;
        _numberLabel.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return _numberLabel;
}


-(UILabel*)v3Label
{
    if (_v3Label == nil) {
        _v3Label = [UILabel new];
        _v3Label.backgroundColor = [UIColor clearColor];
        _v3Label.adjustsFontSizeToFitWidth = YES;
        _v3Label.numberOfLines=0;
        _v3Label.layer.borderWidth = 0;
        _v3Label.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return _v3Label;
}


-(UISlider*)indexSlider
{
    if (_indexSlider == nil) {
        _indexSlider = [self buildSlider];
    }
    return _indexSlider;
}

-(UILabel*)minLabel
{
    if (_minLabel == nil) {
        _minLabel = [UILabel new];
        _minLabel.backgroundColor = [UIColor whiteColor];
        _minLabel.adjustsFontSizeToFitWidth = YES;
        _minLabel.numberOfLines=0;
        _minLabel.layer.borderWidth = 0;
        _minLabel.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return _minLabel;
}


-(UILabel*)maxLabel
{
    if (_maxLabel == nil) {
        _maxLabel = [UILabel new];
        _maxLabel.backgroundColor = [UIColor whiteColor];
        _maxLabel.adjustsFontSizeToFitWidth = YES;
        _maxLabel.numberOfLines=0;
        _maxLabel.layer.borderWidth = 0;
        _maxLabel.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return _maxLabel;
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    [self.view addSubview:self.v3Label];
    
    [self.view addSubview:self.numberLabel];
    
    [self.view addSubview:self.nImageView];
    
    [self.view addSubview:self.minLabel];
    
    [self.view addSubview:self.indexSlider];
    
    [self.view addSubview:self.maxLabel];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat rate = [self rateOfwidth];
    if(rate == 0)
    {
        rate = [self screenW]/667.0;
    }
    
    self.v3Label.text = @"Number：";
    
    self.indexSlider.minimumValue = 0;
    
    self.indexSlider.value = 0;
    
    self.indexSlider.maximumValue = 0;
    
    self.minLabel.adjustsFontSizeToFitWidth = YES;
    
    self.minLabel.textAlignment = NSTextAlignmentLeft;
    
    self.minLabel.backgroundColor = [UIColor clearColor];
    
    self.minLabel.text = @"0";
    
    self.minLabel.font =[UIFont systemFontOfSize:15*rate];
    
    self.maxLabel.adjustsFontSizeToFitWidth = YES;
    
    self.maxLabel.textAlignment = NSTextAlignmentLeft;
    
    self.maxLabel.backgroundColor = [UIColor clearColor];
    
    self.maxLabel.text = @"0";
    
    self.maxLabel.font =[UIFont systemFontOfSize:15*rate];
    
}

-(void)viewDidLayoutSubviews
{
    CGFloat left,top;
    CGFloat x,y,w,h;
    CGFloat rate = [self rateOfwidth];
    CGFloat rateH = [self rateOfHeight];
    CGFloat xInterval = 10.0,yInterval = 10.0;
    left = 16.10*rate;
    top = 77.00;
    CGFloat sw = [self screenW];
    CGFloat wr = sw/375.0;
    CGFloat wh = [self screenH];
    CGFloat nomalR = wh - 667.0*wr;
    CGFloat fixTop = 0;
    CGFloat fixLeft = 0;
    if (@available(iOS 11.0, *)) {
        fixTop = self.view.safeAreaInsets.top;//remove this line if has error
    } else {
        fixTop = 0;
    }
    if (@available(iOS 11.0, *)) {
        fixLeft = self.view.safeAreaInsets.left;//remove this line if has error
    } else {
        fixLeft = 0;
    }
    left += fixLeft;
    top += fixTop;
    top += offsetY;
    
    CGFloat    v3Label_xInterval = 48.40*rate;
    CGFloat    v3Label_Width = 120.00*rate;
    CGFloat    v3Label_Height = 26.40*rateH;
    CGFloat    numberLabel_xInterval = 10.00*rate;
    CGFloat    numberLabel_Width = 30.00*rate;
    CGFloat    nImageView_xInterval = 204.40*rate;
    CGFloat    nImageView_Width = 60.00*rate;
    CGFloat    nImageView_Height = 60.00*rateH;
    CGFloat    minLabel_yInterval = 11.00*rateH;
    CGFloat    minLabel_Width = 30.00*rate;
    CGFloat    minLabel_Height = 29.50*rateH;
    CGFloat    indexSlider_xInterval = 10.03*rate;
    CGFloat    indexSlider_Width = 262.74*rate;
    CGFloat    indexSlider_Height = 29.45*rateH;
    CGFloat    maxLabel_xInterval = 10.00*rate;
    CGFloat    maxLabel_Width = 30.00*rate;
    
    xInterval = v3Label_xInterval;
    x =  left + xInterval;
    y =  top;
    w = v3Label_Width;
    h = v3Label_Height;
    self.v3Label.frame = CGRectMake(x, y, w, h);
    
    xInterval = numberLabel_xInterval;
    x =  x + w + xInterval;
    y =  top;
    w = numberLabel_Width;
    self.numberLabel.frame = CGRectMake(x, y, w, h);
    
    xInterval = nImageView_xInterval;
    x =  left + w + xInterval;
    w = nImageView_Width;
    h = nImageView_Height;
    self.nImageView.frame = CGRectMake(x, y, w, h);
    
    yInterval = minLabel_yInterval;
    x =  left;
    y =  y + h + yInterval;
    w = minLabel_Width;
    h = minLabel_Height;
    self.minLabel.frame = CGRectMake(x, y, w, h);
    
    xInterval = indexSlider_xInterval;
    x =  x + w + xInterval;
    w = indexSlider_Width;
    h = indexSlider_Height;
    self.indexSlider.frame = CGRectMake(x, y, w, h);
    
    xInterval = maxLabel_xInterval;
    x =  x + w + xInterval;
    w = maxLabel_Width;
    self.maxLabel.frame = CGRectMake(x, y, w, h);
    
}

-(void)sliderDidChanged:(UISlider*)slider
{
    
    if(slider == self.indexSlider)
    {
        if([self.delegate respondsToSelector:@selector(changeMNISTVC:WithName:andValue:)])
        {
            [self.delegate changeMNISTVC:self WithName:@"indexSlider" andValue:slider.value];
        }
        NSLog(@"indexSlider ChangeValue%f",slider.value);
    }
    
}

-(UISlider*)buildSlider
{
    
    UISlider* pSlider = [UISlider new];
    [pSlider addTarget:self action:@selector(sliderDidChanged:) forControlEvents:UIControlEventValueChanged];
    pSlider.maximumValue = 100;
    pSlider.minimumValue = 0;
    
    return pSlider;
}
-(void)buttonDidClicked:(UIButton*)button

{
    
}

-(void)refreshFromDiction:(NSDictionary*)dic
{
    
    /*
     @"numberLabel":@"",
     @"v3Label":@"",
     @"indexSlider":@100,
     @"minLabel":@"",
     @"maxLabel":@"",
     
     */
    if(dic)
    {
        if(dic[@"numberLabel"])
            self.numberLabel.text = [NSString stringWithFormat:@"%@",dic[@"numberLabel"]];
        
        if(dic[@"v3Label"])
            self.v3Label.text = [NSString stringWithFormat:@"%@",dic[@"v3Label"]];
        
        if(dic[@"indexSlider"])
            self.indexSlider.value = [dic[@"indexSlider"] floatValue];
        
        if(dic[@"minLabel"])
            self.minLabel.text = [NSString stringWithFormat:@"%@",dic[@"minLabel"]];
        
        if(dic[@"maxLabel"])
            self.maxLabel.text = [NSString stringWithFormat:@"%@",dic[@"maxLabel"]];
        
        
    }
}

-(void)keyboardShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyBoardHieght=keyBoardRect.size.height;
    
    
}

-(void)keyboardHide:(NSNotification *)note
{
    keyBoardHieght = 0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIButton*)buildButtonWith:(NSString*)title andAction:(SEL)action
{
    UIButton * button = [UIButton new];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 1.0;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.9 green:0.7 blue:0.8 alpha:1.0] forState:UIControlStateHighlighted];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    return button;
}


-(CGFloat)screenH
{
    
    if (self.view.bounds.size.width < self.view.bounds.size.height) {
        return self.view.bounds.size.height;
    }
    else
        return self.view.bounds.size.width;
}

-(CGFloat)screenW
{
    
    if (self.view.bounds.size.width < self.view.bounds.size.height) {
        return self.view.bounds.size.width;
    }
    else
        return self.view.bounds.size.height;
}
-(CGFloat)rateOfwidth
{
    CGFloat rate = self.view.bounds.size.width/375.0;
    return rate;
}
-(CGFloat)rateOfHeight
{
    CGFloat rate = self.view.bounds.size.height/667.0;
    return rate;
}
-(BOOL)islandScape
{
    if (self.view.bounds.size.width < self.view.bounds.size.height) {
        return NO;
    }
    else
        return YES;
}
@end















//the end
