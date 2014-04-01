//
//  ViewController.m
//  Button
//
//  Created by Stephen Greco on 3/31/14.
//  Copyright (c) 2014 Stephen Greco. All rights reserved.
//

#import "ButtonViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpLocation];
    [self setUpUI];
}

//if i understand this shit correctly, wich i probably dont...
//this method is called every time an annotation object is added
//by checking properties of the (MapPin) annotation that it takes
//we can color them according to annotation.bonerTime or [annotation getBonerTime]
//we canalso draw pins from image files insteads of using colors
//ther are only three colors; green red blue
- (MKAnnotationView *) mapView:(MKMapView *)mapView
             viewForAnnotation:(MapPin <MKAnnotation>*) annotation {
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc]
                                  initWithAnnotation:annotation reuseIdentifier:@"pin"];

//    if(annotation getBonerTime)

    if([[annotation title] isEqualToString:@"Current Location"]) { annView.pinColor = MKPinAnnotationColorRed; }else{annView.pinColor = MKPinAnnotationColorGreen;}
    
    //annView.pinColor = MKPinAnnotationColorGreen;
    return annView;
}



-(void) setUpUI
{
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scroll.pagingEnabled = YES;
    scroll.scrollsToTop=YES;
    scroll.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height-20);
    self.view = scroll;
    
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
    trackButton.frame = CGRectMake(self.view.frame.size.width-65,self.view.frame.size.height-87.5,
                                   50, 50);
    [trackButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [trackButton addTarget:self action:@selector(toggleTracking) forControlEvents:UIControlEventTouchUpInside];
    [secondView addSubview:trackButton];
    mapView.showsUserLocation=YES;
    
    
    [mapView.userLocation addObserver:self
                           forKeyPath:@"location"
                              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                              context:NULL];
    [secondView addSubview:mapView];
    [scroll addSubview:secondView];
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    toggleTracking=false;
    //mapView.mapType = MKMapTypeSatellite;
    
    UIScreenEdgePanGestureRecognizer *panGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureHandler:)];
    panGesture.edges = UIRectEdgeLeft;
    [scroll addGestureRecognizer:panGesture];
}


- (IBAction)sendLocation{
    //[mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];

    if (currentLocation == nil){
        NSLog(@"location not set");
        return;
    }
    NSNumber *longitude = [NSNumber numberWithFloat:currentLocation.coordinate.longitude];
    NSNumber *latitude = [NSNumber numberWithFloat:currentLocation.coordinate.latitude];
    NSString *identifier = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSDictionary *tmpDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                             longitude, @"lng",
                             latitude, @"lat",
                             identifier, @"idnum",
                             nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:tmpDict options:0 error:&error];
    NSURL *serverAddr = [NSURL URLWithString:@"http://bonerbutton.com/api/sendLocation"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serverAddr];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[postData length]]
                        forHTTPHeaderField:@"Content-Length"];
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
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    int status = [[parsedData objectForKey:@"status"] intValue];
    id response = [parsedData objectForKey:@"data"];
    if (status != 200){
        NSLog(@"error: %@", response);
        return;
    }
    if ([response isKindOfClass:[NSString class]]){
        NSLog(@"response: %@", response);
        return;
    }
    if ([response isKindOfClass:[NSArray class]]){
        [self handleCoords: response];
    }
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
-(void)setUpLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

-(void)handleCoords:(NSArray*)data{
    for (MapPin<MKAnnotation> *m in coords){
        [mapView removeAnnotation:m];
        [coords removeObject:m];
    }
    for (NSDictionary *d in data){
        float lng = [[d objectForKey:@"lng"] floatValue];
        float lat = [[d objectForKey:@"lat"] floatValue];
        MapPin *pin = [[MapPin alloc]
                       initWithCoordinates:CLLocationCoordinate2DMake(lat,lng)
                       placeName:@"Boner" description:@"There's a boner here"];
        [coords addObject:pin];
        [mapView addAnnotation:pin];
    }
}


- (void)gestureHandler:(UIScreenEdgePanGestureRecognizer *)gesture {
    NSLog(@"Pan Gesture Called (DOES NOTHING)");
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

-(void)toggleTracking{
    if(!toggleTracking)
    {
        CLLocationCoordinate2D noLocation = mapView.userLocation.location.coordinate;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 5000, 5000);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
        [mapView setRegion:adjustedRegion animated:YES];
    }
    toggleTracking= !toggleTracking;
    
    
    //request list of boners
    float longitude = currentLocation.coordinate.longitude;
    float latitude = currentLocation.coordinate.latitude;
    float radius = 10;
    NSString *identifier = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSString *params = [NSString stringWithFormat:@"lng=%f&lat=%f&rad=%f&idnum=%@",
                        longitude,latitude, radius, identifier];
    NSString *url = @"http://bonerbutton.com/api/getboners";
    NSURL *serverAddr = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", url, params]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serverAddr];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if(toggleTracking==false)
        return;
    if ([mapView showsUserLocation]) {
        CLLocationCoordinate2D noLocation = mapView.userLocation.location.coordinate;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 5000, 5000);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
        [mapView setRegion:adjustedRegion animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
