//
//  WalletEditorDetailViewController.swift
//  BudgetBaddy
//
//  Created by 柴田健作 on 2024/06/29.
//

import UIKit

class WalletEditorViewController: UIViewController {
    private let wallet: Wallet
    
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
    private let walletName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Menu - main
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
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
        
        self.setupUI()
        self.setupValue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupValue() {
        walletName.text = self.wallet.name
    }
    
    private func setupUI() {
        // Menu
        self.view.addSubview(mainView)
        self.view.addSubview(headerView)
        // header
        headerView.addSubview(walletName)
        // main
        mainView.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            // header
            headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerViewHeight),
            
            walletName.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            walletName.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            // main
            mainView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: mainView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
        ])
    }
}

extension WalletEditorViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("MemberList", comment: "")
        case 1:
            return NSLocalizedString("Category", comment: "")
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.wallet.sharedUsersInfo.count + 1
        case 1:
            return self.wallet.categories.count + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch indexPath.section {
        case 0:
            if indexPath.row == self.wallet.sharedUsersInfo.count {
                cell.textLabel?.text = NSLocalizedString("AddMember", comment: "")
                return cell
            }
            cell.textLabel?.text = self.wallet.sharedUsersInfo[indexPath.row].username
            return cell
        case 1:
            if indexPath.row == self.wallet.categories.count {
                cell.textLabel?.text = "カテゴリ追加"
                return cell
            }
            cell.textLabel?.text = self.wallet.categories[indexPath.row].name
            return cell
        default:
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if indexPath.row == self.wallet.sharedUsersInfo.count {
                let modalViewController = AddSharingMemberViewController(wallet: self.wallet)
                modalViewController.delegate = self
                if let sheet = modalViewController.sheetPresentationController {
                    sheet.detents = [.medium(), .medium()]
                    sheet.prefersGrabberVisible = true
                }
                self.present(modalViewController, animated: true, completion: nil)
            }
        case 1:
            if indexPath.row == self.wallet.categories.count {
                
            }
        default:
            break
        }
    }
}

extension WalletEditorViewController: AddSharingMemberDelegate {
    func sharingUserAppended() {
        self.tableView.reloadData()
    }
}
