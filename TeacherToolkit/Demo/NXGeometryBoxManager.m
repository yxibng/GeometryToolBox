//
//  NXGeometryBoxManager.m
//  TeacherToolkit
//
//  Created by yxibng on 2023/3/22.
//

#import "NXGeometryBoxManager.h"

@interface NXGeometryBoxManager ()


@property (nonatomic, strong) NSMutableArray *rulerTools;
@property (nonatomic, strong) NSMutableArray *isoscelesRightTriangleTools;
@property (nonatomic, strong) NSMutableArray *rightTriangleTools;
@property (nonatomic, strong) NSMutableArray *protractorTools;
@property (nonatomic, strong) NSMutableArray *compassTools;

@end



@implementation NXGeometryBoxManager

- (instancetype)init {
    
    if (self = [super init]) {
        _rulerTools = [NSMutableArray array];
        _isoscelesRightTriangleTools = [NSMutableArray array];
        _rightTriangleTools = [NSMutableArray array];
        _protractorTools = [NSMutableArray array];
        _compassTools = [NSMutableArray array];
    }
    return self;
}




- (NSMutableArray *)toolsWithType:(NXGeometryToolType)type
{
    switch (type) {
        case NXGeometryToolTypeRuler:
            return self.rulerTools;
            break;
        case NXGeometryToolTypeIsoscelesRightTriangle:
            return self.isoscelesRightTriangleTools;
            break;
        case NXGeometryToolTypeRightTriangle:
            return self.rightTriangleTools;
            break;
        case NXGeometryToolTypeProtractor:
            return self.protractorTools;
            break;
        case NXGeometryToolTypeCompass:
            return self.compassTools;
            break;
    }
}





- (BOOL)openToolWithType:(NXGeometryToolType)type addToWhiteboard:(UIView *)whiteboard {
    
    NSMutableArray *tools = [self toolsWithType:type];
    if (tools.count >= kMaxNumberOfToolsOneKindAllowed) {
        return NO;
    }
    
    /*
     TODO: open tool
     add to array
     */
    return YES;
}


@end
