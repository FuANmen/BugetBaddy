//
//  CreateBreakdownView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/23.
//

import UIKit

protocol BreakdownEditorViewDelegate: AnyObject {
    func okButtonTapped_atBreakdownEditor()
    func cancelButtonTapped_atBreakdownEditor()
}

class BreakdownEditorView: UIView {
    weak var delegate: BreakdownEditorViewDelegate?
    private var targetMonth: String = ""
    private var breakdown: Breakdown? = nil {
        didSet {
            if breakdown == nil {
                headerLabel.text = NSLocalizedString("BreadownEditor_Add_Title", comment: "")
                self.nameField.text = ""
                self.amountField.text = ""
            } else {
                headerLabel.text = NSLocalizedString("BreadownEditor_Edit_Title", comment: "")
                self.nameField.text = breakdown!.title
                self.amountField.text = String(Int(breakdown!.amount))
            }
        }
    }
    
    private var dialogView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = BACKGROUND_COLOR
        return view
    }()
    
    private var headerLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("BreadownEditor_Add_Title", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    private var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var nameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Title", comment: "")
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private var amountField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Amount", comment: "")
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
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
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDialogView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDialogView()
    }
    
    func configure(targetMonth: String, breakdown: Breakdown? = nil) {
        self.targetMonth = targetMonth
        self.breakdown = breakdown
    }
    
    // MARK: - Setup
    private func setupDialogView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        self.addSubview(dialogView)
        dialogView.addSubview(horizonLine)
        dialogView.addSubview(verticalLine)
        dialogView.addSubview(headerView)
        dialogView.addSubview(mainView)
        dialogView.addSubview(okButton)
        dialogView.addSubview(cancelButton)
        
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        horizonLine.translatesAutoresizingMaskIntoConstraints = false
        verticalLine.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        mainView.translatesAutoresizingMaskIntoConstraints = false
        okButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        let viewWidth =  UIScreen.main.bounds.size.width * 0.75
        
        NSLayoutConstraint.activate([
            dialogView.widthAnchor.constraint(equalToConstant: viewWidth),
            dialogView.heightAnchor.constraint(equalToConstant: 200),
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
            
            headerView.topAnchor.constraint(equalTo: dialogView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 40),
            
            mainView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: horizonLine.topAnchor),
            
            okButton.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            okButton.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            okButton.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor),
            okButton.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: verticalLine.trailingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor)
        ])
        
        // Header
        headerView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
        
        // Main
        mainView.addSubview(nameField)
        mainView.addSubview(amountField)
        
        nameField.translatesAutoresizingMaskIntoConstraints = false
        amountField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 16),
            nameField.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 32),
            nameField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -32),
            
            amountField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16),
            amountField.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 32),
            amountField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -32),
        ])
        
        // キーボードを閉じるためのジェスチャーを追加
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Button Actions
    @objc private func hideKeyboard() {
        mainView.endEditing(true)
    }
    
    @objc private func okButtonTapped() {
        if self.breakdown == nil {
            BreakdownDao().addBreakDown(targetMonth: self.targetMonth
                                        , title: nameField.text!
                                        , amount: Double(amountField.text!)!
                                        , source_pattern: "0")
        } else {
            BreakdownDao().updateBreakDown(breakdown: self.breakdown!
                                           , title: nameField.text!
                                           , amount: Double(amountField.text!))
        }
        delegate?.okButtonTapped_atBreakdownEditor()
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.cancelButtonTapped_atBreakdownEditor()
    }
}
