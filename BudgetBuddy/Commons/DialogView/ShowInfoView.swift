//
//  ShowInfoView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/03/22.
//

import UIKit

protocol ShowInfoViewDelegate: AnyObject {
    func closeButtonTapped()
}

class ShowInfoView: UIView {
    private var dialogView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .systemGray2
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: ShowInfoViewDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDialogView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDialogView()
    }
    
    // MARK: - Setup
    
    private func setupDialogView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        self.addSubview(dialogView)
        dialogView.addSubview(closeButton)
        
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let viewWidth =  UIScreen.main.bounds.size.width * 0.75
        
        NSLayoutConstraint.activate([
            dialogView.widthAnchor.constraint(equalToConstant: viewWidth),
            dialogView.heightAnchor.constraint(equalToConstant: 160),
            dialogView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            dialogView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            closeButton.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor, constant: -8)
        ])
    }
    
    // MARK: - Button Actions
    
    @objc private func closeButtonTapped() {
        delegate?.closeButtonTapped()
    }
}
