//
//  ViewController.m
//  Button
//
//  Created by Stephen Greco on 3/31/14.
//  Copyright (c) 2014 Stephen Greco. All rights reserved.
//

#import "ButtonViewController.h"

@implementation ViewController {
    BOOL didCenterLocation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpLocation];
    [self setUpUI];
    /*[NSTimer scheduledTimerWithTimeInterval:30.0 target:self
                                   selector:@selector(requestBonersFromUserLocation)
                                   userInfo:nil repeats:YES];*/
    
}

-(void) setUpUI
{
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scroll.pagingEnabled = YES;
    scroll.scrollsToTop=YES;
    scroll.contentSize = CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height-20);
    self.view = scroll;
    
    UIImage *backgroundImage = [UIImage imageNamed:@"background_image.png"];
    UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
    background.frame = CGRectMake(0,0,scroll.contentSize.width, scroll.contentSize.height);
    [self.view addSubview:background];
    
	self.view.backgroundColor = [UIColor blackColor];
    UIImage *buttonBackground = [UIImage imageNamed:@"boner_button.png"];
    
    float width = self.view.bounds.size.width;
    float height = scroll.bounds.size.height;
    float buttonWidth = 0.75 * width;
    
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
    mapBorder.backgroundColor = [UIColor colorWithRed:106.0/255.0 green:0 blue:0 alpha:1];
    [secondView addSubview:mapBorder];
    
    mapView = [(MKMapView*) [MKMapView alloc]initWithFrame:CGRectMake(0.01*width, 0.01*width, 0.98 * width, 0.98*width)];
    mapView.delegate=self;
    
    trackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    trackButton.frame = CGRectMake(self.view.frame.size.width-80,self.view.frame.size.height-100,
                                   75, 75);
    trackingDisabled =[UIImage imageNamed:@"targetInactive.png"];
    trackingEnabled = [UIImage imageNamed:@"targetActive.png"];
    

    [trackButton setBackgroundImage:[UIImage imageNamed:@"targetInactive.png"] forState:UIControlStateNormal];
    //[trackButton setBackgroundImage:[UIImage imageNamed:@"targetActive.png"] forState:UIControlStateSelected];
    //[trackButton setBackgroundImage:[UIImage imageNamed:@"targetActive.png"] forState:UIControlStateHighlighted];
    [trackButton addTarget:self action:@selector(toggleTracking) forControlEvents:UIControlEventTouchUpInside];
    [secondView addSubview:trackButton];
    
    mapView.showsUserLocation=YES;
    [mapView.userLocation addObserver:self
                           forKeyPath:@"location"
                              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                              context:NULL];
    [mapBorder addSubview:mapView];
    [scroll addSubview:secondView];
    toggleTracking=false;
    
    
    UIScreenEdgePanGestureRecognizer *panGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureHandler:)];
    panGesture.edges = UIRectEdgeLeft;
    [scroll addGestureRecognizer:panGesture];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    didCenterLocation = NO;
    
}







/*
 * LOCATION FUNCTIONS
 */

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
}


-(void)setUpLocation{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (!didCenterLocation){
        MKCoordinateRegion mapRegion;
        mapRegion.center.latitude = mapView.userLocation.coordinate.latitude;
        mapRegion.center.longitude = mapView.userLocation.coordinate.longitude;
        mapRegion.span.latitudeDelta = 0.1;
        mapRegion.span.longitudeDelta = 0.1;
        [mapView setRegion:mapRegion animated: YES];
        didCenterLocation = YES;
    }
    else if (toggleTracking && [mapView showsUserLocation]) {
        CLLocationCoordinate2D noLocation = mapView.userLocation.location.coordinate;
        MKCoordinateRegion viewRegion2 = MKCoordinateRegionMake(noLocation, [mapView region].span);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion2];
        [mapView setRegion:adjustedRegion animated:YES];
    }
}







/*
 * MAP FUNCTIONS
 */

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
        long long age = [[d objectForKey:@"age"] longLongValue];
        MapPin *pin = [[MapPin alloc]
                       initWithCoordinates:CLLocationCoordinate2DMake(lat,lng)
                       andAge:age];
        [mapView addAnnotation:pin];
    }
}

-(void)toggleTracking{
    
    if(!toggleTracking)
    {
        [trackButton setBackgroundImage:trackingEnabled forState:UIControlStateNormal];
        //[trackButton setHighlighted:YES];
        //[trackButton setSelected:YES];
        CLLocationCoordinate2D noLocation = mapView.userLocation.location.coordinate;
        MKCoordinateRegion viewRegion2 = MKCoordinateRegionMakeWithDistance(noLocation, 5000, 5000);
        MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion2];
        [mapView setRegion:adjustedRegion animated:YES];
    }
    else{
        [trackButton setBackgroundImage:trackingDisabled forState:UIControlStateNormal];
        //[trackButton setHighlighted:NO];
        //[trackButton setSelected:NO];
    }
    toggleTracking= !toggleTracking;
}

- (MKAnnotationView *) mapView:(MKMapView *)map
             viewForAnnotation:(MapPin <MKAnnotation>*) annotation {
    
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc]
                                  initWithAnnotation:annotation reuseIdentifier:@"pin"];
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    if([annotation isEqual:[map userLocation]]) {
        annView.pinColor = MKPinAnnotationColorRed;
    }
    else{
        UIImage*original =[UIImage imageNamed:@"boner.png"];
        annView.image =  [UIImage imageWithCGImage:[original CGImage]
                                             scale:(original.scale * 6.0)
                                       orientation:(original.imageOrientation)];
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval difference = currentTime - ((NSTimeInterval)annotation.bonerTime / 1000);
        annView.alpha = MAX(0.0, 1 - (difference / 86400));
    }
    return annView;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)map{
    MKCoordinateRegion region = mapView.region;
    [self requestBonersWithLng: region.center.longitude
                           lat: region.center.latitude
                           rad: region.span.latitudeDelta + region.span.longitudeDelta];
}







/*
 * NETWORK FUNCTIONS
 */

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

-(IBAction)requestBonersFromUserLocation{
    float longitude = currentLocation.coordinate.longitude;
    float latitude = currentLocation.coordinate.latitude;
    float radius = 1.0;
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


-(IBAction)requestBonersWithLng:(float)longitude lat: (float)latitude rad: (float)radius{
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





/*
 * MISC FUNCTIONS
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"%@", [error localizedDescription]);
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)gestureHandler:(UIScreenEdgePanGestureRecognizer *)gesture {
    NSLog(@"Pan Gesture Called (DOES NOTHING)");
}

@end
