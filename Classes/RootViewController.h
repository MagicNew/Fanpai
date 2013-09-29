//
//  RootViewController.h
//  Sample
//
//  Created by Niu Kun on 13-8-8.
//
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController
{
    NSMutableArray *imageArray;
}

@property (nonatomic, assign) UIWindow *window;

@end

@protocol PhotoPickerControllerDelegate <NSObject>
@optional
- (void)photoPickerController:(RootViewController *)controller didFinishPickingWithImageFromCamera:(UIImage *)image;
@end;