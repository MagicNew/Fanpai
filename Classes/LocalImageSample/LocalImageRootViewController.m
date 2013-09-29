//
//  RootViewController.m
//  Sample
//
//  Created by Kirby Turner on 2/8/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "LocalImageRootViewController.h"


#define SHARE_WEIXIN 0
#define SHARE_WEIXIN_PYQ 1
#define SHARE_MAIL 2
#define SHARE_SAVE_ALBUM 3
#define SHARE_SINA_WEIBO 4
#define SHARE_TENGXUN_WEIBO 5
#define SHARE_WANGYI_WEIBO 6

@interface LocalImageRootViewController (Private)
- (UIActivityIndicatorView *)activityIndicator;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
@end

@implementation LocalImageRootViewController

- (void)dealloc 
{
   [activityIndicatorView_ release], activityIndicatorView_ = nil;
   [myPhotos_ release], myPhotos_ = nil;
   [activityIndicatorView_ release], activityIndicatorView_ = nil;
   
   [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        _scene = WXSceneSession;
    }
    return self;
}

- (void)viewDidLoad 
{
   [super viewDidLoad];
   
   [self setTitle:NSLocalizedString(@"相册", @"Photo Album screen title.")];
   //self.navigationController.navigationBarHidden = NO;
//   UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
//                                                                              target:self
//                                                                              action:@selector(addPhoto)];
//   [[self navigationItem] setRightBarButtonItem:addButton];
//   [addButton release];
   
   if (myPhotos_ == nil) {
      myPhotos_ = [[Photos alloc] init];
      [myPhotos_ setDelegate:self];
   }
   [self setDataSource:myPhotos_];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
   [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
   [myPhotos_ flushCache];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
   return YES;
}

- (void)willLoadThumbs 
{
   [self showActivityIndicator];
}

- (void)didLoadThumbs 
{
   [self hideActivityIndicator];
}


#pragma mark -
#pragma mark Activity Indicator
   
- (UIActivityIndicatorView *)activityIndicator 
{
   if (activityIndicatorView_) {
      return activityIndicatorView_;
   }
   
   activityIndicatorView_ = [[UIActivityIndicatorView alloc] 
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
   [activityIndicatorView_ setCenter:self.view.center];
   [[self view] addSubview:activityIndicatorView_];
   
   return activityIndicatorView_;
}

- (void)showActivityIndicator 
{
   [[self activityIndicator] startAnimating];
}

- (void)hideActivityIndicator 
{
   [[self activityIndicator] stopAnimating];
}

- (void)savePhoto:(UIImage *)image addToPhotoAlbum:(BOOL)isAddToPhotoAlbum
{
    [self showActivityIndicator];
    
    NSString * const key = @"nextNumber";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *nextNumber = [defaults valueForKey:key];
    if ( ! nextNumber ) {
        nextNumber = [NSNumber numberWithInt:1];
    }
    [defaults setObject:[NSNumber numberWithInt:([nextNumber intValue] + 1)] forKey:key];
    
    NSString *name = [NSString stringWithFormat:@"picture-%05i", [nextNumber intValue]];
    
    // Save to the photo album if picture is from the camera.
    [myPhotos_ savePhoto:image withName:name addToPhotoAlbum:isAddToPhotoAlbum];
}



#pragma mark -
#pragma mark Actions

- (void)addPhoto 
{
   if (!photoPicker_) {
      photoPicker_ = [[PhotoPickerController alloc] initWithDelegate:self];
   }
   [photoPicker_ show];
}


#pragma mark -
#pragma mark PhotoPickerControllerDelegate

- (void)photoPickerController:(PhotoPickerController *)controller didFinishPickingWithImage:(UIImage *)image isFromCamera:(BOOL)isFromCamera 
{
   [self showActivityIndicator];
   
   NSString * const key = @"nextNumber";
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   NSNumber *nextNumber = [defaults valueForKey:key];
   if ( ! nextNumber ) {
      nextNumber = [NSNumber numberWithInt:1];
   }
   [defaults setObject:[NSNumber numberWithInt:([nextNumber intValue] + 1)] forKey:key];
   
   NSString *name = [NSString stringWithFormat:@"picture-%05i", [nextNumber intValue]];

   // Save to the photo album if picture is from the camera.
   [myPhotos_ savePhoto:image withName:name addToPhotoAlbum:isFromCamera];
}


#pragma mark -
#pragma mark PhotosDelegate

- (void)didFinishSave 
{
   [self reloadThumbs];
}

//可以发送邮件的话
-(void)displayComposerSheet:(NSString *)path
{
    
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    
    MFMailComposeViewController *controller =
    [[MFMailComposeViewController alloc] init];
    
    [controller setMailComposeDelegate:self];
    [controller addAttachmentData:imageData
                         mimeType:@"image/jpeg"
                         fileName:@"Image.jpg"];
    
    [controller setMessageBody:@"From M.Camera" isHTML:YES];
    
    // Show the status bar because, otherwise, we will have some layout
    // problems when the controller is dismissed.
    if ([[UIApplication sharedApplication] respondsToSelector:
         @selector(setStatusBarHidden:withAnimation:)])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:YES];
    }
    else
    {
        // get around deprecation warnings.
        id sharedApp = [UIApplication sharedApplication];
        [sharedApp setStatusBarHidden:NO animated:YES];
    }
    
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:first@example.com&subject=my email!";
    //@"mailto:first@example.com?cc=second@example.com,third@example.com&subject=my email!";
    NSString *body = @"&body=email body!";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
}

