//
//  SettingsViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/10.
//

import UIKit

class SettingGoalViewController: UIViewController {
    let sections: [String] = [NSLocalizedString("SetGoal_Section_1", comment: ""),
                              NSLocalizedString("SetGoal_Section_2", comment: ""),
                              NSLocalizedString("SetGoal_Section_3", comment: "")]
    let cellsForEachSection: [[String]] = [
        [NSLocalizedString("SetGoal_Cell_1-1", comment: "")],
        [NSLocalizedString("SetGoal_Cell_2-1", comment: ""), NSLocalizedString("SetGoal_Cell_2-2", comment: "")],
        [NSLocalizedString("SetGoal_Cell_3-1", comment: "")]
    ]

    // MARK: - UI Elements
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = BACKGROUND_COLOR
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("SetGoal_Title", comment: "")
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(TextFieldTableCell.self, forCellReuseIdentifier: TextFieldTableCell.identifier)
        tableView.register(SwitchTableCell.self, forCellReuseIdentifier: SwitchTableCell.identifier)
        tableView.register(DetailLabelTableCell.self, forCellReuseIdentifier: DetailLabelTableCell.identifier)
        return tableView
    }()
    
    private let buttonSection_1: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .systemGray3
        button.addTarget(self, action: #selector(tappedButton_section1), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()

    private let buttonSection_2: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(tappedButton_section2), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    // Dialog
    private let showInfoView: ShowInfoView = {
        let dialog = ShowInfoView()
        return dialog
    }()
    private var createUserSetTranLogView: CreateUserSetTranLogView = {
        let dialog = CreateUserSetTranLogView()
        return dialog
    }()
    private var editUserSetTranLogView: EditUserSetTranLogView = {
        let dialog = EditUserSetTranLogView()
        return dialog
    }()
    
    private var category: Category

    // MARK: - View Lifecycle
    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Se_Title", comment: "")
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(topView)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // TopView
        topView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
        ])
        
        // Dialog
        showInfoView.delegate = self
        showInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        createUserSetTranLogView.setInit(category: self.category)
        createUserSetTranLogView.delegate = self
        createUserSetTranLogView.translatesAutoresizingMaskIntoConstraints = false
        
        editUserSetTranLogView.delegate = self
        editUserSetTranLogView.translatesAutoresizingMaskIntoConstraints = false

        // キーボードを閉じるためのジェスチャーを追加
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func getSectionLabel(section: Int) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemGray
        label.sizeToFit()
        label.text = sections[section]
        return label
    }
    
    // MARK: - Event
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func tappedButton_section1() {
        if let sheet = self.sheetPresentationController {
            sheet.animateChanges {
                sheet.selectedDetentIdentifier = .large
            }
        }
        
        showInfoView.alpha = 0
        self.view.addSubview(showInfoView)
        
        NSLayoutConstraint.activate([
            showInfoView.topAnchor.constraint(equalTo: self.view.topAnchor),
            showInfoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            showInfoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            showInfoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.showInfoView.alpha = 1.0
        }
    }
    
    @objc private func tappedButton_section2() {
        createUserSetTranLogView.alpha = 0
        self.view.addSubview(createUserSetTranLogView)
        
        NSLayoutConstraint.activate([
            createUserSetTranLogView.topAnchor.constraint(equalTo: self.view.topAnchor),
            createUserSetTranLogView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            createUserSetTranLogView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            createUserSetTranLogView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.createUserSetTranLogView.alpha = 1.0
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SettingGoalViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.category.repeat_flg {
            return 3
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60)
        
        let label = self.getSectionLabel(section: section)
        
        if section == 0 {
            headerView.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16)
            ])
        }
        if section == 1 {
            headerView.addSubview(label)
            headerView.addSubview(buttonSection_1)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            buttonSection_1.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                
                buttonSection_1.centerYAnchor.constraint(equalTo: label.centerYAnchor),
                buttonSection_1.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                buttonSection_1.heightAnchor.constraint(equalToConstant: 24),
                buttonSection_1.widthAnchor.constraint(equalToConstant: 24)
            ])
        }
        if section == 2 {
            headerView.addSubview(label)
            headerView.addSubview(buttonSection_2)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            buttonSection_2.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                
                buttonSection_2.centerYAnchor.constraint(equalTo: label.centerYAnchor),
                buttonSection_2.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                buttonSection_2.heightAnchor.constraint(equalToConstant: 24),
                buttonSection_2.widthAnchor.constraint(equalToConstant: 24)
            ])
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else if section == 1 {
            if self.category.repeat_flg {
                return 2
            } else {
                return 1
            }
        } else if section == 2 {
            if self.category.userSetTransferLogs.count == 0 {
                return 1
            }
            return self.category.userSetTransferLogs.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 50
        }
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableCell.identifier, for: indexPath) as! TextFieldTableCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.configure(labelText: cellsForEachSection[indexPath.section][indexPath.row], fieldValue: self.category.name, tag: 1)
            return cell
        }else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableCell.identifier, for: indexPath) as! SwitchTableCell
                cell.delegate = self
                cell.selectionStyle = .none
                cell.configure(labelText: cellsForEachSection[indexPath.section][indexPath.row], defSwitchState: self.category.repeat_flg, tag: 1)
                return cell
            } else if indexPath.row == 1 {
                let totalAmount = self.category.getTotalOfUserSetTransferLog()
                let cell = tableView.dequeueReusableCell(withIdentifier: DetailLabelTableCell.identifier, for: indexPath) as! DetailLabelTableCell
                cell.selectionStyle = .none
                cell.configure(labelText: cellsForEachSection[indexPath.section][indexPath.row]
                               , detailText: NSLocalizedString("Money", comment: "") + String(Int(totalAmount)))
                cell.titleLabel.textColor = .systemGray2
                cell.detailLabel.textColor = .systemGray2
                return cell
            }
        } else if indexPath.section == 2 {
            if self.category.userSetTransferLogs.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: DetailLabelTableCell.identifier, for: indexPath) as! DetailLabelTableCell
                cell.configure(labelText: cellsForEachSection[indexPath.section][indexPath.row], detailText: NSLocalizedString("Money", comment: "") + "0")
                cell.titleLabel.textColor = .systemGray2
                cell.detailLabel.textColor = .systemGray2
                return cell
            }
            let userSetTransferLog = self.category.userSetTransferLogs[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailLabelTableCell.identifier, for: indexPath) as! DetailLabelTableCell
            cell.configure(labelText: userSetTransferLog.title
                           , detailText: NSLocalizedString("Money", comment: "") + String(Int(userSetTransferLog.amount)))
            cell.titleLabel.textColor = .black
            cell.detailLabel.textColor = .black
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if self.category.userSetTransferLogs.count == 0 {
                createUserSetTranLogView.alpha = 0
                self.view.addSubview(createUserSetTranLogView)
                
                NSLayoutConstraint.activate([
                    createUserSetTranLogView.topAnchor.constraint(equalTo: self.view.topAnchor),
                    createUserSetTranLogView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    createUserSetTranLogView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    createUserSetTranLogView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
                
                navigationController?.setNavigationBarHidden(true, animated: true)
                self.tabBarController?.tabBar.isHidden = true
                
                UIView.animate(withDuration: 0.3) {
                    self.createUserSetTranLogView.alpha = 1.0
                }
            } else {
                let target = self.category.userSetTransferLogs[indexPath.row]
                editUserSetTranLogView.setInit(userSetTransferLog: target, category: self.category)
                editUserSetTranLogView.alpha = 0
                self.view.addSubview(editUserSetTranLogView)
                
                NSLayoutConstraint.activate([
                    editUserSetTranLogView.topAnchor.constraint(equalTo: self.view.topAnchor),
                    editUserSetTranLogView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    editUserSetTranLogView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    editUserSetTranLogView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
                
                navigationController?.setNavigationBarHidden(true, animated: true)
                self.tabBarController?.tabBar.isHidden = true
                
                UIView.animate(withDuration: 0.3) {
                    self.editUserSetTranLogView.alpha = 1.0
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (_, _, completion) in
            let target = self!.category.userSetTransferLogs[indexPath.row]
            UserSetTransferLogDao().deleteUserSEtTransferLog(userSetTransferLog: target)
            self?.tableView.reloadData()
        }
        
        let configuration: UISwipeActionsConfiguration!
        if indexPath.section == 1 && self.category.userSetTransferLogs.count > 0 {
            configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        } else {
            configuration = UISwipeActionsConfiguration(actions: [])
        }
    
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

extension SettingGoalViewController: TextFieldTableDelegate {
    func changedText(value: String, tag: Int) {
        if tag == 1 {
            if value != "" {
                CategoryDao().updateCategory(category: self.category, name: value)
            }
        }
    }
}

extension SettingGoalViewController: SwitchTableCellDelegate {
    func changedSwitch(value: Bool, tag: Int) {
        if tag == 1 {
            // Tag = '1'(Section: 0, Row: 0)
            CategoryDao().updateCategory(category: self.category, repeat_flg: value)
            tableView.reloadData()
        }
    }
}

// Mark: - DialogDelegate
extension SettingGoalViewController: ShowInfoViewDelegate {
    func closeButtonTapped() {
        self.showInfoView.removeFromSuperview()
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension SettingGoalViewController: CreateUserSetTranLogDelegate {
    func okButtonTapped_atCreateUserSetTranLog() {
        self.tableView.reloadData()
        
        self.createUserSetTranLogView.removeFromSuperview()
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func cancelButtonTapped_atCreateUserSetTranLog() {
        self.createUserSetTranLogView.removeFromSuperview()
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
}

extension SettingGoalViewController: EditUserSetTranLogDelegate {
    func okButtonTapped_atEditUserSetTranLog() {
        self.tableView.reloadData()
        
        self.editUserSetTranLogView.removeFromSuperview()
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func cancelButtonTapped_atEditUserSetTranLog() {
        self.editUserSetTranLogView.removeFromSuperview()
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = false
    }
}
