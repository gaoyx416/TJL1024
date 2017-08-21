//
//  STLogController.m
//  Diabetes
//
//  Created by xuqidong on 16/3/1.
//  Copyright © 2016年 hlcc. All rights reserved.
//

#import "STLogController.h"
#import "STLogView.h"
#import "STDietRecordViewController.h"
#import "STMedicationController.h"
#import "LogDateHeaderView.h"

#define TYPECOUNT 5

#define IntTOSting(__int__) [NSString stringWithFormat:@"%d",__int__]


@interface STLogController()<UIPickerViewDelegate,UIPickerViewDataSource,STDietRecordVCDelegate>
{
    int days;
    
    NSArray *BloodArr;
    
    UIScrollView *TypeScrollview;
    
    UIScrollView *BloodSugarScrollview;//血糖
    
    UILabel *yearLab;
    UILabel *monthLab;
    //时间选择器
    UIView *alertTimeView;
    UIView *alertTimeBackGroundView;
    UIPickerView *timePickerView;
    UILabel *alertTimeLab;
    int year;
    int month;
}

@property (nonatomic,strong) LogDateHeaderView *headerView;

@end

@implementation STLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"指尖血（点击单元格编辑）"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bloodClick:) name:@"bloodClick" object:nil];//监测异常
    
    self.view.backgroundColor = RGB(241, 241, 245);

    NSDate *date = [NSDate date];
    year         = [[date toString:@"yyyy"] intValue];
    month        = [[date toString:@"MM"] intValue];
    
    
    [self setLeftBtnImgNamed:nil];
    [self setRightBtnImgNamed:@"iconfont-shuju"];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self makeTimeSelectView];//时间选择
    [self makeTypeScrollview];
    
    [self makeTabble];
    
//    //获取所有数据
    [self getData];
}

- (void)bloodArrHaveData
{
    if (BloodArr.count>0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - - 时间选择
- (void)makeTimeSelectView{
    UIButton *TimeSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    TimeSelectBtn.frame = CGRectMake(0, 8, SCREEN_WIDTH, 40);
    [TimeSelectBtn addTarget:self action:@selector(TimeSelectDown) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:TimeSelectBtn];
    
    TimeSelectBtn.backgroundColor = [UIColor whiteColor];
    yearLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2-20, TimeSelectBtn.height)];
    yearLab.text = [NSString stringWithFormat:@"%d年",year];
    yearLab.textColor = RGB(91, 92, 89);
    yearLab.font = [UIFont systemFontOfSize:16];
    yearLab.textAlignment = NSTextAlignmentCenter;
    [TimeSelectBtn addSubview:yearLab];
    UIImageView *sanjiaoImg = [[UIImageView alloc] initWithFrame:CGRectMake(yearLab.width/2+25+8, 0, 10, 8.2)];
    sanjiaoImg.x = yearLab.centerY;
    sanjiaoImg.image = GL_IMAGE(@"Triangle 1");
    [TimeSelectBtn addSubview:sanjiaoImg];
    
    monthLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2-20, TimeSelectBtn.height)];
    monthLab.text = [NSString stringWithFormat:@"%d月",month];
    monthLab.textColor = RGB(91, 92, 89);
    monthLab.font = [UIFont systemFontOfSize:16];
    monthLab.textAlignment = NSTextAlignmentCenter;
    [TimeSelectBtn addSubview:monthLab];
    UIImageView *sanjiaoImg1 = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+monthLab.width/2+10+7.6, 0, 10, 8.2)];
    sanjiaoImg1.centerY = monthLab.centerY;
    sanjiaoImg1.image = GL_IMAGE(@"Triangle 1");
    [TimeSelectBtn addSubview:sanjiaoImg1];
    
    //竖线
    UIView *line         = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, 0.5, TimeSelectBtn.height-6)];
    line.backgroundColor = RGB(241, 241, 245);
    [TimeSelectBtn addSubview:line];
    line.top             = 3;
    line.width           = 1;
}

