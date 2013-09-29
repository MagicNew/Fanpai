//
//  RootViewController.m
//  Sample
//
//  Created by Niu Kun on 13-8-8.
//
//

#import "RootViewController.h"
#import "LocalImageRootViewController.h"

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define GET_IMAGE(__NAME__,__TYPE__)    [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:__NAME__ ofType:__TYPE__]]

#define CAMERA_SCALAR 1.25
//#define SCREEN_WIDTH    [[UIScreen mainScreen]bounds].size.width * [[UIScreen mainScreen]scale]
//#define SCREEN_HEIGHT   [[UIScreen mainScreen]bounds].size.height * [[UIScreen mainScreen]scale]

#define SCREEN_WIDTH    [[UIScreen mainScreen]bounds].size.width
#define SCREEN_HEIGHT   [[UIScreen mainScreen]bounds].size.height

@interface RootViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) LocalImageRootViewController *imageViewController;
@property (nonatomic, retain) UIImagePickerController *imagePickerController;
@property (nonatomic) BOOL fisrtTake;    //拍摄第一张

@end

@implementation RootViewController

@synthesize window = _window;
@synthesize imageViewController;
@synthesize imagePickerController;
@synthesize fisrtTake;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:NSLocalizedString(@"拍照", @"Photo Album screen title.")];

    imageViewController = [[LocalImageRootViewController alloc] init];
    imageArray = [[NSMutableArray alloc] init];
    fisrtTake = YES;
    //self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initImagePicker];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto {
    [self initImagePicker];
}

- (IBAction)showLocalImageSample
{
    [[self navigationController] pushViewController:imageViewController
                                           animated:YES];
}

//刷新图片
- (void)refreshImage
{
    UIImage *image = [self getSumImageWithImagesHorizontal:imageArray];
    [self.imageViewController savePhoto:image addToPhotoAlbum:NO];
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
    //清空数组
    [imageArray removeAllObjects];
}

- (UIImage *) getSumImageWithImagesHorizontal:(NSArray*) images {
    CGFloat width = 0;
    CGFloat height = 0;
    
    for (int i = 0; i < [images count]; i++)
    {
        CGSize size = [(UIImage*)[images objectAtIndex:i] size];
        if (size.width > size.height)
        {
            if (width == 0)
                width = size.width;
            else
                width = (width > size.width) ? size.width : width;
        }
        else
        {
            if (height == 0)
                height = size.height;
            else
                height = (height > size.height) ? size.height : height;
        }
    }
    
    for (int i = 0; i < [images count]; i++) {
        CGSize size = [(UIImage*)[images objectAtIndex:i] size];
        if (size.width > size.height)
        {
            height += size.height * (width / size.width) * 8/9;
        }
        else
        {
            width += size.width * (height / size.height) * 8/9;
        }
    }
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    CGPoint beginPoint = CGPointMake(0, 0);
    for (int i = 0; i < [images count]; i++) {
        UIImage* image = (UIImage*)[images objectAtIndex:i];
        if (image.size.width > image.size.height)
        {
            [image drawInRect:CGRectMake(beginPoint.x, beginPoint.y, width, image.size.height  * (width / image.size.width))];
            beginPoint.y += image.size.height * (width / image.size.width) * 8/9;
        }
        else
        {
            [image drawInRect:CGRectMake(beginPoint.x, beginPoint.y, image.size.width * (height / image.size.height), height)];
            beginPoint.x += image.size.width * (height / image.size.height) * 8/9;
        }
    }
    
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImg;
}

//-(UIImage*)getSubImage:(UIImage *)sourceImage toRect:(CGRect)rect
//{
//    CGImageRef subImageRef = CGImageCreateWithImageInRect(sourceImage.CGImage, rect);
//    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
//    
//    UIGraphicsBeginImageContext(smallBounds.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(context, smallBounds, subImageRef);
//    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
//    UIGraphicsEndImageContext();
//    
//    return smallImage;
//}

//- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
//
//{
//    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
//    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
//    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return scaledImage;
//}

