//
//  AXPickerView.swift
//  20150718
//
//  Created by ai on 15/7/19.
//  Copyright © 2015年 ai. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

/// default tint color
public let AXDefaultTintColor = UIColor(red: 0.059, green: 0.059, blue: 0.059, alpha: 1.00)
/// default selected color
public let AXDefaultSelectedColor = UIColor(red: 0.294, green: 0.808, blue: 0.478, alpha: 1.00)
/// default seperator color
public let AXDefaultSeperatorColor = UIColor(red: 0.824, green: 0.824, blue: 0.824, alpha: 1.00)
/// default background color
public let AXDefaultBackgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 0.70)
/// default height of tool bar
public let AXPickerToolBarHeight: CGFloat = 44.0
/// default height of date picker and common picker
public let AXPickerHeight: CGFloat = 216.0
/// type of (index, height, insets, backgroundColor) of seperators
typealias AXPickerViewSeperatorConfiguration = (Int, Float?, UIEdgeInsets?, UIColor?)
/// type of (index, tintColor, textFont) of items
typealias AXPickerViewItemConfiguration = (Int, UIColor?, UIFont?)
@available(iOS 7.0, *)
/// completion closure
typealias AXCompletion = (pickerView:AXPickerView) -> ()
@available(iOS 7.0, *)
/// revoking closure
typealias AXRevoking = (pickerView: AXPickerView) -> ()
@available(iOS 7.0, *)
/// executing closure
typealias AXExecuting = (selectedTitle: String, atIndex: Int, inPickerView: AXPickerView) -> ()
@available(iOS 7.0, *)
/// configuration closure
typealias AXConfiguration = (pickerView: AXPickerView) -> ()

@available(iOS 7.0, *)
// style of AXPickerView
// .Normal is a normal style with a list of title string like UIActionSheet style
// .DatePicker is a date picker
// .CommonPicker is a UIPickerView with the custom data
enum AXPickerViewStyle: Int {
    /// a style using String items
    case Normal = 0
    /// a style of date picker
    case DatePicker
    /// a style of custom data picker
    case CommonPicker
}

@available(iOS 7.0, *)
@objc protocol AXPickerViewDelegate: UIPickerViewDelegate {
    
    optional func pickerViewWillShow(pickerView: AXPickerView) -> ()
    optional func pickerViewDidShow(pickerView: AXPickerView) -> ()
    optional func pickerViewWillHide(pickerView: AXPickerView) -> ()
    optional func pickerViewDidHide(pickerView: AXPickerView) -> ()
    optional func pickerViewDidCancle(pickerView: AXPickerView) -> ()
    optional func pickerViewDidConfirm(pickerView: AXPickerView) -> ()
    optional func pickerView(pickerView: AXPickerView, didSelectedItem item: String, atIndex index: Int) -> ()
}

protocol AXLayerTag {
    
    typealias TagType
    
    var tag: TagType!{get set}
}

protocol AXPickerViewDataSource: UIPickerViewDataSource {
    
}

