//
//  HXImageDetailViewController.m
//  Impp
//
//  Created by hsujahhu on 2015/4/12.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import "HXImageDetailViewController.h"
#import "HXAppUtility.h"

#import "UIColor+CustomColor.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface HXImageDetailViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) NSString *mode;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation HXImageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - Initialize

- (id)initWithImage:(UIImage *)image imageUrl:(NSString *)imageUrl mode:(NSString *)mode;
{
    self = [super init];
    if (self) {
        self.mode = mode;
        self.image = image;
        self.imageUrl = imageUrl;
        
    }
    return self;
}

- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.bouncesZoom = YES;
    self.scrollView.bounces = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.delaysContentTouches = YES;
    self.scrollView.canCancelContentTouches = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.autoresizesSubviews = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    // Set up the image we want to scroll & zoom and add it to the scroll view
    
    self.imageView = [[UIImageView alloc] init];
    if (self.image) {
        self.imageView.image = self.image;
        self.imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height *.9);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.center = self.view.center;
        [self updateScrollView];
    }
    
    [self.scrollView addSubview:self.imageView];
    
//    // Tell the scroll view the size of the contents

    
    if (![self.imageUrl isEqualToString:@""]){
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:self.imageUrl]
                         options:0
                        progress:^(NSInteger receivedSize, NSInteger expectedSize){}
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                           if (image) {
                               self.imageView.image = image;
                               self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
                               //self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                               //self.imageView.center = self.view.center;
                               
                               [self updateScrollView];
                           }
                           
                       }];
    }
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
}

- (void)initNavigationBar
{
    NSString *title = [self.mode isEqualToString:@"push"] ? NSLocalizedString(@"查看照片", nil) : @"";
    [HXAppUtility initNavigationTitle:title barTintColor:[UIColor color1] withViewController:self];
    
    if([self.mode isEqualToString:@"modal"]){
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelButtonTapped)];
        [self.navigationItem setLeftBarButtonItem:cancelBarButton];
    }
    
}

#pragma mark - Listener

- (void)cancelButtonTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ScrollView delegate

- (void)updateScrollView
{
    self.scrollView.contentSize = self.imageView.frame.size;
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.5f;
    self.scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

#pragma mark - Helper

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.frame.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height - 64) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
