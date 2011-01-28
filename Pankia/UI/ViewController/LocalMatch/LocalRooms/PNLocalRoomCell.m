//
//  PNLocalRoomCell.m
//  PankiaNet
//
//  Created by Kazuto Maruoka on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PNLocalRoomCell.h"


@implementation PNLocalRoomCell

- (void)setRoomName:(NSString *)newRoomName
{
	PNLog(@"PNLocalRoomCell setRoomName:%@",newRoomName);
    roomNameLabel.text = newRoomName;
}

- (void)dealloc
{
    [super dealloc];
}

@end
