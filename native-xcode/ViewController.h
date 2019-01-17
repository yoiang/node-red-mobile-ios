//
//  ViewController.h
//  native-xcode
//
//  Created by Ian Grossberg on 1/16/19.
//  Copyright © 2019 Adorkable. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface ViewController : UIViewController<WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet UIButton *myButton;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;

@property (weak, nonatomic) IBOutlet WKWebView *webView;

- (IBAction)myButtonAction:(id)sender;
- (IBAction)refresh:(id)sender;

@end

