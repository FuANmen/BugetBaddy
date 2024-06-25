//
//  SignUpViewController.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/23.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    enum SignUpError: Error {
        case error(String)
    }
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "メールアドレス"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "パスワード"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        return textField
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "ユーザー名"
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .next
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("アカウント作成", for: .normal)
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(usernameTextField)
        view.addSubview(signUpButton)
        
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            usernameTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            signUpButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 40),
            signUpButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    @objc private func signUpButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let username = usernameTextField.text, !username.isEmpty else {
            print("必要な情報を入力してください")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            do {
                // アカウント作成エラー
                if let error = error as NSError? {
                    if let authErrorCode = AuthErrorCode.Code(rawValue: error.code) {
                        switch authErrorCode {
                        case .emailAlreadyInUse:
                            throw SignUpError.error("このメールアドレスはすでに使用されています。")
                        case .invalidEmail:
                            throw SignUpError.error("無効なメールアドレスです。正しい形式で入力してください。")
                        case .weakPassword:
                            throw SignUpError.error("パスワードが弱すぎます。6文字以上で入力してください。")
                        case .operationNotAllowed:
                            throw SignUpError.error("メールアドレスとパスワードの認証は現在無効です。")
                        case .networkError:
                            throw SignUpError.error("ネットワークエラーが発生しました。接続を確認して再試行してください。")
                        case .tooManyRequests:
                            throw SignUpError.error("リクエストが多すぎます。しばらくしてから再試行してください。")
                        case .internalError:
                            throw SignUpError.error("内部エラーが発生しました。再試行してください。")
                        default:
                            throw SignUpError.error("エラーが発生しました: \(error.localizedDescription)")
                        }
                    } else {
                        // その他のエラー
                        throw SignUpError.error("予期しないエラーが発生しました: \(error.localizedDescription)")
                    }
                }
                
                guard let userId = authResult?.user.uid else { return }
                
                // アカウントに紐づく情報の登録
                Task {
                    if await UsersDao.saveUserData(userId: userId, email: email, username: username) {
                        self.dismiss(animated: true)
                    } else {
                        throw SignUpError.error("ユーザ情報の取得に失敗")
                    }
                }
            } catch SignUpError.error(let message) {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            } catch {
                return 
            }
        }
    }
}
