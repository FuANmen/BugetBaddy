//
//  EditUserSetTranLogView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/11.
//

import UIKit

protocol EditUserSetTranLogDelegate: AnyObject {
    func okButtonTapped_atEditUserSetTranLog()
    func cancelButtonTapped_atEditUserSetTranLog()
}

class EditUserSetTranLogView: UIView {
    private var dialogView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private var view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var label1: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("???_MS_001", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private lazy var amountLabel: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Amount", comment: "")
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private lazy var titleLabel: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Title", comment: "")
        return textField
    }()
    
    private var okButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var horizonLine: UIView = {
        let line = UIView()
        line.backgroundColor = .systemGray3
        return line
    }()
    
    private var verticalLine: UIView = {
        let line = UIView()
        line.backgroundColor = .systemGray3
        return line
    }()
    
    weak var delegate: EditUserSetTranLogDelegate?
    var target: UserSetTransferLog? = nil
    var category: Category? = nil
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDialogView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setInit(userSetTransferLog: UserSetTransferLog, category: Category) {
        self.amountLabel.text = String(userSetTransferLog.amount)
        self.titleLabel.text = userSetTransferLog.title
        
        self.target = userSetTransferLog
        self.category = category
    }
    
    // MARK: - Setup
    private func setupDialogView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        self.addSubview(dialogView)
        dialogView.addSubview(horizonLine)
        dialogView.addSubview(verticalLine)
        dialogView.addSubview(view)
        dialogView.addSubview(okButton)
        dialogView.addSubview(cancelButton)
        
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        horizonLine.translatesAutoresizingMaskIntoConstraints = false
        verticalLine.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        okButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        let viewWidth =  UIScreen.main.bounds.size.width * 0.85
        
        NSLayoutConstraint.activate([
            dialogView.widthAnchor.constraint(equalToConstant: viewWidth),
            dialogView.heightAnchor.constraint(equalToConstant: 160),
            dialogView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            dialogView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            horizonLine.heightAnchor.constraint(equalToConstant: 1),
            horizonLine.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            horizonLine.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            horizonLine.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor, constant: -40),
            
            verticalLine.widthAnchor.constraint(equalToConstant: 1),
            verticalLine.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            verticalLine.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor),
            verticalLine.centerXAnchor.constraint(equalTo: dialogView.centerXAnchor),
            
            view.topAnchor.constraint(equalTo: dialogView.topAnchor),
            view.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: horizonLine.topAnchor),
            
            okButton.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            okButton.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            okButton.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor),
            okButton.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: verticalLine.trailingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor),
        ])
        
        // View
        view.addSubview(label1)
        view.addSubview(amountLabel)
        view.addSubview(titleLabel)
        
        label1.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            label1.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            
            amountLabel.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 18),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            amountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            amountLabel.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        // キーボードを閉じるためのジェスチャーを追加
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Button Actions
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func okButtonTapped() {
        // TODO: - 入力チェック
        
        // 更新
        UserSetTransferLogDao().updateUserSetTransferLog(userSetTransferLog: target!
                                                         , title: titleLabel.text!
                                                         , amount: Double(amountLabel.text!)!)
        // OK押下後のイベント発火
        delegate?.okButtonTapped_atEditUserSetTranLog()
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.cancelButtonTapped_atEditUserSetTranLog()
    }
}
