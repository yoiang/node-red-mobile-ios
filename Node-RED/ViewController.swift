//
//  ViewController.swift
//  native-xcode
//
//  Created by Ian Grossberg on 1/17/19.
//  Copyright © 2019 Adorkable. All rights reserved.
//

import Foundation
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var loadingView: UIActivityIndicatorView?
    @IBOutlet weak var webView: WKWebView?

    private var nodeRedThread: Thread?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView?.navigationDelegate = self
    }
}

extension ViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadingView?.startAnimating()

        NodeJSProject.deployNodeJSProject { (error) in
            if let error = error {
                print("Error during deploy: \(error)")
            }

            let thread = Thread.init(target: self, selector: #selector(self.startNodeRed), object: nil)
            self.nodeRedThread = thread
            thread.stackSize = 2 * 1024 * 1024
            thread.start()
        }
    }

    @objc func startNodeRed() {
        do {
            try NodeRED.start(started: {
                self.browseToNodeRed()
            }, stopped: {
                print("NodeJS finished")
            })
        } catch {
            print("While starting Node-RED: \(error)")
        }
    }
}

extension ViewController {
    @IBAction func refresh(sender: Any?) {
        self.browseToNodeRed()
    }

    func browseToNodeRed() {
        guard let url = NodeRED.editorURL else {
            print("Unable to construct url")
            return
        }

        DispatchQueue.main.async {
            self.webView?.load(URLRequest(url: url))
        }
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Failed provisional navigation: \(error)")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed navigation: \(error)")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadingView?.stopAnimating()
    }
}