- (void)TimeSelectDown{
    alertTimeView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    alertTimeView.backgroundColor = [UIColor blackColor];
    alertTimeView.alpha           = 0.4;
    [self.view.window addSubview:alertTimeView];
    
    alertTimeBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0, 0)];
    alertTimeBackGroundView.backgroundColor = [UIColor whiteColor];
    alertTimeBackGroundView.layer.cornerRadius = 5;
    [self.view.window addSubview:alertTimeBackGroundView];
    
    //动画
    [UIView animateWithDuration:0.2 animations:^{
        alertTimeBackGroundView.frame = CGRectMake(47, 0, SCREEN_WIDTH-2*47, 311);
         alertTimeBackGroundView.centerY = self.view.centerY-32;
    } completion:^(BOOL finished) {
        alertTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, alertTimeBackGroundView.width, 47)];
        alertTimeLab.text = [NSString stringWithFormat:@"%d年%d月",year,month];
        alertTimeLab.textColor = TCOL_MAIN;
        alertTimeLab.font = [UIFont systemFontOfSize:19];
        alertTimeLab.textAlignment = NSTextAlignmentCenter;
        [alertTimeBackGroundView addSubview:alertTimeLab];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 47, alertTimeBackGroundView.width ?: SCREEN_WIDTH, 0.5)];
        line.backgroundColor = TCOL_MAIN;
        [alertTimeBackGroundView addSubview:line];
        
        timePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0,30,alertTimeBackGroundView.width,240)];
        timePickerView.delegate = self;
        timePickerView.dataSource =  self;
        NSDate *minDate = [[NSDate alloc] initWithTimeIntervalSince1970:1970-01-01];
        NSDate *maxDate = [NSDate date];
//        timePickerView
//        timePickerView.minimumDate = minDate;
//        timePickerView.maximumDate = maxDate;
        timePickerView.showsSelectionIndicator = YES;
        [alertTimeBackGroundView addSubview:timePickerView];
        
        [timePickerView selectRow:year-2000 inComponent:0 animated:YES];
        [timePickerView selectRow:month-1 inComponent:1 animated:YES];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake((alertTimeBackGroundView.width/2-90)/2, 266, 90, 30);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:RGB(128, 129, 127) forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        cancelBtn.layer.cornerRadius = 5;
        cancelBtn.layer.borderWidth = 1;
        cancelBtn.layer.borderColor = RGB(128, 129, 127).CGColor;
        [cancelBtn addTarget:self action:@selector(cancelDown) forControlEvents:UIControlEventTouchUpInside];
        [alertTimeBackGroundView addSubview:cancelBtn];
        
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        okBtn.frame = CGRectMake((alertTimeBackGroundView.width/2-90)/2+alertTimeBackGroundView.width/2, 266, 90, 30);
        [okBtn setTitle:@"确定" forState:UIControlStateNormal];
        [okBtn setTitleColor:TCOL_MAIN forState:UIControlStateNormal];
        okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        okBtn.layer.cornerRadius = 5;
        okBtn.layer.borderWidth = 1;
        okBtn.layer.borderColor = TCOL_MAIN.CGColor;
        [okBtn addTarget:self action:@selector(okDown) forControlEvents:UIControlEventTouchUpInside];
        [alertTimeBackGroundView addSubview:okBtn];
    }];
    

}
- (void)cancelDown{
    
    for (UIView *view in alertTimeBackGroundView.subviews) {
        [view removeFromSuperview];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        alertTimeBackGroundView.frame = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0, 0);
        alertTimeView.alpha = 0;
    } completion:^(BOOL finished) {
        [alertTimeView removeFromSuperview];
        [alertTimeBackGroundView removeFromSuperview];
    }];
}

- (void)okDown{
    year = (int)[timePickerView selectedRowInComponent:0]+2000;
    month = (int)[timePickerView selectedRowInComponent:1]+1;
    [self cancelDown];
    yearLab.text = [NSString stringWithFormat:@"%d年",year];
    monthLab.text = [NSString stringWithFormat:@"%d月",month];
    
    //重新请求数据
    [self getData];
    
    UIButton *tmpBtn;
    for (NSInteger i = 0;i < TYPECOUNT;i++) {
        UIButton *btn = [self.view viewWithTag:2310 + i];
        if (btn.selected) {
            tmpBtn = btn;
        }
    }
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger yrow = [pickerView selectedRowInComponent:0];
    NSInteger mrow = [pickerView selectedRowInComponent:1];
    alertTimeLab.text = [NSString stringWithFormat:@"%ld年%ld月",yrow+2000,mrow+1];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 1) {//月
        return 12;
    }else if(component == 0){//年
        NSDate *date = [NSDate date];
        return [[date toString:@"yyyy"] intValue] - 1999;
    }else{
        return 1;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *myView = nil;
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 30)];
    myView.textAlignment = NSTextAlignmentCenter;
    myView.font = [UIFont systemFontOfSize:20];         //用label来设置字体大小
    myView.backgroundColor = [UIColor clearColor];
    myView.textColor = RGB(74, 74, 74);
    if (component == 0) {
        myView.text = [NSString stringWithFormat:@"%ld",2000+(long)row];
    }else if (component == 1){
        myView.text = [NSString stringWithFormat:@"%ld",(long)row+1];
    }
    return myView;
}



