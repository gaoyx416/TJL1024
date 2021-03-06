//
//  Example2Controller.m
//  MagicPie
//
//  Created by Alexander on 30.12.13.
//  Copyright (c) 2013 Alexandr Corporation. All rights reserved.
//

#import "Example2Controller.h"
#import "Example2PieView.h"
#import "MyPieElement.h"
#import "PieLayer.h"

@interface Example2Controller ()

@property (nonatomic, strong)Example2PieView* pieView;

@end

@implementation Example2Controller
@synthesize pieView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    pieView = [[Example2PieView alloc]initWithFrame:CGRectMake(0, 50,375, 375)];
    pieView.backgroundColor = [ UIColor whiteColor];
    for(int year = 2001; year <= 2004; year++){
        MyPieElement* elem = [MyPieElement pieElementWithValue:(5+arc4random()%8) color:[self randomColor]];
        elem.title = [NSString stringWithFormat:@"%d year", year];
        [pieView.layer addValues:@[elem] animated:NO];
    }
    
    [self.view addSubview:pieView];
    //mutch easier do this with array outside
    pieView.layer.transformTitleBlock = ^(PieElement* elem){
        return [(MyPieElement*)elem title];
    };
    pieView.layer.showTitles = ShowTitlesAlways;
}

- (UIColor*)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (IBAction)backPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)randomValuesPressed:(id)sender
{
    [PieElement animateChanges:^{
        for(PieElement* elem in pieView.layer.values){
            elem.val = (5+arc4random()%8);
        }
    }];
}

- (IBAction)randomColorPressed:(id)sender
{
    [PieElement animateChanges:^{
        for(PieElement* elem in pieView.layer.values){
            elem.color = [self randomColor];
        }
    }];
}
@end
