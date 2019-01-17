//
//  AppDelegate.m
//  native-xcode
//
//  Created by Ian Grossberg on 1/16/19.
//  Copyright © 2019 Adorkable. All rights reserved.
//

#import "AppDelegate.h"

#import "NodeRunner.h"

@import ZipArchive;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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

+ (NSString*)pathForNodeJSProject {
    NSObject *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    return [NSString stringWithFormat:@"%@/nodejs-project", libraryPath];
}

+ (void)deployNodeJSProject:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SSZipArchive unzipFileAtPath:[[NSBundle mainBundle] pathForResource:@"nodejs-project.zip" ofType:@""] toDestination:[AppDelegate pathForNodeJSProject]];

        dispatch_sync(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

+ (void)startNodeRed:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //    NSString* srcPath = [[NSBundle mainBundle] pathForResource:@"nodejs-project/node_modules/node-red/red.js" ofType:@""];
        NSString* srcPath = [NSString stringWithFormat:@"%@/main.js", [AppDelegate pathForNodeJSProject]];
        NSObject *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

        NSArray* nodeArguments = [NSArray arrayWithObjects:
                                  @"node",
                                  srcPath,
                                  @"--userDir",
                                  [NSString stringWithFormat:@"%@/.node-red/", documentPath],
#if TARGET_IPHONE_SIMULATOR
#else
                                  @"--settings",
                                  [[NSBundle mainBundle] pathForResource:@"nodejs-project/deviceSettings.js" ofType:@""],
#endif
                                  @"--mobileDocumentDir",
                                  documentPath,
                                  nil
                                  ];
        [NodeRunner startEngineWithArguments:nodeArguments];

        dispatch_sync(dispatch_get_main_queue(), ^{
            completion();
        });
    });

}

+ (void)monitorFile:(NSString*)filePath notify:(void (^)(NSString*))notify {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    NSString* path = [filePath stringByDeletingLastPathComponent];
    int folderId = open([path UTF8String], O_EVTONLY);
    __block dispatch_source_t folder = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, folderId, DISPATCH_VNODE_WRITE, queue);

    // call the passed block if the source is modified
    dispatch_source_set_event_handler(folder, ^{
        int fileId = open([filePath UTF8String], O_EVTONLY);
        if (fileId == -1) {
            return;
        }

        dispatch_source_cancel(folder);

//        __block typeof(self) blockSelf = self;
        __block dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileId, DISPATCH_VNODE_DELETE, queue);
        dispatch_source_set_event_handler(source, ^{
            unsigned long flags = dispatch_source_get_data(source);
            if(flags & DISPATCH_VNODE_DELETE)
            {
                dispatch_source_cancel(source);

                notify(path);
                //            [blockSelf monitorFile:path notify:notify];
            }
        });
        dispatch_source_set_cancel_handler(source, ^(void) {
            close(fileId);
        });
        dispatch_resume(source);
    });

    // close the file descriptor when the dispatch source is cancelled
    dispatch_source_set_cancel_handler(folder, ^{
        close(folderId);
    });

    dispatch_resume(folder);
}

@end
