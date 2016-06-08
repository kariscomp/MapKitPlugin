//
//  Cordova
//
//

#import "MapKit.h"
#import "CDVAnnotation.h"
#import "AsyncImageView.h"

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395
#define MAX_ZOOMLEVEL 19

@implementation MapKitView

@synthesize buttonCallback;
@synthesize childView;
@synthesize mapView;
@synthesize imageButton;


/**
 * Create a native map view
 */



- (void)createView
{
    NSDictionary *options = [[NSDictionary alloc] init];
    [self createViewWithOptions:options];
}

- (void)createViewWithOptions:(NSDictionary *)options {

    //This is the Designated Initializer

    // defaults
    float left = [([options objectForKey:@"left"]) integerValue] > 0 ? [[options objectForKey:@"left"] floatValue] : 0;
    float top = [([options objectForKey:@"top"]) integerValue] > 0 ? [[options objectForKey:@"top"] floatValue] : 0;
    float height = [([options objectForKey:@"height"]) integerValue] > 0 ? [[options objectForKey:@"height"] floatValue] : self.webView.bounds.size.height/2;
    float width = [([options objectForKey:@"width"]) integerValue] > 0 ? [[options objectForKey:@"width"] floatValue] : self.webView.bounds.size.width;
    float x = self.webView.bounds.origin.x + left;
    float y = self.webView.bounds.origin.y + top;
    BOOL atBottom = ([options objectForKey:@"atBottom"]) ? [[options objectForKey:@"atBottom"] boolValue] : NO;

    if(atBottom) {
        y += self.webView.bounds.size.height - height;
    }

    self.childView = [[UIView alloc] initWithFrame:CGRectMake(x,y,width,height)];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(self.childView.bounds.origin.x, self.childView.bounds.origin.x, self.childView.bounds.size.width, self.childView.bounds.size.height)];
    self.mapView.delegate = self;
    self.mapView.multipleTouchEnabled   = YES;
    self.mapView.autoresizesSubviews    = YES;
    self.mapView.userInteractionEnabled = YES;
    self.mapView.showsUserLocation = YES;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.childView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    CLLocationCoordinate2D centerCoord = { [[options objectForKey:@"lat"] floatValue] , [[options objectForKey:@"lon"] floatValue] };
//  CLLocationDistance diameter = [[options objectForKey:@"diameter"] floatValue];
//
//  MKCoordinateRegion region=[ self.mapView regionThatFits: MKCoordinateRegionMakeWithDistance(centerCoord,
//                                                                                                diameter*(height / self.webView.bounds.size.width),
//                                                                                                diameter*(height / self.webView.bounds.size.width))];
//    [self.mapView setRegion:region animated:YES];
    [self.childView addSubview:self.mapView];
    
    [ [ [ self viewController ] view ] addSubview:self.childView];
//    self.childView.layer.zPosition = -1;
//    self.webView.layer.zPosition = 0;
//    self.webView.backgroundColor = [UIColor clearColor];
//    self.webView.opaque = NO;
    
    NSArray *HTMLs = [options objectForKey:@"children"];
    NSString *elemId;
    NSDictionary *elemSize, *elemInfo;
    for (int i = 0; i < [HTMLs count]; i++) {
        elemInfo = [HTMLs objectAtIndex:i];
        elemSize = [elemInfo objectForKey:@"size"];
        elemId = [elemInfo objectForKey:@"id"];
        NSLog(@"%@", elemId);
//        [self.pluginLayer putHTMLElement:elemId size:elemSize];
//        [self.pluginScrollView.debugView putHTMLElement:elemId size:elemSize];
    }

}

- (void)destroyMap:(CDVInvokedUrlCommand *)command
{
    if (self.mapView)
    {
        [ self.mapView removeAnnotations:mapView.annotations];
        [ self.mapView removeFromSuperview];

        mapView = nil;
    }
    if(self.imageButton)
    {
        [ self.imageButton removeFromSuperview];
        //[ self.imageButton removeTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
        self.imageButton = nil;

    }
    if(self.childView)
    {
        [ self.childView removeFromSuperview];
        self.childView = nil;
    }
    self.buttonCallback = nil;
}

