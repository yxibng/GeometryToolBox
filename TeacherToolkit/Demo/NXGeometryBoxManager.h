//
//  NXGeometryBoxManager.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/22.
//

#import <Foundation/Foundation.h>
#import "NXGeometryToolProtocol.h"

NS_ASSUME_NONNULL_BEGIN


//每种工具最多允许多少个
#define kMaxNumberOfToolsOneKindAllowed 5



@class NXGeometryBoxManager;
@protocol NXGeometryBoxManagerDelegate <NSObject>





@end


@interface NXGeometryBoxManager : NSObject


/*
 打开工具
 每一种工具最多可以打开 5 个
 
 成功打开返回 true，
 打开失败返回 false, 打开失败的原因可能是： 已经打开了5个该类型的工具
 */

- (BOOL)openToolWithType:(NXGeometryToolType)type addToWhiteboard:(UIView *)whiteboard;







@end

NS_ASSUME_NONNULL_END
