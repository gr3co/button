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
#import <iAd/iAd.h>
#import <MapKit/MapKit.h>
#import "MapPin.h"
#import <Mapbox/Mapbox.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> {
    UIButton *theButton;
    UIButton *fbShareButton;
    UIButton *twitterButton;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    ADBannerView *bannerView;
    MKMapView * mapView;
    BOOL toggleTracking;
    UIButton* trackButton;
    UIImage* trackingDisabled;
    UIImage* trackingEnabled;
}

@end
