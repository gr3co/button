//
//  ViewController.m
//  Button
//
//  Created by Stephen Greco on 3/31/14.
//  Copyright (c) 2014 Stephen Greco. All rights reserved.
//

#import "ButtonViewController.h"

@interface ViewController ()
{
    MKMapView * mapView;
    BOOL toggleTracking;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    scroll.pagingEnabled = YES;
    scroll.scrollsToTop=YES;
    //scroll.
    /* Programmatically generate scrollable views
     NSInteger numberOfViews = 3;
     for (int i = 0; i < numberOfViews; i++) {
     CGFloat xOrigin = i * self.view.frame.size.width;
     UIView *awesomeView = [[UIView alloc] initWithFrame:CGRectMake(xOrigin, 0, self.view.frame.size.width, self.view.frame.size.height)];
     awesomeView.backgroundColor = [UIColor colorWithRed:0.5/i green:0.5 blue:0.5 alpha:1];
     [scroll addSubview:awesomeView];
     }*/
    scroll.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height-20);
    self.view = scroll;
    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
	self.view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:1.0 alpha:1.0];
    UIImage *buttonBackground = [UIImage imageNamed:@"bubble_icon.png"];
    
    float width = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    float buttonWidth = width / 2;
    

    
    
    theButton = [UIButton buttonWithType:UIButtonTypeSystem];
    theButton.frame = CGRectMake(width/2 - buttonWidth/2, height/2 - buttonWidth/2,
                                 buttonWidth, buttonWidth);
    [theButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [theButton setBackgroundImage:buttonBackground forState:UIControlStateSelected];
    [theButton setBackgroundImage:buttonBackground forState:UIControlStateHighlighted];
    [theButton addTarget:self action:@selector(sendLocation) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:theButton];
    
    UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mapView = [(MKMapView*) [MKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-100)];
    mapView.delegate=self;
    
    UIButton* trackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

    //trackButton.center = CGPointMake(100, 100);
    //trackButton.center = CGPointMake(self.view.frame.size.width-10, self.view.frame.size.height);
    trackButton.frame = CGRectMake(self.view.frame.size.width-65,self.view.frame.size.height-87.5,
                                   50, 50);
    [trackButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [trackButton addTarget:self action:@selector(toggleTracking) forControlEvents:UIControlEventTouchUpInside];
    [secondView addSubview:trackButton];
    
    //CLLocationCoordinate2D noLocation = mapView.userLocation.location.coordinate;
    //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 5000, 5000);
    //MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    //[mapView setRegion:adjustedRegion animated:YES];
    //[mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    //[mapView setRegion:[mapView regionThatFits:viewRegion]];
    mapView.showsUserLocation = YES;
    //[mapView setDelegate:self];
    mapView.showsUserLocation=YES;
    

    
//    [mapView showsUserLocation];
    [mapView.userLocation addObserver:self
                                forKeyPath:@"location"
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                   context:NULL];
    [secondView addSubview:mapView];
    [scroll addSubview:secondView];
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    //PAN GESTURE IS USELESS CURRENTLY
    UIScreenEdgePanGestureRecognizer *panGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureHandler:)];
    panGesture.edges = UIRectEdgeLeft;
    [scroll addGestureRecognizer:panGesture];
    toggleTracking=false;

    //[self.view = [MKMapView alloc]init];
    //MKMapView * mapView = (MKMapView *)self.view;
    //mapView.mapType = MKMapTypeSatellite;
    
}

-(void)toggleTracking{
    toggleTracking= !toggleTracking;
//    if ([mapView showsUserLocation]) {
//        [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
//    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if(toggleTracking==false)
        return;
    if ([mapView showsUserLocation]) {
        [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];

        //r[mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
        // [mapView setCenterCoordinate:mapView.userLocation.location.coordinate zoomLevel:14 animated:YES];        // and of course you can use here old and new location values
   }
}

- (void)gestureHandler:(UIScreenEdgePanGestureRecognizer *)gesture {
    NSLog(@"Pan Gesture Called");
/*
    UIView *view = [self.view hitTest:[gesture locationInView:gesture.view] withEvent:nil];
    if(UIGestureRecognizerStateBegan == gesture.state ||
       UIGestureRecognizerStateChanged == gesture.state) {
        CGPoint translation = [gesture translationInView:gesture.view];
        // Move the view's center using the gesture
        self.view.center = CGPointMake(_centerX + translation.x, view.center.y);
    } else {// cancel, fail, or ended
        // Animate back to center x
        [UIView animateWithDuration:.3 animations:^{
            view.center = CGPointMake(_centerX, view.center.y);
        }];
    }*/
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)sendLocation{
    //[mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    NSLog(@"sendLocation currently deactivated");
    return;
    if (currentLocation == nil){
        NSLog(@"location not set");
        return;
    }
    NSNumber *longitude = [NSNumber numberWithFloat:currentLocation.coordinate.longitude];
    NSNumber *latitude = [NSNumber numberWithFloat:currentLocation.coordinate.latitude];
    NSDictionary *tmpDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                         longitude, @"long",
                         latitude, @"lat",
                         nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmpDict options:0 error:&error];
    NSURL *serverAddr = [NSURL URLWithString:@"http://192.168.1.112:3000/api/sendLocation"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serverAddr];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"connection established");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@", jsonArray);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                 message:[error localizedDescription]
                                delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                       otherButtonTitles:nil] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

}


@end