- (void)clearMapPins:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)addMapPins:(CDVInvokedUrlCommand *)command
{
    
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }

    NSArray *pins = command.arguments[0];

    for (int y = 0; y < pins.count; y++)
    {
        NSDictionary *pinData = [pins objectAtIndex:y];
        CLLocationCoordinate2D pinCoord = { [[pinData objectForKey:@"lat"] floatValue] , [[pinData objectForKey:@"lon"] floatValue] };
        NSString *title=[[pinData valueForKey:@"title"] description];
        NSString *subTitle=[[pinData valueForKey:@"snippet"] description];
        NSInteger index=[[pinData valueForKey:@"index"] integerValue];
        BOOL selected = [[pinData valueForKey:@"selected"] boolValue];

        NSString *pinColor = nil;
        NSString *imageURL = nil;

        if([[pinData valueForKey:@"icon"] isKindOfClass:[NSNumber class]])
        {
            pinColor = [[pinData valueForKey:@"icon"] description];
        }
        else if([[pinData valueForKey:@"icon"] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *iconOptions = [pinData valueForKey:@"icon"];
            pinColor = [[iconOptions valueForKey:@"pinColor" ] description];
            imageURL = [[iconOptions valueForKey:@"resource"] description];
//            NSString *urlString = [[iconOptions valueForKey:@"resource"] description];
//            imageURL = [[NSBundle mainBundle] pathForResource:urlString ofType:nil];
        }

        CDVAnnotation *annotation = [[CDVAnnotation alloc] initWithCoordinate:pinCoord index:index title:title subTitle:subTitle imageURL:imageURL];
        annotation.pinColor=pinColor;
        annotation.selected = selected;

        [self.mapView addAnnotation:annotation];
    }
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

-(void)showMap:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView)
    {
        [self createViewWithOptions:command.arguments[0]];
    }
    self.childView.hidden = NO;
    self.mapView.showsUserLocation = YES;
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

-(void)getCurrentPosition:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    
    CLLocationCoordinate2D centerCoord = [self.mapView centerCoordinate];
    NSNumber *lat = [NSNumber numberWithDouble:centerCoord.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:centerCoord.longitude];
    NSDictionary *location=@{@"latitude":lat, @"longitude":lon};
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:location forKey:@"location"];
    
    MKZoomScale zoomScale = self.mapView.visibleMapRect.size.width / self.mapView.bounds.size.width; //MKZoomScale is just a CGFloat typedef
    double zoomExponent = log2(zoomScale);
    NSNumber *zoomLevel = [NSNumber numberWithDouble:(MAX_ZOOMLEVEL - ceil(zoomExponent))];
    [result setValue:zoomLevel forKey:@"zoomLevel"];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result] callbackId:command.callbackId];
}

#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

-(void)setCenterLocation:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    NSDictionary *options = command.arguments[0];
    CLLocationCoordinate2D pinCoord;
    NSUInteger zoomLevel;
    BOOL animated;
    if (options)
    {
        NSDictionary *centerLocation = [options objectForKey:@"coordinate"];
        if (centerLocation) {
            pinCoord = (CLLocationCoordinate2D) {
                [[centerLocation objectForKey:@"lat"] floatValue] ,
                [[centerLocation objectForKey:@"lon"] floatValue]
            };
        } else {
            pinCoord = self.mapView.userLocation.coordinate;
        }
        zoomLevel = (NSUInteger)[options objectForKey:@"zoomLevel"];
        animated = (BOOL)[options objectForKey:@"animated"];
    }
    else
    {
        pinCoord = self.mapView.userLocation.coordinate;
        zoomLevel = 5;
        animated = true;
    }
    
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self.mapView centerCoordinate:pinCoord andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(pinCoord, span);
    
    // set the region like normal
    [self.mapView setRegion:region animated:animated];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

