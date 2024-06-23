//
//  SettingsViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/10.
//

import UIKit
import StoreKit
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    let sections: [String] = [NSLocalizedString("Se_Section_1", comment: ""),
                              NSLocalizedString("Se_Section_2", comment: ""),
                              NSLocalizedString("Se_Section_3", comment: "")]
    let cellsForEachSection: [[String]] = [
        [NSLocalizedString("Se_Cell_1-1", comment: ""), NSLocalizedString("Se_Cell_1-2", comment: "")],
        [NSLocalizedString("Se_Cell_2-4", comment: "")],
        [NSLocalizedString("Se_Cell_3-1", comment: ""), NSLocalizedString("Se_Cell_3-2", comment: "")]
    ]

    // MARK: - UI Elements

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Se_Title", comment: "")
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsForEachSection[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = cellsForEachSection[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let viewController = MonthlyDefaultManagementAmountViewController()
                navigationController?.pushViewController(viewController, animated: true)
            } else if indexPath.row == 1 {
                let viewController = CategorysSettingViewController()
                navigationController?.pushViewController(viewController, animated: true)
            }
        case 1:
            if indexPath.row == 0 {
                let viewController = LanguageSelectionViewController()
                navigationController?.pushViewController(viewController, animated: true)
            }
        case 2:
            if indexPath.row == 0 {
                if MFMailComposeViewController.canSendMail() {
                    let mailComposer = MFMailComposeViewController()
                    mailComposer.mailComposeDelegate = self
                    mailComposer.setToRecipients(["recipient@example.com"]) // 送信先メールアドレス
                    mailComposer.setSubject(NSLocalizedString("Se_Mail_Subject", comment: ""))
                    
                    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        let iOSVersion = UIDevice.current.systemVersion
                        let deviceModel = UIDevice.current.model
                        mailComposer.setMessageBody(NSString(format: NSLocalizedString("Se_Mail_Text", comment: "") as NSString, appVersion, iOSVersion, deviceModel) as String, isHTML: false)
                    }
                    present(mailComposer, animated: true, completion: nil)
                } else {
                    // メールの送信ができない場合の処理
                    print("メールの送信がサポートされていません。")
                }
            } else if indexPath.row == 1 {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        default:
            break
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
