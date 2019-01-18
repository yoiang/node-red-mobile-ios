//
//  NodeRED.swift
//  native-xcode
//
//  Created by Ian Grossberg on 1/17/19.
//  Copyright © 2019 Adorkable. All rights reserved.
//

import Foundation

class NodeRED: NodeJSProject {
    static func start(started: (() -> Void)?, stopped: (() -> Void)?) throws {
        guard let projectPath = self.fullPathForDeployedNodeJSProject else {
            throw Errors.unableToRetrieveDeployedNodeJSProjectPath
        }

        let scriptPath = projectPath.path + "/main.js"

        guard let documentsPath = AppDelegate.userDocumentsPath else {
            throw Errors.unableToRetrieveUserDocumentsPath
        }

        var arguments = [
            "--userDir",
            documentsPath.path + "/.node-red/",
            "--mobileDocumentDir",
            documentsPath.path
        ]
        #if !targetEnvironment(simulator)
        arguments.append(contentsOf: [
            "--settings",
            projectPath.path + "/deviceSettings.js"
            ])
        #endif

        do {
            try AppDelegate.monitor(URL(fileURLWithPath: "Node-RED.booting.tracking", relativeTo: NodeJSProject.fullPathForTrackingFiles)) { (_) in
                started?()
            }
        } catch {
            print("Unable to monitor booting tracking file: \(error)")
        }

        try NodeJSProject.startNode(scriptPath, with: arguments, stopped: stopped)
    }

    static var editorURL: URL? {
        return URL(string: "http://127.0.0.1:1880")
    }
}


extension NodeRED {
    enum Errors: Error {
        case unableToRetrieveUserDocumentsPath

        case unableToRetrieveDeployedNodeJSProjectPath
    }
}
