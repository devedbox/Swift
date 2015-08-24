//
//  AXProgressHUD.swift
//  20150718
//
//  Created by ai on 15/8/20.
//  Copyright © 2015年 ai. All rights reserved.
//

import Swift
import UIKit
import Darwin
import ObjectiveC
import Foundation
import CoreGraphics

public enum AXPracticalHUDMode: Int {
    /** HUD is shown using an UIActivityIndicatorView. This is the default. */
   case Indeterminate
    /** HUD is shown using a round, pie-chart like, progress view. */
   case Determinate
    /** HUD is shown using a horizontal progress bar */
   case DeterminateHorizontalBar
    /** HUD is shown using a ring-shaped progress view. */
   case AnnularDeterminate
    /** Shows a custom view */
   case CustomView
    /** Shows only labels */
   case Text
}

public enum AXPracticalHUDAnimation: Int {
    /** Opacity animation */
   case Fade = 1
    /** Flip in animation */
   case FlipIn
}

public enum AXPracticalHUDPosition: Int {
    case Top = 1
    case Center
    case Bottom
}

public enum AXPracticalHUDTranslucentStyle: Int {
    case Light = 1
    case Dark
}

@objc public protocol AXPracticalHUDDelegate {
    optional func HUDDidHidden(HUD: AXPracticalHUD) -> Void
}

public typealias AXPracticalHUDCompletionBlock = () -> Void

private let padding: CGFloat = 4.0
private let fontSize: CGFloat = 14.0
private let detailFontSize: CGFloat = 12.0
private let defaultMargin: CGFloat = 15.0

