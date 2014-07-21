//
//  OSPhotoSelectionView.m
//  Ocasta Studios
//
//  Created by Chris Birch on 15/04/2014.
//  Copyright (c) 2014 OcastaStudios. All rights reserved.
//

#import "OSPhotoSelectionView.h"
#import "OSPhotoSelectionViewCell.h"
#import "OSPhotoSelectionViewPhoto.h"
#import "UIView+NibLoading.h"

@interface OSPhotoSelectionView ()
{
    BOOL firstTime;
    NSUInteger numPhotos;
    /**
     * The height as originally defined within the nib for the can add buttoi
     */
    CGFloat canAdd_ButtonHeight;
    
    NSMutableArray* images;
    
    NSIndexPath* currentlySelectedIndexPath;
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhoto;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addButtonHeightConstraint;

@end
@implementation OSPhotoSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        firstTime = YES;
        _showsControls = YES;
        _sourceType = UIImagePickerControllerSourceTypeCamera;
        
        images = [NSMutableArray new];
    }
    return self;
}

-(void)setShowsControls:(BOOL)canAddPictures
{
    _showsControls = canAddPictures;
    
}

-(OSPhotoSelectionViewPhoto*)addImage:(UIImage*)image
{
    OSPhotoSelectionViewPhoto* photo = [[OSPhotoSelectionViewPhoto alloc] initWithImage:image];
    
    photo.awaitingConfirmationToAdd = _requireConfirmOnImageUpdate;
    
    if (!_requireConfirmOnImageUpdate)
        photo.cellState = OSPhotoSelectionViewCellStateNormal;
    else
        //set to add started state so we know which animation to use
        photo.cellState = OSPhotoSelectionViewCellStateAddStarted;
    
    [images addObject:photo];
    [self.collectionView reloadData];
//    
//    NSIndexPath* indexPath =[NSIndexPath indexPathForItem:[images indexOfObject:photo] inSection:0];
//    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
    [self setNeedsUpdateConstraints];
    
    
    if ([self.delegate respondsToSelector:@selector(OSPhotoSelectionView:imageAdded:withIndex:)])
    {
        [self.delegate OSPhotoSelectionView:self imageAdded:photo withIndex:images.count-1];
    }
    
    return photo;

}


-(OSPhotoSelectionViewPhoto*)addImageUrl:(NSString*)imageUrl
{
    OSPhotoSelectionViewPhoto* photo = [[OSPhotoSelectionViewPhoto alloc] initWithUrl:imageUrl];

    //set to add started state so we know which animation to use
    photo.cellState = OSPhotoSelectionViewCellStateAddStarted;
    
    photo.awaitingConfirmationToAdd = _requireConfirmOnImageUpdate;
    

    [images addObject:photo];
    
//    if (images.count >1)
//    {
//        NSIndexPath* indexPath =[NSIndexPath indexPathForItem:[images indexOfObject:photo] inSection:0];
//        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
//    }
//    else
        [self.collectionView reloadData];
    
    
    [self setNeedsUpdateConstraints];
    
    
    if ([self.delegate respondsToSelector:@selector(OSPhotoSelectionView:imageAdded:withIndex:)])
    {
        [self.delegate OSPhotoSelectionView:self imageAdded:photo withIndex:images.count-1];
    }
    
    return photo;
    
}

-(void)removePhoto:(OSPhotoSelectionViewPhoto*)photo
{
    [self removePhoto:photo forceWithoutConfirmation:NO];
}
-(void)removePhoto:(OSPhotoSelectionViewPhoto*)photo forceWithoutConfirmation:(BOOL)force
{
    photo.cellState = OSPhotoSelectionViewCellStateRemoveStarted;
    
    photo.awaitingConfirmationToRemove = _requireConfirmOnImageUpdate;
    
    NSUInteger index =[images indexOfObject:photo];
    
    if ([self.delegate respondsToSelector:@selector(OSPhotoSelectionView:imageRemoved:withIndex:)])
    {
        [self.delegate OSPhotoSelectionView:self imageRemoved:photo withIndex:index];
    }
    else if(_requireConfirmOnImageUpdate)
    {
        [NSException raise:@"Deletion requires confirmation but delegate doesnt respond to removed method, so nothing will happen!" format:@""];
    }
    
    if (!_requireConfirmOnImageUpdate || force)
    {
        [images removeObject:photo];
        [_collectionView reloadData];
        [self setNeedsUpdateConstraints];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];

    if (firstTime)
    {
        [_collectionView registerNib:[UINib nibWithNibName:@"OSPhotoSelectionViewCell" bundle:nil] forCellWithReuseIdentifier:REUSE_PHOTO_SELECTION_VIEW_CELL];
        [_collectionView registerNib:[UINib nibWithNibName:@"OSPhotoSelectionViewWithDeleteCell" bundle:nil] forCellWithReuseIdentifier:REUSE_PHOTO_SELECTION_VIEW_WITH_DELETE_CELL];
        //_collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        
        canAdd_ButtonHeight = _addButtonHeightConstraint.constant;
        
        firstTime = NO;
    }
}

