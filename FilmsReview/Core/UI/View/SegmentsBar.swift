//
//  SegmentsBar.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 10.09.25.
//

import UIKit

fileprivate enum Constants {
    static let scrollBottom: CGFloat = -10

    static let stackSpacing: CGFloat = 20
    static let buttonEdgeInset: CGFloat = 2

    static let underlineHeight: CGFloat = 3
    static let underlineAnimDuration: TimeInterval = 0.25

}

final class SegmentsBar: UIView {
    var onSelect: ((Int) -> Void)?
    var titles: [String] = [] { didSet { rebuildButtons() } }

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = Constants.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var underline: UIView = {
        let view = UIView()
        view.backgroundColor = .titlePrimary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var buttons: [UIButton] = []
    private var underlineCenterX: NSLayoutConstraint?
    private var underlineWidth: NSLayoutConstraint?

    init(titles: [String]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.titles = titles
        setupViews()
        setupConstraints()
        rebuildButtons()
        select(index: 0, animated: false)
    }

    required init?(coder: NSCoder) { nil }

    @objc private func tap(_ sender: UIButton) { select(index: sender.tag, animated: true) }

    func select(index: Int, animated: Bool) {
        guard buttons.indices.contains(index) else { return }
        buttons.enumerated().forEach { i, b in
            b.setTitleColor(i == index ? .titlePrimary : .secondaryLabel, for: .normal)
        }
        updateUnderline(for: index, animated: animated)
        scrollToVisibleButton(at: index, animated: animated)
        onSelect?(index)
    }

    private func setupViews() {
        addSubviews(scrollView, underline)
        scrollView.addSubview(stackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: Spacing.xs4),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Spacing.xs3),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Spacing.xs3),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.scrollBottom),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),

            underline.heightAnchor.constraint(equalToConstant: Constants.underlineHeight),
            underline.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func rebuildButtons() {
        buttons.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        titles.enumerated().forEach { idx, title in
            let btn = makeButton(title: title, index: idx)
            buttons.append(btn)
            stackView.addArrangedSubview(btn)
        }
    }

    private func makeButton(title: String, index: Int) -> UIButton {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .montserrat(.semiBold, size: Spacing.xs3)
        b.setTitleColor(index == .zero ? .titlePrimary : .secondaryLabel, for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: .zero,
                                           left: Constants.buttonEdgeInset,
                                           bottom: .zero,
                                           right: Constants.buttonEdgeInset)
        b.tag = index
        b.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
        return b
    }

    private func measuredTitleWidth(for button: UIButton) -> CGFloat {
        guard let title = button.title(for: .normal),
              let font = button.titleLabel?.font else { return 0 }
        return ceil((title as NSString).size(withAttributes: [.font: font]).width)
    }

    private func updateUnderline(for index: Int, animated: Bool) {
        underlineCenterX?.isActive = false
        underlineWidth?.isActive = false

        let target = buttons[index]
        let width = measuredTitleWidth(for: target)

        underlineCenterX = underline.centerXAnchor.constraint(equalTo: target.centerXAnchor)
        underlineWidth = underline.widthAnchor.constraint(equalToConstant: width)

        underlineCenterX?.isActive = true
        underlineWidth?.isActive = true

        layoutIfNeeded()
        guard animated else { return }
        UIView.animate(withDuration: Constants.underlineAnimDuration,
                       delay: .zero,
                       options: .curveEaseInOut) {
            self.layoutIfNeeded()
        }
    }

    private func scrollToVisibleButton(at index: Int, animated: Bool) {
        let button = buttons[index]
        let frameInScroll = button.convert(button.bounds, to: scrollView)
        scrollView.scrollRectToVisible(
            frameInScroll.insetBy(dx: -Spacing.xs3, dy: .zero),
            animated: animated
        )
    }
}
