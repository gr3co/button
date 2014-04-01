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

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description {
    self = [super init];
    if (self != nil) {
        coordinate = location;
        title = placeName;
        subtitle = description;
        bonerTime = 0;
    }
    return self;
}

- (NSTimeInterval)getBonerTime{
    return *(self->bonerTime);
}

@end