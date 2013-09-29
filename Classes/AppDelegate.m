#import "AppDelegate.h"
#import "RootViewController.h"
#import "LocalImageRootViewController.h"
#import "WXApi.h"

@implementation AppDelegate

@synthesize window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{   
    RootViewController *newController = [[RootViewController alloc] init];
    UINavigationController *newNavController = [[UINavigationController alloc] initWithRootViewController:newController];
    [newController release];


    [[newNavController navigationBar] setBarStyle:UIBarStyleBlack];
    [[newNavController navigationBar] setTranslucent:YES];
    

    self.window.rootViewController = newNavController;
   
    // Override point for customization after application launch
    [window makeKeyAndVisible];
   
    [WXApi registerApp:@"wx467eb2393b553f83"];
   return YES;
}


- (void)dealloc 
{
    [window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:self];
}

@end
