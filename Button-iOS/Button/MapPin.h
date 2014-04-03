//
//  MapPin.h
//  Button
//
//  Created by Rolando Schneiderman on 4/1/14.
//  Copyright (c) 2014 Stephen Greco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPin : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property long bonerTime;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location andAge:(long)age;
- (long)getBonerTime;

@end
