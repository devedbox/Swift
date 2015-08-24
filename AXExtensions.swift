//
//  AXExtensions.swift
//  20150718
//
//  Created by ai on 15/8/8.
//  Copyright © 2015年 ai. All rights reserved.
//

import Foundation
import Swift
import UIKit
import Photos
import AssetsLibrary

extension UINavigationBar {
    public func setSeperatorHidden(hidden: Bool) -> Void {
        for view in self.subviews {
            if view is UIImageView && view.subviews.count > 0 {
                for seperator in view.subviews {
                    if seperator is UIImageView {
                        seperator.hidden = hidden
                    }
                }
            }
        }
    }
}
extension UIToolbar {
    public func setSeperatorHidden(hidden: Bool) -> Void {
        for view in self.subviews {
            if view is UIImageView && view.subviews.count == 0 {
                view.hidden = hidden
            }
        }
    }
}
extension UIViewController {
    struct customProperties {
        
    }
    public func setTitle(title: String, titleColor: UIColor = UIColor.whiteColor(), titleFont: UIFont = UIFont.boldSystemFontOfSize(19)) -> Void {
        self.title = title
        let label = UILabel(frame: CGRectZero)
        label.textColor = titleColor
        label.font = titleFont
        label.backgroundColor = UIColor.clearColor()
        label.text = self.title
        navigationController?.navigationItem.titleView = label
    }
}
@available(iOS 8.0, *)
extension PHAsset {
    var image: UIImage? {
        return { () -> UIImage? in
            var aImage: UIImage?
            PHImageManager.defaultManager().requestImageForAsset(self, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.Default, options: { () -> PHImageRequestOptions in
                let option = PHImageRequestOptions()
                option.synchronous = true
                return option
                }(), resultHandler: { (image, userInfo) -> Void in
                    aImage = image
                })
            return aImage
        }()
    }
}
@available(iOS 8.0, *)
public func ==(lhs: PHAsset, rhs: PHAsset) -> Bool {
    return lhs.localIdentifier == rhs.localIdentifier
}
extension ALAsset {
    var image: UIImage {
        return UIImage(CGImage: self.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
    }
}
public func ==(lhs: ALAsset, rhs: ALAsset) -> Bool {
    return lhs.valueForProperty(ALAssetPropertyAssetURL) as! String == rhs.valueForProperty(ALAssetPropertyAssetURL) as! String
}