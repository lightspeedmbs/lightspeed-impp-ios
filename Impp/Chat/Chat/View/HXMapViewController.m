//
//  HXMapViewController.m
//  IMChat
//
//  Created by Herxun on 2015/1/9.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import "HXMapViewController.h"
#import "HXAppUtility.h"
#import "UIColor+CustomColor.h"

@interface HXMapViewController ()
@property (nonatomic, strong) MKMapView* mapView;
@end

@implementation HXMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView = [[MKMapView alloc]initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    [self initNavigationBar];
    [self performSelector:@selector(showLocation) withObject:nil afterDelay:0.5];
}

- (void)initNavigationBar
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // set navigation bar
    [HXAppUtility initNavigationTitle:@"" barTintColor:[UIColor color1] withViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.mapType = MKMapTypeStandard;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}

- (IBAction)btnBackClicked:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)showLocation
{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.fLatitude, self.fLongitude);
    MKCoordinateRegion regionCenter = MKCoordinateRegionMake(location, MKCoordinateSpanMake(0.005, 0.005));//zoom level
    regionCenter = [self.mapView regionThatFits:regionCenter];
    [self.mapView setRegion:regionCenter animated:YES];
    
    [self performSelector:@selector(addLocationAnnotation) withObject:nil afterDelay:2.0f];
}

- (void)addLocationAnnotation
{
    MKPointAnnotation* annotatePoint = [[MKPointAnnotation alloc] init];
    annotatePoint.coordinate = CLLocationCoordinate2DMake(self.fLatitude, self.fLongitude);
    annotatePoint.title = @"I'm Here";
    annotatePoint.subtitle = @"";
    
    [self.mapView addAnnotation:annotatePoint];
    [self.mapView selectAnnotation:annotatePoint animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *reuseId = @"pin";
    MKPinAnnotationView *pav = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pav == nil)
    {
        pav = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pav.draggable = YES;
        pav.canShowCallout = YES;
    }
    else
    {
        pav.draggable = YES;
        pav.annotation = annotation;
    }
    
    pav.animatesDrop = YES;
    pav.selected = YES;
    return pav;
}

@end
