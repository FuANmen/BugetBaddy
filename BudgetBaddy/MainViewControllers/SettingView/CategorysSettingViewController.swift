//
//  CategorysSettingViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/23.
//

import UIKit
import RealmSwift

class CategorysSettingViewController: UIViewController {
    let sections: [String] = [NSLocalizedString("SeCa_Section_1", comment: ""),
                              NSLocalizedString("SeCa_Section_2", comment: "")]
    let categoryDao = CategoryDao()
    
    var userCategories: Results<Category>? = nil
    // MARK: - UI Elements

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.allowsSelection = false
        tableView.register(CategorysSettingViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("SeCa_Title", comment: "")
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

extension CategorysSettingViewController: UITableViewDataSource, UITableViewDelegate, CategorysSettingViewCellDelegate {
    
    func saveButtonTapped(in cell: CategorysSettingViewCell, name: String) {
        categoryDao.updateCategory(category: cell.category!, name: name)
        
        cell.didSave()
        
        let alertController = UIAlertController(title: NSLocalizedString("Se_Success", comment: ""), message: "", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            userCategories = categoryDao.getCategories().filter("category_type_div == 0")
            return userCategories?.count ?? 0
        case 1:
            return 2
        default :
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CategorysSettingViewCell
        cell.delegate = self
        switch indexPath.section {
        case 0:
            cell.configure(with: userCategories![indexPath.row])
        case 1:
            if indexPath.row == 0 {
                cell.configure(with: categoryDao.getOrCreateTotalCategory())
            } else if indexPath.row == 1 {
                cell.configure(with: categoryDao.getOrCreateOtherCategory())
            }
        default :
            break
        }
        return cell
    }
}
