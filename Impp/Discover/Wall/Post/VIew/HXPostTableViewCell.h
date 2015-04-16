//
//  HXPostTableViewCell.h
//  Impp
//
//  Created by Herxun on 2015/4/8.
//  Copyright (c) 2015年 hsujahhu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ImagePost,
    TextPost,
    ImageAndTextPost
} PostType;

@interface HXIndexedCollectionView : UICollectionView
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface HXPostTableViewCell : UITableViewCell
@property (nonatomic, strong) HXIndexedCollectionView *collectionView;

- (id)initWithPostInfo:(NSDictionary *)postInfo
       reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

- (void)setCellIndex:(NSIndexPath *)index;
+ (CGFloat)heightForCellPost:(NSString *)post postType:(PostType)type;

@end
