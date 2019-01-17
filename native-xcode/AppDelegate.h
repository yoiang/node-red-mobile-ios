//
//  AppDelegate.h
//  native-xcode
//
//  Created by Ian Grossberg on 1/16/19.
//  Copyright © 2019 Adorkable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (void)deployNodeJSProject:(void (^)(void))completion;
+ (void)startNodeRed:(void (^)(void))completion;

+ (void)monitorFile:(NSString*)path notify:(void (^)(NSString*))notify;

@end