#pragma mark - - 设置滚动
- (void)setIndex:(NSString*)index{
    UIButton *btn = (UIButton*)[self.view viewWithTag:2310+[index intValue]];
    [self changeType:btn];
}

- (void)changeType:(UIButton*)sender{
    for (int i=2310; i<2310+TYPECOUNT; i++) {
        UIButton *btn = (UIButton*)[self.view viewWithTag:i];
        btn.selected = NO;
    }
    sender.selected = YES;
    
    NSInteger index = sender.tag-2310;

    
    UIView *line = (UIView*)[self.view viewWithTag:1101];
    [UIView animateWithDuration:0.2 animations:^{
        line.frame = CGRectMake(index*(SCREEN_WIDTH/TYPECOUNT), 39, SCREEN_WIDTH/TYPECOUNT, 2);
        TypeScrollview.contentOffset = CGPointMake(index*SCREEN_WIDTH, 0);
    }];
}

#pragma mark - - makeTypeScrollview
- (void)makeTypeScrollview{
    TypeScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 42+64, SCREEN_WIDTH, SCREEN_HEIGHT-(42 + 64 + 49))];
    TypeScrollview.pagingEnabled = YES;
    TypeScrollview.scrollEnabled = NO;
    TypeScrollview.contentSize   = CGSizeMake(TYPECOUNT*SCREEN_WIDTH, TypeScrollview.height);
    [self addSubView:TypeScrollview];
}

#pragma mark - - makeTabble
- (void)makeTabble{
    //血糖
    [self BloodSugarView];
    
    //获取所有数据
    [self getData];
}

- (void)BloodSugarView{
    [self addSubView:self.headerView];
    
    WS(ws);
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ws.view).offset(64);
        make.centerX.equalTo(ws.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 42));
    }];
    
    //绘制表头
    [TypeScrollview addSubview:[STLogView makeHeaderView]];
}

- (LogDateHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [LogDateHeaderView new];
        WS(ws);
        _headerView.dateChange = ^{
            [ws loadBloodSugar];
        };
    }
    return _headerView;
}

#pragma mark - - HTTP 血糖数据
- (void)loadBloodSugar{
    NSDictionary *dic = @{
                          @"FuncName":@"getBloodValueByMonthNew",
                          @"InField":@{
                              @"ACCOUNT":USER_ACCOUNT,	//帐号
//                              @"YEAR" : @"2017",
//                              @"MONTH" : @"8",
                              @"BEGINDATE":self.headerView.leftDateBtn.lbl.text, //起始日期
                              @"ENDDATE":self.headerView.rightDateBtn.lbl.text,  //结束日期
                              @"DEVICE":@"1"
                          },
                          @"OutField":@[]
                          };
    [GL_Requst postWithParameters:dic SvpShow:true success:^(GLRequest *request, id response) {
        NSDictionary *myDic = response;
        if ([myDic[@"Tag"] intValue]==0) {
            return;
        }
        BloodArr = [[myDic[@"Result"][@"OutTable"] reverseObjectEnumerator] allObjects];
        [BloodSugarScrollview removeFromSuperview];
        BloodSugarScrollview = [STLogView makeBloodSugarScrollview:TypeScrollview andSelectYear:year andMonth:month andData:BloodArr];
        [self bloodArrHaveData];
    } failure:^(GLRequest *request, NSError *error) {
        
    }];
}


- (void)getData{
    //血糖
    [self loadBloodSugar];
}

