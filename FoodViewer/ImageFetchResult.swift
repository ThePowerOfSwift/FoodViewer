//
//  ImageFetchResult.swift
//  FoodViewer
//
//  Created by arnaud on 05/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum ImageFetchResult {
    case success(Data)
    case loading
    case loadingFailed(Error)
    case noData
    case noImageAvailable
    
    func description() -> String {
        switch self {
        case .success: return NSLocalizedString("Image is loaded", comment: "String presented in a tagView if the image has been loaded")
        case .loading: return NSLocalizedString("Image is being loaded", comment: "String presented in a tagView if the image is currently being loaded")
        case .loadingFailed: return NSLocalizedString("Image loading has failed", comment: "String presented in a tagView if the image loading has failed")
        case .noData: return NSLocalizedString("Image was empty", comment: "String presented in a tagView if the image data contained no data")
        case .noImageAvailable: return NSLocalizedString("No image available", comment: "String presented in a tagView if no image is available")

        }
    }
    
    func retrieveImageData(_ url: URL?, cont: ((ImageFetchResult) -> Void)?) {
        if let imageURL = url {
            // self.nutritionImageData = .Loading
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try Data(contentsOf: imageURL, options: NSData.ReadingOptions.mappedIfSafe)
                    if imageData.count > 0 {
                        // if we have the image data we can go back to the main thread
                        DispatchQueue.main.async(execute: { () -> Void in
                            // set the received image data to the current product if valid
                            cont?(.success(imageData))
                            return
                        })
                    } else {
                        DispatchQueue.main.async(execute: { () -> Void in
                            // set the received image data to the current product if valid
                            cont?(.noData)
                            return
                        })
                    }
                }
                catch {
                    DispatchQueue.main.async(execute: { () -> Void in
                        // set the received image data to the current product if valid
                        cont?(.loadingFailed(error))
                        return
                    })
                }
            })
        } else {
            cont?(.noImageAvailable)
            return
        }
    }

}
