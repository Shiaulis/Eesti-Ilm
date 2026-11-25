//
//  AboutMeViewController.swift
//  EstonianWeather
//

import UIKit

final class AboutMeViewController: UIViewController {
    private enum Layout {
        static let contentPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 20
        static let maxPhotoWidth: CGFloat = 400
        static let photoCornerRadius: CGFloat = 16
        static let photoShadowRadius: CGFloat = 10
        static let photoShadowOpacity: Float = 0.33
    }

    private let contactURL: URL?
    private let openURL: ((URL) -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStack = UIStackView()
    private let photoShadowView = PhotoShadowView(
        cornerRadius: Layout.photoCornerRadius,
        shadowRadius: Layout.photoShadowRadius,
        shadowOpacity: Layout.photoShadowOpacity
    )
    private let photoImageView = UIImageView()
    private let descriptionLabel = UILabel()
    private var contactButton: UIButton?

    init(
        contactURL: URL? = SettingsConfiguration.contactURL(),
        openURL: ((URL) -> Void)? = nil
    ) {
        self.contactURL = contactURL
        self.openURL = openURL
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String(localized: "About me")
        self.navigationItem.largeTitleDisplayMode = .never
        self.view.backgroundColor = .systemBackground

        self.configureScrollView()
        self.configurePhoto()
        self.configureDescriptionLabel()
        self.configureContactButton()
    }

    // MARK: - Setup

    private func configureScrollView() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.alwaysBounceVertical = true
        self.view.addSubview(self.scrollView)

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(self.contentView)

        self.contentStack.translatesAutoresizingMaskIntoConstraints = false
        self.contentStack.axis = .vertical
        self.contentStack.alignment = .center
        self.contentStack.spacing = Layout.sectionSpacing
        self.contentView.addSubview(self.contentStack)

        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

            self.contentView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.contentView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),

            self.contentStack.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: Layout.contentPadding),
            self.contentStack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -Layout.contentPadding),
            self.contentStack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.contentPadding),
            self.contentStack.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.contentPadding),
        ])
    }

    private func configurePhoto() {
        let photoImage = UIImage(resource: .shiaulis)

        self.photoShadowView.translatesAutoresizingMaskIntoConstraints = false
        self.photoShadowView.isAccessibilityElement = false
        self.photoShadowView.accessibilityElementsHidden = true

        self.photoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.photoImageView.image = photoImage
        self.photoImageView.contentMode = .scaleAspectFit
        self.photoImageView.layer.cornerRadius = Layout.photoCornerRadius
        self.photoImageView.layer.cornerCurve = .continuous
        self.photoImageView.clipsToBounds = true
        self.photoImageView.isAccessibilityElement = false

        self.photoShadowView.addSubview(self.photoImageView)
        self.contentStack.addArrangedSubview(self.photoShadowView)

        let aspectRatio = photoImage.size.width > 0 ? photoImage.size.height / photoImage.size.width : 1
        let preferredWidthConstraint = self.photoShadowView.widthAnchor.constraint(equalToConstant: Layout.maxPhotoWidth)
        preferredWidthConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            self.photoImageView.topAnchor.constraint(equalTo: self.photoShadowView.topAnchor),
            self.photoImageView.bottomAnchor.constraint(equalTo: self.photoShadowView.bottomAnchor),
            self.photoImageView.leadingAnchor.constraint(equalTo: self.photoShadowView.leadingAnchor),
            self.photoImageView.trailingAnchor.constraint(equalTo: self.photoShadowView.trailingAnchor),

            self.photoShadowView.heightAnchor.constraint(equalTo: self.photoShadowView.widthAnchor, multiplier: aspectRatio),
            self.photoShadowView.widthAnchor.constraint(lessThanOrEqualToConstant: Layout.maxPhotoWidth),
            self.photoShadowView.widthAnchor.constraint(lessThanOrEqualTo: self.contentStack.widthAnchor),
            preferredWidthConstraint,
        ])
    }

    private func configureDescriptionLabel() {
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.text = String(localized: .aboutMeDescription)
        self.descriptionLabel.font = .preferredFont(forTextStyle: .body)
        self.descriptionLabel.adjustsFontForContentSizeCategory = true
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.textAlignment = .natural
        self.descriptionLabel.textColor = .label

        self.contentStack.addArrangedSubview(self.descriptionLabel)

        NSLayoutConstraint.activate([
            self.descriptionLabel.widthAnchor.constraint(equalTo: self.contentStack.widthAnchor),
        ])
    }

    private func configureContactButton() {
        guard let contactURL = self.contactURL else {
            return
        }

        var configuration = UIButton.Configuration.borderedProminent()
        configuration.title = String(localized: "Contact me")
        configuration.titleLineBreakMode = .byWordWrapping
        configuration.titleAlignment = .center

        let button = UIButton(
            configuration: configuration,
            primaryAction: UIAction { [weak self] _ in
                self?.openContactURL(contactURL)
            }
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        self.contactButton = button
        self.contentStack.addArrangedSubview(button)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(lessThanOrEqualTo: self.contentStack.widthAnchor),
        ])
    }

    // MARK: - Actions

    private func openContactURL(_ url: URL) {
        if let openURL = self.openURL {
            openURL(url)
        }
        else if let windowScene = self.view.window?.windowScene {
            windowScene.open(url, options: nil)
        }
        else {
            UIApplication.shared.open(url)
        }
    }
}

private final class PhotoShadowView: UIView {
    private let cornerRadius: CGFloat

    init(cornerRadius: CGFloat, shadowRadius: CGFloat, shadowOpacity: Float) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = .zero
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.cornerRadius
        ).cgPath
    }
}

#Preview {
    UINavigationController(rootViewController: AboutMeViewController())
}
