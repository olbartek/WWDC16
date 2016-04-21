//
//  MainViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate {
    func presentedViewControllerWillDismissToCenterPoint(centerPoint: CGPoint, withSnapShot snapshot: UIView)
}

class MainViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var leftMarginView: UIView!
    @IBOutlet weak var rightMarginView: UIView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var showCategoriesTapGesture        : UITapGestureRecognizer?
    var hideCategoriesTapGestureLeft    : UITapGestureRecognizer?
    var hideCategoriesTapGestureRight   : UITapGestureRecognizer?
    var animatingImage                  : UIImageView?
    var currentSnapshot                 : UIView?
    
    var categories: [Category] = {
        var categories = [Category]()
        for i in 0..<CategoryModel.NumOfCategories {
            let categoryTitle = CategoryModel.Titles[i]
            let categoryBgColor = CategoryModel.Colors[i]
            let categoryIconName = CategoryModel.IconNames[i]
            let newCategory = Category(title: categoryTitle, bgColor: categoryBgColor, iconName: categoryIconName, type: CategoryType(rawValue: i)!)
            categories.append(newCategory)
        }
        return categories
    }()
    
    // MARK: VC's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        configureTableView()
        showNameLabels(true, withAnimation: false)
        addGestureRecognizers()
        setupAnimatingImage()
    }
    
    // MARK: Appearance
    
    func registerNibs() {
        tableView.registerNib(UINib(nibName: CategoryTableViewCell.identifier(), bundle: nil), forCellReuseIdentifier: CategoryTableViewCell.identifier())
    }
    
    func configureTableView() {
        tableView.contentInset = UIEdgeInsets(top: 5+8, left: 0, bottom: 5+8, right: 0)
    }
    
    // MARK: Gesture recognizers
    
    func addGestureRecognizers() {
        addShowCategoriesTapGesture()
    }
    
    func addShowCategoriesTapGesture() {
        showCategoriesTapGesture = UITapGestureRecognizer(target: self, action: #selector(didRecognizedShowCategoriesTapGesture(_:)))
        view.addGestureRecognizer(showCategoriesTapGesture!)
    }
    
    func addHideCategoriesTapGesture() {
        hideCategoriesTapGestureLeft = UITapGestureRecognizer(target: self, action: #selector(didRecognizedHideCategoriesTapGesture(_:)))
        leftMarginView.addGestureRecognizer(hideCategoriesTapGestureLeft!)
        hideCategoriesTapGestureRight = UITapGestureRecognizer(target: self, action: #selector(didRecognizedHideCategoriesTapGesture(_:)))
        rightMarginView.addGestureRecognizer(hideCategoriesTapGestureRight!)
    }
    
    func didRecognizedShowCategoriesTapGesture(gesture: UITapGestureRecognizer) {
        removeShowCategoriesTapGesture()
        doAnimation()
    }
    
    func didRecognizedHideCategoriesTapGesture(gesture: UITapGestureRecognizer) {
        removeHideCategoriesTapGesture()
        undoAnimation()
    }
    
    func removeShowCategoriesTapGesture() {
        if let showCategoriesTapGesture = showCategoriesTapGesture {
            view.removeGestureRecognizer(showCategoriesTapGesture)
            self.showCategoriesTapGesture = nil
        }
    }
    
    func removeHideCategoriesTapGesture() {
        if let hideCategoriesTapGestureLeft = hideCategoriesTapGestureLeft {
            leftMarginView.removeGestureRecognizer(hideCategoriesTapGestureLeft)
            self.hideCategoriesTapGestureLeft = nil
        }
        if let hideCategoriesTapGestureRight = hideCategoriesTapGestureRight {
            leftMarginView.removeGestureRecognizer(hideCategoriesTapGestureRight)
            self.hideCategoriesTapGestureRight = nil
        }
    }
    
    // MARK: Animations
    
    func doAnimation() {
        showNameLabels(false)
        //animateImage()
        showCategories()
    }
    
    func undoAnimation() {
        
        tableViewHeightConstraint.constant = MainTableView.MinHeight
        UIView.animateWithDuration(Animation.HideCategories.Duration, animations: {
            self.view.layoutIfNeeded()
        }) { [weak self] (finished) in
            guard let weakSelf = self else { return }
            weakSelf.showNameLabels(true)
            weakSelf.addShowCategoriesTapGesture()
        }
    }
    
    func showNameLabels(show: Bool, withAnimation isAnimation: Bool = true) {
        let alphaToSet:CGFloat = show ? 1.0 : 0.0
        
        if isAnimation {
            UIView.animateWithDuration(Animation.ShowNameLabels.Duration) {
                self.nameLabel.alpha = alphaToSet
                self.surnameLabel.alpha = alphaToSet
            }
        } else {
            nameLabel.alpha = alphaToSet
            surnameLabel.alpha = alphaToSet
        }
    }
    
    func showCategories() {
        tableViewHeightConstraint.constant = MainTableView.MaxHeight
        UIView.animateWithDuration(Animation.ShowCategories.Duration,
                                   delay: Animation.ShowCategories.Delay,
                                   usingSpringWithDamping: Animation.ShowCategories.Damping,
                                   initialSpringVelocity: Animation.ShowCategories.Velocity,
                                   options: .CurveEaseInOut,
                                   animations: {
                                    self.view.layoutIfNeeded()
            },
                                   completion: { [weak self] (finished) in
                                    guard let weakSelf = self else { return }
                                    weakSelf.addHideCategoriesTapGesture()
            })
    }
    
    func animateImage() {
        animatingImage?.startAnimating()
    }
    
    func setupAnimatingImage() {
        let animatingImage = UIImageView(frame: CGRect(origin: CGPointZero, size: CGSize(width: AnimatingImage.Width, height: AnimatingImage.Height)))
        animatingImage.center = view.center
        animatingImage.animationImages       = [UIImage(named: "bubbles.gif")!]
        animatingImage.animationDuration     = Animation.Bubbles.Duration
        animatingImage.animationRepeatCount  = 0
        self.animatingImage = animatingImage
        view.addSubview(animatingImage)
    }
    
    func generateAnimationImages() -> [UIImage] {
        var imgs: [UIImage] = []
        var imgName = ""
        for i in 0...55 {
            if i < 10 {
                imgName = "Comp 1_0000\(i)"
            } else if i == 34 { continue }
            else {
                imgName = "Comp 1_000\(i)"
            }
            
            imgs.append(UIImage(named: imgName)!)
        }
        return imgs
    }
    
    
}

// MARK: TableView delegate & dataSource

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell        = tableView.dequeueReusableCellWithIdentifier(CategoryTableViewCell.identifier(), forIndexPath: indexPath) as! CategoryTableViewCell
        cell.delegate   = self
        let category    = categories[indexPath.row]
        cell.configureWithCategory(category)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! CategoryTableViewCell
        if cell.categoryType != .Something {
            cell.performAnimation()
        }
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MainTableView.CellMaxHeight
    }
    
    
}

