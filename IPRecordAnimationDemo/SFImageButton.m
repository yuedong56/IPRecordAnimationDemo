//
//  SFImageButton.m
//  HandShakerComponent
//
//  Created by Xu Lian on 2017-09-03.
//  Copyright © 2017 smartisan. All rights reserved.
//

#import "SFImageButton.h"

@implementation SFImageButton


- (id)init
{
    if (self=[super init]) {
        [self setImagePosition: NSImageOnly];
        [self setBordered:NO];
        [self setButtonType:NSMomentaryChangeButton];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self setImagePosition: NSImageOnly];
        [self setBordered:NO];
        [self setButtonType:NSMomentaryChangeButton];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    if (self=[super initWithFrame:frameRect]) {
        [self setImagePosition: NSImageOnly];
        [self setBordered:NO];
        [self setButtonType:NSMomentaryChangeButton];
    }
    return self;
}

@end