@available(iOS 7.0, *)
extension AXPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    class func showInWindow(window: UIWindow, animated:Bool, style:AXPickerViewStyle = .Normal, items:[String]? = nil, title: String? = nil, tips: String? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> () {
        showInView(window, animated: animated, style: style, items: items, title: title, tips: tips, configuration: configuration, completion: completion, revoking: revoking, executing: executing)
    }
    
    class func showInWindow(window: UIWindow, animated:Bool, style:AXPickerViewStyle = .Normal, items:[String]? = nil, title: String? = nil, customView: UIView? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> () {
        showInView(window, animated: animated, style: style, items: items, title: title, customView: customView, configuration: configuration, completion: completion, revoking: revoking, executing: executing)
    }
    
    @available(iOS 7.0, *)
    class func showInView(view: UIView, animated: Bool, style:AXPickerViewStyle = .Normal, items:[String]? = nil, title: String? = nil, tips: String? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> () {
        let picker = AXPickerView(style: style, items: items)
        configuration?(pickerView: picker)
        picker.view = view
        picker.title = title
        
        picker.sizeToFit()
        
        if let tip = tips {
            let string = NSString(string: tip)
            let font = UIFont.systemFontOfSize(12)
            let usedSize = string.boundingRectWithSize(CGSizeMake(picker.bounds.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil)
            
            let label = UILabel(frame: CGRectMake(0, 0, ceil(usedSize.width), ceil(usedSize.height)))
            label.textAlignment = NSTextAlignment.Left
            label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            label.numberOfLines = 0
            label.backgroundColor = UIColor.clearColor()
            label.font = font
            label.textColor = AXDefaultTintColor.colorWithAlphaComponent(0.5)
            label.text = tip
            
            picker.customView = label
        }
        
        picker.show(animated: animated, completion: completion, revoking: revoking, executing: executing)
    }
    
    class func showInView(view: UIView, animated: Bool, style:AXPickerViewStyle = .Normal, items:[String]? = nil, title: String? = nil, customView: UIView? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> () {
        let picker = AXPickerView(style: style, items: items)
        
        if let config = configuration {
            config(pickerView: picker)
        }
        
        picker.view = view
        picker.title = title
        picker.customView = customView
        
        picker.show(animated: animated, completion: completion, revoking: revoking, executing: executing)
    }
}

private class CALayer_ax: CALayer, AXLayerTag {
    
    typealias TagType = Int
    
    var tag: TagType!
}

@available(iOS 7.0, *)

class AXPickerView: UIView {
    //MARK: - Internal Properties
    var items = [String]?() {
        didSet {
            setNeedsDisplay()
        }
    }
    var style: AXPickerViewStyle! {
        didSet {
            switch style! {
            case .Normal:
                seperatorInsets = UIEdgeInsetsMake(0, 20, 0, 20)
            default :
                seperatorInsets = UIEdgeInsetsZero
            }
        }
    }
    
    weak var view: UIView?
    
    var customView: UIView? {
        didSet {
            if customView == nil {
                if let oldView = oldValue {
                    oldView.removeFromSuperview()
                }
            }
            
            setNeedsDisplay()
        }
    }
    
    var title: String? {
        get {
            return _titleLabel.text
        }
        set {
            _titleLabel.text = newValue
            setNeedsDisplay()
        }
    }
    
    var titleFont: UIFont? = UIFont.systemFontOfSize(14) {
        didSet {
            guard let _ = _titleLabel else {
                return
            }
            _titleLabel.font = titleFont!
        }
    }
    var titleTextColor: UIColor? = AXDefaultTintColor.colorWithAlphaComponent(CGFloat(0.5)) {
        didSet {
            guard let _ = _titleLabel else {
                return
            }
            _titleLabel.textColor = titleTextColor!
        }
    }
    var cancleFont: UIFont? = UIFont.systemFontOfSize(16) {
        didSet {
            _cancleBtn.titleLabel?.font = cancleFont
        }
    }
    var cancleTextColor: UIColor? = UIColor(red: 0.973, green: 0.271, blue: 0.231, alpha: 1.00) {
        didSet {
            _cancleBtn.tintColor = cancleTextColor
        }
    }
    var completeFont: UIFont? = UIFont.systemFontOfSize(16) {
        didSet {
            _completeBtn.titleLabel?.font = completeFont
        }
    }
    var completeTextColor: UIColor? = AXDefaultSelectedColor {
        didSet {
            _completeBtn.tintColor = completeTextColor
        }
    }
    /// the font of button items default : system_18
    var itemFont: UIFont? = UIFont.systemFontOfSize(18) {
        didSet {
            configureViews()
        }
    }
    /// the tintColor of button items 
    var itemTintColor: UIColor? = nil {
        didSet {
            configureViews()
        }
    }
    
    var itemConfigs: [AXPickerViewItemConfiguration]? = [AXPickerViewItemConfiguration]() {
        didSet {
            configureViews()
        }
    }
    
    /// the color of seperators
    var seperatorColor: UIColor? = AXDefaultSeperatorColor {
        didSet {
            configureViews()
        }
    }
    /// the default insets of seperators
    var seperatorInsets: UIEdgeInsets? = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) {
        didSet {
            configureViews()
        }
    }
    /// a list of custom configuration of seperator
    /// use a type of (Int, UIEdgetInsets)
    var seperatorConfigs: [AXPickerViewSeperatorConfiguration]? = [(0, Float(0.7), UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), nil)] {
        didSet {
            configureViews()
        }
    }
    
    var customViewInsets: UIEdgeInsets? = UIEdgeInsetsMake(5, 5, 5, 5) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak var delegate: AXPickerViewDelegate? {
        didSet{
            if style == .CommonPicker {
                _commonPicker?.delegate = self.delegate
            }
        }
    }
    weak var dataSource: AXPickerViewDataSource? {
        didSet{
            if style == .CommonPicker {
                _commonPicker?.dataSource = self.dataSource
            }
        }
    }
    
    // MARK: - Private And Lazy Properties
    
    private let padding:CGFloat = 5.0
    
    private var _completion: AXCompletion? = nil
    private var _revoking: AXRevoking? = nil
    private var _executing: AXExecuting? = nil
    
    private lazy var _titleLabel: UILabel! = {
       [unowned self]() -> UILabel in
        let label = UILabel(frame: CGRectMake(0, 0, AXPickerToolBarHeight * 2.0, AXPickerToolBarHeight))
        label.font = self.titleFont
        label.textColor = self.titleTextColor
        label.backgroundColor = AXDefaultBackgroundColor
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        label.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleLeftMargin).union(UIViewAutoresizing.FlexibleRightMargin)
        return label
    }()
    
    private lazy var _completeBtn: UIButton! = {
        [unowned self]() -> UIButton in
        let button = UIButton(type: .System)
        button.backgroundColor = AXDefaultBackgroundColor
        button.setTitle("完成", forState: .Normal)
        button.tintColor = self.completeTextColor
        button.titleLabel?.font = self.completeFont
        button.addTarget(self, action: "didConfirm:", forControlEvents: UIControlEvents.TouchUpInside)
        button.tag = 1001
        return button
    }()
    
    private lazy var _cancleBtn: UIButton! = {
       [unowned self]() -> UIButton in
        let button = UIButton(type: .System)
        button.backgroundColor = AXDefaultBackgroundColor
        button.setTitle("取消", forState: .Normal)
        button.tintColor = self.cancleTextColor
        button.titleLabel?.font = self.cancleFont
        button.addTarget(self, action: "didCancle:", forControlEvents: UIControlEvents.TouchUpInside)
        button.tag = 1002
        return button
    }()
    
    private lazy var _datePicker: UIDatePicker! = {
        [unowned self]() -> UIDatePicker in
        ///custom initialize date picker
        let picker = UIDatePicker(frame: CGRectMake(0.0, AXPickerToolBarHeight, self.bounds.size.width, AXPickerHeight))
        picker.backgroundColor = AXDefaultBackgroundColor
        picker.datePickerMode = .DateAndTime
        picker.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleBottomMargin).union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        return picker
    }()
    
    private lazy var _commonPicker: UIPickerView! = {
       [unowned self]() -> UIPickerView in
        ///custom initialize picker view
        let picker = UIPickerView(frame: CGRectMake(0.0, AXPickerToolBarHeight, self.bounds.size.width, AXPickerHeight))
        picker.backgroundColor = AXDefaultBackgroundColor
        picker.delegate = self
        picker.dataSource = self
        picker.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleBottomMargin).union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        return picker
    }()
    
    private lazy var _backgroundView: UIControl! = {
      [unowned self]() -> UIControl in
        let backgroundView = UIControl(frame: CGRectZero)
        backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        backgroundView.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
        backgroundView.addTarget(self, action: "didTouchBackground:", forControlEvents: UIControlEvents.TouchDown)
        return backgroundView
    }()
    private lazy var _effectBar: UIToolbar! = {
        () -> UIToolbar in
        let effectBar = UIToolbar(frame: CGRectZero)
        effectBar.translucent = true
        effectBar.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
        for view in effectBar.subviews {
            if view is UIImageView {
                view.hidden = true
            }
        }
        return effectBar
        }()
    @available(iOS 8.0, *)
    private lazy var _effectView: UIVisualEffectView! = {
      () -> UIVisualEffectView in
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        effectView.tintColor = UIColor.clearColor()
        effectView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
        return effectView
    }()
    @available(iOS 8.0, *)
    private var _effectViewOfViews: UIVisualEffectView {
        get {
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
            effectView.frame = CGRectMake(0, 0, self.bounds.width, AXPickerToolBarHeight)
            effectView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
            return effectView
        }
    }
    @available(iOS 8.0, *)
    private lazy var _photoAssetsResult: PHFetchResult? = get() {
        () -> AnyObject? in
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil)
        if let aFetchResult = fetchResult.firstObject {
            let result = PHAsset.fetchAssetsInAssetCollection(aFetchResult as! PHAssetCollection, options: fetchOptions)
            return result
        } else {
            return nil
        }
        } as? PHFetchResult
    private let _photoLibrary: ALAssetsLibrary = ALAssetsLibrary()
    private var _photoAssets: [ALAsset] = [ALAsset]()
    @available(iOS, introduced=7.0, deprecated=8.0)
    lazy var validPhotoGroup: (() -> Void)? = {
        [unowned self]() -> Void in
        self._photoLibrary.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: {
            (aGroup: ALAssetsGroup!, stopGroup: UnsafeMutablePointer<ObjCBool>) -> Void in
            stopGroup.initialize(ObjCBool(true))
            if aGroup != nil {
                aGroup.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse) {
                    (assets: ALAsset!, index: Int, stopAssets: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if let aAssets = assets {
                        self._photoAssets += [aAssets]
                        if self._photoAssets.count == aGroup.numberOfAssets() - 1 {
                            stopAssets.initialize(ObjCBool(true))
                            if let collectionView = self.customView as? UICollectionView {
                                collectionView.reloadData()
                            }
                        }
                    }
                }
            }
            }, failureBlock: {
                (error: NSError!) -> Void in
                #if DEBUG
                    print(error)
                #endif
        })
    }
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializer()
    }
    
    convenience init(style: AXPickerViewStyle = .Normal, items: [String]? = nil) {
        self.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 0))
        self.style = style
        self.items = items
        
        switch self.style! {
            
        case .Normal:
            seperatorInsets = UIEdgeInsetsMake(0, 20, 0, 20)
        default :
            seperatorInsets = UIEdgeInsetsZero
        }
    }
    
    private func initializer() -> () {
        self.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(UIViewAutoresizing.FlexibleWidth)
        backgroundColor = UIColor.clearColor()
        tintColor = AXDefaultTintColor
        if #available(iOS 8.0, *) {
            addSubview(_effectView)
        } else {
            addSubview(_effectBar)
        }
        addObserver(self, forKeyPath: "frame", options: .New, context: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resizingCustomView", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    deinit {
        items?.removeAll()
        removeObserver(self, forKeyPath: "frame")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: - Override
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let aStyle = style else {return}
        
        func configureCustomView(inout customView: UIView) -> () {
            
            let originY = {
                () -> CGFloat in
                switch style! {
                case .Normal:
                    if let _ = title?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
                        return AXPickerToolBarHeight
                    } else {
                        return 0.0
                    }
                default:
                    return AXPickerToolBarHeight
                }
                }()
            
            var rect = customView.bounds
            rect.origin.y = originY + (customViewInsets?.top ?? 0)
            rect.origin.x = (customViewInsets?.left ?? 0)
            rect.size.width = self.bounds.width - ((customViewInsets?.left ?? 0) + (customViewInsets?.right ?? 0))
            customView.frame = rect
            
            customView.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleLeftMargin).union(UIViewAutoresizing.FlexibleWidth)
        }
        
        if customView != nil {
            configureCustomView(&(customView!))
            addSubview(customView!)
        }
        
        switch aStyle {
            
        case .Normal:
            if (title != nil && title!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                addSubview(_titleLabel)
            } else {
                _titleLabel.removeFromSuperview()
            }
            
            let buttons = {
                () -> [UIButton] in
                return subviews.filter({
                    (view: UIView) -> Bool in
                    if view is UIButton && view.tag != 1001 && view.tag != 1002 {
                        return true
                    } else {
                        return false
                    }
                }) as! [UIButton]
            }()
            for button in buttons {
                button.removeFromSuperview()
            }
            
            if let titles = items {
                for (index, item) in titles.enumerate() {
                    addSubview(button(atIndex: index, withTitle: item))
                }
            }
        case .DatePicker:
            execute {
                [unowned self]() -> () in
                var seperatorLayer: CALayer_ax!
                self.layer.sublayers?.contains() {
                    (layer: CALayer) -> Bool in
                    if let aLayer = layer as? CALayer_ax {
                        seperatorLayer = aLayer
                        return true
                    } else {
                        return false
                    }
                }
                if seperatorLayer != nil {
                    seperatorLayer!.removeFromSuperlayer()
                }
                
                if let _ = self.customView {
                    var rect = self._datePicker!.frame
                    rect.origin.y = AXPickerToolBarHeight + self.customView!.bounds.height + (self.customViewInsets!.top ?? 0) + (self.customViewInsets!.bottom ?? 0)
                    self._datePicker!.frame = rect
                } else {
                    var rect = self._datePicker!.frame
                    rect.origin.y = AXPickerToolBarHeight
                    self._datePicker!.frame = rect
                    self.layer.addSublayer(self.seperator(atIndex: 1, height: 0.5, color: self.seperatorColor ?? AXDefaultSeperatorColor))
                }
            }
            addSubview(_datePicker!)
            addSubview(_titleLabel)
        case .CommonPicker:
            execute {
                [unowned self]() -> () in
                var seperatorLayer: CALayer_ax!
                self.layer.sublayers?.contains() {
                    (layer: CALayer) -> Bool in
                    if let aLayer = layer as? CALayer_ax {
                        seperatorLayer = aLayer
                        return true
                    } else {
                        return false
                    }
                }
                if seperatorLayer != nil {
                    seperatorLayer!.removeFromSuperlayer()
                }
                
                if let _ = self.customView {
                    var rect = self._commonPicker!.frame
                    rect.origin.y = AXPickerToolBarHeight + self.customView!.bounds.height + (self.customViewInsets!.top ?? 0) + (self.customViewInsets!.bottom ?? 0)
                    self._commonPicker!.frame = rect
                } else {
                    var rect = self._commonPicker!.frame
                    rect.origin.y = AXPickerToolBarHeight
                    self._commonPicker!.frame = rect
                    self.layer.addSublayer(self.seperator(atIndex: 1, height: 0.5, color: self.seperatorColor ?? AXDefaultSeperatorColor))
                }
            }
            addSubview(_commonPicker!)
            addSubview(_titleLabel)
        }
        
        resizingSelf()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        sizeToFit()
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var rightSize = super.sizeThatFits(size)
        rightSize.width = UIScreen.mainScreen().bounds.width
        
        guard let aStyle = style else {
            return rightSize
        }
        if aStyle == .DatePicker || aStyle == .CommonPicker {
            rightSize.height = AXPickerHeight + AXPickerToolBarHeight
        } else {
            var height: CGFloat = AXPickerToolBarHeight
            
            if title != nil && title!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                height += AXPickerToolBarHeight
            }
            
            if let itemCount = items?.count {
                height += AXPickerToolBarHeight * CGFloat(itemCount)
            }
            
            height += padding
            rightSize.height = height
        }
        
        rightSize.height += {
            () -> CGFloat in
                if let _ = customView {
                    return customView!.bounds.height + (customViewInsets!.top ?? 0) + (customViewInsets!.bottom ?? 0)
                } else {
                    return 0
                }
            }()
        
        return rightSize
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if let mySuperView = newSuperview {
            _backgroundView.frame = mySuperView.bounds
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let _ = self.superview {
            resizingSelf()
            
            guard let aStyle = style else {
                return
            }
            
            configureTools()
            
            switch aStyle {
                
            case .Normal:
                if let count = items?.count {
                    if count > 0 {
                        addSubview(_cancleBtn)
                    }
                }
            case .DatePicker, .CommonPicker:
                addSubview(_completeBtn)
                addSubview(_cancleBtn)
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            if let frame = change?[NSKeyValueChangeNewKey]?.CGRectValue {
                if #available(iOS 8.0, *) {
                    _effectView.frame = CGRectMake(0, 0, frame.width, frame.height)
                } else {
                    _effectBar.frame = CGRectMake(0, 0, frame.width, frame.height)
                }
            }
        }
    }
    
    //MARK: - Public Instance Methods
    
    func show(animated animated: Bool, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> () {
        if let aView = view {
            alpha = 0.0
            _backgroundView.alpha = 0.0
            
            _completion = completion
            _revoking = revoking
            _executing = executing
            
            delegate?.pickerViewWillShow?(self)
            aView.addSubview(_backgroundView)
            aView.addSubview(self)
            
            if animated {
                transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, self.bounds.height), CGAffineTransformMakeScale(1, 1))
                alpha = 1.0
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions(rawValue: 7), animations: { [weak self]() -> Void in
                        self?._backgroundView.alpha = 1.0
                        self?.transform = CGAffineTransformIdentity
                    }, completion: { [weak self](finished) -> Void in
                        self?.delegate?.pickerViewDidShow?(self!)
                    })
            } else {
                alpha = 1.0
                _backgroundView.alpha = 1.0
            }
        }
    }
    
    func hide(animated animated: Bool) -> () {
        if let _ = superview {
            delegate?.pickerViewWillHide?(self)
            
            UIView.animateWithDuration(
                0.25,
                delay: 0.0,
                options: UIViewAnimationOptions(rawValue: 7),
                animations: { [weak self]() -> Void in
                    self?.transform = CGAffineTransformMakeTranslation(0.0, (self?.bounds.height)!)
                    self?._backgroundView.alpha = 0.0
                },
                completion: { [weak self](finished) -> Void in
                    if finished {
                        self?.removeFromSuperview()
                        self?._backgroundView.removeFromSuperview()
                        self?.transform = CGAffineTransformIdentity
                        
                        self?.delegate?.pickerViewDidHide?(self!)
                    }
                })
        }
    }
    
    //MARK: - Private Instance Methods
    
    private func button(atIndex index: Int, withTitle title: String?, rightHeight height: CGFloat = AXPickerToolBarHeight) -> UIButton {
        let button = UIButton(type: .System)
        button.setTitle(title, forState: .Normal)
        button.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(.FlexibleWidth).union(.FlexibleRightMargin).union(.FlexibleLeftMargin)
        button.backgroundColor = AXDefaultBackgroundColor
        var aItemColor: UIColor!
        var aItemFont: UIFont!
        
        itemConfigs?.contains() {
            (configs: AXPickerViewItemConfiguration) -> Bool in
            let (aIndex, color, font) = configs
            if aIndex == index {
                aItemColor = color
                aItemFont = font
                return true
            } else {
                return false
            }
        }
        
        button.tintColor = aItemColor ?? (itemTintColor ?? self.tintColor)
        button.titleLabel?.font = aItemFont ?? itemFont
        button.frame = CGRectMake(0, {
            () -> CGFloat in
            var originY = AXPickerToolBarHeight * CGFloat(self.title?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ? index + 1 : index)
            if let _ = customView {
                originY += customView!.bounds.height + (customViewInsets!.top ?? 0) + (customViewInsets!.bottom ?? 0)
            }
            return originY
            }(), self.bounds.width, height)
        button.tag = index + Int(1)
        button.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        var insets: UIEdgeInsets?
        
        seperatorConfigs?.contains(){
            (config: AXPickerViewSeperatorConfiguration) -> Bool in
            let (aIndex, _, aInsets, _) = config
            if aIndex == index {
                insets = aInsets
                return true
            } else {
                return false
            }
        }
        if index == 0 {
            if customView == nil {
                button.layer.addSublayer(seperator(atIndex: 0, height: 0.5, color: seperatorColor ?? AXDefaultSeperatorColor, insets: insets))
            }
        } else {
            button.layer.addSublayer(seperator(atIndex: 0, height: 0.5, color: seperatorColor ?? AXDefaultSeperatorColor, insets: insets))
        }
        return button
    }

    private func seperator(atIndex index: Int, height: CGFloat, color: UIColor, insets:UIEdgeInsets? = nil) -> CALayer_ax {
        let layer = CALayer_ax()
        layer.frame = CGRectMake((insets ?? seperatorInsets!).left, AXPickerToolBarHeight * CGFloat(index), self.bounds.size.width - ((insets ?? seperatorInsets!).left + (insets ?? seperatorInsets!).right), height)
        layer.backgroundColor = color.CGColor
        layer.tag = index + 1
        return layer
    }
    
    private func configureViews() -> () {
        _titleLabel.font = titleFont
        _titleLabel.textColor = titleTextColor
        
        switch style! {
            
        case .Normal:
            let buttons = self.subviews.filter() {
                (aView: UIView) -> Bool in
                return aView is UIButton
            }
            
            for (index, button) in (buttons as! [UIButton]).enumerate(){
                let seperatorBlock = {
                    (config: (Int, Float?, UIEdgeInsets?, UIColor?)) -> Bool in
                    let (aIndex, _, _, _) = config
                    return aIndex == index - 1
                }
                
                let itemBlock = {
                    (config:(Int, UIColor?, UIFont?)) -> Bool in
                    let (aIndex, _, _) = config
                    return aIndex == index - 1
                }
                
                let seperatorLayerBlock = {
                    (aLayer: CALayer) -> Bool in
                    return aLayer is CALayer_ax
                }
                
                if seperatorConfigs != nil {
                    if seperatorConfigs!.contains(seperatorBlock) {
                        if let seperatorLayer = button.layer.sublayers?.filter(seperatorLayerBlock).first {
                            let (_, height, insets, backgroundColor) = (seperatorConfigs!.filter(seperatorBlock).first)!
                            var rect = seperatorLayer.frame
                            rect.origin.x = insets?.left ?? 0
                            rect.size.width = self.bounds.width - ((insets?.left)! + (insets?.right)!) ?? 0
                            rect.size.height = CGFloat(height ?? 0.5)
                            seperatorLayer.frame = rect
                            seperatorLayer.backgroundColor = backgroundColor?.CGColor ?? AXDefaultSeperatorColor.CGColor
                        }
                    }
                } else {
                    if let seperatorLayer = button.layer.sublayers?.filter(seperatorLayerBlock).first {
                        seperatorLayer.backgroundColor = (seperatorColor ?? AXDefaultSeperatorColor).CGColor
                        var rect = seperatorLayer.frame
                        rect.origin.x = seperatorInsets?.left ?? 0
                        rect.size.width = self.bounds.width - ((seperatorInsets?.left)! + (seperatorInsets?.right)!) ?? 0
                        seperatorLayer.frame = rect
                    }
                }
                
                if itemConfigs != nil {
                    if itemConfigs!.contains(itemBlock) {
                        let (_, tintColor, textFont) = (itemConfigs!.filter(itemBlock).first)!
                        button.tintColor = tintColor
                        button.titleLabel?.font = textFont
                    }
                } else {
                    button.tintColor = itemTintColor ?? tintColor
                    button.titleLabel?.font = itemFont
                }
            }
            _cancleBtn.titleLabel?.font = cancleFont
            _cancleBtn.tintColor = cancleTextColor
        case .DatePicker, .CommonPicker:
            _completeBtn.titleLabel?.font = completeFont
            _completeBtn.tintColor = completeTextColor
            _cancleBtn.titleLabel?.font = cancleFont
            _cancleBtn.tintColor = cancleTextColor
        }
    }
    
    private func configureTools() -> () {
        _titleLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleBottomMargin)
        var rect = _titleLabel.frame
        rect.size.height = AXPickerToolBarHeight
        
        switch style! {
            
        case .Normal:
            let size = CGSizeMake(self.bounds.width, AXPickerToolBarHeight)
            _cancleBtn.frame = CGRectMake(0.0, {
                () -> CGFloat in
                var originY = AXPickerToolBarHeight * CGFloat((items?.count ?? 0) + ((title?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) > 0 ? 1 : 0)) + padding
                if let _ = customView {
                    originY += customView!.bounds.height + (customViewInsets!.top ?? 0) + (customViewInsets!.bottom ?? 0)
                }
                return originY
                }(), size.width, size.height)
            _cancleBtn.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(UIViewAutoresizing.FlexibleRightMargin).union(UIViewAutoresizing.FlexibleLeftMargin).union(.FlexibleWidth)
            rect.origin.x = 0
            rect.size.width = bounds.size.width
        case .DatePicker, .CommonPicker:
            let size = CGSizeMake(AXPickerToolBarHeight, AXPickerToolBarHeight)
            _cancleBtn.frame = CGRectMake(0, 0, size.width, size.height)
            _cancleBtn.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleRightMargin)
            _completeBtn.frame = CGRectMake(self.bounds.width - size.width, 0, size.width, size.height)
            _completeBtn.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleLeftMargin)
            rect.size.width = bounds.size.width - AXPickerToolBarHeight * 2.0
            rect.origin.x = (bounds.width - rect.width) / 2
        }
        
        _titleLabel.frame = rect
    }
    
    private func resizingSelf(animated animated: Bool = false) -> () {
        if let aSuperView = superview {
            let size = sizeThatFits(self.bounds.size)
            let originY = aSuperView.bounds.size.height - size.height
            
            var rect = frame
            rect.origin.y = originY
            
            if animated {
                UIView.animateWithDuration(0.25, animations: { [unowned self]() -> Void in
                    self.frame = rect
                    }, completion: nil)
            } else {
                frame = CGRectMake(0, originY, size.width, size.height)
            }
        }
    }
    
    @objc private func resizingCustomView() {
        if let label = customView as? UILabel {
            let usedSize = label.text!.boundingRectWithSize(CGSizeMake(bounds.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : label.font], context: nil)
            var rect = label.frame
            rect.size.width = ceil(usedSize.width)
            rect.size.height = ceil(usedSize.height)
            label.frame = rect
            
            setNeedsDisplay()
        }
    }
    
    //MARK: - Actions
    @objc private func buttonClicked(sender: UIButton) -> () {
        hide(animated: true)
        delegate?.pickerView?(self, didSelectedItem:sender.titleForState(.Normal) ?? "", atIndex: sender.tag - Int(1))
        if let aExecuting = _executing {
            aExecuting(selectedTitle: sender.titleForState(.Normal) ?? "", atIndex: sender.tag - Int(1), inPickerView: self)
        }
    }
    
    @objc private func didConfirm(sender: UIButton) -> () {
        hide(animated: true)
        delegate?.pickerViewDidConfirm?(self)
        if let aCompletion = _completion {
            aCompletion(pickerView: self)
        }
    }
    
    @objc private func didCancle(sender: UIButton) -> () {
        hide(animated: true)
        delegate?.pickerViewDidCancle?(self)
        if let aRevoking = _revoking {
            aRevoking(pickerView: self)
        }
    }
    
    @objc private func didTouchBackground(sender: UIControl) -> () {
        hide(animated: true)
        delegate?.pickerViewDidCancle?(self)
        if let aRevoking = _revoking {
            aRevoking(pickerView: self)
        }
    }
    
    //MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return (dataSource?.numberOfComponentsInPickerView(pickerView))!
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (dataSource?.pickerView(pickerView, numberOfRowsInComponent: component))!
    }
}

