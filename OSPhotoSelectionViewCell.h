//
//  OSPhotoSelectionViewCell.h
//  Ocasta Studios
//
//  Created by Chris Birch on 15/04/2014.
//  Copyright (c) 2014 OcastaStudios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSPhotoSelectionViewPhoto.h"

#define REUSE_PHOTO_SELECTION_VIEW_CELL @"REUSE_OS_PHOTOSELECTIONVIEW_CELL"
#define REUSE_PHOTO_SELECTION_VIEW_WITH_DELETE_CELL @"REUSE_OS_PHOTOSELECTIONVIEWWITHDELETE_CELL"

@class OSPhotoSelectionView;

@interface OSPhotoSelectionViewCell : UICollectionViewCell<UIAlertViewDelegate>

@property (nonatomic,strong) OSPhotoSelectionViewPhoto* image;

@property (nonatomic,weak) OSPhotoSelectionView* parent;

@property (nonatomic,strong) UIImage* placeholder;

@property (nonatomic,strong) NSIndexPath* indexPath;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
-(void)update;

@end
