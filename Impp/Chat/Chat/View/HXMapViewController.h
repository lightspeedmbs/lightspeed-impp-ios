//
//  HXMapViewController.h
//  IMChat
//
//  Created by Herxun on 2015/1/9.
//  Copyright (c) 2015年 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface HXMapViewController : UIViewController<MKMapViewDelegate>
@property (nonatomic, assign) float fLatitude;
@property (nonatomic, assign) float fLongitude;
@end
