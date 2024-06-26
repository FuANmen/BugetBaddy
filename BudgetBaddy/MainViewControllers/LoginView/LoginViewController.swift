//
//  LoginViewController.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    enum SomeError: Error {
        case error(String)
    }
    
    // UI要素の定義
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
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ログイン", for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
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
        
        emailTextField.text = "s.ke.marisa@gmail.com"
        passwordTextField.text = "K68k4839"
    }
    
    private func setupUI() {
        // UI要素をビューに追加
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        
        // Auto Layoutを使ってレイアウトを設定
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
            loginButton.widthAnchor.constraint(equalToConstant: 100),
            
            signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 40),
            signUpButton.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    // MARK: - Action Event
    @objc private func signUpButtonTapped() {
        let signUpViewController = SignUpViewController()
        self.present(signUpViewController, animated: true, completion: nil)
    }
    
    @objc private func loginButtonTapped() {
        do {
            // 入力チェック
            guard let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
                throw SomeError.error("必要な情報を入力してください")
            }
            
            // Firebase Authenticationを使ってログイン
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                do {
                    if error != nil {
                        throw SomeError.error("ログインに失敗")
                    }
                    
                    // ログインユーザ情報取得
                    guard let userId = authResult?.user.uid else {
                        throw SomeError.error("ユーザIDの取得に失敗")
                    }
                    
                    Task {
                        print(userId)
                        if let user = await UsersDao.fetchUser(userId: userId) {
                            self!.navigateToMainScreen(user: user)
                        } else {
                            throw SomeError.error("ユーザ情報の取得に失敗")
                        }
                    }
                } catch SomeError.error(let message) {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        self?.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(ok)
                    self?.present(alert, animated: true, completion: nil)
                } catch {
                    return
                }
            }
        } catch SomeError.error(let message) {
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        } catch {
            return
        }
    }
    
    private func navigateToMainScreen(user: User) {
        // メイン画面への遷移処理
        let mainViewController = MonthlyViewController()
        mainViewController.user = user
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        self.present(navigationController, animated: true, completion: nil)
    }
}