private let reusedIdentifier = "AXImagePickerCell"
private let rightHeight: CGFloat = 220
private let minWidth:CGFloat = 110

//typealias AXImagePickerCompletion = (images: [UIImage]?, ) -> Void

let imagePickerExecuting: AXExecuting = {
    (title: String, index: Int, pickerView: AXPickerView) -> Void in
    
//    let imagePickerController = UIImagePickerController()
//    imagePickerController.delegate = pickerView
    
    let imagePickerController = AXImagePickerController()
    
    switch index {
    case 0:
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
//            imagePickerController.sourceType = .Camera
            if let rootViewController = pickerView.window?.rootViewController {
                rootViewController.presentViewController(imagePickerController, animated: true, completion: nil)
            }
        }
    case 1:
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
//            imagePickerController.sourceType = .PhotoLibrary
            if let rootViewController = pickerView.window?.rootViewController {
                rootViewController.presentViewController(imagePickerController, animated: true, completion: nil)
            }
        }
    case 2:
        break
    default:
        break
    }
}

@available(iOS 7.0, *)
extension AXPickerView: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private class AXImagePickerCell: UICollectionViewCell {
        let label = {
            () -> UILabel in
            let lab = UILabel(frame: CGRectZero)
            lab.backgroundColor = UIColor.clearColor()
            lab.font = UIFont.systemFontOfSize(12)
            lab.textColor = AXDefaultSelectedColor
            lab.text = "已选择"
            lab.sizeToFit()
            lab.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleLeftMargin).union(UIViewAutoresizing.FlexibleRightMargin).union(UIViewAutoresizing.FlexibleTopMargin)
            lab.hidden = true
            return lab
            }()
        
        lazy var imageView: UIImageView! = {
            return get() {
                [unowned self]() -> AnyObject in
                let imgView = UIImageView(frame: CGRectZero)
                imgView.backgroundColor = UIColor.clearColor()
                imgView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth).union(.FlexibleBottomMargin).union(.FlexibleRightMargin)
                imgView.contentMode = UIViewContentMode.ScaleAspectFill
                imgView.clipsToBounds = true
                return imgView
            } as! UIImageView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            initializer()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            initializer()
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            imageView?.image = nil
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            imageView.frame = self.contentView.bounds
            var rect = label.frame
            rect.origin.x = (imageView.bounds.width - rect.width) / 2
            rect.origin.y = (imageView.bounds.height - rect.height) / 2
            label.frame = rect
        }
        
        override var selected: Bool {
            get {
                return super.selected
            }
            set {
                super.selected = newValue
                
                label.hidden = !selected
                if selected {
                    imageView.alpha = 0.1
                } else {
                    imageView.alpha = 1.0
                }
            }
        }
        
        private func initializer() -> Void {
            addSubview(imageView)
            addSubview(label)
        }
    }
    
    class func showImagePickerInWindow(window: UIWindow, animated: Bool, configuration: AXConfiguration? = nil) -> Void {
        
    }
    
    class func showImagePickerInView(view: UIView, animated: Bool, configuration: AXConfiguration? = nil) -> Void {
        let picker = AXPickerView(style: .Normal, items: ["拍摄", "从相册选取"])
        picker.seperatorInsets = UIEdgeInsetsZero
        picker.view = view
        configuration?(pickerView: picker)
        let collectionView = UICollectionView(frame: CGRectMake(0, 0, 0, rightHeight), collectionViewLayout: {
            () -> UICollectionViewFlowLayout in
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            return layout
            }())
        collectionView.allowsMultipleSelection = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.registerClass(AXImagePickerCell.self, forCellWithReuseIdentifier: reusedIdentifier)
        collectionView.delegate = picker
        collectionView.dataSource = picker
        picker.customView = collectionView
        picker.validPhotoGroup?()
        picker.show(animated: true, completion: nil, revoking: nil, executing: imagePickerExecuting)
    }
    
    private func rightSize(originalSize size: CGSize, rightHeight: CGFloat) -> CGSize {
        return CGSizeMake(max(minWidth, size.width * (rightHeight / size.height)), rightHeight)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if #available(iOS 8.0, *) {
            let assets = _photoAssetsResult?.objectAtIndex(indexPath.row) as! PHAsset
            let size = CGSizeMake(CGFloat(assets.pixelWidth), CGFloat(assets.pixelHeight))
            return rightSize(originalSize: size, rightHeight: rightHeight)
        } else {
            let defaultRepresentation = _photoAssets[indexPath.row].defaultRepresentation()
            let size = defaultRepresentation.dimensions()
            return rightSize(originalSize: size, rightHeight: rightHeight)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if #available(iOS 8.0, *) {
            return _photoAssetsResult?.count ?? 0
        } else {
            return _photoAssets.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusedIdentifier, forIndexPath: indexPath) as! AXImagePickerCell
        if #available(iOS 8.0, *) {
            let assets = _photoAssetsResult?.objectAtIndex(indexPath.row) as! PHAsset
            PHImageManager.defaultManager().requestImageForAsset(assets, targetSize: rightSize(originalSize: CGSizeMake(CGFloat(assets.pixelWidth), CGFloat(assets.pixelHeight)), rightHeight: rightHeight), contentMode: .AspectFill, options: nil) { (image, userInfo) -> Void in
                cell.imageView.image = image!
            }
        } else {
            let aspectRatioThumbnail = _photoAssets[indexPath.row].aspectRatioThumbnail()
            cell.imageView.image = UIImage(CGImage: aspectRatioThumbnail.takeUnretainedValue())
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let count = collectionView.indexPathsForSelectedItems()?.count {
            if count >= 9 {
                return false
            }
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let count = collectionView.indexPathsForSelectedItems()?.count {
            if count > 0 {
                self.items = ["拍摄", "从相册选取", "已选择\(count)张"]
                self.itemConfigs = [(2, AXDefaultSelectedColor, nil)]
                return
            }
        }
        self.items = ["拍摄", "从相册选取"]
        self.itemConfigs?.removeAll()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let count = collectionView.indexPathsForSelectedItems()?.count {
            if count > 0 {
                self.items = ["拍摄", "从相册选取", "已选择\(count)张"]
                self.itemConfigs = [(2, AXDefaultSelectedColor, nil)]
                return
            }
        }
        self.items = ["拍摄", "从相册选取"]
        self.itemConfigs?.removeAll()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        viewController.navigationController?.navigationBar.tintColor = AXDefaultSelectedColor
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        
    }
    
    func navigationControllerSupportedInterfaceOrientations(navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(navigationController: UINavigationController) -> UIInterfaceOrientation
    {
        return UIInterfaceOrientation.Portrait
    }
}