- (void) alertWithTitle: (NSString *)_title_ msg: (NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title_
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = @"邮件发送取消";
            break;
        case MFMailComposeResultSaved:
            msg = @"邮件保存成功";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            [self alertWithTitle:nil msg:msg];
            break;
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败";
            [self alertWithTitle:nil msg:msg];
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)shareImageByMailAtPath:(NSString *)path
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if (mailClass != nil)
    {
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet:path];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}

- (void)sendImageContentAtPath:(NSString *)path scene:(enum WXScene)scene
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        NSData *imageData = [NSData dataWithContentsOfFile:path];
        UIImage *image = [[UIImage alloc] initWithData:imageData];

        WXMediaMessage *message = [WXMediaMessage message];
        UIImagePNGRepresentation(image);
        [message setThumbImage:[self generatePhotoThumbnail:image]];
        [image release];
        
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = [NSData dataWithContentsOfFile:path];
        message.mediaObject = ext;
        SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        [WXApi sendReq:req];
    }
    else
    {
        UIAlertView *alView = [[UIAlertView alloc]initWithTitle:@"" message:@"您的设备上还没有安装微信,无法使用此功能。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"免费下载微信", nil];
        [alView show];
        [alView release];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *weiXinLink = @"itms-apps://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weiXinLink]];
    }
}

- (void)shareImageToSinaWeiboAtPath:(NSString *)path
{
    
}

- (void)shareImageToTengxunWeiboAtPath:(NSString *)path
{
    
}

- (void)shareImageToWangyiWeiboAtPath:(NSString *)path
{
    
}

- (void)shareImageToWeixinAtPath:(NSString *)path
{
    [self sendImageContentAtPath:path scene:WXSceneSession];
}

- (void)shareImageToWeixinPYQAtPath:(NSString *)path
{
    [self sendImageContentAtPath:path scene:WXSceneTimeline];
}

- (void)shareImageSaveToAlbum:(NSString *)path
{
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    [image release];
}

- (void)exportImageAtPath:(NSString *)path actionIndex:(NSInteger)actionIndex
{
    switch (actionIndex) {
        case SHARE_MAIL:
            [self shareImageByMailAtPath:path];
            break;
        
        case SHARE_WEIXIN:
            [self shareImageToWeixinAtPath:path];
            break;
            
        case SHARE_WEIXIN_PYQ:
            [self shareImageToWeixinPYQAtPath:path];
            break;
            
        case SHARE_SINA_WEIBO:
            [self shareImageToSinaWeiboAtPath:path];
            break;
            
        case SHARE_WANGYI_WEIBO:
            [self shareImageToWangyiWeiboAtPath:path];
            break;
            
        case SHARE_TENGXUN_WEIBO:
            [self shareImageToTengxunWeiboAtPath:path];
            break;
            
        case SHARE_SAVE_ALBUM:
            [self shareImageSaveToAlbum:path];
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark MFMailComposeViewController

//- (void)mailComposeController:(MFMailComposeViewController*)controller 
//			 didFinishWithResult:(MFMailComposeResult)result 
//								error:(NSError*)error
//{
//	[self.navigationController dismissModalViewControllerAnimated:YES];
//}

- (UIImage *)generatePhotoThumbnail:(UIImage *)image {
    // Create a thumbnail version of the image for the event object.
    CGSize size = image.size;
    CGSize croppedSize;
    CGFloat ratio = 128.0;
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    // check the size of the image, we want to make it
    // a square with sides the size of the smallest dimension
    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }
    
    // Crop the image before resize
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    // Done cropping
    
    // Resize the image
    CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Done Resizing
    
    return thumbnail;
}

@end
