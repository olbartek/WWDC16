//
//  MainViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate {
    func presentedViewControllerWillDismissToCenterPoint(_ centerPoint: CGPoint, withSnapShot snapshot: UIView)
}

class MainViewController: UIViewController {
    
    // MARK: Properties
    
    fileprivate struct Constants {
        static let BubbleAnimationViewSide: CGFloat = 300.0
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var leftMarginView: UIView!
    @IBOutlet weak var rightMarginView: UIView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var tapToBeginLabel: UILabel!
    
    var showCategoriesTapGesture        : UITapGestureRecognizer?
    var hideCategoriesTapGestureLeft    : UITapGestureRecognizer?
    var hideCategoriesTapGestureRight   : UITapGestureRecognizer?
    var animatingImage                  : UIImageView?
    var currentSnapshot                 : UIView?
    var areCategoriesHidden             = true
    var categoryTypeToPresent           : CategoryType?
    var bubbleAnimationView             : UIView?
    var bubblesAnimator                 : BubblesAnimator?
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func appBecomeActive(_ notification: Notification) {
        handleViewControllerToPresent()
    }
    
    // MARK: Appearance
    
    func registerNibs() {
        tableView.register(UINib(nibName: CategoryTableViewCell.identifier(), bundle: nil), forCellReuseIdentifier: CategoryTableViewCell.identifier())
    }
    
    func configureTableView() {
        tableView.contentInset = UIEdgeInsets(top: 5+8, left: 0, bottom: 5+8, right: 0)
    }
    
    func handleViewControllerToPresent() {
        categoryTypeToPresent = DefaultsManager.loadCategoryTypeToPresent()
        if let categoryTypeToPresent = categoryTypeToPresent {
            let vc: UIViewController?
            switch categoryTypeToPresent {
            case .myApps:
                vc = VC.MyApps
            case .aboutMe:
                vc = VC.AboutMe
            case .interests:
                vc = VC.Interests
            case .skills:
                vc = VC.Skills
            default:
                vc = nil
            }
            if let vcToPresent = vc as? PresentedViewController {
                vcToPresent.delegate = self
                vcToPresent.categoryCellCenter = view.center
                present(vcToPresent, animated: false, completion: {
                    DefaultsManager.saveCategoryTypeToPresent(nil)
                    self.categoryTypeToPresent = nil
                })
            }
        }
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
    
    func didRecognizedShowCategoriesTapGesture(_ gesture: UITapGestureRecognizer) {
        if areCategoriesHidden {
            removeShowCategoriesTapGesture()
            doAnimation()
        }
    }
    
    func didRecognizedHideCategoriesTapGesture(_ gesture: UITapGestureRecognizer) {
        if !areCategoriesHidden {
            removeHideCategoriesTapGesture()
            undoAnimation()
        }
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
        view.isUserInteractionEnabled = false
        showNameLabels(false)
        perform(#selector(animateBubbles), with: nil, afterDelay: Animation.ShowNameLabels.Duration)
        perform(#selector(showCategories), with: nil, afterDelay: Animation.ShowNameLabels.Duration + 2 * Animation.Bubbles.RotateOneHalfDuration + Animation.Bubbles.DelayBetweenRotations)
    }
    
    func undoAnimation() {
        view.isUserInteractionEnabled = false
        tableViewHeightConstraint.constant = MainTableView.MinHeight
        UIView.animate(withDuration: Animation.HideCategories.Duration, animations: {
            self.view.layoutIfNeeded()
        }, completion: { [weak self] (finished) in
            guard let weakSelf = self else { return }
            weakSelf.view.isUserInteractionEnabled = true
            weakSelf.areCategoriesHidden = true
            weakSelf.showNameLabels(true)
            weakSelf.addShowCategoriesTapGesture()
        }) 
    }
    
    func showNameLabels(_ show: Bool, withAnimation isAnimation: Bool = true) {
        let alphaToSet:CGFloat = show ? 1.0 : 0.0
        
        if isAnimation {
            UIView.animate(withDuration: Animation.ShowNameLabels.Duration, animations: {
                self.nameLabel.alpha = alphaToSet
                self.surnameLabel.alpha = alphaToSet
                self.tapToBeginLabel.alpha = alphaToSet
            }) 
        } else {
            nameLabel.alpha = alphaToSet
            surnameLabel.alpha = alphaToSet
            tapToBeginLabel.alpha = alphaToSet
        }
    }
    
    func showCategories() {
        topBar.isHidden = false
        bottomBar.isHidden = false
        tableViewHeightConstraint.constant = MainTableView.MaxHeight
        UIView.animate(withDuration: Animation.ShowCategories.Duration,
                                   delay: Animation.ShowCategories.Delay,
                                   usingSpringWithDamping: Animation.ShowCategories.Damping,
                                   initialSpringVelocity: Animation.ShowCategories.Velocity,
                                   options: UIViewAnimationOptions(),
                                   animations: {
                                    self.view.layoutIfNeeded()
            },
                                   completion: { [weak self] (finished) in
                                    guard let weakSelf = self else { return }
                                    weakSelf.view.isUserInteractionEnabled = true
                                    weakSelf.areCategoriesHidden = false
                                    weakSelf.addHideCategoriesTapGesture()
            })
    }
    
    func animateBubbles() {
        let bubbleAnimationView = UIView(frame: CGRect.zero)
        bubbleAnimationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bubbleAnimationView)
        view.bringSubview(toFront: bubbleAnimationView)
        bubbleAnimationView
            .constrain(.centerY, .equal, bubbleAnimationView.superview!, .centerY)?
            .constrain(.centerX, .equal, bubbleAnimationView.superview!, .centerX)?
            .constrain(.width, .equal, constant: Constants.BubbleAnimationViewSide)?
            .constrain(.height, .equal, constant: Constants.BubbleAnimationViewSide)
        self.bubbleAnimationView = bubbleAnimationView
        
        let bubblesAnimator = BubblesAnimator(referenceView: bubbleAnimationView)
        bubblesAnimator.delegate = self
        self.bubblesAnimator = bubblesAnimator
        
        topBar.isHidden = true
        bottomBar.isHidden = true
        
        bubblesAnimator.startAnimation()
    }
    
    func cleanupAfterBubblesAnimation() {
        if let bubbleAnimationView = bubbleAnimationView {
            bubbleAnimationView.removeFromSuperview()
            self.bubbleAnimationView = nil
        }
        if let _ = bubblesAnimator {
            self.bubblesAnimator = nil
        }
    }
    
}

// MARK: TableView delegate & dataSource

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell        = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier(), for: indexPath) as! CategoryTableViewCell
        cell.delegate   = self
        let category    = categories[(indexPath as NSIndexPath).row]
        cell.configureWithCategory(category)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CategoryTableViewCell
        cell.performAnimation()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CategoryModel.TVCHeight
    }
    
    
}

