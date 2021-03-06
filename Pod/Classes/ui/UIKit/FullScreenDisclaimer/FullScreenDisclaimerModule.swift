//
//  FullScreenDisclaimerModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/10/2016.
//
//

import Foundation
import AptoSDK

class FullScreenDisclaimerModule: UIModule, FullScreenDisclaimerModuleProtocol {
  private let disclaimer: Content
  private var presenter: FullScreenDisclaimerPresenterProtocol?

  var onDisclaimerAgreed: ((_ fullScreenDisclaimerModule: FullScreenDisclaimerModuleProtocol) -> Void)?

  init(serviceLocator: ServiceLocatorProtocol, disclaimer: Content) {
    self.disclaimer = disclaimer

    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    let viewController = buildFullScreenDisclaimerViewController(uiConfig)
    addChild(viewController: viewController, completion: completion)
  }

  private func buildFullScreenDisclaimerViewController(_ uiConfig: UIConfig) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.fullScreenDisclaimerPresenter()
    let interactor = serviceLocator.interactorLocator.fullScreenDisclaimerInteractor(disclaimer: disclaimer)
    let viewController = serviceLocator.viewLocator.fullScreenDisclaimerView(uiConfig: uiConfig,
                                                                             eventHandler: presenter)
    presenter.interactor = interactor
    presenter.router = self
    presenter.analyticsManager = serviceLocator.analyticsManager
    self.presenter = presenter
    return viewController
  }
}

extension FullScreenDisclaimerModule: FullScreenDisclaimerRouterProtocol {
  func agreeTapped() {
    onDisclaimerAgreed?(self)
    onFinish?(self)
  }
}