public class AXPracticalHUD: UIView {
    // prperties
    public var lockBackground: Bool = true
    public var size: CGSize = CGSizeZero
    public var square: Bool     = false
    public var margin: CGFloat = defaultMargin
    public var offsetX: CGFloat = 0.0
    public var offsetY: CGFloat = 0.0
    public var minSize: CGSize  = CGSizeZero
    public var graceTime: NSTimeInterval = 0.0
    public var animation: AXPracticalHUDAnimation = .Fade
    public var completion: AXPracticalHUDCompletionBlock?
    public var minShowTime: NSTimeInterval = 0.5
    public var dimBackground: Bool = false
    public weak var delegate: AXPracticalHUDDelegate?
    public var contentInsets: UIEdgeInsets = UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)
    public var progressing: Bool = false
    public var opacity: CGFloat = 0.8 {
        didSet {
            executeOnMainThread { () -> Void in
                self.contentView.opacity = self.opacity
            }
        }
    }
    public var color: UIColor? {
        didSet {
            executeOnMainThread { () -> Void in
                self.contentView.color = self.color
            }
        }
    }
    public var endColor: UIColor? {
        didSet {
            executeOnMainThread { () -> Void in
                self.contentView.endColor = self.endColor
            }
        }
    }
    public var translucent: Bool = false {
        didSet {
            executeOnMainThread { () -> Void in
                self.contentView.translucent = self.translucent
            }
        }
    }
    public var translucentStyle: AXPracticalHUDTranslucentStyle = .Dark {
        didSet {
            let block: dispatch_block_t = { () -> Void in
                self.contentView.translucentStyle = self.translucentStyle
            }
            executeOnMainThread(block)
        }
    }
    public var text: String? {
        get { return self.label.text }
        set {
            executeOnMainThread { () -> Void in
                self.label.text = newValue
            }
        }
    }
    public var font: UIFont! {
        get { return self.label.font }
        set {
            executeOnMainThread { () -> Void in
                self.label.font = newValue
            }
        }
    }
    public var mode: AXPracticalHUDMode = .Indeterminate {
        didSet {
            executeOnMainThread { () -> Void in
                self.updateIndicators()
                self.setNeedsLayout()
                self.setNeedsDisplay()
            }
        }
    }
    public var position: AXPracticalHUDPosition = .Center {
        didSet {
            executeOnMainThread { () -> Void in
                self.setNeedsLayout()
                self.setNeedsDisplay()
            }
        }
    }
    public var progress: CGFloat = 0.0 {
        didSet {
            executeOnMainThread { () -> Void in
                if self.indicator is AXBarProgressView {
                    (self.indicator as! AXBarProgressView).value = self.progress
                } else if self.indicator is AXRoundProgressView {
                    (self.indicator as! AXRoundProgressView).value = self.progress
                }
            }
        }
    }
    public var detailText: String? {
        get { return self.detailLabel.text }
        set {
            executeOnMainThread { () -> Void in
                self.detailLabel.text = newValue
            }
        }
    }
    public var customView: UIView? {
        didSet {
            executeOnMainThread { () -> Void in
                self.updateIndicators()
                self.setNeedsLayout()
                self.setNeedsDisplay()
            }
        }
    }
    public var cornerRadius: CGFloat = 8.0 {
        didSet {
            executeOnMainThread { () -> Void in
                self.contentView.layer.cornerRadius = self.cornerRadius
                self.contentView.layer.masksToBounds = true
            }
        }
    }
    public var detailTextColor: UIColor? {
        get { return self.detailLabel.textColor }
        set {
            executeOnMainThread { () -> Void in
                self.detailLabel.textColor = newValue?.colorWithAlphaComponent(0.75)
            }
        }
    }
    public var textColor: UIColor? {
        get { return self.label.textColor }
        set {
            executeOnMainThread { () -> Void in
                self.label.textColor = newValue
            }
        }
    }
    public var detailFont: UIFont! {
        get { return self.detailLabel.font }
        set {
            executeOnMainThread { () -> Void in
                self.detailLabel.font = newValue
            }
        }
    }
    public var activityIndicatorColor: UIColor? {
        didSet {
            executeOnMainThread { () -> Void in
                self.updateIndicators()
                self.setNeedsLayout()
                self.setNeedsDisplay()
            }
        }
    }
    public var removeFromSuperViewOnHide: Bool = false
    // private property
    private var animated: Bool = false
    private var isFinished: Bool = false
    private var executedMethod: Selector?
    private var executedTarget: NSObject?
    private var executedObject: AnyObject?
    private var rotationTransform: CGAffineTransform = CGAffineTransformIdentity
    private var graceTimer: NSTimer!
    private var minShowTimer: NSTimer?
    private var showStarted: NSDate?
    private var contentFrame: CGRect {
        switch position {
        case .Top:
            return CGRectMake(round((bounds.width - size.width) / 2) + offsetX, 0 + offsetY, size.width, size.height)
        case .Center:
            return CGRectMake(round((bounds.width - size.width) / 2) + offsetX, round((bounds.size.height - size.height) / 2) + offsetY, size.width, size.height)
        case .Bottom:
            if let height = superview?.bounds.height {
                return CGRectMake(round((bounds.width - size.width) / 2) + offsetX, height - size.height + offsetY, size.width, size.height)
            } else {
                return CGRectMake(round((bounds.width - size.width) / 2) + offsetX, round((bounds.size.height - size.height) / 2) + offsetY, size.width, size.height)
            }
        }
    }
    private lazy var label: UILabel = get { [unowned self] () -> AnyObject? in
        let label = UILabel(frame: self.bounds)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .Center
        label.opaque = false
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(fontSize)
        return label
    } as! UILabel
    private lazy var detailLabel: UILabel = get { [unowned self] () -> AnyObject? in
        let label = UILabel(frame: self.bounds)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = .Center
        label.opaque = false
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(detailFontSize)
        return label
    } as! UILabel
    private var indicator: UIView?
    private lazy var contentView: AXPracticalHUDContentView = get { [unowned self] () -> AnyObject? in
        let view = AXPracticalHUDContentView(frame: CGRectZero)
        view.layer.cornerRadius = self.cornerRadius
        view.layer.masksToBounds = true
        view.opacity = self.opacity
        view.color = self.color
        view.endColor = self.endColor
        view.translucent = self.translucent
        view.translucentStyle = self.translucentStyle
        return view
    } as! AXPracticalHUDContentView
    private class AXRoundProgressView: UIView {
        var value: CGFloat = 0.0 {
            didSet {
                setNeedsDisplay()
            }
        }
        var progressColor: UIColor = UIColor.whiteColor() {
            didSet {
                setNeedsDisplay()
            }
        }
        var progressBackgroundColor: UIColor = UIColor(white: 1, alpha: 0.1) {
            didSet {
                setNeedsDisplay()
            }
        }
        var annular: Bool = false {
            didSet {
                setNeedsDisplay()
            }
        }
        init() {
            super.init(frame: CGRectMake(0, 0, 37, 37))
            initializer()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        final func initializer() -> Void {
            backgroundColor = UIColor.clearColor()
            opaque = false
        }
        
        override private func drawRect(rect: CGRect) {
            super.drawRect(rect)
            let allRect = bounds
            let circleRect = CGRectInset(allRect, 2.0, 2.0)
            let context = UIGraphicsGetCurrentContext()
            
            if annular {
                // draw background
                let isPre_IOS_7 = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0
                let lineWidth: CGFloat = isPre_IOS_7 ? 5.0 : 2.0
                let backgroundPath = UIBezierPath()
                backgroundPath.lineWidth = lineWidth
                backgroundPath.lineCapStyle = .Butt
                let center: CGPoint = CGPointMake(bounds.size.width/2, bounds.size.height/2)
                let radius: CGFloat = (bounds.width - lineWidth) / 2
                // 90 degrees
                let startAngle: CGFloat = -CGFloat((M_PI / 2));
                var endAngle: CGFloat = CGFloat(2.0) * CGFloat(M_PI) + startAngle
                backgroundPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                progressBackgroundColor.set()
                backgroundPath.stroke()
                // draw progress
                let progressPath = UIBezierPath()
                progressPath.lineCapStyle = isPre_IOS_7 ? .Round : .Square
                progressPath.lineWidth = lineWidth
                endAngle = value * CGFloat(2.0) * CGFloat(M_PI) + startAngle
                progressPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                progressColor.set()
                progressPath.stroke()
            } else {
                // draw background
                progressColor.setStroke()
                progressBackgroundColor.setFill()
                CGContextSetLineWidth(context, 2.0);
                CGContextFillEllipseInRect(context, circleRect);
                CGContextStrokeEllipseInRect(context, circleRect);
                // draw progress
                let center: CGPoint = CGPointMake(allRect.size.width/2, allRect.size.height/2)
                let radius: CGFloat = (allRect.width - 4) / 2
                let startAngle: CGFloat = -CGFloat((M_PI / 2));
                let endAngle: CGFloat = value * CGFloat(2.0) * CGFloat(M_PI) + startAngle
                progressColor.setFill()
                CGContextMoveToPoint(context, center.x, center.y);
                CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
                CGContextClosePath(context);
                CGContextFillPath(context);
            }
        }
    }
    
    private class AXBarProgressView: UIView {
        var value: CGFloat = 0.0 {
            didSet {
                setNeedsDisplay()
            }
        }
        var lineColor: UIColor = UIColor.whiteColor() {
            didSet {
                setNeedsDisplay()
            }
        }
        var progressColor: UIColor = UIColor.whiteColor() {
            didSet {
                setNeedsDisplay()
            }
        }
        var trackColor: UIColor = UIColor.clearColor() {
            didSet {
                setNeedsDisplay()
            }
        }
        init() {
            super.init(frame: CGRectMake(0, 0, 120, 12))
            initializer()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        final func initializer() -> Void {
            backgroundColor = UIColor.clearColor()
            opaque = false
        }
        override private func drawRect(rect: CGRect) {
            super.drawRect(rect)
            let context = UIGraphicsGetCurrentContext()
            
            CGContextSetLineWidth(context, 2);
            CGContextSetStrokeColorWithColor(context,lineColor.CGColor);
            CGContextSetFillColorWithColor(context, trackColor.CGColor);
            
            // Draw background
            var radius: CGFloat = (rect.size.height / 2) - 2;
            CGContextMoveToPoint(context, 2, rect.size.height/2);
            CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
            CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
            CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width - 2, rect.size.height / 2, radius);
            CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2, rect.size.width - radius - 2, rect.size.height - 2, radius);
            CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);
            CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2, rect.size.height/2, radius);
            CGContextFillPath(context);
            
            // Draw border
            CGContextMoveToPoint(context, 2, rect.size.height/2);
            CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
            CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
            CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width - 2, rect.size.height / 2, radius);
            CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2, rect.size.width - radius - 2, rect.size.height - 2, radius);
            CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);
            CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2, rect.size.height/2, radius);
            CGContextStrokePath(context);
            
            CGContextSetFillColorWithColor(context, progressColor.CGColor);
            radius = radius - 2;
            let amount: CGFloat = value * rect.size.width;
            
            // Progress in the middle area
            if (amount >= radius + 4 && amount <= (rect.size.width - radius - 4)) {
                CGContextMoveToPoint(context, 4, rect.size.height/2);
                CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
                CGContextAddLineToPoint(context, amount, 4);
                CGContextAddLineToPoint(context, amount, radius + 4);
                
                CGContextMoveToPoint(context, 4, rect.size.height/2);
                CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
                CGContextAddLineToPoint(context, amount, rect.size.height - 4);
                CGContextAddLineToPoint(context, amount, radius + 4);
                
                CGContextFillPath(context);
            }
                
                // Progress in the right arc
            else if (amount > radius + 4) {
                let x: CGFloat = amount - (rect.size.width - radius - 4);
                
                CGContextMoveToPoint(context, 4, rect.size.height/2);
                CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
                CGContextAddLineToPoint(context, rect.size.width - radius - 4, 4);
                var angle: CGFloat = -acos(x/radius);
                if isnan(angle) {
                    angle = CGFloat(0.0);
                }
                CGContextAddArc(context, rect.size.width - radius - CGFloat(4), rect.size.height / 2, radius, CGFloat(M_PI), angle, 0);
                CGContextAddLineToPoint(context, amount, rect.size.height/2);
                
                CGContextMoveToPoint(context, 4, rect.size.height/2);
                CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
                CGContextAddLineToPoint(context, rect.size.width - radius - 4, rect.size.height - 4);
                angle = acos(x/radius);
                if isnan(angle) {
                    angle = CGFloat(0.0);
                }
                CGContextAddArc(context, rect.size.width - radius - CGFloat(4), rect.size.height / 2, radius, -CGFloat(M_PI), angle, 1);
                CGContextAddLineToPoint(context, amount, rect.size.height/2);
                
                CGContextFillPath(context);
            } else if (amount < radius + 4 && amount > 0) {// Progress is in the left arc
                CGContextMoveToPoint(context, 4, rect.size.height/2);
                CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
                CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);
                
                CGContextMoveToPoint(context, 4, rect.size.height/2);
                CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius + 4, rect.size.height - 4, radius);
                CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);
                
                CGContextFillPath(context);
            }
        }
    }
    
    private class AXPracticalHUDContentView: UIView {
        var color: UIColor? {
            didSet {
                setNeedsDisplay()
            }
        }
        var endColor: UIColor? {
            didSet {
                setNeedsDisplay()
            }
        }
        var translucent: Bool = false {
            didSet {
                if self.translucent {
                    insertSubview(self.effectView, atIndex: 0)
                } else {
                    self.effectView.removeFromSuperview()
                }
                setNeedsDisplay()
                setNeedsLayout()
            }
        }
        var translucentStyle: AXPracticalHUDTranslucentStyle = .Dark {
            didSet {
                if translucent == false {
                    return
                }
                if #available(iOS 8.0, *) {
                    if let eff = effectView as? UIVisualEffectView {
                        switch translucentStyle {
                        case .Light:
                            eff.effect = UIBlurEffect(style: .ExtraLight)
                        case .Dark:
                            eff.effect = UIBlurEffect(style: .Dark)
                        }
                    }
                } else {
                    if let eff = effectView as? UIToolbar {
                        switch translucentStyle {
                        case .Light:
                            eff.barStyle = .Default
                        case .Dark:
                            eff.barStyle = .Black
                        }
                    }
                }
            }
        }
        var opacity: CGFloat = 0.8 {
            didSet {
                setNeedsDisplay()
            }
        }
        private lazy var effectView: UIView = get { () -> AnyObject? in
            if #available(iOS 8.0, *) {
                let effect = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
                effect.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
                return effect
            } else {
                let effect = UIToolbar(frame: CGRectZero)
                effect.setSeperatorHidden(true)
                effect.barStyle = .Black
                effect.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
                return effect
            }
        } as! UIView
        
        convenience init() {
            self.init(frame: CGRectZero)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            initializer()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private final func initializer() -> Void {
            backgroundColor = UIColor.clearColor()
            if translucent {
                insertSubview(effectView, atIndex: 0)
            }
        }
        
        private override func drawRect(rect: CGRect) {
            super.drawRect(rect)
            
            guard let context = UIGraphicsGetCurrentContext() else {
                fatalError("Invalid Context")
            }
            UIGraphicsPushContext(context)
            
            if translucent {
                CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
            } else if let aColor = endColor {
                // Gradient color
                let gradLocations: [CGFloat] = [0.0, 1.0]
                var r1: CGFloat = 0.0
                var r2: CGFloat = 0.0
                var g1: CGFloat = 0.0
                var g2: CGFloat = 0.0
                var b1: CGFloat = 0.0
                var b2: CGFloat = 0.0
                var a1: CGFloat = 0.75
                var a2: CGFloat = 0.0
                color?.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
                aColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
                let gradColors: [CGFloat] = [r1, g1, b1, a1, r2, g2, b2, a2]
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocations.count)
                CGContextDrawLinearGradient(context, gradient, CGPointMake(bounds.width / 2, bounds.height), CGPointMake(bounds.width / 2, 0), CGGradientDrawingOptions.DrawsAfterEndLocation)
                CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
            } else {
                if color == nil {
                    CGContextSetGrayFillColor(context, 0.0, opacity)
                } else {
                    CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
                }
                
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, CGRectGetMinX(bounds) + 0.0, CGRectGetMinY(bounds));
                CGContextAddArc(context, CGRectGetMaxX(bounds) - 0.0, CGRectGetMinY(bounds) + 0.0, 0.0, 3 * CGFloat(M_PI) / 2, 0, 0);
                CGContextAddArc(context, CGRectGetMaxX(bounds) - 0.0, CGRectGetMaxY(bounds) - 0.0, 0.0, 0, CGFloat(M_PI) / 2, 0);
                CGContextAddArc(context, CGRectGetMinX(bounds) + 0.0, CGRectGetMaxY(bounds) - 0.0, 0.0, CGFloat(M_PI) / 2, CGFloat(M_PI), 0);
                CGContextAddArc(context, CGRectGetMinX(bounds) + 0.0, CGRectGetMinY(bounds) + 0.0, 0.0, CGFloat(M_PI), 3 * CGFloat(M_PI) / 2, 0);
                CGContextClosePath(context);
                CGContextFillPath(context);
            }
            
            UIGraphicsPopContext()
        }
        
        private override func layoutSubviews() {
            super.layoutSubviews()
            
            effectView.frame = bounds
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializer()
    }
    
    convenience init(withWindow window: UIWindow) {
        self.init(withView: window)
    }
    
    convenience init(withView view: UIView) {
        self.init(frame: view.bounds)
    }

    private final func initializer() -> Void {
        alpha = 0.0
        opaque = false
        contentMode = .Center
        backgroundColor = UIColor.clearColor()
        autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleBottomMargin).union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        
        addSubview(contentView)
        contentView.addSubview(label)
        contentView.addSubview(detailLabel)
        updateIndicators()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusBarOrientationDidChange:", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
    }
    
    //MARK: - Override
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            updateForCurrentOrientationAnimated(false)
        }
    }
    
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, withEvent: event) {
            if lockBackground {
                return view
            } else {
                if contentFrame.contains(point) {
                    return view
                } else {
                    return nil
                }
            }
        }
        return nil
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("UIGraphicsGetCurrentContext get context failed")
        }
        
        UIGraphicsPushContext(context)
        
        if dimBackground == true {
            //Gradient colours
            let gradLocationsNum: size_t = 2
            let gradLocations:[CGFloat] = [0.0, 1.0]
            let gradColors:[CGFloat] = [0.0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, 0.3]
            guard let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB() else {
                fatalError("CGColorSpaceCreateDeviceRGB get color space failed")
            }
            guard let gradient: CGGradientRef = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum) else {
                fatalError("CGGradientCreateWithColorComponents get gradient failed")
            }
            //Gradient center
            let gradCenter: CGPoint = CGPointMake(bounds.width / 2, bounds.height / 2)
            //Gradient radius
            let gradRadius: CGFloat = min(bounds.width , bounds.height)
            //Gradient draw
            CGContextDrawRadialGradient (context, gradient, gradCenter, 0, gradCenter, gradRadius, CGGradientDrawingOptions.DrawsAfterEndLocation)
        }
        
        UIGraphicsPopContext();
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let aFrame = superview?.bounds {
            frame = aFrame
        }
        let maxWidth: CGFloat = bounds.width - contentInsets.left - contentInsets.right - 2 * margin
        
        var rect_indicator = indicator?.frame ?? CGRectZero
        var rect_label = { [unowned self] () -> CGRect in
            let size = getTextSize(self.label.text, font: self.label.font)
            let rect = CGRectMake(0, 0, size.width, size.height)
            return rect
            }()
        var rect_detail = { [unowned self] () -> CGRect in
            let size = getMutableTextSize(self.detailLabel.text, font: self.detailLabel.font, maxSize: CGSizeMake(maxWidth, CGFloat.max))
            let rect = CGRectMake(0, 0, size.width, size.height)
            return rect
            }()
        let height_content = get { () -> AnyObject? in
            var height = rect_indicator.height + rect_label.height + rect_detail.height
            height += self.contentInsets.top + self.contentInsets.bottom
            if rect_label.height > 0.0 {
                height += padding
            }
            if rect_detail.height > 0.0 {
                height += padding
            }
            return ceil(height)
        } as! CGFloat
        let width_content = get { [unowned self] () -> AnyObject? in
            if self.position == .Top || self.position == .Bottom {
                return maxWidth + self.contentInsets.left + self.contentInsets.right
            }
            let width = min(maxWidth, max(rect_indicator.width, rect_label.width, rect_detail.width)) + self.contentInsets.left + self.contentInsets.right
            return width
        } as! CGFloat
        
        var size_content = CGSizeMake(width_content, height_content)
        if square == true {
            let maxValue: CGFloat = max(width_content, height_content)
            if maxValue <= bounds.width - 2 * margin {
                size_content.width = maxValue
            }
            if (maxValue <= bounds.height - 2 * margin) {
                size_content.height = maxValue
            }
        }
        if (size_content.width < minSize.width) {
            size_content.width = minSize.width
        }
        if (size_content.height < minSize.height) {
            size_content.height = minSize.height
        }
        
        size = size_content
        
        rect_indicator.origin.y = contentInsets.top
        rect_indicator.origin.x = round((size.width - rect_indicator.width) / 2) + contentInsets.left - contentInsets.right
        indicator?.frame = rect_indicator
        
        rect_label.origin.y = rect_label.height > 0.0 ? CGRectGetMaxY(rect_indicator) + padding : CGRectGetMaxY(rect_indicator)
        rect_label.origin.x = round((size.width - rect_label.size.width) / 2) + contentInsets.left - contentInsets.right
        label.frame = rect_label

        rect_detail.origin.y = rect_detail.height > 0.0 ? CGRectGetMaxY(rect_label) + padding : CGRectGetMaxY(rect_label)
        rect_detail.origin.x = round((size.width - rect_detail.width) / 2) + contentInsets.left - contentInsets.right
        detailLabel.frame = rect_detail
        
        contentView.frame = contentFrame
    }
    
    func show(animated animated: Bool, executingBlock block: dispatch_block_t? = nil, onQueue queue: dispatch_queue_t! = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), completion:AXPracticalHUDCompletionBlock? = nil) -> Void
    {
        func showAnimated(animated: Bool) -> Void {
            assert(NSThread.isMainThread(), "AXPracticalHUD needs to be accessed on the main thread.")
            self.animated = animated
            // If the grace time is set postpone the HUD display
            if graceTime > 0.0 {
                let newGraceTimer = NSTimer(timeInterval: graceTime, target: self, selector: "handleGraceTimer:", userInfo: nil, repeats: false)
                NSRunLoop.currentRunLoop().addTimer(newGraceTimer, forMode: NSRunLoopCommonModes)
                graceTimer = newGraceTimer
            } else {
                // ... otherwise show the HUD imediately
                showingAnimated(animated)
            }
        }
        self.completion = completion
        if let executedBlock = block {
            progressing = true
            dispatch_async(queue, { () -> Void in
                executedBlock()
                dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                    self.clear()
                })
            })
        }
        showAnimated(animated)
    }
    
    func hide(animated animated: Bool, afterDelay delay:NSTimeInterval? = nil) -> Void {
        func hideAnimated(animated: Bool) -> Void {
            assert(NSThread.isMainThread(), "AXPracticalHUD needs to be accessed on the main thread.")
            self.animated = animated;
            // If the minShow time is set, calculate how long the hud was shown,
            // and pospone the hiding operation if necessary
            if self.minShowTime > 0.0 && showStarted != nil {
                let interv: NSTimeInterval = NSDate().timeIntervalSinceDate(showStarted!)
                if (interv < self.minShowTime) {
                    minShowTimer = NSTimer.scheduledTimerWithTimeInterval(minShowTime - interv, target: self, selector: "handleMinShowTimer:", userInfo: nil, repeats: false)
                    return
                } 
            }
            // ... otherwise hide the HUD immediately
            hidingAnimated(animated)
        }
        if let aDelay = delay {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(aDelay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                hideAnimated(animated)
            })
        } else {
            hideAnimated(animated)
        }
    }
    
    func show(animated animated: Bool, executingMethod method: Selector, toTarget target: NSObject, withObject object: AnyObject) -> Void {
        executedMethod = method
        executedTarget = target
        executedObject = object
        // Launch execution in new thread
        progressing = true
        NSThread.detachNewThreadSelector("executing", toTarget: self, withObject: nil)
        // Show HUD view
        show(animated: animated)
    }
    
    //MARK: - Helpers
    private final func showingAnimated(animated: Bool) -> Void {
        // Cancel any scheduled hideDelayed: calls
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        setNeedsDisplay()
        setNeedsLayout()
        self.showStarted = NSDate();
        // Fade in
        if animated {
            if animation == .FlipIn {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.alpha = 1.0
                })
                let translation = (position == .Center || position == .Bottom) ? bounds.height : -contentFrame.height
                var rect = contentFrame
                rect.origin.y = translation
                contentView.frame = rect
                UIView.animateWithDuration(0.5, delay: 0.15, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.9, options: UIViewAnimationOptions(rawValue: 7), animations: { [unowned self] () -> Void in
                    self.contentView.frame = self.contentFrame
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions(rawValue: 7), animations: { () -> Void in
                    self.alpha = 1.0
                    }, completion: nil)
            }
        }
        else {
            alpha = 1.0
        }
    }
    
    private final func hidingAnimated(animated: Bool) -> Void {
        // Fade out
        if animated && showStarted != nil {
            if animation == .FlipIn {
                let translation = (position == .Center || position == .Bottom) ? bounds.height : -contentFrame.height
                var rect = contentFrame
                rect.origin.y = translation
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.9, options: UIViewAnimationOptions(rawValue: 7), animations: { () -> Void in
                    self.contentView.frame = rect
                    }, completion: { (finished) -> Void in
                        if finished {
                            self.contentView.frame = self.contentFrame
                            self.completed()
                        }
                    })
                UIView.animateWithDuration(0.25, delay: 0.15, options: UIViewAnimationOptions(rawValue: 7), animations: { () -> Void in
                    self.alpha = 0.02
                    }, completion: nil)
            } else {
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions(rawValue: 7), animations: { () -> Void in
                    self.alpha = 0.02
                    }, completion: { (finished) -> Void in
                        self.completed()
                    })
            }
        } else {
            alpha = 0.0
            completed()
        }
        self.showStarted = nil;
    }
    
    private final func updateIndicators() -> Void {
        let isActivityIndicator = indicator is UIActivityIndicatorView
        let isRoundIndicator = indicator is AXRoundProgressView
        
        switch mode {
        case .Indeterminate:
            if isActivityIndicator == false {
                // Update to indeterminate indicator
                indicator?.removeFromSuperview()
                indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge);
                (indicator as! UIActivityIndicatorView).startAnimating()
                contentView.addSubview(indicator!)
            }
            if __IPHONE_OS_VERSION_MIN_REQUIRED >= 50000 {
                (indicator as! UIActivityIndicatorView).color = activityIndicatorColor ?? UIColor.whiteColor()
            }
        case .DeterminateHorizontalBar:
            // Update to bar determinate indicator
            indicator?.removeFromSuperview()
            indicator = AXBarProgressView();
            contentView.addSubview(indicator!)
        case .Determinate, .AnnularDeterminate:
            if !isRoundIndicator {
                // Update to determinante indicator
                indicator?.removeFromSuperview()
                self.indicator = AXRoundProgressView();
                contentView.addSubview(indicator!)
            }
            if (mode == .AnnularDeterminate) {
                (indicator as! AXRoundProgressView).annular = true
            }
        case .CustomView:
            if customView != indicator {
                // Update custom view indicator
                indicator?.removeFromSuperview()
                indicator = customView;
                guard let aIndicator = indicator else {
                    return
                }
                contentView.addSubview(aIndicator)
            }
        default :
            indicator?.removeFromSuperview()
            indicator = nil;
        }
    }
    
    private final func completed() -> Void {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        isFinished = true
        alpha = 0.0
        if removeFromSuperViewOnHide {
            removeFromSuperview()
        }
        transform = CGAffineTransformIdentity
        contentView.transform = CGAffineTransformIdentity
        completion?()
        delegate?.HUDDidHidden?(self)
    }
    
    @objc private final func statusBarOrientationDidChange(notification: NSNotification) -> Void {
        if let _ = superview {
            updateForCurrentOrientationAnimated(true)
        }
    }
    
    @objc private final func handleGraceTimer(timer: NSTimer) -> Void {
        // Show the HUD only if the task is still running
        if progressing {
            self.showingAnimated(animated)
        }
    }
    
    @objc private final func handleMinShowTimer(timer: NSTimer) -> Void {
        hidingAnimated(animated)
    }
    
    @objc private final func executing() -> Void {
        autoreleasepool { () -> () in
            // Start executing the requested task
            guard let method = executedMethod else {
                fatalError("Method is nil value.")
            }
            executedTarget?.performSelector(method, withObject: executedObject)
            // Task completed, update view in main thread (note: view operations should
            // be done only in the main thread
            performSelectorOnMainThread("clear", withObject: nil, waitUntilDone: false)
        }
    }
    
    @objc private final func clear() -> Void {
        progressing = false
        executedTarget = nil
        executedObject = nil
        hide(animated: animated)
    }
    
    private final func updateForCurrentOrientationAnimated(animated: Bool) -> Void {
        // Stay in sync with the superview in any case
        if let view = superview {
            self.bounds = view.bounds;
            setNeedsDisplay()
            layoutSubviews()
        }
        // Not needed on iOS 8+, compile out when the deployment target allows,
        // to avoid sharedApplication problems on extension targets
        if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000 {
            // Only needed pre iOS 7 when added to a window
            let iOS8OrLater: Bool = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0;
            if iOS8OrLater || !(superview is UIWindow) {
                return;
            }
            
            let orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
            var radians: CGFloat = 0.0
            if UIInterfaceOrientationIsLandscape(orientation) {
                if (orientation == .LandscapeLeft) {
                    radians = -CGFloat(M_PI_2)
                } else {
                    radians = CGFloat(M_PI_2)
                }
                // Window coordinates differ!
                self.bounds = CGRectMake(0, 0, bounds.size.height, bounds.size.width);
            } else {
                if (orientation == .PortraitUpsideDown) {
                    radians = CGFloat(M_PI)
                } else {
                    radians = 0.0
                }
            }
            rotationTransform = CGAffineTransformMakeRotation(radians);
            
            if animated {
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(0.3)
            }
            transform = rotationTransform
            if animated {
                UIView.commitAnimations()
            }
        }
    }
}
extension AXPracticalHUD {
    class func showHUDInView(view:UIView, animated: Bool) -> AXPracticalHUD {
        let HUD = AXPracticalHUD(withView: view)
        HUD.removeFromSuperViewOnHide = true
        view.addSubview(HUD)
        HUD.show(animated: animated)
        return HUD
    }
    
