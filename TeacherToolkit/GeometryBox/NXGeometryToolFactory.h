//
//  NXGeometryToolFactory.h
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/30.
//

#import <Foundation/Foundation.h>
#import "NXGeometryToolProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NXGeometryToolFactory : NSObject

+ (UIView<NXGeometryToolProtocol> *)createGeometryToolWithType:(NXGeometryToolType)type;

@end

NS_ASSUME_NONNULL_END
