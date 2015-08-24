//
//  ViewController.swift
//  20150718
//
//  Created by ai on 15/7/18.
//  Copyright © 2015年 ai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var pickerView = AXPickerView(style: .Normal, items: ["BeiJing", "ShangHai", "HongKong", "ChengDu"])
    let seperatorConfigs:[AXPickerViewSeperatorConfiguration] = [(0, nil, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), nil),(1, nil, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), nil),(2, nil, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), nil),(3, nil, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), nil)]
    let itemConfigs:[AXPickerViewItemConfiguration] = [(0, UIColor.redColor(), UIFont.systemFontOfSize(18)),(1, UIColor.redColor(), UIFont.systemFontOfSize(18))]
//    var pickerView = AXPickerView(style: .DatePicker)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.addObserver(self, forKeyPath: "view.backgroundColor", options: .New, context: nil)
        
        view.backgroundColor = UIColor.orangeColor()
        
        let imageView = UIImageView(image: UIImage(imageLiteral: "timo.jpg"))
        imageView.frame = view.bounds
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleHeight)
        
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.contentSize = view.bounds.size
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        let button = UIButton(type: .System)
        button.backgroundColor = UIColor.orangeColor()
        button.layer.cornerRadius = 3.0
        button.layer.masksToBounds = true
        button.frame = CGRectMake(view.bounds.size.width / 2 - 88, 120, 176, 44)
        button.tintColor = UIColor.whiteColor()
        button.setTitle("点击查看", forState: .Normal)
        button.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleBottomMargin).union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        button.tag = 1
        button.addTarget(self, action: Selector("buttonClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let showButton = UIButton(type: .System)
        showButton.backgroundColor = UIColor.orangeColor()
        showButton.layer.cornerRadius = 3.0
        showButton.layer.masksToBounds = true
        showButton.frame = CGRectMake(view.bounds.size.width / 2 - 88, 184, 176, 44)
        showButton.tintColor = UIColor.whiteColor()
        showButton.setTitle("Show HUD", forState: .Normal)
        showButton.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleBottomMargin).union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        showButton.tag = 2
        showButton.addTarget(self, action: Selector("buttonClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let hideButton = UIButton(type: .System)
        hideButton.backgroundColor = UIColor.orangeColor()
        hideButton.layer.cornerRadius = 3.0
        hideButton.layer.masksToBounds = true
        hideButton.frame = CGRectMake(view.bounds.size.width / 2 - 88, 248, 176, 44)
        hideButton.tintColor = UIColor.whiteColor()
        hideButton.setTitle("Hide HUD", forState: .Normal)
        hideButton.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(.FlexibleBottomMargin).union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        hideButton.tag = 3
        hideButton.addTarget(self, action: Selector("buttonClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(button)
        view.addSubview(showButton)
        view.addSubview(hideButton)
        
        pickerView.view = view!
        pickerView.delegate = self
        
//        AXPracticalHUD.showHUDInView(view, animated: true)
//        AXPracticalHUD.sharedHUD.showPie(inView: view, text: "你好", detail: "这是一条测试消息")
//        AXPracticalHUD.sharedHUD.showProgress(inView: view, text: "你还", detail: "这是一条测试消息")
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
//            AXPracticalHUD.sharedHUD.progress = 0.7
//        })
//        AXPracticalHUD.sharedHUD.showSimple(inView: view, text: nil, detail: nil)
//        let HUD = AXPracticalHUD.showHUDInView(view, animated: true)
//        HUD.translucent = true
        
        AXPracticalHUD.sharedHUD.cornerRadius = 0.0
        AXPracticalHUD.sharedHUD.margin = 0.0
        AXPracticalHUD.sharedHUD.lockBackground = false
//        AXPracticalHUD.sharedHUD.dimBackground = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        let imagePicker = AXImagePickerController()
//        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonClicked(sender: UIButton) {
        
//        self.pickerView.show(animated: true)
//        AXPickerView.showInWindow(view.window!, animated: true, style: .Normal, items: cities, title: "城市")
//        AXPickerView.showInWindow(view.window!, animated: true, style: .DatePicker)
        
        
//        let customView = UIImageView(image: UIImage(imageLiteral: "timo2.jpg"))
//        customView.frame = CGRectMake(0, 0, self.view.bounds.width, 120)
//        customView.contentMode = UIViewContentMode.ScaleAspectFill
//        customView.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleHeight)
//        customView.clipsToBounds = true
//        
//        AXPickerView.showInWindow(view.window!, animated: true, style: .Normal, items: ["下载", "标记为喜欢"], title: "冲锋车", tips: "捱过了十六年的铁窗生涯，义气冠绝黑道的发哥（吴镇宇 饰）出狱后，第一时间实行他那苦思多年的惊天妙计：召集昔日好兄弟，如熟悉一切机械的保龄球场维修员丧宝（任达华 饰），潦倒后巷造型师杜公子（谭耀文 饰）、以及昔日辣手车神现任小巴司机林东（郑浩南 饰），合力将一架十六座小巴改装成冲锋车，用最“和平”的方式，打劫一辆走私黑钱的运尸车。", configuration: {
//            (pickerView: AXPickerView) -> () in
//            pickerView.seperatorInsets = UIEdgeInsetsZero
//            }, revoking: {
//                [unowned self](revoking: AXPickerView) -> () in
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { [unowned self]() -> Void in
//                    AXPickerView.showInWindow(self.view.window!, animated: true, style: .Normal, items: ["北京", "上海", "广州", "成都"], title: "城市", customView: customView, configuration: nil, completion: nil, revoking: nil, executing: nil)
//                }
//            }) {
//            (selectedTitle: String, atIndex: Int, inPickerView: AXPickerView) -> () in
//                if #available(iOS 8.0, *) {
//                    let alert = UIAlertController(title: "提示", message: "您已选择\(selectedTitle)", preferredStyle: .Alert)
//                    alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
//                    alert.addAction(UIAlertAction(title: "选择照片", style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction) -> Void in
//                    }))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//        }
        
        if sender.tag == 1 {
            AXPickerView.showImagePickerInView(view.window!, animated: true)
        } else if sender.tag == 2 {
            AXPracticalHUD.sharedHUD.showText(inView: self.view, text: "Bonjour", detail: "Give you a message") { (HUD) -> Void in
                HUD.translucent = true
                HUD.position  = .Top
                HUD.animation = .FlipIn
            }
//            AXPracticalHUD.sharedHUD.showSimple(inView: view, text: "Bonjour", detail: "Give you a message", configuration: { (HUD) -> Void in
//                HUD.translucent = true
//                HUD.translucentStyle = .Light
//                HUD.textColor = UIColor.blackColor()
//                HUD.detailTextColor = UIColor.blackColor()
//                HUD.activityIndicatorColor = UIColor.blackColor()
//                HUD.position  = .Center
//                HUD.animation = .Fade
//            })
        } else if sender.tag == 3 {
            AXPracticalHUD.sharedHUD.hide(animated: true)
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let path = keyPath {
            print(path)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "view.backgroundColor", context: nil)
    }
}

extension ViewController: AXPickerViewDelegate {
    func pickerViewDidShow(pickerView: AXPickerView) {
        let customView = UIImageView(image: UIImage(imageLiteral: "timo2.jpg"))
        customView.frame = CGRectMake(0, 0, self.view.bounds.width, 120)
        customView.contentMode = UIViewContentMode.ScaleAspectFill
        customView.clipsToBounds = true
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { [unowned self]() -> Void in
            self.pickerView.customView = customView
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { [unowned self]() -> Void in
                self.pickerView.items = ["北京", "上海", "香港",]
                self.pickerView.title = nil
                self.pickerView.customView = nil
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { [unowned self]() -> Void in
                    self.pickerView.items = ["北京", "上海", "广州", "成都"]
                    self.pickerView.title = "城市"
                    self.pickerView.seperatorConfigs = self.seperatorConfigs
                    self.pickerView.itemConfigs = self.itemConfigs
                    self.pickerView.customView = customView
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { [unowned self]() -> Void in
                        self.pickerView.customViewInsets = UIEdgeInsetsZero
                    }
                }
            }
        }
    }
    func pickerViewDidHide(pickerView: AXPickerView) {
        self.pickerView = AXPickerView(style: .Normal, items: ["BeiJing", "ShangHai", "HongKong", "ChengDu"])
        self.pickerView.view = view!
        self.pickerView.delegate = self
    }
}