    class func hideHUDInView(view: UIView, animated: Bool) -> Bool {
        if let HUD = self.HUDInView(view) {
            HUD.removeFromSuperViewOnHide = true
            HUD.hide(animated: animated)
            return true
        }
        return false
    }
    
    class func hideAllHUDsInView(view: UIView, animated: Bool) -> Int {
        if let HUDs = self.HUDsInView(view) {
            for var i: Int = 0; i < HUDs.count; i++ {
                let HUD = HUDs[i]
                HUD.removeFromSuperViewOnHide = true
                HUD.hide(animated: animated)
            }
            return HUDs.count
        }
        return 0
    }
    
    class func HUDInView(view:UIView) -> AXPracticalHUD? {
        for var i: Int = view.subviews.count - 1; i >= 0; i-- {
            if view.subviews[i] is AXPracticalHUD {
                return (view.subviews[i] as! AXPracticalHUD)
            }
        }
        return nil
    }
    
    class func HUDsInView(view: UIView) -> [AXPracticalHUD]? {
        var HUDs: [AXPracticalHUD] = []
        for var i: Int = 0; i < view.subviews.count; i++ {
            if view.subviews[i] is AXPracticalHUD {
                HUDs.append((view.subviews[i] as! AXPracticalHUD))
            }
        }
        if HUDs.count > 0 {
            return HUDs
        }
        return nil
    }
}
extension AXPracticalHUD {
    class var sharedHUD: AXPracticalHUD {
        struct _storage {
            static let sharedInstance: AXPracticalHUD = get({ () -> AnyObject? in
                let hud = AXPracticalHUD()
                hud.removeFromSuperViewOnHide = true
                hud.animation = .Fade
                return hud
            }) as! AXPracticalHUD
        }
        return _storage.sharedInstance
    }
    
