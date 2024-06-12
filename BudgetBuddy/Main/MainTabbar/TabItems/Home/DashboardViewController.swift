//
//  DashboardViewControlelr.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/01.
//

import Foundation
import UIKit
import Charts

class DashboardViewController: UIViewController {
    
    // Scroll
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    // Alert
    private var alertAriaHeightConstraint: NSLayoutConstraint?
    private let alertAria: AlertAriaView = {
        let view = AlertAriaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Data
    private var dataAriaHeightConstraint: NSLayoutConstraint?
    private let dataAria: DataAriaView = {
        let view = DataAriaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Backup
    private var backupAriaHeightConstraint: NSLayoutConstraint?
    private let backupAria: BackupAriaView = {
        let view = BackupAriaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Setting
    private var settingAriaHeightConstraint: NSLayoutConstraint?
    private let settingAria: settingAriaView = {
        let view = settingAriaView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // bottomDummyView
    private let bottomDummyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation
        self.navigationController?.navigationBar.backgroundColor = NAVIGATION_BACK_COLOR
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        // View
        view.backgroundColor = BACKGROUND_COLOR
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        alertAria.configure()
        dataAria.configure()
        backupAria.configure()
        settingAria.configure()
        
        updateViewsHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame {
            let statusBarView = UIView(frame: statusBarFrame)
            statusBarView.backgroundColor = NAVIGATION_BACK_COLOR
            view.addSubview(statusBarView)
        }
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(alertAria)
        scrollView.addSubview(dataAria)
        scrollView.addSubview(backupAria)
        scrollView.addSubview(settingAria)
        scrollView.addSubview(bottomDummyView)
        
        scrollView.delegate = self
        alertAria.delegate = self
        dataAria.delegate = self

        alertAriaHeightConstraint = alertAria.heightAnchor.constraint(equalToConstant: 0)
        dataAriaHeightConstraint = dataAria.heightAnchor.constraint(equalToConstant: 0)
        backupAriaHeightConstraint = backupAria.heightAnchor.constraint(equalToConstant: 0)
        settingAriaHeightConstraint = settingAria.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            alertAria.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            alertAria.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            alertAria.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            alertAriaHeightConstraint!,
            
            dataAria.topAnchor.constraint(equalTo: alertAria.bottomAnchor),
            dataAria.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dataAria.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dataAriaHeightConstraint!,
            
            backupAria.topAnchor.constraint(equalTo: dataAria.bottomAnchor),
            backupAria.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backupAria.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            backupAriaHeightConstraint!,
            
            settingAria.topAnchor.constraint(equalTo: backupAria.bottomAnchor),
            settingAria.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            settingAria.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            settingAriaHeightConstraint!,
            
            bottomDummyView.topAnchor.constraint(equalTo: settingAria.bottomAnchor),
            bottomDummyView.heightAnchor.constraint(equalToConstant: 0),
            bottomDummyView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomDummyView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        // navigation
        configureNavigationBar()
    }
    
    private func updateViewsHeight() {
        alertAriaHeightConstraint!.constant = alertAria.getViewHeight()
        dataAriaHeightConstraint!.constant = dataAria.getViewHeight()
        backupAriaHeightConstraint!.constant = backupAria.getViewHeight()
        settingAriaHeightConstraint!.constant = settingAria.getViewHeight()
        self.view.layoutIfNeeded()
        // ScrollView
        let contentHeight = max(self.view.frame.height + 100, bottomDummyView.frame.maxY + 100)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: contentHeight)
    }
    
    private func configureNavigationBar() {
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.barTintColor = BACKGROUND_COLOR
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
    }
}

extension DashboardViewController: UIScrollViewDelegate {
    // コレクションビューのスクロールイベントを監視するメソッド
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // スクロール位置に応じてNavigationBarの背景色と文字色を変えないように設定
        configureNavigationBar()
    }
}
// MARK: - AlertAriaView
extension DashboardViewController: AlertAriaDelegate {
    internal func viewUpdated_onAlertAria() {
        self.updateViewsHeight()
    }
}
// MARK: - DataAriaView
extension DashboardViewController: DataAriaDelegate {
    internal func thisWeekTapped() {
        if let tabbar = self.tabBarController as? MainTabBarController {
            tabbar.monthlyVC_preview = 1
            tabbar.setSelectedIndex(1)
        }
    }
    
    internal func thisMonthTapped() {
        if let tabbar = self.tabBarController as? MainTabBarController {
            tabbar.monthlyVC_preview = 0
            tabbar.setSelectedIndex(1)
        }
    }
    
    internal func createTranTapped() {
        let addTransactionVC = TransactionEditorViewController()
        addTransactionVC.configure()
        addTransactionVC.delegate = self
        present(addTransactionVC, animated: true, completion: nil)
    }
}
// MARK: - TransactionEditorViewController
extension DashboardViewController: TransactionEditorViewDelegate {
    func saveBtnTapped_atTransactionEditor() {
        self.alertAria.configure()
        self.dataAria.configure()
        
        self.updateViewsHeight()
    }
}
