//
//  OSPhotoSelectionViewCell.m
//  Ocasta Studios
//
//  Created by Chris Birch on 15/04/2014.
//  Copyright (c) 2014 OcastaStudios. All rights reserved.
//

#import "OSPhotoSelectionViewCell.h"
#import "OSPhotoSelectionView.h"
#import <QuartzCore/QuartzCore.h>
#import <UIImageView+AFNetworking>

@interface OSPhotoSelectionViewCell ()
{
    BOOL isObserving;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinny;

@property (weak, nonatomic) IBOutlet UIButton *btnDelete;


@end
@implementation OSPhotoSelectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setImage:(OSPhotoSelectionViewPhoto *)image
{
    if (isObserving)
    {
        [_image removeObserver:self forKeyPath:@"awaitingConfirmationToAdd"];
        [_image removeObserver:self forKeyPath:@"awaitingConfirmationToRemove"];
    }
 
    _image = image;
  
    
    [_image addObserver:self forKeyPath:@"awaitingConfirmationToAdd" options: NSKeyValueObservingOptionNew context:nil];
    [_image addObserver:self forKeyPath:@"awaitingConfirmationToRemove" options: NSKeyValueObservingOptionNew context:nil];
//
    isObserving = YES;
//    
    
 
    
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
   if ([keyPath isEqualToString:@"awaitingConfirmationToAdd"])
   {
       if (_image.cellState == OSPhotoSelectionViewCellStateAdding)
       {
           [self animateAddFinished];
       }
   }
    else
    {
        if (_image.cellState == OSPhotoSelectionViewCellStateNormal)
        {
            [self showSpinny];
            [self animateRemove];
        }
        else if (_image.cellState == OSPhotoSelectionViewCellStateRemoveStarted)
        {
            [self showSpinny];
            [self animateRemove];
        }
        
    }
    
}

-(void)animateRemove
{
    _image.cellState = OSPhotoSelectionViewCellStateRemoving;
    self.alpha = 1;

    //
    [UIView animateWithDuration:0.2 animations:^{
                    self.alpha = 0.5;
        self.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }];
}
/**
 * Occurs when an image has been added
 */
-(void)animateAddFinished
{
    [_spinny stopAnimating];
    _spinny.hidden = YES;
    
    _image.cellState = OSPhotoSelectionViewCellStateNormal;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];

}

-(void)animteIn
{
    self.alpha = 0.5;
    self.transform = CGAffineTransformMakeScale(0.1, 0.1);

    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}
        
        

-(void)showSpinny
{
    _spinny.hidden = NO;
    [_spinny startAnimating];
}

-(void) hideSpinny
{
    _spinny.hidden = YES;
    [_spinny stopAnimating];
}
        
-(void)prepareForReuse
{
    [super prepareForReuse];
    [self hideSpinny];
    self.alpha = 1;
}
        

-(void)update
{
    if(_image.image)
    {
        _imgView.image = _image.image;
    }
    else
    {
        //must be a url
        self.alpha =0;
        NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_image.url]];
        
        _btnDelete.alpha = 0;
        
        [_imgView setImageWithURLRequest:request placeholderImage:_placeholder success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             _image.image = image;
             _imgView.image = image;
             
//             if (_image.cellState == OSPhotoSelectionViewCellStateAddStarted)
//             {
//                 _image.cellState = OSP
//             }
             _image.cellState = OSPhotoSelectionViewCellStateNormal;
             
             [self hideSpinny];
             [UIView animateWithDuration:0.2 animations:^{
                 self.alpha = 1;
                 _btnDelete.alpha =1;
             }];
             [self update];
             
             _image.awaitingConfirmationToAdd = NO;
             
             
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             _image.cellState = OSPhotoSelectionViewCellStateNormal;
                          [self update];
                          _image.awaitingConfirmationToAdd = NO;
         }];

    }

    switch (_image.cellState)
    {
        case OSPhotoSelectionViewCellStateAddStarted:
        {
            //We need to show the adding animation
            [self showSpinny];
            [self animteIn];
            
            _image.cellState = OSPhotoSelectionViewCellStateAdding;
            
            break;
        }
        case OSPhotoSelectionViewCellStateAdding:
        {
            [self showSpinny];
            //We need to just show the spinny
            break;
        }
        case OSPhotoSelectionViewCellStateNormal:
        {
            [self hideSpinny];
            
            //Just show the image
            break;
        }
        case OSPhotoSelectionViewCellStateRemoveStarted:
        {
            //We need to show the removing animation
            [self showSpinny];
            [self animateRemove];
            break;
        }
        case OSPhotoSelectionViewCellStateRemoving:
        {
            [self showSpinny];
            break;
        }
    } 
}


- (IBAction)cmDelete:(UIButton *)sender
{
    [UIAlertView showAlertLocalisedWithTitle:@"ALERT_DELETE_PHOTO_CONFIRMATION_TITLE" message:@"ALERT_DELETE_PHOTO_CONFIRMATION_MSG" delegate:self cancelButtonTitle:@"ALERT_DELETE_PHOTO_CONFIRMATION_NO" otherButtonTitleLocalised:@"ALERT_DELETE_PHOTO_CONFIRMATION_YES"];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex)
    {
        [_parent removePhoto:_image];
    }
}

@end
