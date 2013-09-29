#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, WXApiDelegate>
{
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

