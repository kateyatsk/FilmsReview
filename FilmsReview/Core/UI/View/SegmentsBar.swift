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
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
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
        let underlineView = UIView()
        underlineView.backgroundColor = .titlePrimary
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        return underlineView
    }()
    
    private var buttons: [UIButton] = []
    private var underlineCenterX: NSLayoutConstraint?
    private var underlineWidth: NSLayoutConstraint?
    private var selectedIndex: Int = 0
    
    init(titles: [String], initialIndex: Int = 0) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.titles = titles
        self.selectedIndex = max(0, min(initialIndex, titles.count - 1))
        setupViews()
        setupConstraints()
        rebuildButtons()
        select(index: selectedIndex, animated: false)
    }
    
    required init?(coder: NSCoder) { nil }
    
    func select(index: Int, animated: Bool) {
        guard buttons.indices.contains(index) else { return }
        selectedIndex = index
        
        buttons.enumerated().forEach { idx, button in
            button.setTitleColor(idx == index ? .titlePrimary : .secondaryLabel, for: .normal)
        }
        
        updateUnderline(for: index, animated: animated)
        scrollToVisibleButton(at: index, animated: animated)
    }
    
    @objc private func tap(_ sender: UIButton) {
        select(index: sender.tag, animated: true)
        onSelect?(sender.tag)
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
        guard !titles.isEmpty else {
            buttons.forEach { $0.removeFromSuperview() }
            buttons = []
            underline.isHidden = true
            return
        }
        
        selectedIndex = min(max(0, selectedIndex), titles.count - 1)
        
        buttons.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        titles.enumerated().forEach { idx, title in
            let button = makeButton(title: title, index: idx)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        underline.isHidden = false
        select(index: selectedIndex, animated: false)
    }
    
    private func makeButton(title: String, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .montserrat(.semiBold, size: Spacing.xs3)
        button.setTitleColor(index == selectedIndex ? .titlePrimary : .secondaryLabel, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(
            top: .zero,
            left: Constants.buttonEdgeInset,
            bottom: .zero,
            right: Constants.buttonEdgeInset
        )
        button.tag = index
        button.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
        return button
    }
    
    private func measuredTitleWidth(for button: UIButton) -> CGFloat {
        guard let title = button.title(for: .normal),
              let font = button.titleLabel?.font else { return 0 }
        return ceil((title as NSString).size(withAttributes: [.font: font]).width)
    }
    
    private func updateUnderline(for index: Int, animated: Bool) {
        guard buttons.indices.contains(index) else { return }
        
        underlineCenterX?.isActive = false
        underlineWidth?.isActive = false
        
        let targetButton = buttons[index]
        let width = measuredTitleWidth(for: targetButton)
        
        underlineCenterX = underline.centerXAnchor.constraint(equalTo: targetButton.centerXAnchor)
        underlineWidth = underline.widthAnchor.constraint(equalToConstant: width)
        
        underlineCenterX?.isActive = true
        underlineWidth?.isActive = true
        
        if animated {
            UIView.animate(withDuration: Constants.underlineAnimDuration,
                           delay: 0,
                           options: .curveEaseInOut) {
                self.layoutIfNeeded()
            }
        } else {
            self.layoutIfNeeded()
        }
    }
    
    private func scrollToVisibleButton(at index: Int, animated: Bool) {
        guard buttons.indices.contains(index) else { return }
        let button = buttons[index]
        let frameInScroll = button.convert(button.bounds, to: scrollView)
        scrollView.scrollRectToVisible(
            frameInScroll.insetBy(dx: -Spacing.xs3, dy: 0),
            animated: animated
        )
    }
}
