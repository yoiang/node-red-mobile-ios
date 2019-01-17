//
//  AppDelegate.swift
//  native-xcode
//
//  Created by Ian Grossberg on 1/17/19.
//  Copyright © 2019 Adorkable. All rights reserved.
//

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
}

extension AppDelegate {
    static var userDocumentsPath: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

extension AppDelegate {
    static func monitor(_ file: URL, onDeleted: @escaping (_ file: URL) -> Void) throws {
        let watchQueue = DispatchQueue.global()

        let folderPath = file.deletingLastPathComponent()

        let folderId = open(folderPath.path, O_EVTONLY)
        guard folderId != -1 else {
            throw Errors.unableToMonitorFolder
        }

        let folderDispatch = DispatchSource.makeFileSystemObjectSource(fileDescriptor: folderId, eventMask: .write, queue: watchQueue)

        folderDispatch.setEventHandler {
            let fileId = open(file.path, O_EVTONLY)
            guard fileId != -1 else {
                return
            }

            folderDispatch.cancel()

            let fileDispatch = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileId, eventMask: .delete, queue: watchQueue)

            fileDispatch.setEventHandler {
                fileDispatch.cancel()

                onDeleted(file)
            }

            fileDispatch.setCancelHandler {
                close(fileId)
            }

            fileDispatch.resume()
        }

        folderDispatch.setCancelHandler {
            close(folderId)
        }

        folderDispatch.resume()
    }
}

extension AppDelegate {
    enum Errors: Error {
        case unableToMonitorFolder
    }
}
