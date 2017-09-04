//
//  XueTangRingTimeView.h
//  TangJiaoLian
//
//  Created by 高临原 on 2017/8/8.
//  Copyright © 2017年 高临原♬. All rights reserved.
//

#import "GLView.h"


/**
 环形时间表连接状态枚举

 - GLRingTimeUnunitedStatus: 环形时间表连接状态
 */
typedef NS_ENUM(NSInteger,GLRingTimeStatus){
    GLRingTimeUnunitedStatus = 0, /**< 环形时间未连接状态 */
    GLRingTimePolarizationStatus, /**< 环形时间极化中状态 */
    GLRIngTimeConnectingStatus    /**< 环形时间连接中状态 */
};


typedef NS_ENUM(NSInteger,GLRingTimeHintLabelStatus){
    GLRingTimeHintLabelPolarizationStatus = 0, /**< 极化中 */
    GLRingTimeHintLabelNormal,                 /**< 正常 */
    GLRingTimeHintLabelAbNormal                /**< 异常 */
};


@interface XueTangRingTimeView : GLView

typedef void(^ConnectBtnClick)();

typedef void(^PolarizationFinish)();

@property (nonatomic,strong) UILabel *hintLbl; /**< 异常提示 */

@property (nonatomic,strong) GLButton *connectionBtn;  /**< 连接按钮 */

@property (nonatomic,copy) ConnectBtnClick connectBtnClick; /**< 连接按钮回调 */

@property (nonatomic,copy) NSString *nowHour;           /**< 记录当前时间 */

@property (nonatomic,assign) GLRingTimeStatus status;   /**< 环信时间表连接状态 */

@property (nonatomic,strong) UILabel *polarizationTimeLbl; /**< 极化时间 */

@property (nonatomic,strong) NSTimer *timer; /**< 计时器对象 */

@property (nonatomic,copy) PolarizationFinish polarizationFinish; /**< 极化完成 */


/**
 根据时间刷新闪烁按钮的状态
 */
- (void)refreshTwinklingBtn;


/**
 更改提示标签的状态

 @param status 标签状态
 @param hour 标签提示的时间
 @param abnormalCount 异常数据数量
 */
- (void)changeHintLblSatuts:(GLRingTimeHintLabelStatus)status WithHour:(NSInteger)hour WithAbnormalCount:(NSInteger)abnormalCount;

@end
