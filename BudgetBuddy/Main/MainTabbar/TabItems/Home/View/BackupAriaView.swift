//
//  BackupAriaView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/31.
//

import UIKit

class BackupAriaView: UIView {
    
    private let title: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Backup", comment: "")
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Export
    private let exportView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.systemCyan.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 1
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let exportIcon: UIImageView = {
        let image = UIImageView()
        image.setSymbolImage(UIImage(systemName: "square.and.arrow.up")!, contentTransition: .automatic)
        image.tintColor = .systemGreen
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let exportLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Export", comment: "")
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Import
    private let importView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.systemCyan.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 1
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let importIcon: UIImageView = {
        let image = UIImageView()
        image.setSymbolImage(UIImage(systemName: "square.and.arrow.down")!, contentTransition: .automatic)
        image.tintColor = .systemOrange
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let importLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Import", comment: "")
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        
    }
    
    internal func getViewHeight() -> CGFloat {
        return 100
    }
    
    private func setupUI() {
        self.addSubview(title)
        self.addSubview(exportView)
        self.addSubview(importView)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            
            exportView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            exportView.centerXAnchor.constraint(equalTo: self.leadingAnchor, constant: self.frame.width / 4),
            exportView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            exportView.trailingAnchor.constraint(equalTo: self.centerXAnchor, constant: -6),
            exportView.heightAnchor.constraint(equalToConstant: 100),
            
            importView.topAnchor.constraint(equalTo: exportView.topAnchor),
            importView.centerXAnchor.constraint(equalTo: self.leadingAnchor, constant: self.frame.width / 4 * 3),
            importView.leadingAnchor.constraint(equalTo: self.centerXAnchor, constant: 6),
            importView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            importView.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        // Export
        exportView.addSubview(exportIcon)
        exportView.addSubview(exportLabel)
        
        NSLayoutConstraint.activate([
            exportIcon.centerXAnchor.constraint(equalTo: exportView.centerXAnchor),
            exportIcon.topAnchor.constraint(equalTo: exportView.topAnchor, constant: 12),
            exportIcon.widthAnchor.constraint(equalToConstant: 40),
            exportIcon.heightAnchor.constraint(equalToConstant: 40),
            
            exportLabel.centerXAnchor.constraint(equalTo: exportView.centerXAnchor),
            exportLabel.topAnchor.constraint(equalTo: exportIcon.bottomAnchor, constant: 12)
        ])
        
        // Import
        importView.addSubview(importIcon)
        importView.addSubview(importLabel)
        
        NSLayoutConstraint.activate([
            importIcon.centerXAnchor.constraint(equalTo: importView.centerXAnchor),
            importIcon.topAnchor.constraint(equalTo: importView.topAnchor, constant: 12),
            importIcon.widthAnchor.constraint(equalToConstant: 40),
            importIcon.heightAnchor.constraint(equalToConstant: 40),
            
            importLabel.centerXAnchor.constraint(equalTo: importView.centerXAnchor),
            importLabel.topAnchor.constraint(equalTo: importIcon.bottomAnchor, constant: 12)
        ])
    }
}
