//
//  AXFunctions.swift
//  20150718
//
//  Created by ai on 15/8/20.
//  Copyright © 2015年 ai. All rights reserved.
//

import Foundation
import UIKit

/// execute a closure of () -> Void
public func execute(block:(() -> ())) {
    block()
}
/// execute a closure of () -> Void on main thread
public func executeOnMainThread(block: dispatch_block_t) {
    if NSThread.isMainThread() {
        block()
    } else {
        dispatch_async(dispatch_get_main_queue(), block)
    }
}
/// get a instant AnyObject with a closure of () -> AnyObject?
public func get(block:() -> AnyObject?) -> AnyObject? {
    return block()
}

public func getTextSize(text: NSString?, font: UIFont) -> CGSize {
    guard let aText = text else {
        return CGSizeZero
    }
    if aText.length > 0 {
        return aText.sizeWithAttributes([NSFontAttributeName : font])
    }
    return CGSizeZero
}

public func getMutableTextSize(text: NSString?, font: UIFont, maxSize: CGSize) -> CGSize {
    guard let aText = text else {
        return CGSizeZero
    }
    if aText.length > 0 {
        let size = aText.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil)
        return CGSizeMake(size.width, ceil(size.height))
    }
    return CGSizeZero
}
