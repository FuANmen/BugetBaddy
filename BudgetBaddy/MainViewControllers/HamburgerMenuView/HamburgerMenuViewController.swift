//
//  HamburgerMenuViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/06/22.
//

import UIKit

protocol HamburgerMenuViewDelegate: AnyObject {
    func walletSelected(wallet: Wallet)
    func logout()
}

class TableCellsInSection {
    var section: String
    var cells: [String]
    init(section: String, cells: [String]) {
        self.section = section
        self.cells = cells
    }
}

class HamburgerMenuViewController: UIViewController {
    weak var delegate: HamburgerMenuViewDelegate?

    var completion: (() -> Void)?
    
    private var loginUserInfo: User
    private var userWallets: [Wallet]
    private var sharedWallets: [Wallet]
    private var selectedWallet: Wallet?
    
    private var menuViewWidth: CGFloat = 0.0
    
    // MenuTable
    private let tableCellsInSections: [TableCellsInSection] = [
        TableCellsInSection(section: "My Wallets", cells: []),
        TableCellsInSection(section: "Shared Wallets", cells: [])
    ]
    
    private let outView: UIView = {
        let view = UIView()
        view.backgroundColor = .customDarkGray
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var menuViewLeadingAnchor: NSLayoutConstraint?
    private let menuView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Menu
    private let headerViewHeight: CGFloat = 100
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
    
    private let footerViewHeight: CGFloat = 60
    private let footerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.systemGray4.cgColor
        view.layer.shadowOpacity = 1.0
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowRadius = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Menu - hewadder
    private let userSettingBtn: UIButton = {
        let button = UIButton()
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(userSettingBtnTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userAdressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray3
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Menu - main
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    // Menu - footer
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.tintColor = .systemBlue
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle(NSLocalizedString("Logout", comment: ""), for: .normal)
        button.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.forward"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(logoutBtnTapped), for: .touchUpInside)
        
        var config = UIButton.Configuration.plain()
        config.imagePadding = 10.0
        config.baseForegroundColor = .systemBlue
        button.configuration = config
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(loginUserInfo: User, userWallets: [Wallet], sharedWallets: [Wallet], selectedWallet: Wallet?) {
        self.loginUserInfo = loginUserInfo
        self.userWallets = userWallets
        self.sharedWallets = sharedWallets
        self.selectedWallet = selectedWallet
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemGray3
        self.menuViewWidth = UIScreen.main.bounds.width * 0.7
        
        self.setupUI()
        self.setupValue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.openThisView()
    }
    
    private func setupValue() {
        self.userNameLabel.text = self.loginUserInfo.username
        self.userAdressLabel.text = self.loginUserInfo.email
    }
    
    private func setupUI() {
        self.view.backgroundColor = .clear
        self.view.addSubview(outView)
        self.view.addSubview(menuView)
        
        menuViewLeadingAnchor = menuView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -self.menuViewWidth)
        NSLayoutConstraint.activate([
            menuView.topAnchor.constraint(equalTo: self.view.topAnchor),
            menuView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            menuViewLeadingAnchor!,
            menuView.widthAnchor.constraint(equalToConstant: self.menuViewWidth),
            
            outView.topAnchor.constraint(equalTo: self.view.topAnchor),
            outView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            outView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
            outView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        
        // Menu
        menuView.addSubview(mainView)
        menuView.addSubview(headerView)
        menuView.addSubview(footerView)
        // header
        headerView.addSubview(userSettingBtn)
        headerView.addSubview(userNameLabel)
        headerView.addSubview(userAdressLabel)
        // main
        mainView.addSubview(tableView)
        // footer
        footerView.addSubview(logoutButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // header
            headerView.topAnchor.constraint(equalTo: menuView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: menuView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerViewHeight),
            
            userSettingBtn.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            userSettingBtn.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            userAdressLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            userAdressLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -32),
            userAdressLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userAdressLabel.leadingAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            userNameLabel.bottomAnchor.constraint(equalTo: userAdressLabel.topAnchor, constant: 2),
            
            // main
            mainView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: menuView.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            
            tableView.topAnchor.constraint(equalTo: mainView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            
            // footer
            footerView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: menuView.trailingAnchor),
            footerView.heightAnchor.constraint(equalToConstant: footerViewHeight),
            footerView.bottomAnchor.constraint(equalTo: menuView.bottomAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            logoutButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20)
        ])
        
        // MARK: - GESTURE
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewPanGesture(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(panGesture)
        let outViewTapped = UITapGestureRecognizer(target: self, action: #selector(outViewTapped(_:)))
        outView.isUserInteractionEnabled = true
        outView.addGestureRecognizer(outViewTapped)
    }
    
    // MARK: - Event
    private func openThisView() {
        self.menuViewLeadingAnchor!.constant = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
            self.outView.alpha = 0.8
        })
    }
    
    private func closeThisView() {
        self.menuViewLeadingAnchor!.constant = -self.menuViewWidth
        UIView.animate(withDuration: 0.4, animations: {
            self.outView.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: {_ in
            self.dismiss(animated: false, completion: self.completion!)
        })
    }
    
    // MARK: - ActionEvent
    @objc func outViewTapped(_ gesture: UITapGestureRecognizer) {
        self.closeThisView()
    }
    
    @objc func userSettingBtnTapped() {
        
    }
    
    @objc func logoutBtnTapped() {
        self.closeThisView()
        self.delegate?.logout()
    }
    
    @objc private func viewPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began, .changed:
            break
        case .ended:
            if translation.x < 0  {
                self.closeThisView()
            }
        default:
            break
        }
    }
}

extension HamburgerMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var sectionCount: Int = 0
        if self.userWallets.count > 0 { sectionCount += 1 }
        if self.sharedWallets.count > 0 { sectionCount += 1 }
        
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableCellsInSections[section].section
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.userWallets.count
        } else if section == 1 {
            return self.sharedWallets.count
        }
        return self.tableCellsInSections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = self.userWallets[indexPath.row].name
            if self.userWallets[indexPath.row].walletId == self.selectedWallet?.walletId {
                cell.backgroundColor = .systemYellow
            }
        } else if indexPath.section == 1 {
            cell.textLabel?.text = self.sharedWallets[indexPath.row].name
            if self.sharedWallets[indexPath.row].walletId == self.selectedWallet?.walletId {
                cell.backgroundColor = .systemYellow
            }
        } else {
            cell.textLabel?.text = self.tableCellsInSections[indexPath.section].cells[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.delegate?.walletSelected(wallet: self.userWallets[indexPath.row])
            self.closeThisView()
        case 1:
            self.delegate?.walletSelected(wallet: self.sharedWallets[indexPath.row])
            self.closeThisView()
        default:
            break
        }
    }
}
