//
//  CreditCardView.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 29/11/2016.
//
//

import Foundation
import AptoSDK
import SnapKit
import UIKit

let cardAspectRatio = 1.585772508336421
let nameOnCardMaxLength = 23

public class CreditCardView: UIView {
  private let uiConfiguration: UIConfig
  private var cardStyle: CardStyle?
  // Container View
  private var showingBack = false
  private let logos: [CardNetwork: UIImage?] = [
    .visa: UIImage.imageFromPodBundle("card_network_visa")?.asTemplate(),
    .mastercard: UIImage.imageFromPodBundle("card_network_mastercard")?.asTemplate(),
    .amex: UIImage.imageFromPodBundle("card_logo_amex"),
    .other: nil
  ]

  // MARK: - Front View
  private let frontView = UIImageView()
  private let imageView = UIImageView()
  private let cardNumber = UIFormattedLabel()
  private let cardHolder = UILabel()
  private let expireDate = UIFormattedLabel()
  private let expireDateText = UILabel()
  private let frontCvv = UIFormattedLabel()
  private let frontCvvText = UILabel()
  private let lockedView = UIView()
  private let lockImageView = UIImageView(image: UIImage.imageFromPodBundle("card-locked-icon"))

  // MARK: - Back View
  private let backView = UIView()
  private let backImage = UIImageView()
  private let cvc = UIFormattedLabel()
  private let backLine = UIView()

  // MARK: - State
  private var cardState: FinancialAccountState = .active
  private var cardInfoShown = false {
    didSet {
      cardNumber.isUserInteractionEnabled = cardInfoShown
    }
  }
  private var cardNumberText: String?
  private var lastFourText: String?
  private var cardHolderText: String?
  private var expirationMonth: UInt?
  private var expirationYear: UInt?
  private var cvvText: String?
  private var cardNetwork: CardNetwork?
  private var hasValidFundingSource = true

  public var textColor: UIColor = .white {
    didSet {
      updateLabelsFontColor()
    }
  }

  // MARK: - Lifecycle
  public init(uiConfiguration: UIConfig, cardStyle: CardStyle?) {
    self.uiConfiguration = uiConfiguration
    self.cardStyle = cardStyle
    super.init(frame: .zero)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.layer.cornerRadius = 10
    setUpShadow()
    setupFrontView()
    setupBackView()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public methods

  public func set(cardHolder: String?) {
    cardHolderText = cardHolder?.uppercased()
    updateCard()
  }

  public func set(cardNumber: String?) {
    cardNumberText = cardNumber
    updateCard()
  }

  public func set(lastFour: String?) {
    lastFourText = lastFour
    updateCard()
  }

  public func set(expirationMonth: UInt, expirationYear: UInt) {
    self.expirationMonth = expirationMonth
    self.expirationYear = expirationYear
    updateCard()
  }

  public func set(cvc: String?) {
    cvvText = cvc
    updateCard()
  }

  public func set(cardState: FinancialAccountState) {
    self.cardState = cardState
    updateCard()
  }

  public func set(showInfo: Bool) {
    self.cardInfoShown = showInfo
    updateCard()
  }

  public func set(cardNetwork: CardNetwork?) {
    self.cardNetwork = cardNetwork
    updateCard()
  }

  public func set(validFundingSource: Bool) {
    self.hasValidFundingSource = validFundingSource
    updateCardEnabledState()
  }

  public func set(cardStyle: CardStyle?) {
    self.cardStyle = cardStyle
    updateCardStyle()
  }

  func didBeginEditingCVC() {
    if !showingBack {
      flip()
      showingBack = true
    }
  }

  func didEndEditingCVC() {
    if showingBack {
      flip()
      showingBack = false
    }
  }

  // MARK: - Private methods

  fileprivate func flip() {
    var showingSide: UIView = frontView
    var hiddenSide: UIView = backView
    if showingBack {
      (showingSide, hiddenSide) = (backView, frontView)
    }
    UIView.transition(from: showingSide,
                      to: hiddenSide,
                      duration: 0.7,
                      options: [.transitionFlipFromRight, .showHideTransitionViews],
                      completion: nil)
  }

  fileprivate func set(cardNetwork: CardNetwork, enabled: Bool, alpha: CGFloat) {
    UIView.animate(withDuration: 2) {
      self.imageView.tintColor = self.textColor
      self.imageView.image = self.logos[cardNetwork]! // swiftlint:disable:this force_unwrapping
    }
  }
}

// MARK: - Setup UI
private extension CreditCardView {
  func setUpShadow() {
    let height = 4
    layer.shadowOffset = CGSize(width: 0, height: height)
    layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
    layer.shadowOpacity = 1
    layer.shadowRadius = 8
  }

