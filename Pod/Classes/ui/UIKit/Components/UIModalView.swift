//
//  UIModalView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/03/2018.
//

import UIKit

protocol Modal {
  func show(animated: Bool)
  func dismiss(animated: Bool, completion: (() -> Void)?)
  var backgroundView: UIView {get}
  var dialogView: UIView {get set}
}

extension Modal where Self: UIView {
  func show(animated: Bool) {
    self.backgroundView.alpha = 0
    self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height / 2)
    guard let topViewController = UIApplication.topViewController() else { return }
    if let navController = topViewController.navigationController {
      navController.view.addSubview(self)
    }
    else {
      topViewController.view.addSubview(self)
    }
    if animated {
      UIView.animate(withDuration: 0.33, animations: { // swiftlint:disable:this trailing_closure
        self.backgroundView.alpha = 0.66
      })
      UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10,
                     options: UIView.AnimationOptions(rawValue: 0), animations: {
        self.dialogView.center = self.center
      }, completion: { _ in })
    }
    else {
      self.backgroundView.alpha = 0.66
      self.dialogView.center = self.center
    }
  }

  func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
    if animated {
      UIView.animate(withDuration: 0.33, animations: {
        self.backgroundView.alpha = 0
      }, completion: { _ in })
      UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10,
                     options: UIView.AnimationOptions(rawValue: 0), animations: {
        self.dialogView.center = CGPoint(x: self.center.x, y: self.frame.height + self.dialogView.frame.height / 2)
      }, completion: { _ in
        self.removeFromSuperview()
        completion?()
      })
    }
    else {
      self.removeFromSuperview()
      completion?()
    }
  }
}
