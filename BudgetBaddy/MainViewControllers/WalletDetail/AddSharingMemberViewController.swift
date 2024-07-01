//
//  AddMemberViewController.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/30.
//

import UIKit

protocol AddSharingMemberDelegate: AnyObject {
    func sharingUserAppended()
}

enum Errors: Error {
    case error(String)
}

class AddSharingMemberViewController: UIViewController {
    weak var delegate: AddSharingMemberDelegate?
    
    private let wallet: Wallet
    private var target: User? = nil {
        didSet {
            self.addUserButton.isEnabled = self.target != nil
            self.addUserButton.backgroundColor = self.target != nil ? .systemGreen : .systemGray3
        }
    }
    
    // Menu
    private let headerViewHeight: CGFloat = 60
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.systemGray4.cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Menu - hewadder
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("AddMember", comment: "")
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Menu - main
    private let inputUserIdFieldWidth: CGFloat = 300
    private let inputUserIdField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("InputUserId_Placeholder", comment: "")
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let addUserBtnWidht: CGFloat = 120
    private let addUserButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        button.backgroundColor = .systemGray3
        button.addTarget(self, action: #selector(addUserBtnTapped), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(wallet: Wallet) {
        self.wallet = wallet
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        // Menu
        self.view.addSubview(mainView)
        self.view.addSubview(headerView)
        // header
        headerView.addSubview(titleLabel)
        // main
        mainView.addSubview(inputUserIdField)
        mainView.addSubview(addUserButton)
        
        inputUserIdField.delegate = self
        
        NSLayoutConstraint.activate([
            // header
            headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerViewHeight),
            
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            // main
            mainView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            inputUserIdField.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 32),
            inputUserIdField.centerXAnchor.constraint(equalTo: mainView.centerXAnchor),
            inputUserIdField.widthAnchor.constraint(equalToConstant: inputUserIdFieldWidth),
            
            addUserButton.centerXAnchor.constraint(equalTo: inputUserIdField.centerXAnchor),
            addUserButton.topAnchor.constraint(equalTo: inputUserIdField.bottomAnchor, constant: 32),
            addUserButton.widthAnchor.constraint(equalToConstant: addUserBtnWidht)
        ])
        
        // キーボードを閉じるためのジェスチャーを追加
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    // MARK: - ActionEvents
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func addUserBtnTapped() {
        // walletにUserInfo追加
        let newUserInfo = UserInfo(userId: self.target!.userId, username: self.target!.username)
        WalletsDao.addSharingUserToWallet(wallet: self.wallet, userInfo: newUserInfo)
        self.wallet.sharedUsersInfo.append(newUserInfo)
        
        // User.sharedWallets に追加
        UsersDao.addSharedWalletIdToUser(userId: self.target!.userId, walletId: self.wallet.walletId)
        
        self.delegate!.sharingUserAppended()
        self.dismiss(animated: false, completion: nil)
    }
}

extension AddSharingMemberViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        let userId = inputUserIdField.text!
        // TODO: 入力チェック
        if userId == "" {
            return
        } else if userId == wallet.ownerId {
            return
        } else if let dupli = wallet.sharedUsersInfo.first(where: { $0.userId == userId }) {
            return
        }
        
        Task {
            if let user = await UsersDao.fetchUser(userId: userId) {
                self.target = user
            } else {
                self.target = nil
            }
        }
    }
}