// MARK: CategoryTableViewCell delegate

extension MainViewController: CategoryTableViewCellDelegate {
    
    func animationDidStopForCategoryCell(_ categoryCell: CategoryTableViewCell, withItsCenterInMainViewCoords center: CGPoint) {
        guard let categoryType = categoryCell.categoryType else { return }
        var vc: UIViewController?
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else { return }
            switch categoryType {
            case .aboutMe:
                vc = VC.AboutMe
            case .myApps:
                vc = VC.MyApps
            case .interests:
                vc = VC.Interests
            case .skills:
                vc = VC.Skills
            case .contactMe:
                vc = VC.ContactMe
            }
            if let presentedVC = vc as? PresentedViewController {
                presentedVC.delegate = self
                presentedVC.categoryCellCenter = center
                weakSelf.present(presentedVC, animated: false, completion: nil)
            }
        }
        let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if let categoryCellResizableView = categoryCell.resizableView {
                categoryCellResizableView.removeFromSuperview()
                categoryCell.resizableView = nil
            }
        }
    }
}

// MARK: MainViewController delegate

extension MainViewController: MainViewControllerDelegate {
    func presentedViewControllerWillDismissToCenterPoint(_ centerPoint: CGPoint, withSnapShot snapshot: UIView) {
        currentSnapshot = snapshot
        UIView.animate(withDuration: 0.3, animations: {
            self.currentSnapshot!.frame = CGRect(origin: centerPoint, size: CGSize.zero)
            }, completion: { (finished) in
                self.currentSnapshot!.removeFromSuperview()
                self.currentSnapshot = nil
        }) 
    }
}

// MARK: BubblesAnimator delegate

extension MainViewController: BubblesAnimatorDelegate {
    func bubbleAnimationDidStart() {
        
    }
    func bubbleAnimationDidStop() {
        cleanupAfterBubblesAnimation()
    }
}
