//
//  ViewController.h
//  Button
//
//  Created by Stephen Greco on 3/31/14.
//  Copyright (c) 2014 Stephen Greco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate> {
    UIButton *theButton;
    UIButton *fbShareButton;
    UIButton *twitterButton;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@end
