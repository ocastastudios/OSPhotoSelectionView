//
//  OSPhotoSelectionViewPhoto.m
//  Ocasta Studios
//
//  Created by Chris Birch on 15/05/2014.
//  Copyright (c) 2014 OcastaStudios. All rights reserved.
//

#import "OSPhotoSelectionViewPhoto.h"

@implementation OSPhotoSelectionViewPhoto

- (id)initWithImage:(UIImage *)image
{
    if (self = [super init])
    {
        _image = image;
        _userDictionary = [NSMutableDictionary new];
    }
    return self;
}

-(id)initWithUrl:(NSString *)url
{
    if (self = [super init])
    {
        _url = url;
        _userDictionary = [NSMutableDictionary new];
    }
    return self;
}

@end
