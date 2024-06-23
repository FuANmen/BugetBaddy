//
//  GoalAlertSettingViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/13.
//


import UIKit

class GoalAlertSettingViewController: UIViewController {
    let sections: [String] = [NSLocalizedString("GoAlertSet_Section_1", comment: "")]
    let cellsForEachSection: [[String]] = [
        [NSLocalizedString("GoAlertSet_Cell_1-1", comment: "")]
    ]

    // MARK: - UI Elements
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = BACKGROUND_COLOR
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("GoAlertSet_Title", comment: "")
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(SwitchTableCell.self, forCellReuseIdentifier: SwitchTableCell.identifier)
        tableView.register(DetailLabelTableCell.self, forCellReuseIdentifier: DetailLabelTableCell.identifier)
        return tableView
    }()
    
    private var goal: Goal

    // MARK: - View Lifecycle
    init(goal: Goal) {
        self.goal = goal
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    private func getSectionLabel(section: Int) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .systemGray
        label.sizeToFit()
        label.text = sections[section]
        return label
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension GoalAlertSettingViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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

        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableCell.identifier, for: indexPath) as! SwitchTableCell
            cell.configure(labelText: NSLocalizedString("GoAlertSet_Cell_1-1", comment: ""), defSwitchState: self.goal.alert_flg, tag: 1)
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension GoalAlertSettingViewController: SwitchTableCellDelegate {
    func changedSwitch(value: Bool, tag: Int) {
        if tag == 1 {
            // Tag = '1'(Section: 0, Row: 0)
            GoalDao().updateGoal(goal: self.goal, alert_flg: value)
            tableView.reloadData()
        }
    }
}
