//
//  MainViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var leftMarginView: UIView!
    @IBOutlet weak var rightMarginView: UIView!
    
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    let cellColors: [UIColor]           = [.themeOrangeColor(), .themePurpleColor(), .themePlumColor(), .themeBlueColor(), .themeRedColor()]
    var showCategoriesTapGesture        : UITapGestureRecognizer?
    var hideCategoriesTapGestureLeft    : UITapGestureRecognizer?
    var hideCategoriesTapGestureRight   : UITapGestureRecognizer?
    
    // MARK: VC's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        configureTableView()
        showNameLabels(true, withAnimation: false)
        addGestureRecognizers()
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
    
    // MARK: Actions
    
    @IBAction func doAnimationButtonPressed(sender: UIButton) {
        doAnimation()
    }
    
    
    @IBAction func undoAnimationButtonPressed(sender: UIButton) {
        undoAnimation()
    }
    
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellColors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CategoryTableViewCell.identifier(), forIndexPath: indexPath) as! CategoryTableViewCell
        let cellColor = cellColors[indexPath.row]
        cell.selectionStyle = .None
        cell.bgView.backgroundColor = cellColor
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MainTableView.CellMaxHeight
    }
    
    
}
