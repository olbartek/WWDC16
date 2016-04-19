//
//  MainViewController.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

let kTableViewMaxHeight: CGFloat = 600.0
let kTableViewMinHeight: CGFloat = 0.0
let kTableViewCellMaxHeight: CGFloat = 250.0
let kShowCategoriesAnimationDuration = 1.0
let kHideCategoriesAnimationDuration = 0.5

class MainViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    let cellColors: [UIColor] = [.themeOrangeColor(), .themePurpleColor(), .themePlumColor(), .themeBlueColor(), .themeRedColor()]
    var pinchGestureRecognizer: UIPinchGestureRecognizer?
    var lastScale: CGFloat = 0.0
    
    // MARK: VC's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
        configureTableView()
        showNameLabels(true, withAnimation: false)
        addPinchGestureRecognizer()
    }
    
    // MARK: Appearance
    
    func registerNibs() {
        tableView.registerNib(UINib(nibName: CategoryTableViewCell.identifier(), bundle: nil), forCellReuseIdentifier: CategoryTableViewCell.identifier())
    }
    
    func configureTableView() {
        tableView.contentInset = UIEdgeInsets(top: 5+8, left: 0, bottom: 5+8, right: 0)
    }
    
    // MARK: Gesture recognizers
    
    func addPinchGestureRecognizer() {
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didRecognizedPinch(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer!)
    }
    
    func removePinchGestureRecognizer() {
        if let pinchGestureRecognizer = pinchGestureRecognizer {
            view.removeGestureRecognizer(pinchGestureRecognizer)
            self.pinchGestureRecognizer = nil
        }
    }
    
    func didRecognizedPinch(gesture: UIPinchGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Changed {
            var scale = 1.0 - (lastScale - gesture.scale)
            let bounds = gesture.view!.bounds
            scale = min(scale, kTableViewMaxHeight / CGRectGetHeight(bounds))
            scale = max(scale, kTableViewMinHeight / CGRectGetHeight(bounds))
            print(scale * kTableViewMaxHeight)
            lastScale = scale
        }
    }
    
    // MARK: Animations
    
    func doAnimation() {
        removePinchGestureRecognizer()
        showNameLabels(false)
        tableViewHeightConstraint.constant = kTableViewMaxHeight
        UIView.animateWithDuration(kShowCategoriesAnimationDuration,
                                   delay: 0.3,
                                   usingSpringWithDamping: 0.6,
                                   initialSpringVelocity: 0.5,
                                   options: .CurveEaseInOut,
                                   animations: {
                                    self.view.layoutIfNeeded()
            },
                                   completion: { [weak self] (finished) in
                                    guard let weakSelf = self else { return }
                                    weakSelf.addPinchGestureRecognizer()
            })
    }
    
    func undoAnimation() {
        removePinchGestureRecognizer()
        tableViewHeightConstraint.constant = 0
        UIView.animateWithDuration(kHideCategoriesAnimationDuration, animations: {
            self.view.layoutIfNeeded()
        }) { [weak self] (finished) in
            guard let weakSelf = self else { return }
            weakSelf.showNameLabels(true)
            weakSelf.addPinchGestureRecognizer()
        }
    }
    
    func showNameLabels(show: Bool, withAnimation isAnimation: Bool = true) {
        let alphaToSet:CGFloat = show ? 1.0 : 0.0
        
        if isAnimation {
            UIView.animateWithDuration(0.3) {
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
        return kTableViewCellMaxHeight
    }
    
    
}
