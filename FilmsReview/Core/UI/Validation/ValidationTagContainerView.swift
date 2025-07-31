//
//  ValidationTagContainerView.swift
//  FilmsReview
//
//  Created by Екатерина Яцкевич on 21.07.25.
//

import UIKit

fileprivate enum Constants {
    enum Spacing {
        static let layout: CGFloat = 6
    }
}

final class ValidationTagContainerView: UIView, UICollectionViewDelegateFlowLayout {
    weak var delegate: (any ValidationTagContainerDelegate)?
    
    private var collectionView: UICollectionView!
    
    init(delegate: ValidationTagContainerDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupCollectionView() {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.Spacing.layout
        layout.minimumLineSpacing = Constants.Spacing.layout
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ValidationTagCell.self, forCellWithReuseIdentifier: ValidationTagCell.reuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    
    func reloadTags() {
        collectionView.reloadData()
    }
    
}

extension ValidationTagContainerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        delegate?.rulesState.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ValidationTagCell.reuseID,
                for: indexPath
            ) as? ValidationTagCell,
            let delegate = delegate as? ValidationDelegate
        else { return UICollectionViewCell() }
        
        let rule = delegate.rules[indexPath.item]
        let isValid = delegate.rulesState[rule] ?? false
        cell.configure(message: rule.message, isValid: isValid)
        return cell
    }
}


protocol ValidationTagContainerDelegate: AnyObject {
    var rulesState: [ValidationRule: Bool] { get set }
    func checkValidationTags(text: String, completion: () -> ())
}

final class ValidationDelegate: ValidationTagContainerDelegate {
    let rules: [ValidationRule]
    var rulesState: [ValidationRule : Bool]
    
    init(rules: [ValidationRule]) {
        self.rules = rules
        self.rulesState = Dictionary(uniqueKeysWithValues: rules.map { ($0, false) })
    }
    
    func checkValidationTags(text: String, completion: () -> ()) {
        for (rule, _) in rulesState {
            let result = NSPredicate(format: "SELF MATCHES %@", rule.regex).evaluate(with: text)
            rulesState[rule] = result
        }
        completion()
    }
}



