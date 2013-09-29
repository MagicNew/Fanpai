//
//  RootViewController.h
//  Sample
//
//  Created by Kirby Turner on 2/8/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "KTThumbsViewController.h"
#import "PhotoPickerController.h"
#import "Photos.h"
#import "WXApi.h"
#import "WXApiObject.h"

//@protocol sendMsgToWeChatViewDelegate <NSObject>
//- (void) sendImageContentAtPath:(NSString *)path;
//@end

@class Photos;

@interface LocalImageRootViewController : KTThumbsViewController <PhotoPickerControllerDelegate, PhotosDelegate, MFMailComposeViewControllerDelegate, WXApiDelegate>
{
@private
   PhotoPickerController *photoPicker_;
   Photos *myPhotos_;
   UIActivityIndicatorView *activityIndicatorView_;
}

- (void)savePhoto:(UIImage *)image addToPhotoAlbum:(BOOL)isAddToPhotoAlbum;

//@property (nonatomic, assign) id<sendMsgToWeChatViewDelegate> delegate;
@end