    func showPie(inView view: UIView, text: String? = nil, detail: String? = nil, configuration: ((HUD: AXPracticalHUD) -> Void)? = nil) -> Void {
        mode = .Determinate
        self.text = text
        detailText = detail
        view.addSubview(self)
        configuration?(HUD: self)
        show(animated: true)
    }
    
    func showProgress(inView view: UIView, text: String? = nil, detail: String? = nil, configuration: ((HUD: AXPracticalHUD) -> Void)? = nil) -> Void {
        mode = .DeterminateHorizontalBar
        self.text = text
        detailText = detail
        view.addSubview(self)
        configuration?(HUD: self)
        show(animated: true)
    }
    
    func showText(inView view: UIView, text: String, detail: String? = nil, configuration: ((HUD: AXPracticalHUD) -> Void)? = nil) -> Void {
        mode = .Text
        self.text = text
        detailText = detail
        view.addSubview(self)
        configuration?(HUD: self)
        show(animated: true)
    }
    
    func showSimple(inView view: UIView, text: String? = nil, detail: String? = nil, configuration: ((HUD: AXPracticalHUD) -> Void)? = nil) -> Void {
        mode = .Indeterminate
        self.text = text
        detailText = detail
        view.addSubview(self)
        configuration?(HUD: self)
        show(animated: true)
    }
}