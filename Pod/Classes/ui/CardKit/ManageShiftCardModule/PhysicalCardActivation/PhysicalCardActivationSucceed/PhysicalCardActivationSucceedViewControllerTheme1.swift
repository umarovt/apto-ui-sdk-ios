//
//  PhysicalCardActivationSucceedViewController.swift
//  AptoSDK
//
// Created by Takeichi Kanzaki on 22/10/2018.
//

import SnapKit
import AptoSDK
import Bond
import ReactiveKit

class PhysicalCardActivationSucceedViewControllerTheme1: PhysicalCardActivationSucceedViewControllerProtocol {
  private let disposeBag = DisposeBag()
  private unowned let presenter: PhysicalCardActivationSucceedPresenterProtocol

  init(uiConfiguration: UIConfig, presenter: PhysicalCardActivationSucceedPresenterProtocol) {
    self.presenter = presenter
    super.init(uiConfiguration: uiConfiguration)
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpUI()
    setUpViewModelSubscriptions()
    presenter.viewLoaded()
  }

  override func closeTapped() {
    presenter.closeTapped()
  }
}

// MARK: - View model subscriptions
private extension PhysicalCardActivationSucceedViewControllerTheme1 {
  func setUpViewModelSubscriptions() {
    presenter.viewModel.showGetPinButton.observeNext { [unowned self] _ in
      self.setUpUI()
    }.dispose(in: disposeBag)
  }
}

// MARK: - Set up UI
private extension PhysicalCardActivationSucceedViewControllerTheme1 {
  func setUpUI() {
    view.backgroundColor = uiConfiguration.uiBackgroundPrimaryColor
    setUpNavigationBar()
    let bottomConstraint: ConstraintItem
    if presenter.viewModel.showGetPinButton.value {
      let label = createChargeApplyLabel()
      let button = createGetPinButton(bottomView: label)
      bottomConstraint = button.snp.top
    }
    else {
      bottomConstraint = view.snp.bottom
    }
    let explanationLabel = createExplanationLabel(bottomConstraint: bottomConstraint)
    createTitleLabel(bottomView: explanationLabel)
  }

  func setUpNavigationBar() {
    navigationController?.navigationBar.setUpWith(uiConfig: uiConfiguration)
    title = "physical.card.activation.succeed.title".podLocalized()
  }

  func createTitleLabel(bottomView: UIView) {
    let title = "manage_card.get_pin_nue.title".podLocalized()
    let label = ComponentCatalog.largeTitleLabelWith(text: title, uiConfig: uiConfiguration)
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(44)
      make.bottom.equalTo(bottomView.snp.top).offset(-6)
    }
  }

  func createExplanationLabel(bottomConstraint: ConstraintItem) -> UILabel {
    let explanation = "manage_card.get_pin_nue.explanation".podLocalized()
    let label = ComponentCatalog.mainItemRegularLabelWith(text: explanation, multiline: true, uiConfig: uiConfiguration)
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(44)
      make.bottom.equalTo(bottomConstraint).offset(-36)
    }
    return label
  }

  func createGetPinButton(bottomView: UIView) -> UIButton {
    let button = ComponentCatalog.buttonWith(title: "manage_card.get_pin_nue.call_to_action.title".podLocalized(),
                                             uiConfig: uiConfiguration) { [unowned self] in
      self.presenter.getPinTapped()
    }
    view.addSubview(button)
    button.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(44)
      make.bottom.equalTo(bottomView.snp.top).offset(-32)
    }
    return button
  }

  func createChargeApplyLabel() -> UILabel {
    let chargeExplanation = "manage_card.get_pin_nue.footer".podLocalized()
    let label = ComponentCatalog.instructionsLabelWith(text: chargeExplanation, uiConfig: uiConfiguration)
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview().inset(56)
      make.bottom.equalToSuperview().inset(44)
    }
    return label
  }
}
