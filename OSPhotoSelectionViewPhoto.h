//
//  OSPhotoSelectionViewPhoto.h
//  Ocasta Studios
//
//  Created by Chris Birch on 15/05/2014.
//  Copyright (c) 2014 OcastaStudios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    OSPhotoSelectionViewCellStateAddStarted,
    OSPhotoSelectionViewCellStateAdding,
    OSPhotoSelectionViewCellStateNormal,
    OSPhotoSelectionViewCellStateRemoveStarted,
    OSPhotoSelectionViewCellStateRemoving
} OSPhotoSelectionViewCellState;
@interface OSPhotoSelectionViewPhoto : NSObject

/**
 * Helps with animation of showing hiding spinny when tableview is reloaded
 */
@property (nonatomic,assign) OSPhotoSelectionViewCellState cellState;

@property (nonatomic,strong) NSString* url;
@property (nonatomic,strong) UIImage* image;

/**
 * Arbitrary values set by user code
 */
@property (nonatomic,strong) NSMutableDictionary* userDictionary;
/**
 * if the parent requireConfirmOnImageUpdate property is YES then this is set to YES
 * whenever a picture is added
 */
@property(nonatomic,assign) BOOL awaitingConfirmationToAdd;

/**
 * if the parent requireConfirmOnImageUpdate property is YES then this is set to YES
 * whenever a picture is removed.
 */
@property(nonatomic,assign) BOOL awaitingConfirmationToRemove;


-(id)initWithImage:(UIImage*)image;
-(id)initWithUrl:(NSString*)url;

@end
