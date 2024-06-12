//
//  AlertAriaView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/30.
//

import UIKit

protocol AlertAriaDelegate: AnyObject {
    func viewUpdated_onAlertAria()
}

class AlertAriaView: UIView {
    weak var delegate: AlertAriaDelegate?
    
    var cellCount: Int = 2
    
    private let lineSpacing: CGFloat = 10.0
    private let defaultCellHeight: CGFloat = 80
    private let alertDialogCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AlertCollectionCell.self, forCellWithReuseIdentifier: AlertCollectionCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configure() {
        alertDialogCollectionView.reloadData()
    }
    
    internal func getViewHeight() -> CGFloat {
        var alertHeight: CGFloat = 0.0
        for i in 0..<alertDialogCollectionView.numberOfItems(inSection: 0) {
            alertHeight += (defaultCellHeight + self.lineSpacing)
        }
        return alertHeight
    }
    
    private func setupUI() {
        // ArartAria
        self.addSubview(alertDialogCollectionView)
        
        alertDialogCollectionView.delegate = self
        alertDialogCollectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            alertDialogCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
            alertDialogCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            alertDialogCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            alertDialogCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

extension AlertAriaView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // セルの数を返すメソッド
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }

    // セルを返すメソッド
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlertCollectionCell.identifier, for: indexPath) as! AlertCollectionCell
        cell.configure()
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 60), height: defaultCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
}

extension AlertAriaView: AlertCollectionCellDelegate {
    internal func closeButtonTapped_onAlertCell(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: alertDialogCollectionView)
        if let indexPath = alertDialogCollectionView.indexPathForItem(at: buttonPosition) {
            cellCount -= 1
            UIView.animate(withDuration: 0.2, animations: {
                self.alertDialogCollectionView.deleteItems(at: [indexPath])
            }, completion: {_ in 
                self.delegate!.viewUpdated_onAlertAria()
            })
        }
    }
}
