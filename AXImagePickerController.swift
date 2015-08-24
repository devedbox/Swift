//
//  AXImagePickerController.swift
//  20150718
//
//  Created by ai on 15/7/25.
//  Copyright © 2015年 ai. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
import Photos
import Swift

private let _AXAlbumTableViewCellHeight: CGFloat = 88
private let _AXAlbumTableViewCellPadding: CGFloat = 10
private let _AXAlbumTableViewCellLeftMargin: CGFloat = 20
//private let _AXAlbumSelectionChangedNotification = "__ax_album_selection_changed_notification"
@objc protocol AXImagePickerControllerDelegate {
    optional func imagePickerController(picker: AXImagePickerController, previewWithImages images: [UIImage]) -> Void
    optional func imagePickerController(picker: AXImagePickerController, selectedImages images: [UIImage]) -> Void
    optional func imagePickerControllerDidCancel(picker: AXImagePickerController) -> Void
}
@available(iOS 7.0, *)
class AXImagePickerController: UINavigationController {
    // MARK : - Customs
    private class _AXAlbumTableViewCell: UITableViewCell {
        lazy var albumView: UIImageView = {
            () -> UIImageView in
            let imageView = UIImageView(frame: CGRectZero)
            imageView.opaque = true
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            imageView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth).union(UIViewAutoresizing.FlexibleRightMargin)
            return imageView
            }()
        lazy var albumTitleLabel: UILabel = {
            () -> UILabel in
            let label = UILabel(frame: CGRectZero)
            label.font = UIFont.systemFontOfSize(17)
            label.textColor = AXDefaultTintColor
            label.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
            return label
            }()
        lazy var albumDetailLabel: UILabel = {
            () -> UILabel in
            let label = UILabel(frame: CGRectZero)
            label.font = UIFont.systemFontOfSize(12)
            label.textColor = AXDefaultTintColor.colorWithAlphaComponent(0.5)
            label.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
            return label
            }()
        lazy dynamic var albumSelectedInfo: UILabel = {
            () -> UILabel in
            let label = UILabel(frame: CGRectZero)
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont.systemFontOfSize(34)
            label.textColor = AXDefaultSelectedColor
            label.backgroundColor = UIColor.clearColor()
            label.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
            return label
            }()
        lazy private var albumViewEffetView: UIView = {
           () -> UIView in
            var view: UIView!
            if #available(iOS 8.0, *) {
                view = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
            } else {
                let aView = UIToolbar(frame: CGRectZero)
                aView.translucent = true
                aView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
                for view in aView.subviews {
                    if view is UIImageView {
                        view.hidden = true
                    }
                }
                view = aView
            }
            return view
        }()
        init() {
            super.init(style: .Default, reuseIdentifier: "_ax_[unnamed reuse identifier]")
            initializer()
        }
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            initializer()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            removeObserver(self, forKeyPath: "albumSelectedInfo.text")
        }
        
        private func initializer() -> Void {
            contentView.addSubview(albumView)
            contentView.addSubview(albumTitleLabel)
            contentView.addSubview(albumDetailLabel)
            contentView.backgroundColor = UIColor.clearColor()
            self.backgroundColor = UIColor.clearColor()
            self.clipsToBounds = false
            accessoryType = .DisclosureIndicator
            addObserver(self, forKeyPath: "albumSelectedInfo.text", options: .New, context: nil)
        }
        
        private override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            if keyPath == "albumSelectedInfo.text" {
                albumSelectedInfo.sizeToFit()
                if let newInfo = change?[NSKeyValueChangeNewKey] as? String {
                    if newInfo.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                        accessoryType = .None
                        accessoryView = albumSelectedInfo
                    } else {
                        accessoryType = .DisclosureIndicator
                        accessoryView = nil
                    }
                } else {
                    accessoryType = .DisclosureIndicator
                    accessoryView = nil
                }
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            albumDetailLabel.sizeToFit()
            albumTitleLabel.sizeToFit()
            
            albumView.frame = CGRectMake(0, (contentView.bounds.height - _AXAlbumTableViewCellHeight) / 2, _AXAlbumTableViewCellHeight, _AXAlbumTableViewCellHeight)
            albumTitleLabel.frame = CGRectMake(CGRectGetMaxX(albumView.frame) + _AXAlbumTableViewCellLeftMargin, (contentView.bounds.height - (albumTitleLabel.bounds.height + albumDetailLabel.bounds.height + _AXAlbumTableViewCellPadding)) / 2, albumTitleLabel.bounds.width, albumTitleLabel.bounds.height)
            albumDetailLabel.frame = CGRectMake(albumTitleLabel.frame.origin.x, CGRectGetMaxY(albumTitleLabel.frame) + _AXAlbumTableViewCellPadding, albumDetailLabel.bounds.width, albumDetailLabel.bounds.height)
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            albumDetailLabel.text = nil
            albumTitleLabel.text = nil
            albumView.image = nil
            albumSelectedInfo.text = nil
        }
    }
    private class _AXPhotoCollectionViewCell: UICollectionViewCell {
        let label = {
            () -> UILabel in
            let lab = UILabel(frame: CGRectZero)
            lab.backgroundColor = UIColor(white: 0, alpha: 0.5)
            lab.font = UIFont.boldSystemFontOfSize(12)
            lab.textColor = AXDefaultSelectedColor
            lab.textAlignment = .Center
            lab.text = "已选择"
            lab.sizeToFit()
            lab.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleLeftMargin).union(UIViewAutoresizing.FlexibleRightMargin).union(UIViewAutoresizing.FlexibleTopMargin)
            lab.hidden = true
            return lab
            }()
        
        lazy var photoView: UIImageView! = {
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
            photoView?.image = nil
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            photoView.frame = self.contentView.bounds
            label.frame = photoView.bounds
        }
        
        override var selected: Bool {
            get {
                return super.selected
            }
            set {
                super.selected = newValue
                label.hidden = !selected
            }
        }
        
        private func initializer() -> Void {
            addSubview(photoView)
            addSubview(label)
        }
    }
    private class _AXViewController: UIViewController {
        final private lazy var _backgroundView: UIView = {
            [unowned self]() -> UIView in
            var view: UIView!
            if #available(iOS 8.0, *) {
                let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
                effectView.frame = self.view.bounds
                effectView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
                view = effectView
            } else {
                let effectBar = UIToolbar(frame: CGRectZero)
                effectBar.translucent = true
                effectBar.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
                for view in effectBar.subviews {
                    if view is UIImageView {
                        view.hidden = true
                    }
                }
                view = effectBar
            }
            return view
            }()
        lazy var titleLabel: UILabel! = get { () -> AnyObject? in
            let label = UILabel(frame: CGRectZero)
            label.textColor = AXDefaultSelectedColor
            label.backgroundColor = UIColor.clearColor()
            label.font = UIFont.boldSystemFontOfSize(19)
            return label
        } as! UILabel
        lazy var countLabel: UILabel! = get { () -> AnyObject? in
            let label = UILabel(frame: CGRectZero)
            label.textColor = AXDefaultSelectedColor
            label.backgroundColor = UIColor.clearColor()
            label.font = UIFont.systemFontOfSize(23)
            return label
        } as! UILabel
        override var title: String? {
            didSet {
                titleLabel.text = title
                titleLabel.sizeToFit()
                self.navigationItem.titleView = titleLabel
            }
        }
        override private func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
            self.setToolbarItems((get({ [unowned self]() -> AnyObject? in
                let leftItem = UIBarButtonItem(title: "预览", style: .Plain, target: self, action: "preview:")
                let rightItem = UIBarButtonItem(title: "发送", style: .Plain, target: self, action: "send:")
                return [leftItem, UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil), UIBarButtonItem(customView: self.countLabel), UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil), rightItem]
            }) as! [UIBarButtonItem]), animated: true)
        }
        override private func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            view.backgroundColor = UIColor.whiteColor()
            navigationController?.navigationBar.tintColor = AXDefaultSelectedColor
            navigationController?.navigationBar.barStyle = .Default
            navigationController?.navigationBar.barTintColor = nil
            navigationController?.toolbar.tintColor = AXDefaultSelectedColor
            navigationController?.toolbar.barStyle = .Default
            navigationController?.toolbar.barTintColor = nil
            navigationController?.toolbar.setSeperatorHidden(false)
            navigationController?.navigationBar.setSeperatorHidden(false)
            updateSelectionInfo()
            // FIXME:
            /*
            if let _ax_navigation = navigationController as? AXImagePickerController {
                if let ss = _ax_navigation.snapShot {
                    view.backgroundColor = UIColor.clearColor()
                    view.addSubview(ss)
                    view.addSubview(_backgroundView)
                }
            }*/
        }
        
        override private func viewDidAppear(animated: Bool) {
            super.viewDidAppear(animated)
            if let picker = navigationController as? AXImagePickerController {
                if picker._selectedImageInfo.count > 0 {
                    picker.setToolbarHidden(false, animated: true)
                } else {
                    picker.setToolbarHidden(true, animated: true)
                }
            }
        }
        
        override private func preferredStatusBarStyle() -> UIStatusBarStyle {
            return .Default
        }
        
        override private func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
            return .Fade
        }
        
        @objc private func cancel(sender: AnyObject) -> Void {
            if let _ = presentingViewController {
                if let picker = navigationController as? AXImagePickerController {
                    picker.axDelegate?.imagePickerControllerDidCancel?(picker)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        func updateSelectionInfo() -> Void {
            if let picker = navigationController as? AXImagePickerController {
                let albumSelections = picker._selectedImageInfo.values.array
                var countOfSelectedPhoto: Int = 0
                for (_, selection) in albumSelections.enumerate() {
                    countOfSelectedPhoto += selection.count
                }
                countLabel.text = "\(countOfSelectedPhoto)/9"
                countLabel.sizeToFit()
            }
        }
        
        @objc func preview(sender: UIBarButtonItem) -> Void {
            if let picker = navigationController as? AXImagePickerController {
                if let selectedImage = picker._selectedImages {
                    if picker.previewEnabled == true {
                        let previewController = _AXPreviewController.defaultController()
                        previewController.title = "预览"
                        previewController.assets = picker._selectedAssets
                        picker.pushViewController(previewController, animated: true)
//                        previewController.imageViewControllers = get({ () -> AnyObject? in
//                            var viewControllers: [_AXPreviewController._AXImageController] = []
//                            for (_, image) in selectedImage.enumerate() {
//                                viewControllers.append(get({ () -> AnyObject? in
//                                    let imageViewController = _AXPreviewController._AXImageController()
//                                    imageViewController.imageView.image = image
//                                    return imageViewController
//                                }) as! _AXPreviewController._AXImageController)
//                            }
//                            return viewControllers
//                        }) as! [_AXPreviewController._AXImageController]
                    } else {
                        picker.axDelegate?.imagePickerController?(picker, previewWithImages: selectedImage)
                    }
                }
            }
        }
        
        @objc func send(sender: UIBarButtonItem) -> Void {
            if let picker = navigationController as? AXImagePickerController {
                if let selectedImage = picker._selectedImages {
                    picker.axDelegate?.imagePickerController?(picker, selectedImages: selectedImage)
                }
            }
        }
    }
    
    private class _AXAlbumViewController: _AXViewController, UITableViewDelegate, UITableViewDataSource {
        let reuseIdentifier = "__ax_album_tableViewCell"
        let albumLibrary = ALAssetsLibrary()
        var albumGroups: [ALAssetsGroup]? {
            didSet {
                self.albumView.reloadData()
            }
        }
        @available(iOS 8.0, *)
        lazy var albumList: [PHAssetCollection]! = get { () -> AnyObject? in
            var resultList: [PHAssetCollection] = [PHAssetCollection]()
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "estimatedAssetCount >= 0", argumentArray: nil)
            options.sortDescriptors = [NSSortDescriptor(key: "estimatedAssetCount", ascending: false)]
            options.includeAllBurstAssets = false
            options.includeHiddenAssets = false
            let smartAlbumResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: options)
            smartAlbumResult.enumerateObjectsUsingBlock({ (object, index, stop) -> Void in
                if let aAlbum = object as? PHAssetCollection {
                    let photoResult = PHAsset.fetchAssetsInAssetCollection(aAlbum, options: nil)
                    if photoResult.count > 0 {
                        resultList.append(aAlbum)
                    }
                }
            })
            let albumResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: options)
            albumResult.enumerateObjectsUsingBlock({ (object, index, stop) -> Void in
                if let aAlbum = object as? PHAssetCollection {
                    let photoResult = PHAsset.fetchAssetsInAssetCollection(aAlbum, options: nil)
                    if photoResult.count > 0 {
                        resultList.append(aAlbum)
                    }
                }
            })
            return resultList.sort({ (obj1, obj2) -> Bool in
                let photoResult1 = PHAsset.fetchAssetsInAssetCollection(obj1, options: nil)
                let photoResult2 = PHAsset.fetchAssetsInAssetCollection(obj2, options: nil)
                if photoResult1.count >= photoResult2.count {
                    return true
                } else {
                    return false
                }
            })
        } as! [PHAssetCollection]
        lazy var albumView: UITableView! = get { [unowned self]() -> AnyObject? in
            let tableView = UITableView(frame: self.view.bounds, style: .Plain)
            tableView.backgroundColor = UIColor.clearColor()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerClass(_AXAlbumTableViewCell.self, forCellReuseIdentifier: self.reuseIdentifier)
            tableView.rowHeight = _AXAlbumTableViewCellHeight
            tableView.separatorInset = UIEdgeInsetsMake(0, _AXAlbumTableViewCellHeight, 0, 0)
            return tableView
        } as! UITableView
        var topAlbumInfo: AnyObject? {
            get {
                if #available(iOS 8.0, *) {
                    return albumList.first
                } else {
                    loadGroups()
                    return albumGroups?.first
                }
            }
        }
        convenience init() {
            self.init(nibName: nil, bundle: nil)
            title = "相册"
        }
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            title = "相册"
        }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override private func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(albumView)
            if #available(iOS 8.0, *) {} else {
                loadGroups()
            }
        }
        private func loadGroups() {
            var groups = [ALAssetsGroup]()
            execute({ [unowned self]() -> () in
                self.albumLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: {
                    (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if group != nil && group.numberOfAssets() > 0 {
                        groups.append(group)
                    }
                    self.albumGroups = groups.sort({ (obj1, obj2) -> Bool in
                        if obj1.numberOfAssets() > obj2.numberOfAssets() {
                            return true
                        } else {
                            return false
                        }
                    })
                    }, failureBlock: {
                        (error: NSError!) -> Void in
                        #if DEBUG
                            print(error)
                        #endif
                })
            })
        }
        override private func viewDidAppear(animated: Bool) {
            super.viewDidAppear(animated)
            view.bringSubviewToFront(albumView)
        }
        override private func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            albumView.reloadData()
        }
        // MARK: - UITableViewDataSource
        @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if #available(iOS 8.0, *) {
                return albumList.count ?? 0
            } else {
                return albumGroups?.count ?? 0
            }
        }
        
        @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell: _AXAlbumTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! _AXAlbumTableViewCell
            if #available(iOS 8.0, *) {
                let album = albumList[indexPath.row]
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let assetsResult = PHAsset.fetchAssetsInAssetCollection(album, options: fetchOptions)
                if let assets = assetsResult.firstObject as? PHAsset {
                    PHImageManager.defaultManager().requestImageForAsset(assets, targetSize: CGSizeMake(_AXAlbumTableViewCellHeight * 2, _AXAlbumTableViewCellHeight * 2), contentMode: PHImageContentMode.AspectFill, options: nil, resultHandler: { (image, userInfo) -> Void in
                        if image != nil {
                            cell.albumView.image = image!
                        }
                    })
                    cell.albumDetailLabel.text = String(assetsResult.count)
                }
                
                cell.albumTitleLabel.text = album.localizedTitle
                if let picker = navigationController as? AXImagePickerController {
                    if let info = picker._selectedImageInfo[album.localizedTitle ?? ""] {
                        cell.albumSelectedInfo.text = info.count > 0 ? "\(info.count)" : ""
                    } else {
                        cell.albumSelectedInfo.text = nil
                    }
                } else {
                    cell.albumSelectedInfo.text = nil
                }
            } else {
                if let group = albumGroups?[indexPath.row] {
                    cell.albumView.image = UIImage(CGImage: group.posterImage().takeUnretainedValue())
                    cell.albumTitleLabel.text = (group.valueForProperty(ALAssetsGroupPropertyName) as? String) ?? ""
                    cell.albumDetailLabel.text = String(group.numberOfAssets())
                }
            }
            return cell
        }
        // MARK: - UITableDelegate
        @objc func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if #available(iOS 8.0, *) {
                let album = albumList[indexPath.row]
                let photoVC = _AXPhotoViewController(photoCollection: album)
                photoVC.title = album.localizedTitle
                navigationController?.pushViewController(photoVC, animated: true)
            } else {
                if let group = albumGroups?[indexPath.row] {
                    let photoVC = _AXPhotoViewController(assetsGroup: group)
                    photoVC.title = group.valueForProperty(ALAssetsGroupPropertyName) as? String
                    navigationController?.pushViewController(photoVC, animated: true)
                }
            }
        }
    }
    
    private class _AXPhotoViewController: _AXViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,  UICollectionViewDataSource {
        let reuseIdentifier = "__ax_photo_collectionViewCell"
        let assetsLibrary: ALAssetsLibrary = ALAssetsLibrary()
        var photoCollection: AnyObject!//use AnyObject instead of PHAssetCollection
        var assetsGroup: ALAssetsGroup!
        
        var photos: AnyObject!
        var assets: [ALAsset] = [ALAsset]()
        
        var padding: CGFloat {
            return 2.0
        }
        var size: CGSize {
            return CGSizeMake((self.view.bounds.width - padding * 4) / 3, (self.view.bounds.width - padding * 2) / 3)
        }
        
        lazy var photoView: UICollectionView! = get { [unowned self]() -> AnyObject? in
            let collectionView: UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
            collectionView.backgroundColor = UIColor.clearColor()
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.registerClass(_AXPhotoCollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
            collectionView.allowsMultipleSelection = true
            collectionView.showsHorizontalScrollIndicator = false
            return collectionView
        } as! UICollectionView
        
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            fatalError("init(coder:) has not been implemented")
        }
        @available(iOS 8.0, *)
        convenience init(photoCollection: PHAssetCollection) {
            self.init(nibName: nil, bundle: nil)
            self.photoCollection = photoCollection
        }
        convenience init(assetsGroup: ALAssetsGroup) {
            self.init(nibName: nil, bundle: nil)
            self.assetsGroup = assetsGroup
        }
        
        override private func viewDidLoad() {
            super.viewDidLoad()
            
            view.addSubview(photoView)
            if #available(iOS 8.0, *) {
                if let collection = photoCollection as? PHAssetCollection {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let result = PHAsset.fetchAssetsInAssetCollection(collection, options: fetchOptions)
                    photos = result
                    photoView.reloadData()
                }
            } else {
                if let aGroup = assetsGroup {
                    aGroup.enumerateAssetsUsingBlock({ [unowned self](asset: ALAsset!, index, stop) -> Void in
                        if asset != nil {
                            self.assets.append(asset)
                        }
                        if index == aGroup.numberOfAssets() - 1 {
                            self.photoView.reloadData()
                        }
                    })
                }
            }
        }
        
        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            
            photoView.reloadData()
            if let picker = navigationController as? AXImagePickerController {
                if let localizedTitle = title {
                    if let selectedImageInfo = picker._selectedImageInfo[localizedTitle] {
                        for (_, object) in selectedImageInfo.enumerate() {
                            if #available(iOS 8.0, *) {
                                if let row = (photos as? PHFetchResult)?.indexOfObject(object as! PHAsset) {
                                    photoView.selectItemAtIndexPath(NSIndexPath(forRow: row, inSection: 0), animated: false, scrollPosition: .None)
                                }
                            } else {
                                if let row = assets.indexOf(object as! ALAsset) {
                                    photoView.selectItemAtIndexPath(NSIndexPath(forRow: row, inSection: 0), animated: false, scrollPosition: .None)
                                }
                            }
                        }
                    }
                }
            }
        }
        // MARK: - UICollectionViewFlowLayout
        @objc func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return size
        }
        
        @objc func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsetsMake(padding, padding, padding, padding)
        }
        
        @objc func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return padding
        }
        
        @objc func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return padding
        }
        // MARK: - UICollectionViewDataSource
        @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if #available(iOS 8.0, *) {
                if let result = photos as? PHFetchResult {
                    return result.count ?? 0
                } else {
                    return 0
                }
            } else {
                return assets.count ?? 0
            }
        }
        
        @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! _AXPhotoCollectionViewCell
            if #available(iOS 8.0, *) {
                if let fetchResult = photos as? PHFetchResult {
                    if let asset = fetchResult.objectAtIndex(indexPath.row) as? PHAsset {
                        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: .AspectFill, options: nil, resultHandler: {
                            (image: UIImage?, info: [NSObject : AnyObject]?) -> Void in
                            if image != nil {
                                cell.photoView.image = image
                            }
                        })
                    }
                }
            } else {
                let asset = assets[indexPath.row]
                cell.photoView.image = UIImage(CGImage: asset.aspectRatioThumbnail().takeUnretainedValue())
            }
            return cell
        }
        // MARK: - UICollectionViewDelegate
        @objc func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
            if let picker = navigationController as? AXImagePickerController {
                let albumSelections = picker._selectedImageInfo.values.array
                var countOfSelectedPhoto: Int = 0
                for (_, selection) in albumSelections.enumerate() {
                    countOfSelectedPhoto += selection.count
                }
                if countOfSelectedPhoto >= 9 {
                    return false
                }
            }
            return true
        }
        
        @objc func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            markSelectedItem()
            updateSelectionInfo()
        }
        
        @objc func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
            markSelectedItem()
            updateSelectionInfo()
        }
        
        // MARK: - Private Methods
        private func markSelectedItem() -> Void {
            if let picker = navigationController as? AXImagePickerController {
                if self.photoView.indexPathsForSelectedItems()?.count > 0 {
                    if let localizedTitle = title {
                        var selectedItem = [AnyObject]()
                        for (_, indexPath) in self.photoView.indexPathsForSelectedItems()!.enumerate() {
                            if #available(iOS 8.0, *) {
                                if let object = (photos as? PHFetchResult)?.objectAtIndex(indexPath.row) {
                                    selectedItem += [object]
                                }
                            } else {
                                selectedItem += [assets[indexPath.row]]
                            }
                        }
                        picker._selectedImageInfo[localizedTitle] = selectedItem
                    }
                } else {
                    if let localizedTitle = title {
                        picker._selectedImageInfo[localizedTitle] = nil
                    }
                }
            }
        }
    }
    
    private class _AXPreviewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        class _AXImageController: UIViewController {
            let imageView: UIImageView = get { () -> AnyObject? in
                let imgView = UIImageView(frame: CGRectZero)
                imgView.backgroundColor = UIColor.blackColor()
                imgView.contentMode = UIViewContentMode.ScaleAspectFit
                imgView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
                imgView.clipsToBounds = true
                return imgView
                } as! UIImageView
            override func viewDidLoad() {
                super.viewDidLoad()
                imageView.userInteractionEnabled = true
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTapGesture:"))
                imageView.frame = view.bounds
                view.addSubview(imageView)
                automaticallyAdjustsScrollViewInsets = false
            }
            override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
            }
            
            @objc func handleTapGesture(tap: UITapGestureRecognizer) -> Void {
                navigationController?.setNavigationBarHidden(!(navigationController!.navigationBarHidden), animated: true)
                navigationController?.setToolbarHidden(!(navigationController!.toolbarHidden), animated: true)
            }
            
            class func defalutController(withImage image: UIImage?) -> _AXImageController {
                let controller = _AXImageController()
                controller.imageView.image = image
                return controller
            }
        }
        
        class _AXAssetsImageController: _AXImageController {
            // PHAsset or ALAsset
            weak var asset: AnyObject?
            class func defaultControllerWithAsset(asset: AnyObject?) -> _AXAssetsImageController {
                let controller = _AXAssetsImageController()
                controller.asset = asset
                if #available(iOS 8.0, *) {
                    controller.imageView.image = (asset as? PHAsset)?.image
                } else {
                    controller.imageView.image = (asset as? ALAsset)?.image
                }
                return controller
            }
        }
        
        class var PageViewController: UIPageViewController {
            return  get { () -> AnyObject? in
                    let vc = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
                    return vc
                    } as! UIPageViewController
        }
        // MARK : - Properties
        weak var pageViewController: UIPageViewController!
        weak var currentImageViewController: _AXAssetsImageController? {
            return pageViewController.viewControllers?.first as? _AXAssetsImageController
        }
        var imageViewControllers: [_AXImageController]! {
            didSet {
                if imageViewControllers.count > 0 {
                    pageViewController.setViewControllers(Array(arrayLiteral: imageViewControllers.first!), direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
                }
            }
        }
        var images: [UIImage]! {
            didSet {
                if images.count > 0 {
                    pageViewController.setViewControllers([_AXImageController.defalutController(withImage: images.first!)], direction: .Forward, animated: true, completion: nil)
                }
            }
        }
        var assets: [AnyObject]! {
            didSet {
                if assets.count > 0 {
                    pageViewController.setViewControllers([_AXAssetsImageController.defaultControllerWithAsset(assets.first)], direction: .Forward, animated: true, completion: nil)
                }
            }
        }
        lazy var titleLabel: UILabel! = get { () -> AnyObject? in
            let label = UILabel(frame: CGRectZero)
            label.textColor = AXDefaultSelectedColor
            label.backgroundColor = UIColor.clearColor()
            label.font = UIFont.boldSystemFontOfSize(19)
            return label
            } as! UILabel
        override var title: String? {
            didSet {
                titleLabel.text = title
                titleLabel.sizeToFit()
                self.navigationItem.titleView = titleLabel
            }
        }
        // MARK : - Life Cycle
        class func defaultController() -> _AXPreviewController {
            let pageVc = _AXPreviewController.PageViewController
            let previewVc = _AXPreviewController()
            pageVc.automaticallyAdjustsScrollViewInsets = false
            pageVc.willMoveToParentViewController(previewVc)
            previewVc.addChildViewController(pageVc)
            pageVc.didMoveToParentViewController(previewVc)
            previewVc.pageViewController = pageVc
            pageVc.delegate = previewVc
            pageVc.dataSource = previewVc
            return previewVc
        }
        // MARK : - Override
        override private func viewDidLoad() {
            super.viewDidLoad()
            automaticallyAdjustsScrollViewInsets = false
            if pageViewController != nil {
                view.addSubview(pageViewController.view)
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "删除", style: UIBarButtonItemStyle.Plain, target: self, action: "deleteItem:")
            setToolbarItems([UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "发送(\(assets.count))", style: UIBarButtonItemStyle.Plain, target: self, action: "send:")], animated: true)
        }
        override private func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.navigationBar.barStyle = .Black
            navigationController?.navigationBar.barTintColor = UIColor.blackColor()
            navigationController?.toolbar.barStyle = .Black
            navigationController?.toolbar.barTintColor = UIColor.blackColor()
            navigationController?.navigationBar.setSeperatorHidden(true)
            navigationController?.toolbar.setSeperatorHidden(true)
        }
        override private func viewDidAppear(animated: Bool) {
            super.viewDidAppear(animated)
            navigationController?.setNavigationBarHidden(true, animated: true)
            navigationController?.setToolbarHidden(true, animated: false)
        }
        // MARK : - Actions
        @objc private func deleteItem(sender: UIBarButtonItem) -> Void {
            if assets.count <= 1 {
                if let picker = navigationController as? AXImagePickerController {
                    picker.deleteAsset(currentImageViewController?.asset)
                    self.assets.removeAtIndex(0)
                }
                navigationController?.popViewControllerAnimated(true)
                return
            }
            if let index = assets.indexOf({ (asset) -> Bool in
                if #available(iOS 8.0, *) {
                    if asset as! PHAsset == currentImageViewController?.asset as! PHAsset {
                        return true
                    } else {
                        return false
                    }
                } else {
                    if asset as! ALAsset == currentImageViewController?.asset as! ALAsset {
                        return true
                    } else {
                        return false
                    }
                }
            }) {
                if let picker = navigationController as? AXImagePickerController {
                    picker.deleteAsset(currentImageViewController?.asset)
                    self.assets.removeAtIndex(index)
                }
            }
        }
        @objc private func send(sender: UIBarButtonItem) -> Void {
            if let picker = navigationController as? AXImagePickerController {
                if let selectedImages = picker._selectedImages {
                    picker.axDelegate?.imagePickerController?(picker, selectedImages: selectedImages)
                }
            }
        }
        // MARK : - UIPageViewControllerDelegate

        // MARK : - UIPageViewControllerDataSource
        @objc func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            if let myAssets = assets {
                if let index = myAssets.indexOf({ (object) -> Bool in
                    if object === (viewController as! _AXAssetsImageController).asset {
                        return true
                    } else {
                        return false
                    }
                }) {
                    if index == 0 {
                        return nil
                    } else {
                        return _AXAssetsImageController.defaultControllerWithAsset(myAssets[index - 1])
                    }
                }
            }
            return nil
        }
        @objc func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            if let myAssets = assets {
                if let index = myAssets.indexOf({ (object) -> Bool in
                    if object === (viewController as! _AXAssetsImageController).asset {
                        return true
                    } else {
                        return false
                    }
                }) {
                    if index == myAssets.count - 1 {
                        return nil
                    } else {
                        return _AXAssetsImageController.defaultControllerWithAsset(myAssets[index + 1])
                    }
                }
            }
            return nil
        }
    }
    // MARK: - Internal Properties
    weak var axDelegate: protocol<AXImagePickerControllerDelegate, UINavigationControllerDelegate>? {
        didSet {
            super.delegate = self.axDelegate
        }
    }
    var previewEnabled: Bool!
    // MARK: - Private & Lazy Load properties
    private lazy var _albumsViewController: _AXAlbumViewController = {
        () -> _AXAlbumViewController in
        let viewController = _AXAlbumViewController()
        return viewController
        }()
    private lazy var _photosViewController: _AXPhotoViewController? = {
        [unowned self]() -> _AXPhotoViewController in
        var viewController: _AXPhotoViewController!
        if #available(iOS 8.0, *) {
            if let collection = self._albumsViewController.topAlbumInfo as? PHAssetCollection {
                viewController = _AXPhotoViewController(photoCollection: collection)
                viewController?.title = collection.localizedTitle
            }
        } else {
            if let group = self._albumsViewController.topAlbumInfo as? ALAssetsGroup {
                viewController = _AXPhotoViewController(assetsGroup: group)
                viewController?.title = group.valueForProperty(ALAssetsGroupPropertyName) as? String
            }
        }
        return viewController
        }()
    // MARK: - Private Properties
    private var _snapShot: UIView?
    // [String : [String : [AnyObject]]]
    private dynamic var _selectedImageInfo: Dictionary<String, [AnyObject]> = [:]
    
    private var _selectedAssets: [AnyObject]? {
        return get({ () -> AnyObject? in
            let albumSelections = self._selectedImageInfo.values.array
            var selectedAssets: [AnyObject] = []
            for (_, selection) in albumSelections.enumerate() {
                for assets in selection {
                    selectedAssets += [assets]
                }
            }
            let sortedAssets = selectedAssets.sort({ (obj1, obj2) -> Bool in
                if #available(iOS 8.0, *) {
                    if let asset1 = obj1 as? PHAsset {
                        if let asset2 = obj2 as? PHAsset {
                            if asset1.creationDate == nil || asset2.creationDate == nil {
                                return false
                            }
                            if asset1.creationDate!.timeIntervalSince1970 > asset2.creationDate!.timeIntervalSince1970 {
                                return true
                            } else {
                                return false
                            }
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }
                } else {
                    if let asset1 = obj1 as? ALAsset {
                        if let asset2 = obj2 as? ALAsset {
                            if (asset1.valueForProperty(ALAssetPropertyDate) as! NSDate).timeIntervalSince1970 > (asset2.valueForProperty(ALAssetPropertyDate) as! NSDate).timeIntervalSince1970 {
                                return true
                            } else {
                                return false
                            }
                        } else {
                            return false
                        }
                    } else {
                        return false
                    }
                }
            })
            return sortedAssets.count > 0 ? sortedAssets : nil
        }) as? [AnyObject]
    }
    
    private var _selectedImages: [UIImage]? {
        return get({ [unowned self]() -> AnyObject? in
            var images: [UIImage] = []
            if #available(iOS 8.0, *) {
                for (_, asset) in (self._selectedAssets as! [PHAsset]).enumerate() {
                    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelHeight)), contentMode: PHImageContentMode.AspectFill, options: get({ () -> AnyObject? in
                        let options = PHImageRequestOptions()
                        options.synchronous = true
                        return options
                    }) as? PHImageRequestOptions, resultHandler: { (image: UIImage?, userInfo) -> Void in
                        if let aImage = image {
                            images.append(aImage)
                        }
                    })
                }
            } else {
                for (_, asset) in (self._selectedAssets as! [ALAsset]).enumerate() {
                    images.append(UIImage(CGImage: asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue()))
                }
            }
            if images.count <= 0 {
                return nil
            }
            return images
        }) as? [UIImage]
    }
    // MARK: - Life Cycle
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        if _photosViewController != nil {
            pushViewController(_albumsViewController, animated: false)
            pushViewController(_photosViewController!, animated: false)
        } else {
            pushViewController(_albumsViewController, animated: false)
        }
        addObserver(self, forKeyPath: "_selectedImageInfo", options: .New, context: nil)
        
        previewEnabled = true
    }
    
    deinit {
        removeObserver(self, forKeyPath: "_selectedImageInfo")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "_selectedImageInfo" {
            if let selectedImageInfo = change?[NSKeyValueChangeNewKey] {
                if selectedImageInfo.count > 0 {
                    setToolbarHidden(false, animated: true)
                } else {
                    setToolbarHidden(true, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // FIXME:
        /*
        if isBeingPresented() {
            let vc = presentingViewController
            if let ss = vc?.view.snapshotViewAfterScreenUpdates(true) {
                snapShot = ss
            }
        }*/
    }
    // MARK: - Actions
    private func deleteAsset(asset: AnyObject?) -> Void {
        for (key, var assets) in _selectedImageInfo {
            if let index =  assets.indexOf({ (object) -> Bool in
                if #available(iOS 8.0, *) {
                    if object as! PHAsset == asset as! PHAsset {
                        return true
                    } else {
                        return false
                    }
                } else {
                    if object as! ALAsset == asset as! ALAsset {
                        return true
                    } else {
                        return false
                    }
                }
            }) {
                assets.removeAtIndex(index)
                _selectedImageInfo[key] = assets
                break
            }
        }
    }
}