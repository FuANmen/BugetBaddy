//
//  LanguageSelectionViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/22.
//

import UIKit

class LanguageSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        return tableView
    }()

    let availableLocales = ["en", "ja"]
    let cellReuseIdentifier = "LanguageCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
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

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableLocales.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let localeIdentifier = availableLocales[indexPath.row]
        let locale = Locale(identifier: localeIdentifier)
        cell.textLabel?.text = locale.localizedString(forIdentifier: localeIdentifier)
        
        // 選択された言語とセルの言語が一致する場合にチェックマークを表示
        if let selectedLanguage = UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first,
           selectedLanguage == localeIdentifier {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocaleIdentifier = availableLocales[indexPath.row]

        // 言語の変更前に再起動するかどうかを確認するダイアログを表示
        let alertController = UIAlertController(
            title: NSLocalizedString("SeLa_Dialog_1_Title", comment: ""),
            message: NSLocalizedString("SeLa_Dialog_1_Message", comment: ""),
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: NSLocalizedString("SeLa_Dialog_1_No", comment: ""), style: .cancel, handler: nil)

        let restartAction = UIAlertAction(title: NSLocalizedString("SeLa_Dialog_1_Yes", comment: ""), style: .destructive) { _ in
            // 言語の選択をUserDefaultsに保存
            UserDefaults.standard.set([selectedLocaleIdentifier], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()

            // アプリを再起動する
            exit(0)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(restartAction)

        present(alertController, animated: true, completion: nil)

        // 選択が行われたらTableViewを再読み込みしてチェックマークを更新
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
