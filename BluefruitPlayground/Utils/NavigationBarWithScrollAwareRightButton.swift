//
//  NavigationBarCustomScrollButton.swift
//  BluefruitPlayground
//
//  Created by Antonio García on 23/10/2019.
//  Copyright © 2019 Adafruit. All rights reserved.
//

import UIKit

// Based on: https://blog.uptech.team/how-to-build-resizing-image-in-navigation-bar-with-large-title-8ba2e8bcb840

// Use setRightButton on willAppear to set the button and call updateRightButtonPosition on scroll
// Warning: this class changes the UINavigationController delegate!

class NavigationBarWithScrollAwareRightButton: UINavigationBar {
    // Constants
    private static let kButtonTag = 100

    // Config (navbar metrics)
    static let navBarHeightSmallState: CGFloat = 44
    static let navBarHeightLargeState: CGFloat = 96.5

    private static let rightMargin: CGFloat = 6//8

    private static let bottomMarginForLargeState: CGFloat = 6//9
    private static let bottomMarginForSmallState: CGFloat = 2

    // Data
    private var navigationButton: UIButton?// = UIButton(type: .custom)
    private var topViewController: UIViewController?

    // MARK: -
    public func setRightButton(topViewController: UIViewController, image: UIImage?, target: Any?, action: Selector) {
        navigationButton?.removeFromSuperview()

        guard let image = image else { return }
        let button = UIButton(type: .custom)

        button.setImage(image, for: .normal)
        button.tag = NavigationBarWithScrollAwareRightButton.kButtonTag
        button.tintColor = UIColor.white
        button.addTarget(target, action: action, for: .touchUpInside)

        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([

            button.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -NavigationBarWithScrollAwareRightButton.rightMargin),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -NavigationBarWithScrollAwareRightButton.bottomMarginForLargeState)
        ])

        self.layoutIfNeeded()       // Force layout to remove adding animation

        self.navigationButton = button

        // Detect topViewControllerChange
        self.topViewController = topViewController
        topViewController.navigationController?.delegate = self

    }

    public var navigationBarScrollViewProgress: CGFloat {
        return (self.frame.height  - NavigationBarWithScrollAwareRightButton.navBarHeightSmallState) / (NavigationBarWithScrollAwareRightButton.navBarHeightLargeState - NavigationBarWithScrollAwareRightButton.navBarHeightSmallState)
    }

    public func updateRightButtonPosition() {
          let yDelta = NavigationBarWithScrollAwareRightButton.bottomMarginForLargeState - NavigationBarWithScrollAwareRightButton.bottomMarginForSmallState

          let y = yDelta * max(0, (1-navigationBarScrollViewProgress))
          navigationButton?.transform = CGAffineTransform(translationX: 0, y: y)
      }
}

// MARK: UINavigationControllerDelegate
extension NavigationBarWithScrollAwareRightButton: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

        // When pushing a new item remove the old button and wait for setup
        if viewController !== topViewController {
            UIView.animate(withDuration: 0.2, animations: {
                self.navigationButton?.alpha = 0
            }) { (_) in
                self.navigationButton?.removeFromSuperview()
            }
        }
    }
}