  func setupFrontView() {
    frontView.translatesAutoresizingMaskIntoConstraints = false
    frontView.layer.cornerRadius = 10
    frontView.clipsToBounds = true
    self.addSubview(frontView)
    frontView.isHidden = false
    frontView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalTo(self)
    }
    setUpImageView()
    setUpExpireDateText()
    setUpExpireDate()
    setUpFrontCVVText()
    setUpFrontCVV()
    setUpCardHolderView()
    setUpCardNumberView()
    setUpLockView()
  }

  func setUpImageView() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .bottomRight
    frontView.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.width.equalTo(60)
      make.height.equalTo(40)
      make.right.equalTo(frontView).inset(20)
      make.bottom.equalTo(frontView).inset(16)
    }
  }

  func setUpExpireDateText() {
    expireDateText.translatesAutoresizingMaskIntoConstraints = false
    expireDateText.font = uiConfiguration.fontProvider.cardLabelFont
    expireDateText.text = "EXP"
    expireDateText.textColor = textColor.withAlphaComponent(0.7)
    frontView.addSubview(expireDateText)
    expireDateText.snp.makeConstraints { make in
      make.bottom.equalTo(frontView).inset(16)
      make.left.equalTo(frontView).offset(20)
    }
  }

  func setUpExpireDate() {
    expireDate.translatesAutoresizingMaskIntoConstraints = false
    expireDate.font = uiConfiguration.fontProvider.cardSmallValueFont
    expireDate.formattingPattern = "**/****"
    expireDate.textColor = textColor
    frontView.addSubview(expireDate)
    expireDate.snp.makeConstraints { make in
      make.bottom.equalTo(expireDateText)
      make.left.equalTo(expireDateText.snp.right).offset(4)
    }
  }

  func setUpFrontCVVText() {
    frontCvvText.translatesAutoresizingMaskIntoConstraints = false
    frontCvvText.font = uiConfiguration.fontProvider.cardLabelFont
    frontCvvText.text = "CVV"
    frontCvvText.textColor = textColor.withAlphaComponent(0.7)
    frontView.addSubview(frontCvvText)
    frontCvvText.snp.makeConstraints { make in
      make.bottom.equalTo(expireDate)
      make.left.equalTo(expireDate.snp.right).offset(20)
    }
  }

  func setUpFrontCVV() {
    frontCvv.translatesAutoresizingMaskIntoConstraints = false
    frontCvv.font = uiConfiguration.fontProvider.cardSmallValueFont
    frontCvv.formattingPattern = "***"
    frontCvv.textColor = textColor
    frontView.addSubview(frontCvv)
    frontCvv.snp.makeConstraints { make in
      make.bottom.equalTo(frontCvvText)
      make.left.equalTo(frontCvvText.snp.right).offset(4)
    }
  }

  func setUpCardHolderView() {
    cardHolder.translatesAutoresizingMaskIntoConstraints = false
    cardHolder.font = uiConfiguration.fontProvider.cardSmallValueFont
    cardHolder.text = ""
    cardHolder.textColor = textColor
    cardHolder.adjustsFontSizeToFitWidth = false
    cardHolder.lineBreakMode = .byCharWrapping
    frontView.addSubview(cardHolder)
    cardHolder.snp.makeConstraints { make in
      make.bottom.equalTo(expireDate.snp.top).offset(-12)
      make.left.equalToSuperview().inset(20)
      make.right.equalToSuperview().inset(80)
    }
  }

  func setUpCardNumberView() {
    cardNumber.translatesAutoresizingMaskIntoConstraints = false
    cardNumber.formattingPattern = "**** **** **** ****"
    cardNumber.textColor = textColor
    cardNumber.textAlignment = .center
    cardNumber.font = uiConfiguration.fontProvider.cardLargeValueFont
    cardNumber.adjustsFontSizeToFitWidth = true
    cardNumber.isUserInteractionEnabled = false
    cardNumber.addTapGestureRecognizer { [unowned self] in
      UIPasteboard.general.string = self.cardNumberText
      UIApplication.topViewController()?.showMessage("credit.card-number-copied".podLocalized(),
                                                     uiConfig: self.uiConfiguration)
    }
    addSubview(cardNumber)
    cardNumber.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.right.equalToSuperview().inset(16)
    }
  }

  func setUpLockView() {
    lockedView.backgroundColor = .black
    lockedView.alpha = 0.7
    lockedView.layer.cornerRadius = layer.cornerRadius
    addSubview(lockedView)
    lockedView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    setUpLockImageView()
  }

  func setUpLockImageView() {
    addSubview(lockImageView)
    lockImageView.contentMode = .center
    lockImageView.tintColor = .white
    lockImageView.alpha = 1
    lockImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  func setupBackView() {
    backView.translatesAutoresizingMaskIntoConstraints = false
    backView.layer.cornerRadius = 10
    backView.clipsToBounds = true
    self.addSubview(backView)
    backView.isHidden = true
    backView.snp.makeConstraints { make in
      make.top.bottom.left.right.equalTo(self)
    }
    setUpBackLine()
    setUpCVC()
  }

  func setUpBackLine() {
    backLine.translatesAutoresizingMaskIntoConstraints = false
    backLine.backgroundColor = colorize(0x000000)
    backView.addSubview(backLine)
    backLine.snp.makeConstraints { make in
      make.top.equalTo(backView).offset(20)
      make.centerX.equalTo(backView)
      make.width.equalTo(300)
      make.height.equalTo(50)
    }
  }

  func setUpCVC() {
    cvc.translatesAutoresizingMaskIntoConstraints = false
    cvc.formattingPattern = "***"
    cvc.backgroundColor = textColor
    cvc.textAlignment = .center
    backView.addSubview(cvc)
    cvc.snp.makeConstraints { make in
      make.top.equalTo(backLine.snp.bottom).offset(10)
      make.width.equalTo(50)
      make.height.equalTo(25)
      make.right.equalTo(backView).inset(10)
    }
  }

  func updateLabelsFontColor() {
    cardNumber.textColor = textColor
    cardHolder.textColor = textColor
    expireDateText.textColor = textColor.withAlphaComponent(0.7)
    expireDate.textColor = textColor
    frontCvvText.textColor = textColor.withAlphaComponent(0.7)
    frontCvv.textColor = textColor
    imageView.tintColor = textColor
  }
}