-(void)drawRegion:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    CLLocationCoordinate2D pinCoord = self.mapView.userLocation.coordinate;
    CGFloat radius = 2000.0;
    circle_lineColor = [UIColor greenColor];
    circle_fillColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.2];
    
    NSDictionary *options = command.arguments[0];
    if (options)
    {
        NSDictionary *coords = [options objectForKey:@"coord"];
        if (coords)
        {
            pinCoord = (CLLocationCoordinate2D){ [[coords objectForKey:@"lat"] floatValue] , [[coords objectForKey:@"lon"] floatValue] };
        }
        id objRadius = [options objectForKey:@"radius"];
        if (objRadius)
        {
            radius = [objRadius floatValue];
        }
        NSDictionary *rgba = [options objectForKey:@"lineColor"];
        if (rgba)
        {
            if (rgba)
            {
                CGFloat r = [[rgba objectForKey:@"red"] integerValue] / 255.0;
                CGFloat g = [[rgba objectForKey:@"green"] integerValue] / 255.0;
                CGFloat b = [[rgba objectForKey:@"blue"] integerValue] / 255.0;
                CGFloat alpha = [[rgba objectForKey:@"alpha"] floatValue];
                circle_lineColor = [UIColor colorWithRed:r  green:g blue:b alpha:alpha];
            }
        }
        rgba = [options objectForKey:@"fillColor"];
        if (rgba)
        {
            if (rgba)
            {
                CGFloat r = [[rgba objectForKey:@"red"] integerValue] / 255.0;
                CGFloat g = [[rgba objectForKey:@"green"] integerValue] / 255.0;
                CGFloat b = [[rgba objectForKey:@"blue"] integerValue] / 255.0;
                CGFloat alpha = [[rgba objectForKey:@"alpha"] floatValue];
                circle_fillColor = [UIColor colorWithRed:r  green:g blue:b alpha:alpha];
            }
        }
    }
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:pinCoord radius:radius];
    [circle setTitle:@"background"];
    [self.mapView addOverlay:circle];
    
    MKCircle *circleLine = [MKCircle circleWithCenterCoordinate:pinCoord radius:radius];
    [circleLine setTitle:@"line"];
    [self.mapView addOverlay:circleLine];
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)hideMap:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES) 
    {
        return;
    }
    // disable location services, if we no longer need it.
    self.mapView.showsUserLocation = NO;
    self.childView.hidden = YES;
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)changeMapType:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }

    int mapType = ([command.arguments[0] objectForKey:@"mapType"]) ? [[command.arguments[0] objectForKey:@"mapType"] intValue] : 0;

    switch (mapType) {
        case 4:
            [self.mapView setMapType:MKMapTypeHybrid];
            break;
        case 2:
            [self.mapView setMapType:MKMapTypeSatellite];
            break;
        default:
            [self.mapView setMapType:MKMapTypeStandard];
            break;
    }

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)drawPolylineOverlay:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    NSDictionary *options = command.arguments[0];
    NSArray *pins = [options objectForKey:@"path"];
    NSDictionary *rgba = [options objectForKey:@"lineColor"];
    
    if (rgba)
    {
        CGFloat r = [[rgba objectForKey:@"red"] integerValue] / 255.0;
        CGFloat g = [[rgba objectForKey:@"green"] integerValue] / 255.0;
        CGFloat b = [[rgba objectForKey:@"blue"] integerValue] / 255.0;
        CGFloat alpha = [[rgba objectForKey:@"alpha"] floatValue];
        polylineColor = [UIColor colorWithRed:r  green:g blue:b alpha:alpha];
    }
    else
    {
        polylineColor = [UIColor redColor];
    }
    
    id width = [options objectForKey:@"lineWidth"];
    if (width)
    {
        polylineWidth = [width floatValue];
    }
    else
    {
        polylineWidth = 2.0;
    }
    
    if ([pins count] == 0) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No path to draw"] callbackId:command.callbackId];
    }
    else {
        
        NSInteger numberOfSteps = pins.count;
        CLLocationCoordinate2D coordinates[numberOfSteps];
        for (int y = 0; y < pins.count; y++)
        {
            NSDictionary *pinData = [pins objectAtIndex:y];
            CLLocationCoordinate2D pinCoord = { [[pinData objectForKey:@"lat"] floatValue] , [[pinData objectForKey:@"lon"] floatValue] };
            coordinates[y] = pinCoord;
        }
        MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
        [self.mapView addOverlay:polyLine];
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
        
    }
}

