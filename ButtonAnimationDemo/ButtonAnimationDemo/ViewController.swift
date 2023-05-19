//
//  ViewController.swift
//  ButtonAnimationDemo
//
//  Created by Artem Vaniukov on 18.05.2023.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var unsuspiciousClass = UnsuspiciousClass(doThingsIn: view, withHelpOf: view1)
    
    private lazy var view1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .brown
        view.layer.shadowOffset = .init(width: 0, height: 7)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 5
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view2 = UIView()
        view2.translatesAutoresizingMaskIntoConstraints = false
        view2.backgroundColor = .cyan
        let view3 = UIView()
        view3.translatesAutoresizingMaskIntoConstraints = false
        view3.backgroundColor = .lightGray
        
        let stack = UIStackView(arrangedSubviews: [view1, view2, view3])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var menuLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Menu"
        label.font = .systemFont(ofSize: 25)
        label.alpha = 0
        return label
    }()
    
    private lazy var buttonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemTeal
        view.layer.cornerRadius = 30
        
        view.layer.shadowColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
        view.layer.shadowOffset = .init(width: 0, height: 7)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 1
        return view
    }()
    
    var selectedMenuView: UIButton? = nil
    
    lazy var effect = UIBlurEffect(style: .systemUltraThinMaterial)
    lazy var effectView = UIVisualEffectView(effect: effect)
    
    lazy var menuViews: [UIButton] = []
    lazy var menuRadius: CGFloat = 150
    
    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
    lazy var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPress(_:)))
    lazy var someGesture = UITapGestureRecognizer(target: self, action: #selector(someSimpleAction))
    
    var isPresented = false
    var isLongPressAvailable = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        longPressGesture.minimumPressDuration = 0.2
        
        view1.addGestureRecognizer(someGesture)
        buttonView.addGestureRecognizer(tapGesture)
        buttonView.addGestureRecognizer(longPressGesture)
        
        setupUI()
    }
}

// MARK: - Animations

private extension ViewController {
    func showMenu() {
        view.bringSubviewToFront(buttonView)
        
        isPresented = true
        
        effectView.frame = view.bounds
        effectView.alpha = 0
        view.insertSubview(effectView, belowSubview: buttonView)
        
        UIView.animate(withDuration: 0.3) {
            self.effectView.alpha = 1
            self.buttonView.layer.shadowOffset = .zero
            self.buttonView.layer.shadowRadius = 0
        }
        
        setupMenuViews()
        
        let origin = CGPoint(x: buttonView.bounds.minX, y: buttonView.bounds.minY)
        let menuElementsCount = CGFloat(menuViews.count)
        var radians: CGFloat = .pi * 1.1
        
        menuViews.forEach { menuView in
            UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.7) {
                menuView.alpha = 1
                let x = origin.x + self.menuRadius * cos(radians)
                let y = origin.y + self.menuRadius * sin(radians)
                
                menuView.frame.origin = .init(x: x, y: y)
            }
            
            radians += .pi / menuElementsCount
        }
    }
        
    func hideMenu() {
        isPresented = false
        
        if unsuspiciousClass.isEverythingOk {
            unsuspiciousClass.someRegularFunction(with: menuViews, andSomeButton: buttonView)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.effectView.alpha = 0
            self.buttonView.layer.shadowOffset = .init(width: 0, height: 7)
            self.buttonView.layer.shadowRadius = 10
            
            if !self.unsuspiciousClass.isEverythingOk {
                self.menuViews.forEach {
                    $0.alpha = 0
                    $0.frame.origin = .init(x: 0, y: 0)
                }
            }
        } completion: { _ in
            guard !self.unsuspiciousClass.isEverythingOk else { return }
            self.effectView.removeFromSuperview()
            self.menuViews = []
            self.buttonView.subviews.forEach { $0.removeFromSuperview() }
        }
    }
}

// MARK: - Actions

private extension ViewController {
    @objc func didTapMenuView(_ button: UIButton) {
        print("Menu view tap")
    }
}

// MARK: - Gestures

private extension ViewController {
    @objc func didTap(_ recognizer: UITapGestureRecognizer) {
        if !isPresented {
            showMenu()
            setupMenuLabels()
        } else {
            hideMenu()
        }
        
        isLongPressAvailable = !isPresented
    }
    
    @objc func didPress(_ recognizer: UILongPressGestureRecognizer) {
        guard isLongPressAvailable else { return }
        
        switch recognizer.state {
        case .began:
            menuLabel.text = ""
            buttonView.addSubview(menuLabel)
            NSLayoutConstraint.activate([
                menuLabel.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor),
                menuLabel.bottomAnchor.constraint(equalTo: buttonView.topAnchor, constant: -200)
            ])
            
            showMenu()
            UIView.animate(withDuration: 0.2) {
                self.menuLabel.alpha = 1
            }
        case .changed:
            menuLabel.text = ""
            selectedMenuView = nil
            let coord = recognizer.location(in: buttonView)
            menuViews.forEach { menuView in
                if menuView.frame.contains(coord) {
                    UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.9) {
                        menuView.transform = .init(scaleX: 1.3, y: 1.3)
                    }
                    
                    menuLabel.text = "Button \(menuView.tag)"
                    selectedMenuView = menuView
                } else {
                    UIView.animate(withDuration: 0.2) {
                        menuView.transform = .identity
                    }
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.2) {
                self.menuLabel.alpha = 0
            }
            hideMenu()
        default:
            break
        }
    }
    
    @objc func someSimpleAction() {
        unsuspiciousClass.doSimpleAction()
    }
}

// MARK: - Layout

private extension ViewController {
    func setupMenuViews() {
        let menuView1 = UIButton(frame: buttonView.bounds)
        let menuView2 = UIButton(frame: buttonView.bounds)
        let menuView3 = UIButton(frame: buttonView.bounds)
        let menuView4 = UIButton(frame: buttonView.bounds)
        let menuView5 = UIButton(frame: buttonView.bounds)
        
        menuViews = [menuView1, menuView2, menuView3, menuView4, menuView5]
        for i in 0..<menuViews.count {
            let menuView = menuViews[i]
            menuView.backgroundColor = .systemGreen
            menuView.layer.cornerRadius = menuView.bounds.height / 2
            menuView.alpha = 0
            menuView.tag = i + 1
            
            menuView.addTarget(self, action: #selector(didTapMenuView(_:)), for: .touchUpInside)
            
            buttonView.addSubview(menuView)
        }
        
        menuView5.backgroundColor = .red
    }
    
    func setupMenuLabels() {
        menuViews.forEach {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.text = "Button \($0.tag)"
            label.font = .systemFont(ofSize: 10)
            
            $0.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: $0.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: $0.topAnchor, constant: -7)
            ])
        }
    }
    
    func setupUI() {
        view.addSubview(buttonView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.heightAnchor.constraint(equalToConstant: 450),
            
            buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            buttonView.widthAnchor.constraint(equalToConstant: 60),
            buttonView.heightAnchor.constraint(equalToConstant: 60),
            buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

