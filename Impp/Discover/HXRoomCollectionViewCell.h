//
//  HXGroupCollectionViewCell.h
//  Impp
//
//  Created by 雷翊廷 on 2015/7/9.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXRoomCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) UIImageView *groupImage;
@property (nonatomic,strong) UILabel *groupNameLabel;
//@property (nonatomic,strong) NSString *photoUrl;
@property (nonatomic,strong) NSIndexPath *indexPath;
//-(void)getPhotoByUrl;
@end