-(void)updateConstraints
{
    [super updateConstraints];
    
    CGSize size =[_collectionView collectionViewLayout].collectionViewContentSize;
    
    _heightConstraint.constant = size.height;
    
    if (_showsControls)
    {
        _btnAddPhoto.hidden = NO;
        _addButtonHeightConstraint.constant = canAdd_ButtonHeight;
    }
    else
    {
        _btnAddPhoto.hidden = YES;
        _addButtonHeightConstraint.constant = 0;
    }

}

-(void)clearAllPhotos
{
    [images removeAllObjects];
    [_collectionView reloadData];
    [self setNeedsUpdateConstraints];
}

-(void)confirmUpdate:(OSPhotoSelectionViewPhoto *)photo
{
    if (photo.awaitingConfirmationToAdd)
        photo.awaitingConfirmationToAdd = NO;
    else if (photo.awaitingConfirmationToRemove)
    {
        photo.awaitingConfirmationToRemove = NO;
        
        NSIndexPath* indexPath =[NSIndexPath indexPathForItem:[images indexOfObject:photo] inSection:0];
        
        [images removeObject:photo];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
        for(OSPhotoSelectionViewCell* cell in _collectionView.visibleCells)
        {
            NSInteger item = cell.indexPath.item;
            
            //check if this item is after the deleted item
            if (item > indexPath.item)
            {
                //it is so we need to subtract one from its index path
                cell.indexPath = [NSIndexPath indexPathForItem:item-1 inSection:0];
            }
        }
        
     //   [_collectionView reloadData];
        [self setNeedsUpdateConstraints];
        
        
    }
}

-(void)cancelUpdate:(OSPhotoSelectionViewPhoto *)photo
{
//    if (photo.awaitingConfirmationToAdd)
//    {
//        photo.awaitingConfirmationToAdd = NO;
//    }
    
    //cancel delete
    if (photo.awaitingConfirmationToRemove)
    {
        photo.awaitingConfirmationToRemove = NO;
        
    }
}






-(void)layoutSubviews
{
    [super layoutSubviews];
}

- (IBAction)cmAddPhoto:(UIButton *)sender
{
    //show the picker
    
    if (_viewControllerParent)
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = _sourceType;
           
        [_viewControllerParent presentViewController:picker animated:YES completion:^{
            
        }];
    }
    else
        [NSException raise:@"You must set a parent view controller" format:@""];
}


#pragma mark -
#pragma mark CollectionView

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* str = REUSE_PHOTO_SELECTION_VIEW_CELL;
    
    if (_canDelete)
        str = REUSE_PHOTO_SELECTION_VIEW_WITH_DELETE_CELL;
    
    OSPhotoSelectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:str forIndexPath:indexPath];
    
    if (indexPath.item < images.count)
        cell.image = images[indexPath.item];
    
    cell.indexPath = indexPath;
    
  cell.parent = self;
    
    [cell update];

    if ([_delegate respondsToSelector:@selector(OSPhotoSelectionView:processCell:andImage:withIndex:)])
    {
        [_delegate OSPhotoSelectionView:self processCell:cell andImage:cell.image withIndex:indexPath.item];
    }
    return cell;
}

-(OSPhotoSelectionViewCell*)cellAtIndexPath:(NSIndexPath*)indexPath
{
    for(OSPhotoSelectionViewCell* cell in _collectionView.visibleCells)
    {
        if ([cell.indexPath isEqual: indexPath])
        {
            return cell;
        }
    }
    
    return nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Deselect old image
    
    if (currentlySelectedIndexPath)
    {
        OSPhotoSelectionViewCell* cell = [self cellAtIndexPath:currentlySelectedIndexPath];

        NSUInteger index = [images indexOfObject:cell.image];
        
        if ([_delegate respondsToSelector:@selector(OSPhotoSelectionView:imageDeselected:withIndex:andCell:)])
        {
            [_delegate OSPhotoSelectionView:self imageDeselected:cell.image withIndex:index andCell:cell];
        }

    }
    
    
    currentlySelectedIndexPath = indexPath;
    
    OSPhotoSelectionViewCell* cell = [self cellAtIndexPath:currentlySelectedIndexPath];
    
    
    
    NSUInteger index = [images indexOfObject:cell.image];
    
    if ([_delegate respondsToSelector:@selector(OSPhotoSelectionView:imageSelected:withIndex:andCell:)])
    {
        [_delegate OSPhotoSelectionView:self imageSelected:cell.image withIndex:index andCell:cell];
    }
    
}

#pragma mark -
#pragma mark Collection View number of cells

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return images.count;
}

#pragma mark -
#pragma mark Collection View Cell Size

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (CGSizeEqualToSize(_imageSize, CGSizeZero))
    {
        
        
        //Get and store the heights of the static sized cells
        static NSNumber *heightCell=nil;
        static NSNumber *widthCell=nil;
        
        if (!heightCell)
        {
            
            UICollectionViewCell *cell = [OSPhotoSelectionViewCell loadInstanceFromNib];
            heightCell = @(cell.bounds.size.height);
            widthCell = @(cell.bounds.size.width);
        }
        
        return CGSizeMake(widthCell.floatValue, heightCell.floatValue);
    }
    else
        return _imageSize;
}


#pragma mark -
#pragma mark ImagePicker

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    [self addImage:chosenImage];
    

    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
}



@end
