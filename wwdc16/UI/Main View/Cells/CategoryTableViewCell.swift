//
//  CategoryTableViewCell.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

@objc protocol CategoryTableViewCellDelegate {
    optional func animationDidStartForCategoryCell(categoryCell: CategoryTableViewCell)
    optional func animationDidStopForCategoryCell(categoryCell: CategoryTableViewCell)
}

class CategoryTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var bgView           : UIView!
    @IBOutlet weak var titleLabel       : UILabel!
    @IBOutlet weak var iconImageView    : UIImageView!
    
    var categoryType                    : CategoryType?
    var resizableView                   : UIView?
    var delegate                        : CategoryTableViewCellDelegate?
    
    // MARK: Configuration
    
    func configureWithCategory(category: Category) {
        categoryType            = category.type
        bgView.backgroundColor  = category.bgColor
        titleLabel.text         = category.title
        iconImageView.image     = UIImage(named: category.iconName)
        selectionStyle          = .None
    }
    
    // MARK: Animation
    
    func performAnimation() {
        guard let window = UIApplication.sharedApplication().keyWindow, mainView = window.rootViewController?.view else { return }
        let cellFrameInMainViewCoords   = convertRect(bounds, toView: nil)
        resizableView                   = UIView(frame: CGRectZero)
        resizableView!.backgroundColor  = bgView.backgroundColor
        resizableView!.center           = CGPoint(x: CGRectGetMidX(cellFrameInMainViewCoords), y: CGRectGetMidY(cellFrameInMainViewCoords))
        mainView.addSubview(resizableView!)
        delegate?.animationDidStartForCategoryCell?(self)
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseInOut,
                                   animations: {
                                    self.resizableView!.frame = mainView.frame
            }, completion: { [weak self] finished in
                guard let weakSelf = self else { return }
                weakSelf.delegate?.animationDidStopForCategoryCell?(weakSelf)
        })
    }
    
}
