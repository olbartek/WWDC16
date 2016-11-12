//
//  CategoryTableViewCell.swift
//  wwdc16
//
//  Created by Bartosz Olszanowski on 19.04.2016.
//  Copyright © 2016 Bartosz Olszanowski. All rights reserved.
//

import UIKit

@objc protocol CategoryTableViewCellDelegate {
    @objc optional func animationDidStartForCategoryCell(_ categoryCell: CategoryTableViewCell, withItsCenterInMainViewCoords center: CGPoint)
    @objc optional func animationDidStopForCategoryCell(_ categoryCell: CategoryTableViewCell, withItsCenterInMainViewCoords center: CGPoint)
}

class CategoryTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var bgView           : UIView!
    @IBOutlet weak var titleLabel       : UILabel!
    @IBOutlet weak var iconImageView    : UIImageView!
    
    var categoryType                    : CategoryType?
    var resizableView                   : UIView?
    var delegate                        : CategoryTableViewCellDelegate?
    var cellCenterInMainViewCoords      : CGPoint?
    
    // MARK: Configuration
    
    func configureWithCategory(_ category: Category) {
        categoryType            = category.type
        bgView.backgroundColor  = category.bgColor
        titleLabel.text         = category.title
        iconImageView.image     = UIImage(named: category.iconName)
        selectionStyle          = .none
    }
    
    // MARK: Animation
    
    func performAnimation() {
        guard let window = UIApplication.shared.keyWindow, let mainView = window.rootViewController?.view else { return }
        let cellFrameInMainViewCoords   = convert(bounds, to: nil)
        resizableView                   = UIView(frame: CGRect.zero)
        resizableView!.backgroundColor  = bgView.backgroundColor
        cellCenterInMainViewCoords      = CGPoint(x: cellFrameInMainViewCoords.midX, y: cellFrameInMainViewCoords.midY)
        resizableView!.center           = cellCenterInMainViewCoords!
        mainView.addSubview(resizableView!)
        delegate?.animationDidStartForCategoryCell?(self, withItsCenterInMainViewCoords: cellCenterInMainViewCoords!)
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(),
                                   animations: {
                                    self.resizableView!.frame = mainView.frame
            }, completion: { [weak self] finished in
                guard let weakSelf = self else { return }
                weakSelf.delegate?.animationDidStopForCategoryCell?(weakSelf, withItsCenterInMainViewCoords: weakSelf.cellCenterInMainViewCoords!)
        })
    }
    
}
