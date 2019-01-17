//
//  AppDelegate.m
//  native-xcode
//
//  Created by Ian Grossberg on 1/16/19.
//  Copyright © 2019 Adorkable. All rights reserved.
//

#import "AppDelegate.h"

#import "NodeRunner.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSThread* nodejsThread = nil;
    nodejsThread = [[NSThread alloc]
                    initWithTarget:self
                    selector:@selector(startNodeRed)
                    object:nil
                    ];
    // Set 2MB of stack space for the Node.js thread.
    [nodejsThread setStackSize:2*1024*1024];
    [nodejsThread start];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)startNodeExample {
    NSString* srcPath = [[NSBundle mainBundle] pathForResource:@"nodejs-project/main.js" ofType:@""];
    NSArray* nodeArguments = [NSArray arrayWithObjects:
                              @"node",
                              srcPath,
                              nil
                              ];
    [NodeRunner startEngineWithArguments:nodeArguments];
}

- (void)startNodeRed {
    NSString* srcPath = [[NSBundle mainBundle] pathForResource:@"nodejs-project/node_modules/node-red/red.js" ofType:@""];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSArray* nodeArguments = [NSArray arrayWithObjects:
                              @"node",
                              srcPath,
                              @"--userDir",
                              [NSString stringWithFormat:@"%@/.node-red/", [paths objectAtIndex:0]],
#if TARGET_IPHONE_SIMULATOR
#else
                              @"--settings",
                              [[NSBundle mainBundle] pathForResource:@"nodejs-project/deviceSettings.js" ofType:@""],
#endif
                              nil
                              ];
    [NodeRunner startEngineWithArguments:nodeArguments];
}

@end