// MARK: - Update card info
private extension CreditCardView {
  func updateCard() {
    cardHolder.text = self.cardHolderText?.prefixOf(nameOnCardMaxLength)
    updateCardInfo()
    updateCardEnabledState()
    updateCardNetwork()
  }

  func updateCardInfo() {
    if !self.cardInfoShown {
      hideCardInfo()
    }
    else {
      showCardInfo()
    }
  }

  func hideCardInfo() {
    if let lastFourText = lastFourText {
      cardNumber.text = "**** **** **** \(lastFourText)"
    }
    else {
      cardNumber.text = "**** **** **** ****"
    }
    expireDate.text = "**/**"
    frontCvv.text = "***"
  }

  func showCardInfo() {
    if let cardNumberText = self.cardNumberText {
      cardNumber.text = cardNumberText
    }
    else {
      cardNumber.text = ""
    }
    if let expirationMonth = expirationMonth, let expirationYear = expirationYear {
      expireDate.text = String(format: "%02ld", expirationMonth) + "/\(expirationYear)"
    }
    else {
      expireDate.text = "MM/YY"
    }
    if let cvv = self.cvvText {
      frontCvv.text = cvv
    }
  }

  func updateCardEnabledState() {
    if cardState == .active && hasValidFundingSource {
      setUpEnabledCard()
    }
    else {
      setUpDisabledCard()
    }
  }

  func updateCardStyle() {
    guard let cardStyle = cardStyle else {
      return
    }
    UIView.animate(withDuration: 2) { [weak self] in
      switch cardStyle.background {
      case .color(let cardColor):
        self?.backgroundColor = cardColor
        self?.imageView.isHidden = false
        self?.frontView.image = nil
      case .image(let url):
        self?.frontView.setImageUrl(url)
        self?.imageView.isHidden = true
      }
      if let rawColor = cardStyle.textColor, let color = UIColor.colorFromHexString(rawColor) {
        self?.textColor = color
      }
    }
  }

  func setUpEnabledCard() {
    lockedView.isHidden = true
    lockImageView.isHidden = true
  }

  func setUpDisabledCard() {
    lockImageView.image = lockedImage()
    lockedView.isHidden = false
    lockImageView.isHidden = false
    bringSubviewToFront(lockedView)
    bringSubviewToFront(lockImageView)
  }

  func lockedImage() -> UIImage? {
    if !hasValidFundingSource {
      return UIImage.imageFromPodBundle("error_backend")?.asTemplate()
    }
    return cardState == .created
      ? UIImage.imageFromPodBundle("icon-card-activate")?.asTemplate()
      : UIImage.imageFromPodBundle("card-locked-icon")?.asTemplate()
  }

  func updateCardNetwork() {
    let enabled = cardState == .active
    if let cardNetwork = cardNetwork {
      self.set(cardNetwork: cardNetwork, enabled: enabled, alpha: 1)
    }
  }
}
