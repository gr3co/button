//
//  MapPin.m
//  Button
//
//  Created by Rolando Schneiderman on 4/1/14.
//  Copyright (c) 2014 Stephen Greco. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize bonerTime;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location andAge:(long long)age{
    self = [super init];
    if (self != nil) {
        coordinate = location;
        title = @"Boner";
        subtitle = @"There is a boner here!";
        bonerTime = age;
    }
    return self;
}

- (long long)getBonerTime{
    return bonerTime;
}

@end