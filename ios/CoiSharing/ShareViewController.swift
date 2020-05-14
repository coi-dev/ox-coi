//
//  ShareViewController.swift
//  CoiSharing
//
//  Created by Cihan Özkan on 17.04.20.
//  Copyright © 2020 OX Software GmbH. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Photos

class ShareViewController: UIViewController {

    let dataContentType = kUTTypeData as String
    let textContentType = kUTTypeText as String
    let urlContentType = kUTTypeURL as String
    let fileURLType = kUTTypeFileURL as String
    let appleKeynoteType = "com.apple.iwork.keynote.keynote"
    let applePagesType = "com.apple.iwork.pages.pages"
    let appleNumbersType = "com.apple.iwork.numbers.numbers"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let content = extensionContext?.inputItems[0] as? NSExtensionItem {
            if let contents = content.attachments {
                for (index, attachment) in contents.enumerated() {
                    if attachment.hasItemConformingToTypeIdentifier(urlContentType) {
                        handleURLs(content: content, attachment: attachment, index: index)
                    } else if attachment.hasItemConformingToTypeIdentifier(textContentType) {
                        handleText(content: content, attachment: attachment)
                    } else if attachment.hasItemConformingToTypeIdentifier(dataContentType) {
                        handleFiles(content: content, attachment: attachment, index: index, identifier: dataContentType)
                    }
                }
            }
        }
        
    }
    
    private func handleText (content: NSExtensionItem, attachment: NSItemProvider) {
        attachment.loadItem(forTypeIdentifier: textContentType, options: nil) { [weak self] data, error in
            if error == nil, let shareText = data as? String, let this = self {
                let userDefaults = UserDefaults(suiteName: SharedData.SuiteName)
                userDefaults?.set(DataType.text.rawValue, forKey: SharedData.DataType)
                userDefaults?.set(shareText, forKey: SharedData.Text)
                userDefaults?.synchronize()
                this.redirectToHostApp()
            }
        }
    }
    
    private func handleURLs (content: NSExtensionItem, attachment: NSItemProvider, index: Int) {
        attachment.loadItem(forTypeIdentifier: urlContentType, options: nil) { [weak self] url, error in
            if error == nil, let shareURL = url as? URL, let this = self {
                if attachment.hasItemConformingToTypeIdentifier(this.fileURLType) {
                    if attachment.hasItemConformingToTypeIdentifier(this.applePagesType) {
                        this.handleFiles(content: content, attachment: attachment, index: index, identifier: this.applePagesType)
                    } else if attachment.hasItemConformingToTypeIdentifier(this.appleNumbersType) {
                        this.handleFiles(content: content, attachment: attachment, index: index, identifier: this.appleNumbersType)
                    } else if attachment.hasItemConformingToTypeIdentifier(this.appleKeynoteType) {
                        this.handleFiles(content: content, attachment: attachment, index: index, identifier: this.appleKeynoteType)
                    } else {
                        this.handleFiles(content: content, attachment: attachment, index: index, identifier: this.fileURLType)
                    }
                    
                } else if attachment.hasItemConformingToTypeIdentifier(this.urlContentType) {
                    let userDefaults = UserDefaults(suiteName: SharedData.SuiteName)
                    userDefaults?.set(DataType.url.rawValue, forKey: SharedData.DataType)
                    userDefaults?.set(shareURL.absoluteString, forKey: SharedData.Text)
                    userDefaults?.synchronize()
                    this.redirectToHostApp()
                }
            }
        }
    }
    
    private func handleFiles (content: NSExtensionItem, attachment: NSItemProvider, index: Int, identifier: String) {
        attachment.loadItem(forTypeIdentifier: identifier, options: nil) { [weak self] data, error in
        if error == nil, let url = data as? URL, let this = self {
                let fileExtension = this.getExtension(from: url, type: .file)
                let newName = UUID().uuidString

            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedData.SuiteName) else {
                this.dismissWithError()
                return
            }
            
            let newPath = containerURL.appendingPathComponent("\(newName).\(fileExtension)")
            _ = this.copyFile(at: url, to: newPath)
            
            if let attachmentsCount = content.attachments?.count {
                if index == attachmentsCount - 1 {
                    let userDefaults = UserDefaults(suiteName: SharedData.SuiteName)
                    userDefaults?.set(DataType.file.rawValue, forKey: SharedData.DataType)
                    userDefaults?.set(newPath, forKey: SharedData.Path)
                    userDefaults?.set(this.mimeType(pathExtension: this.getExtension(from: newPath, type: .file)), forKey: SharedData.MimeType)
                    userDefaults?.set("\(newName).\(fileExtension)", forKey: SharedData.FileName)
                    userDefaults?.synchronize()
                    this.redirectToHostApp()
                }
            }
                
            } else {
                 self?.dismissWithError()
            }
        }
    }
    
    private func dismissWithError() {
        print("[ERROR] Error loading data!")
        let alert = UIAlertController(title: "Error", message: "Error loading data", preferredStyle: .alert)

        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func getExtension(from url: URL, type: SharedMediaType) -> String {
        let parts = url.lastPathComponent.components(separatedBy: ".")
        var ex: String?

        if parts.count > 1 {
            ex = parts.last
        }

        if ex == nil {
            switch type {
                case .image:
                    ex = "PNG"
                case .video:
                    ex = "MP4"
                case .file:
                    ex = "TXT"
            }
        }
        return ex ?? "Unknown"
    }
    
    enum SharedMediaType: Int, Codable {
        case image
        case video
        case file
    }
    
    func copyFile(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch let error {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
    
    func mimeType(pathExtension: String) -> String {
        let pathExtension = pathExtension
        var mimeType = "application/octet-stream" // Be generic, if we can deduce a more specific mime type, it'll be set below
        if let utiCFString = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil) {
            let uti = utiCFString.takeRetainedValue()
            let mimeTypeCFString = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)
            if let mimeTypeNSString = mimeTypeCFString?.takeRetainedValue() {
                mimeType = mimeTypeNSString as String
                print("File at url \(self) has mime type \(mimeType)")
            } else {
                print("Could not infer mime type of file at url \(self).")
            }
        }
        return mimeType
    }

    private func redirectToHostApp() {
        let url = URL(string: "coisharing://")
        var responder = self as UIResponder?
        let selectorOpenURL = sel_registerName("openURL:")
    
        while responder != nil {
            if let responds = responder?.responds(to: selectorOpenURL) {
                if responds {
                    _ = responder?.perform(selectorOpenURL, with: url)
                    break
                }
            }
            responder = responder?.next
        }
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    enum DataType: String {
        case url
        case text
        case file
    }

}
