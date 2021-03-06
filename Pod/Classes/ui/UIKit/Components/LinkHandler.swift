//
//  LinkHandler.swift
//  SwiftSDK
//
//  Created by Ivan Oliver Martínez on 25/08/16.
//
//

import UIKit
import TTTAttributedLabel

public protocol URLHandlerProtocol: class {
  func showExternal(url: URL, headers: [String: String]?, useSafari: Bool?, alternativeTitle: String?)
}

open class LinkHandler: NSObject, TTTAttributedLabelDelegate {
  unowned let urlHandler: URLHandlerProtocol

  public init(urlHandler: URLHandlerProtocol) {
    self.urlHandler = urlHandler
  }

  // swiftlint:disable:next implicitly_unwrapped_optional
  open func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
    urlHandler.showExternal(url: url, headers: nil, useSafari: false, alternativeTitle: nil)
  }
}