- (void)drawPolygonOverlay:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    NSDictionary *options = command.arguments[0];
    NSArray *pins = [options objectForKey:@"path"];
    if ([pins count] == 0) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No path to draw"] callbackId:command.callbackId];
    }
    else {
    
        NSDictionary *rgba = [options objectForKey:@"fillColor"];
        if (rgba)
        {
            CGFloat r = [[rgba objectForKey:@"red"] integerValue] / 255.0;
            CGFloat g = [[rgba objectForKey:@"green"] integerValue] / 255.0;
            CGFloat b = [[rgba objectForKey:@"blue"] integerValue] / 255.0;
            CGFloat alpha = [[rgba objectForKey:@"alpha"] floatValue];
            polygon_fillColor = [UIColor colorWithRed:r  green:g blue:b alpha:alpha];
        }
        else
        {
            polygon_fillColor = [UIColor redColor];
        }
        
        rgba = [options objectForKey:@"strokeColor"];
        if (rgba)
        {
            CGFloat r = [[rgba objectForKey:@"red"] integerValue] / 255.0;
            CGFloat g = [[rgba objectForKey:@"green"] integerValue] / 255.0;
            CGFloat b = [[rgba objectForKey:@"blue"] integerValue] / 255.0;
            CGFloat alpha = [[rgba objectForKey:@"alpha"] floatValue];
            polygon_lineColor = [UIColor colorWithRed:r  green:g blue:b alpha:alpha];
        }
        else
        {
            polygon_lineColor = [UIColor clearColor];
        }
        
        id width = [options objectForKey:@"borderWidth"];
        if (width)
        {
            polygon_lineWidth = [width floatValue];
        }
        else
        {
            polygon_lineWidth = 1.0;
        }
       
        NSInteger numberOfSteps = pins.count;
        CLLocationCoordinate2D coordinates[numberOfSteps];
        for (int y = 0; y < pins.count; y++)
        {
            NSDictionary *pinData = [pins objectAtIndex:y];
            CLLocationCoordinate2D pinCoord = { [[pinData objectForKey:@"lat"] floatValue] , [[pinData objectForKey:@"lon"] floatValue] };
            coordinates[y] = pinCoord;
        }
        MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:numberOfSteps];
        [self.mapView addOverlay:polygon];
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
        
    }
}

- (void)coordToAddress:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    NSDictionary *options = command.arguments[0];
    if ([options objectForKey:@"lat"])
    {
        if ([options objectForKey:@"lon"])
        {
            double latitude = [[options objectForKey:@"lat"] doubleValue];
            double longitude = [[options objectForKey:@"lon"] doubleValue];
            
            NSString *str = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false", latitude, longitude];
            NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"GET"];
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSError *jsonError;
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                NSArray *addressArray = [jsonResponse objectForKey:@"results"];
                NSDictionary *address = (NSDictionary*) addressArray[0];
                
                NSString *addressString = [address objectForKey:@"formatted_address"];
                
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:addressString] callbackId:command.callbackId];
            }] resume];
            
            
        }
    }
}

