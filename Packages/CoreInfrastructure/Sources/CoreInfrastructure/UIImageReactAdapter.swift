//
//  UIImageReactAdapter.swift
//  CoreInfrastructure
//
//  Adapter layer: convert UIImage ↔ Data to keep domain framework-free.
//  All image conversion happens here; domain only sees Data.
//

import Foundation
import UIKit

/// Bridge between UI (UIImage) and domain (Data).
/// Centralizes all UIImage serialization logic.
public struct UIImageReactAdapter {

    public static func imageDataForDomain(_ image: UIImage, compressionQuality: CGFloat = 0.92) throws -> Data {
        guard let jpegData = image.jpegData(compressionQuality: compressionQuality) else {
            throw ImageAdapterError.cannotSerializeImage
        }
        return jpegData
    }

    public enum ImageAdapterError: Error {
        case cannotSerializeImage
    }
}
