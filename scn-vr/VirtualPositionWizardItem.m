//
//  VirtualPositionWizardItem.m
//  scn-vr
//
//  Created by Michael Fuller on 7/12/15.
//  Copyright (c) 2015 M-Gate Labs. All rights reserved.
//

#import "VirtualPositionWizardItem.h"
#import "Constants.h"

@implementation VirtualPositionWizardItem

- (instancetype)initWith:(VirtualDeviceWizardItem *) virtualWizardItem isX:(BOOL) isX
{
    self = [super initWith:isX ? @"Window Offset (X)" : @"Window Offset (Y)" info:@"With this setting you can change how content is displayed on your device." itemId: isX ? WIZARD_ITEM_VIEW_SHIFT_X : WIZARD_ITEM_VIEW_SHIFT_Y type:WizardItemDataTypeSlideFloat];
    if (self) {
        _vdw = virtualWizardItem;
        
        [self reset];
    }
    return self;
}

-(void) reset {
    self.slideValue = [NSNumber numberWithFloat:0.0f];
    [self updateInfo];
}

-(void) chainUpdated {
    [self updateInfo];
}

-(WizardItemChangeAction) changeAction {
    return WizardItemChangeActionNone;
}

-(BOOL)available {
    return _allowShift;
}

-(BOOL) ready {
    return true;
}

-(void) loadForNumber:(NSNumber *) value {
    [super loadForNumber:value];
    [self updateInfo];
}

-(void) updateInfo {
    
    float total = self.itemId == WIZARD_ITEM_VIEW_SHIFT_X ? [_vdw getPhysicalWidthMM] : [_vdw getPhysicalHeightMM];
    float halfTotal = total / 2.0f;
    float min = self.itemId == WIZARD_ITEM_VIEW_SHIFT_X ? [_vdw getTargetVirtualWidthMM] : [_vdw getTargetVirtualHeightMM];
    float halfMin = min / 2.0f;
    float give = halfTotal - halfMin;
    
    //NSLog(@"%@ %f - %f", self.title, total, min);
    
    _allowShift = (give > 0.25f);
    
    //self.slideValue = [NSNumber numberWithFloat:0.0f];
    self.slideMin = [NSNumber numberWithFloat:-give];
    self.slideMax = [NSNumber numberWithFloat:+give];
    self.slideStep = [NSNumber numberWithFloat:0.25f];
    
    if (self.slideValue.floatValue > self.slideMax.floatValue + 0.1f || self.slideValue.floatValue < self.slideMin.floatValue - 0.1f) {
        // Reset if the number overflows
        self.slideValue = [NSNumber numberWithFloat:0.0f];
    }
}

-(void) updateProfileInstance:(ProfileInstance *) instance {
    if (_allowShift) {
        if (self.slideValue.floatValue > 0.1f || self.slideValue.floatValue < -0.1f) {
            // Reverse from MM to PX
            int offset = (int)((self.slideValue.floatValue / IN_2_MM) * instance.physicalDPI);
        
            // Only shift, we we can
            if (self.itemId == WIZARD_ITEM_VIEW_SHIFT_X) {
                instance.virtualOffsetLeft = (instance.physicalWidthPX / 2) + offset - (instance.virtualWidthPX / 2);
            } else if (self.itemId == WIZARD_ITEM_VIEW_SHIFT_Y) {
                instance.virtualOffsetBottom  = (instance.physicalHeightPX / 2) + offset - (instance.virtualHeightPX / 2);
            }
        }
    }
}

@end