- (void)setMapClickable:(CDVInvokedUrlCommand *)command {
    
    NSInteger clickable = [command.arguments[0] integerValue];
    BOOL isClickable;
    if (clickable == 0)
        isClickable = NO;
    else
        isClickable = YES;
    self.mapView.userInteractionEnabled = isClickable;
    self.mapView.zoomEnabled = isClickable;
    self.mapView.scrollEnabled = isClickable;
    
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

//Might need this later?
/*- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;

    [self.mapView setRegion:mapRegion animated: YES];
}


- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated: (BOOL)animated
{
    NSLog(@"region did change animated");
    float currentLat = theMapView.region.center.latitude;
    float currentLon = theMapView.region.center.longitude;
    float latitudeDelta = theMapView.region.span.latitudeDelta;
    float longitudeDelta = theMapView.region.span.longitudeDelta;

    NSString* jsString = nil;
    jsString = [[NSString alloc] initWithFormat:@"geo.onMapMove(\'%f','%f','%f','%f\');", currentLat,currentLon,latitudeDelta,longitudeDelta];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
    [jsString autorelease];
}
 */


- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>) annotation {
  
  if ([annotation class] != CDVAnnotation.class) {
    return nil;
  }

    CDVAnnotation *phAnnotation=(CDVAnnotation *) annotation;
    NSString *identifier=[NSString stringWithFormat:@"INDEX[%li]", (long)phAnnotation.index];
    
    if (phAnnotation.imageURL != nil)
    {
        MKAnnotationView *annView = (MKAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annView == nil)
            annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        else
            annView.annotation = annotation;
        
        annView.canShowCallout = YES;
        annView.enabled = YES;
        NSString *urlString = [[NSBundle mainBundle] pathForResource:phAnnotation.imageURL ofType:nil];
        UIImage *originalImage = [UIImage imageNamed:urlString];
        UIImage *scaledImage = [MapKitView imageWithImage:originalImage scaledToSize:CGSizeMake(40, 40)];
        annView.image = scaledImage;
        
        return annView;
    }
    else
    {
        MKPinAnnotationView *annView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:identifier];

        if (annView!=nil) return annView;

        annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];

        annView.animatesDrop=YES;
        annView.canShowCallout = YES;
        if ([phAnnotation.pinColor isEqualToString:@"120"])
            annView.pinColor = MKPinAnnotationColorGreen;
        else if ([phAnnotation.pinColor isEqualToString:@"270"])
            annView.pinColor = MKPinAnnotationColorPurple;
        else
            annView.pinColor = MKPinAnnotationColorRed;
        
        return annView;
    }
    
//  AsyncImageView* asyncImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(0,0, 50, 32)];
//  asyncImage.tag = 999;
//  if (phAnnotation.imageURL)
//  {
//      NSURL *url = [[NSURL alloc] initWithString:phAnnotation.imageURL];
//      [asyncImage loadImageFromURL:url];
//  } 
//  else 
//  {
//      [asyncImage loadDefaultImage];
//  }
//
//  annView.leftCalloutAccessoryView = asyncImage;
//
//
//  if (self.buttonCallback && phAnnotation.index!=-1)
//  {
//
//      UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//      myDetailButton.frame = CGRectMake(0, 0, 23, 23);
//      myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//      myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//      myDetailButton.tag=phAnnotation.index;
//      annView.rightCalloutAccessoryView = myDetailButton;
//      [ myDetailButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//
//  }
//
//  if(phAnnotation.selected)
//  {
//      [self performSelector:@selector(openAnnotation:) withObject:phAnnotation afterDelay:1.0];
//  }
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView
           rendererForOverlay:(id<MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = polylineColor;
        renderer.lineWidth = polylineWidth;
        return renderer;
    }
    else if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        renderer.fillColor = polygon_fillColor;
        renderer.strokeColor = polygon_lineColor;
        return renderer;
    }
    else if ([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        renderer.fillColor = circle_fillColor;
        renderer.strokeColor = circle_lineColor;
        return renderer;
    }
    
    return nil;
}

-(void)openAnnotation:(id <MKAnnotation>) annotation
{
    [ self.mapView selectAnnotation:annotation animated:YES];
    
}

- (void) checkButtonTapped:(id)button 
{
//  UIButton *tmpButton = button;
//  NSString* jsString = [NSString stringWithFormat:@"%@(\"%li\");", self.buttonCallback, (long)tmpButton.tag];
//  [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)dealloc
{
    if (self.mapView)
    {
        [ self.mapView removeAnnotations:mapView.annotations];
        [ self.mapView removeFromSuperview];
        self.mapView = nil;
    }
    if(self.imageButton)
    {
        [ self.imageButton removeFromSuperview];
        self.imageButton = nil;
    }
    if(childView)
    {
        [ self.childView removeFromSuperview];
        self.childView = nil;
    }
    self.buttonCallback = nil;
}

@end
