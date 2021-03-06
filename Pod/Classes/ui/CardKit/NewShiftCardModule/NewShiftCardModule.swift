//
//  NewShiftCardModule.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 08/03/2018.
//

import UIKit
import AptoSDK

class NewShiftCardModule: UIModule {
  private let initialDataPoints: DataPointList
  private let cardProductId: String

  // swiftlint:disable implicitly_unwrapped_optional
  var contextConfiguration: ContextConfiguration!
  var projectConfiguration: ProjectConfiguration {
    return contextConfiguration.projectConfiguration
  }
  var cardProduct: CardProduct!
  // swiftlint:enable implicitly_unwrapped_optional

  public init(serviceLocator: ServiceLocatorProtocol, initialDataPoints: DataPointList, cardProductId: String) {
    self.initialDataPoints = initialDataPoints
    self.cardProductId = cardProductId
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    self.loadConfigurationFromServer { [weak self] result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success:
        self?.startNewApplication(completion: completion)
      }
    }
  }

  // MARK: - Configuration HandlingApplication

  fileprivate func loadConfigurationFromServer(_ completion:@escaping Result<Void, NSError>.Callback) {
    showLoadingView()
    platform.fetchContextConfiguration { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        self.hideLoadingView()
        completion(.failure(error))
      case .success (let contextConfiguration):
        self.contextConfiguration = contextConfiguration
        self.platform.fetchCardProduct(cardProductId: self.cardProductId) { [weak self] result in
          guard let self = self else { return }
          self.hideLoadingView()
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let cardProduct):
            self.cardProduct = cardProduct
            completion(.success(Void()))
          }
        }
      }
    }
  }

  private func startNewApplication(completion: @escaping Result<UIViewController, NSError>.Callback) {
    showLoadingView()
    platform.applyToCard(cardProduct: cardProduct) { [weak self] result in
      guard let self = self else { return }
      self.hideLoadingView()
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let application):
        let workflowModule = self.workflowModuleFor(application: application)
        self.addChild(module: workflowModule, completion: completion)
      }
    }
  }

  private func workflowModuleFor(application: CardApplication) -> WorkflowModule {
    let moduleFactory = WorkflowModuleFactoryImpl(serviceLocator: serviceLocator, workflowObject: application)

    let workflowModule = WorkflowModule(serviceLocator: serviceLocator, workflowObject: application,
                                        workflowObjectStatusRequester: self, workflowModuleFactory: moduleFactory)
    workflowModule.onClose = { module in
      self.close()
    }

    return workflowModule
  }
}

// MARK: - WorkflowObjectStatusRequester protocol

extension NewShiftCardModule: WorkflowObjectStatusRequester {
  func getStatusOf(workflowObject: WorkflowObject, completion: @escaping (Result<WorkflowObject, NSError>.Callback)) {
    guard let application = workflowObject as? CardApplication else {
      completion(.failure(ServiceError(code: ServiceError.ErrorCodes.internalIncosistencyError)))
      return
    }

    showLoadingView()
    platform.fetchCardApplicationStatus(application.id) { [weak self] result in
      guard let self = self else { return }
      self.hideLoadingView()
      switch result {
      case .failure(let error):
        self.show(error: error)
      case .success(let application):
        if application.status == .approved {
          self.onFinish?(self)
          return
        }
        completion(.success(application))
      }
    }
  }
}

extension CardProduct: WorkflowObject {
  public var workflowObjectId: String {
    return self.id
  }
  public var nextAction: WorkflowAction {
    return self.disclaimerAction
  }
}
