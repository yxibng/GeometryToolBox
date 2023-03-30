//
//  NXGeometryToolFactory.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/30.
//

#import "NXGeometryToolFactory.h"
#import "NXRulerView.h"
#import "NXIsoscelesRightTriangleView.h"
#import "NXRightTriangleView.h"
#import "NXProtractorView.h"
#import "NXCompassView.h"


@implementation NXGeometryToolFactory
+ (UIView<NXGeometryToolProtocol> *)createGeometryToolWithType:(NXGeometryToolType)type {
    switch (type) {
        case NXGeometryToolTypeRuler:
            return [[NXRulerView alloc] init];
        case NXGeometryToolTypeIsoscelesRightTriangle:
            return [[NXIsoscelesRightTriangleView alloc] init];
        case NXGeometryToolTypeRightTriangle:
            return [[NXRightTriangleView alloc] init];
        case NXGeometryToolTypeProtractor:
            return [[NXProtractorView alloc] init];
        case NXGeometryToolTypeCompass:
            return [[NXCompassView alloc] init];
    }
}
@end