// MARK: CategoryTableViewCell delegate

extension MainViewController: CategoryTableViewCellDelegate {
    
    func animationDidStopForCategoryCell(categoryCell: CategoryTableViewCell, withItsCenterInMainViewCoords center: CGPoint) {
        guard let categoryType = categoryCell.categoryType else { return }
        var vc: UIViewController?
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let weakSelf = self else { return }
            switch categoryType {
            case .AboutMe:
                vc = VC.AboutMe
            case .MyApps:
                vc = VC.MyApps
            case .Interests:
                vc = VC.Interests
            case .Skills:
                vc = VC.Skills
            default:
                break
                
            }
            if let presentedVC = vc as? PresentedViewController {
                presentedVC.delegate = self
                presentedVC.categoryCellCenter = center
                weakSelf.presentViewController(presentedVC, animated: false, completion: nil)
            }
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            if let categoryCellResizableView = categoryCell.resizableView {
                categoryCellResizableView.removeFromSuperview()
                categoryCell.resizableView = nil
            }
        }
    }
}

extension MainViewController: MainViewControllerDelegate {
    func presentedViewControllerWillDismissToCenterPoint(centerPoint: CGPoint, withSnapShot snapshot: UIView) {
        currentSnapshot = snapshot
        UIView.animateWithDuration(0.3, animations: {
            self.currentSnapshot!.frame = CGRect(origin: centerPoint, size: CGSizeZero)
            }) { (finished) in
                self.currentSnapshot!.removeFromSuperview()
                self.currentSnapshot = nil
        }
    }
}
