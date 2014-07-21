//
//  OSPhotoSelectionView.h
//  Ocasta Studios
//
//  Created by Chris Birch on 15/04/2014.
//  Copyright (c) 2014 OcastaStudios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSPhotoSelectionViewPhoto.h"
#import "OSPhotoSelectionViewCell.h"

@protocol OSPhotoSelectionViewDelegate;

@interface OSPhotoSelectionView : UIView<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>


@property (nonatomic,assign) id<OSPhotoSelectionViewDelegate> delegate;
@property (nonatomic,assign) BOOL showsControls;
@property (nonatomic,assign) NSUInteger maxImages;
@property (nonatomic,assign) UIImagePickerControllerSourceType sourceType;
@property (nonatomic,assign) BOOL canDelete;

/**
 * Changes the way that images are added and removed.
 * If YES images that are added or removed will show a spinny until confirmUpdate is called.
 * This is useful to show that there is some sort of network activity going on
 */
@property (nonatomic,assign) BOOL requireConfirmOnImageUpdate;



@property(nonatomic,assign) CGSize imageSize;

/**
 * Required to present the image picker
 */
@property (nonatomic,assign) UIViewController* viewControllerParent;

-(OSPhotoSelectionViewPhoto*)addImage:(UIImage*)image;
-(OSPhotoSelectionViewPhoto*)addImageUrl:(NSString*)imageUrl;

/**
 * Returns the cell at the specified index path
 */
-(OSPhotoSelectionViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath;

/**
 * Immediately removes all photos from the selection view
 */
-(void)clearAllPhotos;


/**
 * Removes the specified photo and fires the imageRemoved delegate method.
 * NB: if requireConfirmOnImageUpdate is set to YES then the image is not removed straight away, a spinny is shown and the delegate method is fired.
 */
-(void)removePhoto:(OSPhotoSelectionViewPhoto*)photo;
/**
 * Removes the specified photo and fires the imageRemoved delegate method.
 * NB: if requireConfirmOnImageUpdate is set to YES then the image is not removed straight away, a spinny is shown and the delegate method is fired unless force is YES.
 */
-(void)removePhoto:(OSPhotoSelectionViewPhoto*)photo forceWithoutConfirmation:(BOOL)force;


/**
 * Used when requireConfrimOnImageUpdate is YES.
 */
-(void)confirmUpdate:(OSPhotoSelectionViewPhoto*)photo;

/**
 * Used when requireConfrimOnImageUpdate is YES.
 */
-(void)cancelUpdate:(OSPhotoSelectionViewPhoto*)photo;

@end

@protocol OSPhotoSelectionViewDelegate <NSObject>

@optional

/**
 * Called after cell has been created
 */
-(void)OSPhotoSelectionView:(OSPhotoSelectionView*)selectionView processCell:(OSPhotoSelectionViewCell*) cell andImage: (OSPhotoSelectionViewPhoto*)image withIndex:(NSUInteger)index;
-(void)OSPhotoSelectionView:(OSPhotoSelectionView*)selectionView imageDeselected:(OSPhotoSelectionViewPhoto*)image withIndex:(NSUInteger)index andCell:(OSPhotoSelectionViewCell*)cell;
-(void)OSPhotoSelectionView:(OSPhotoSelectionView*)selectionView imageSelected:(OSPhotoSelectionViewPhoto*)image withIndex:(NSUInteger)index andCell:(OSPhotoSelectionViewCell*)cell;
-(void)OSPhotoSelectionView:(OSPhotoSelectionView*)selectionView imageAdded:(OSPhotoSelectionViewPhoto*)image withIndex:(NSUInteger)index;
-(void)OSPhotoSelectionView:(OSPhotoSelectionView*)selectionView imageRemoved:(OSPhotoSelectionViewPhoto*)image withIndex:(NSUInteger)index;

@end