- (void)initImagePicker
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        //sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //增加提示框，退出程序
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    self.imagePickerController = picker;
    [self setupImagePicker:sourceType];
    [picker release];
    picker = nil;
    
    [self presentModalViewController:self.imagePickerController animated:NO];
}

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController.sourceType = sourceType;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        self.imagePickerController.cameraViewTransform = CGAffineTransformScale(self.imagePickerController.cameraViewTransform, CAMERA_SCALAR, CAMERA_SCALAR);
        // 不使用系统的控制界面
        self.imagePickerController.showsCameraControls = NO;

        UIToolbar *controlView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT -50, SCREEN_WIDTH, 50)];
        controlView.barStyle = UIBarStyleBlackOpaque;
        
//        UIToolbar *controlView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50)];
        controlView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        //相册
        UIButton *imageButton = [UIButton buttonWithType: UIButtonTypeCustom];
        imageButton.frame = CGRectMake(0, 0, 40, 40);
        imageButton.showsTouchWhenHighlighted = YES;
        [imageButton setImage:GET_IMAGE(@"camera_image.png", nil) forState:UIControlStateNormal];
        [imageButton addTarget: self action: @selector(showPhoto) forControlEvents: UIControlEventTouchUpInside];
        UIBarButtonItem *showPicItem = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
        
        //拍照
        UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cameraBtn.frame = CGRectMake(0, 0, 40, 40);
        cameraBtn.showsTouchWhenHighlighted = YES;
        [cameraBtn setImage:GET_IMAGE(@"camera_icon.png", nil) forState:UIControlStateNormal];
        [cameraBtn addTarget:self action:@selector(stillImage:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *takePicItem = [[UIBarButtonItem alloc] initWithCustomView:cameraBtn];
        
        //摄像头切换
        UIButton *cameraDevice = [UIButton buttonWithType:UIButtonTypeCustom];
        cameraDevice.frame = CGRectMake(0, 0, 40, 40);
        cameraDevice.showsTouchWhenHighlighted = YES;
        [cameraDevice setImage:GET_IMAGE(@"camera_mode.png", nil) forState:UIControlStateNormal];
        [cameraDevice addTarget:self action:@selector(changeCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
        if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            //判断是否支持前置摄像头
            cameraDevice.hidden = YES;
        }
        UIBarButtonItem *cameraDeviceItem = [[UIBarButtonItem alloc] initWithCustomView:cameraDevice];
        
        //空item
        UIBarButtonItem *spItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *items = [NSArray arrayWithObjects:showPicItem, spItem, takePicItem, spItem, cameraDeviceItem, nil];
        [controlView setItems:items];
        
        [showPicItem release];
        [takePicItem release];
        [cameraDeviceItem release];
        [spItem release];
        
        self.imagePickerController.cameraOverlayView = controlView;
        
        [controlView release];
        controlView = nil;
    }
}

//拍照
- (void)stillImage:(id)sender
{
    [self.imagePickerController takePicture];
}

- (void)showPhoto
{
    [self.imagePickerController dismissModalViewControllerAnimated:NO];
    [[self navigationController] pushViewController:imageViewController animated:NO];
}

////完成、取消
//- (void)doneAction
//{
//    [self imagePickerControllerDidCancel:self.imagePickerController];
//}

#pragma mark - UIImagePickerController回调
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
    
    if (imageArray.count) {
        [self refreshImage];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        //保存相片到数组，这种方法不可取,会占用过多内存
        //如果是一张就无所谓了，到时候自己改
        [imageArray addObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
        
        if (!self.fisrtTake) {
            [self refreshImage];
            [self changeCameraDevice:nil];
            //[self performSelector:@selector(changeCameraDevice:) withObject:nil afterDelay:1.0f];
            self.fisrtTake = YES;
        }
        else {
            self.fisrtTake = NO;
            [self changeCameraDevice:nil];
            
            [self.imagePickerController performSelector:@selector(takePicture) withObject:nil afterDelay:2.0f];
        }
    }
    else
    {
        NSLog(@"here``");
        //self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //[picker dismissModalViewControllerAnimated:YES];
    }
}

- (void)changeCameraDevice:(id)sender
{
    if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    else {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}



-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIDeviceOrientationPortraitUpsideDown);
}

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        
    }
    
}

-(void) onResp:(BaseResp*)resp
{
    //可以省略
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
    }
}

@end
