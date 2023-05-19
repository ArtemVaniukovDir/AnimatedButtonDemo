//
//  OrdinaryClass.swift
//  ButtonAnimationDemo
//
//  Created by Artem Vaniukov on 19.05.2023.
//

import UIKit

// MARK: Nothing interesting in here

class UnsuspiciousClass {
    
    private let view: UIView
    private let view1: UIView
    
    private var animator: UIDynamicAnimator?
    private var gravity: UIGravityBehavior?
    private var collision: UICollisionBehavior?
    private var itemBehaviour: UIDynamicItemBehavior?
    
    private var physicsBodies: [UIDynamicItem] = []
    
    var isEverythingOk = false
    
    init(doThingsIn view: UIView, withHelpOf view1: UIView) {
        self.view = view
        self.view1 = view1
    }
    
    func doSimpleAction() {
        isEverythingOk.toggle()
        let p = isEverythingOk
        UIView.animate(withDuration: 0.3) {
            self.view1.layer.shadowOffset = p ? .zero : .init(width: 0, height: 7)
            self.view1.layer.shadowOpacity = p ? 0 : 0.5
            self.view1.layer.shadowRadius = p ? 0 : 5
        }
        if !isEverythingOk {
            physicsBodies = []
        }
    }
    
    func someRegularFunction(with views: [UIButton], andSomeButton button: UIView) {
        let views = views as [UIView]
        let subviews = views.flatMap { $0.subviews }
        physicsBodies.append(contentsOf: views)
        physicsBodies.append(contentsOf: subviews)
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior(items: physicsBodies)
        collision = UICollisionBehavior(items: physicsBodies)
        itemBehaviour = UIDynamicItemBehavior(items: physicsBodies)
        
        collision?.addBoundary(withIdentifier: "mainView" as NSCopying, for: .init(rect: view.frame))
        collision?.addBoundary(withIdentifier: "buttonView" as NSCopying, for: .init(rect: button.frame))
        itemBehaviour?.elasticity = 0.9
        
        animator?.addBehavior(gravity!)
        animator?.addBehavior(collision!)
        animator?.addBehavior(itemBehaviour!)
    }
}
