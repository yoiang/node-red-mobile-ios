//
//  ViewController.m
//  native-xcode
//
//  Created by Ian Grossberg on 1/16/19.
//  Copyright © 2019 Adorkable. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (WKNavigationDelegate)
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.webView.navigationDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self browseToNodeRed];
}

- (IBAction)myButtonAction:(id)sender
{
    NSString *localNodeServerURL = @"http:/127.0.0.1:3000/";
    NSURL  *url = [NSURL URLWithString:localNodeServerURL];
    NSString *versionsData = [NSString stringWithContentsOfURL:url];
    if (versionsData)
    {
        NSLog(@"Versions Data: %@", versionsData);
        
        [_myTextView setText:versionsData];
    }
}

- (IBAction)refresh:(id)sender {
    [self browseToNodeRed];
}

- (void)browseToNodeRed {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:1880"]]];
}

@end

@implementation ViewController (WKNavigationDelegate)
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"Failed provisional navigation: %@", error);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"Failed navigation: %@", error);
}
@end