//血糖的异常值
- (void)getBloodAbnormalList{
    NSDictionary *dic = @{
                          @"FuncName":@"getBloodAbnormalList",
                          @"InField":@{
                                  @"ACCOUNT":USER_ACCOUNT,	//帐号
                                  @"YEAR":[@(year) stringValue],	//年份
                                  @"MONTH":[@(month) stringValue],		//月份
                                  @"DEVICE":@"1"
                          },
                          @"OutField":@[
                              ]
                          };
    [GL_Requst postWithParameters:dic SvpShow:self.view success:^(GLRequest *request, id response) {
        NSDictionary *myDic = response;
        if ([myDic[@"Tag"] intValue]==1) {
//            getBloodAbnormalListArr = myDic[@"Result"][@"OutTable"];
        }
    } failure:^(GLRequest *request, NSError *error) {
        
    }];
}


#pragma mark - -
#pragma mark - - 监测分析
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - 添加修改血糖
- (void)bloodClick:(NSNotification*)not{
    NSDictionary *dic  = [not object];
    NSDictionary *dicc = BloodArr[[dic[@"i"] intValue]][@"result"][[dic[@"j"] intValue]];
    GLButton *btn      = [dic objectForKey:@"btn"];
    
    [[BloodSugarScrollview subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj class] isEqual:[GLButton class]] && obj != btn) {
            GLButton *tmpBtn = obj;
            tmpBtn.selected  = false;
        }
    }];
    btn.selected = true;
    NSInteger  bloodSugarValue = [dicc getDoubleValue:@"VALUE"] * 10;
    [SlideRuleView showWithCurrentValue:bloodSugarValue > 0 ? bloodSugarValue : 100];
    [SlideRuleView getValue:^(CGFloat value) {
        
        NSString *btnStr = btn.lbl.text;
        [btn setTitle:[NSString stringWithFormat:@"%.1lf",value/10.0f]  forState:UIControlStateNormal];
        
        NSDictionary *postDic = @{
                                  FUNCNAME : @"saveBloodValue",
                                  INFIELD : @{@"DEVICE":@"1"},
                                  INTABLE : @{
                                          @"BLOOD_TEST" :@[
                                                  @{
                                                  @"ACCOUNT" : USER_ACCOUNT,
                                                  @"COUNTS" : btn.lbl.text,
                                                  @"TYPE" : [dicc getStringValue:@"TYPE"],
                                                  @"DATE" : [BloodArr[[dic[@"i"] intValue]] getStringValue:@"date"]
                                                  }
                                          ]
                                          }
                                  };
        [GL_Requst postWithParameters:postDic SvpShow:true success:^(GLRequest *request, id response) {
            if (GETTAG) {
                if (GETRETVAL) {
                    [btn setTitleColor:TCOL_MAIN forState:UIControlStateNormal];
                    if (btn.lbl.text.length!=0) {
                        if ([btn.lbl.text doubleValue]<=[GL_USERDEFAULTS getDoubleValue:SamTargetLow]) {
                            [btn setTitleColor:TCOL_GLUCOSLOW forState:UIControlStateNormal];
                        } else if ([btn.lbl.text doubleValue]>=[GL_USERDEFAULTS getDoubleValue:SamTargetHeight]){
                            [btn setTitleColor:TCOL_GLUCOSEHEIGHT forState:UIControlStateNormal];
                        }
                    }

                } else {
                    GL_ALERTCONTR(nil, GETRETMSG);
                    [btn setTitle:btnStr  forState:UIControlStateNormal];
                }
            } else {
                GL_ALERTCONTR(nil, GETMESSAGE);
                [btn setTitle:btnStr  forState:UIControlStateNormal];
            }
        } failure:^(GLRequest *request, NSError *error) {
            GL_AFFAil;
            [btn setTitle:btnStr  forState:UIControlStateNormal];
        }];
    }];
    
    [SlideRuleView deleteValue:^{
        if ([dicc getStringValue:@"ID"].length) {
            NSDictionary *postDic = @{
                                      FUNCNAME : @"delSamReferGlucose",
                                      INFIELD  : @{
                                              @"ACCOUNT":USER_ACCOUNT,
                                              @"ID":[dicc getStringValue:@"ID"]
                                              }
                                      };
            [GL_Requst postWithParameters:postDic SvpShow:true success:^(GLRequest *request, id response) { 
                if (GETTAG) {
                    if (GETRETVAL) {
                        [btn setTitle:@"" forState:UIControlStateNormal];
                    } else {
                        GL_ALERTCONTR_1(GETRETMSG);
                    }
                } else {
                    GL_ALERTCONTR_1(GETMESSAGE);
                }
            } failure:^(GLRequest *request, NSError *error) {
                GL_AFFAil;
                }];
        }
    }];
}

@end
