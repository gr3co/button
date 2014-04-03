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
    [self requestBoners];
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self
                                   selector:@selector(requestBoners)
                                   userInfo:nil repeats:YES];
    
}

//if i understand this shit correctly, wich i probably dont...
//this method is called every time an annotation object is added
//by checking properties of the (MapPin) annotation that it takes
//we can color them according to annotation.bonerTime or [annotation getBonerTime]
//we canalso draw pins from image files insteads of using colors
//ther are only three colors; green red blue
- (MKAnnotationView *) mapView:(MKMapView *)map
             viewForAnnotation:(MapPin <MKAnnotation>*) annotation {
    
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc]
                                  initWithAnnotation:annotation reuseIdentifier:@"pin"];

    if([annotation isEqual:[map userLocation]]) {
        annView.pinColor = MKPinAnnotationColorRed;
    }
    else{
        annView.pinColor = MKPinAnnotationColorGreen;
    }
    return annView;
}



-(void) setUpUI
{
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scroll.pagingEnabled = YES;
    scroll.scrollsToTop=YES;
    scroll.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height-20);
    self.view = scroll;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"background_image.jpg"];
    UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
    background.frame = CGRectMake(0,0,scroll.contentSize.width, scroll.contentSize.height);
    [self.view addSubview:background];
    
	self.view.backgroundColor = [UIColor blackColor];
    UIImage *buttonBackground = [UIImage imageNamed:@"bubble_icon.png"];
    
    float width = self.view.bounds.size.width;
    float height = scroll.bounds.size.height;
    float buttonWidth = width / 2;
    
    theButton = [UIButton buttonWithType:UIButtonTypeSystem];
    theButton.frame = CGRectMake(width/2 - buttonWidth/2, height/2 - buttonWidth/2 - 20,
                                 buttonWidth, buttonWidth);
    [theButton setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [theButton setBackgroundImage:buttonBackground forState:UIControlStateSelected];
    [theButton setBackgroundImage:buttonBackground forState:UIControlStateHighlighted];
    [theButton addTarget:self action:@selector(sendLocation) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:theButton];
    
    UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    [bannerView setBackgroundColor:[UIColor clearColor]];
    [secondView addSubview: bannerView];
    
    UIView *mapBorder = [[UIView alloc] initWithFrame:CGRectMake(0, bannerView.frame.size.height, width, width)];
    mapBorder.backgroundColor = [UIColor redColor];
    [secondView addSubview:mapBorder];
    
    mapView = [(MKMapView*) [MKMapView alloc]initWithFrame:CGRectMake(0.01*width, 0.01*width, 0.98 * width, 0.98*width)];
    mapView.delegate=self;
    
    trackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    trackButton.frame = CGRectMake(self.view.frame.size.width-65,self.view.frame.size.height-87.5,
                                   50, 50);
    [trackButton setBackgroundImage:[UIImage imageNamed:@"targetUnactive.png"] forState:UIControlStateNormal];
    [trackButton setBackgroundImage:[UIImage imageNamed:@"targetActive.png"] forState:UIControlStateSelected];
    [trackButton addTarget:self action:@selector(toggleTracking) forControlEvents:UIControlEventTouchUpInside];
    [secondView addSubview:trackButton];
    
    mapView.showsUserLocation=YES;
    [mapView.userLocation addObserver:self
                           forKeyPath:@"location"
                              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                              context:NULL];
    [mapBorder addSubview:mapView];
    [scroll addSubview:secondView];
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    toggleTracking=false;
    
    
    UIScreenEdgePanGestureRecognizer *panGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureHandler:)];
    panGesture.edges = UIRectEdgeLeft;
    [scroll addGestureRecognizer:panGesture];

    
    [self setNeedsStatusBarAppearanceUpdate];
    
}


- (IBAction)sendLocation{
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
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                    message:response
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil] show];
        NSLog(@"error: %@", response);
        return;
    }
    if ([response isKindOfClass:[NSString class]]){
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message from Server", @"")
                                    message:response
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                          otherButtonTitles:nil] show];
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
    NSMutableArray *toRemove = [NSMutableArray array];
    for (MapPin<MKAnnotation> *m in mapView.annotations){
        if (![m isEqual:[mapView userLocation]])
            [toRemove addObject:m];
    }
    [mapView removeAnnotations:toRemove];
    for (NSDictionary *d in data){
        float lng = [[d objectForKey:@"lng"] floatValue];
        float lat = [[d objectForKey:@"lat"] floatValue];
        MapPin *pin = [[MapPin alloc]
                       initWithCoordinates:CLLocationCoordinate2DMake(lat,lng)
                       placeName:@"Boner" description:@"There's a boner here"];
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
        [trackButton setSelected:YES];
        CLLocationCoordinate2D noLocation = mapView.userLocation.location.coordinate;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 5000, 5000);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
        [mapView setRegion:adjustedRegion animated:YES];
    }
    else{
        [trackButton setSelected:NO];
    }
    toggleTracking= !toggleTracking;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    /*[mapView removeAnnotation:myPoint];
    myPoint =[[MapPin alloc] initWithCoordinates:mapView.userLocation.location.coordinate
                                       placeName:@"Me" description:@"My boner"];
    [mapView addAnnotation:myPoint];*/
    if(toggleTracking==false)
        return;
    if ([mapView showsUserLocation]) {
        CLLocationCoordinate2D noLocation = mapView.userLocation.location.coordinate;
        //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 5000, 5000);
        MKCoordinateRegion viewRegion2 = MKCoordinateRegionMake(noLocation, [mapView region].span);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion2];
        [mapView setRegion:adjustedRegion animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Error loading");
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad loaded");
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad will load");
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"Ad did finish");
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(IBAction)requestBoners{
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

@end
