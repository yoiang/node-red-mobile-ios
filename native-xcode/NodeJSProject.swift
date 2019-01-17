//
//  NodeJSProject.swift
//  native-xcode
//
//  Created by Ian Grossberg on 1/17/19.
//  Copyright © 2019 Adorkable. All rights reserved.
//

import Foundation
import ZipArchive

class NodeJSProject {
    static let folderForNodeJSProject = "nodejs-project"

    static var fullPathForDeployedNodeJSProject: URL? {
        guard let documentPath = AppDelegate.userDocumentsPath else {
            return nil
        }

        return URL(fileURLWithPath: self.folderForNodeJSProject, relativeTo: documentPath)
    }

    static let fileForNodeJSProjectZip = "nodejs-project.zip"

    static var fullPathForNodeJSProjectZip: URL? {
        return Bundle.main.url(forResource: self.fileForNodeJSProjectZip, withExtension: nil)
    }

    static let lastModifiedDateFormat = "yyyy-MM-dd HH:mm::ss\n"
    static var lastModifiedDateFormatter: DateFormatter {
        let result = DateFormatter()
        result.dateFormat = self.lastModifiedDateFormat
        return result
    }

    static let folderForTrackingFiles = "process/tracking/"
    static var fullPathForTrackingFiles : URL? {
        guard let documentPath = AppDelegate.userDocumentsPath else {
            return nil
        }

        return URL(fileURLWithPath: self.folderForTrackingFiles, relativeTo: documentPath)
    }
}

extension NodeJSProject {
    private static func dateUsingLastModifiedFile(of file: URL) -> Date? {
        do {
            let string = try String(contentsOf: URL(fileURLWithPath: file.lastPathComponent + ".lastModified", relativeTo: file))

            return self.lastModifiedDateFormatter.date(from: string)
        } catch {
            return nil
        }
    }

    private static func date(of file: URL) -> Date? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: file.absoluteString)

            return attributes[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }

    static func deployNodeJSProject(completion: @escaping (Error?) -> Void) {
        guard let zipPath = self.fullPathForNodeJSProjectZip,
            let deployPath = self.fullPathForDeployedNodeJSProject else {
                print("Unable to construct zip or deploy path")
                return
        }

        let zipDate = self.dateUsingLastModifiedFile(of: zipPath)
        if let zipDate = zipDate,
            let deployDate = self.date(of: deployPath),
            zipDate <= deployDate {

            print("nodejs-project up to date")
            completion(nil)
            return
        }

        print("Updating nodejs-project...")
        DispatchQueue.global().async {
            do {
                try FileManager.default.removeItem(atPath: deployPath.path)
            } catch CocoaError.fileNoSuchFile {
            } catch {
                print("While updating nodejs-project: \(error)")
                completion(error)
                return
            }

            SSZipArchive.unzipFile(atPath: zipPath.path, toDestination: deployPath.path)

            do {
                if let zipDate = zipDate {
                    let attributes = [FileAttributeKey.modificationDate: zipDate]
                    try FileManager.default.setAttributes(attributes, ofItemAtPath: deployPath.path)
                }
                // TODO: else?
                completion(nil)
            } catch {
                print("While updating nodejs-project: \(error)")
                completion(error)
            }
        }
    }

    static func startNode(_ scriptPath: String, with arguments: [String], stopped: (() -> Void)?) throws {

        print("Runing NodeJS script \(scriptPath) with the arguments \(arguments)")
        var nodeArguments = [
            "node",
            scriptPath
        ]
        nodeArguments.append(contentsOf: arguments)
        NodeRunner.startEngine(withArguments: nodeArguments)

        DispatchQueue.main.sync {
            stopped?()
        }
    }
}

