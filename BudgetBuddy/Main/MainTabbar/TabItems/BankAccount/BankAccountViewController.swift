//
//  BankAccountViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/03/02.
//

import UIKit
import RealmSwift

class BankAccountViewController: UIViewController {
    private let goalDao: GoalDao = GoalDao()
    private let breakdownDao: BreakdownDao = BreakdownDao()
    private let dateFuncs: DateFuncs = DateFuncs()
    private let sectionTitles: [String] = [NSLocalizedString("各月の繰越し", comment: ""),
                                   NSLocalizedString("", comment: "")]
    
    // 今月
    private var current: String = ""
    // 今月振替
    private var thisMonthBreakdowns: [Breakdown] = []
    // 毎月繰越
    private var yearth: [String] = []
    private var monthryCarryForwardGoals: [[Goal]] = []
    // 合計
    private var totalBalance: Double = 0.0
    
    // タップされたセルの高さを保持する変数
    private var selectedIndexPath: IndexPath?
    
    // TOP
    private let topViewHeight: CGFloat = 70
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 9
        return view
    }()
    
    private let label_title: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("TotalBalance", comment: "") + ":"
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        label.textColor = .systemGray2
        return label
    }()
    
    private let label_balance: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        label.textColor = .systemGray2
        return label
    }()
    
    // TABLE
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(CarryForwardCell.self, forCellReuseIdentifier: CarryForwardCell.identifier)
        tableView.backgroundColor = BACKGROUND_COLOR
        tableView.sectionHeaderTopPadding = 0
        tableView.tableFooterView = UIView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = BACKGROUND_COLOR
        
        // navigation
        self.navigationController?.navigationBar.backgroundColor = NAVIGATION_BACK_COLOR
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        updateShowData()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateShowData()
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame {
            let statusBarView = UIView(frame: statusBarFrame)
            statusBarView.backgroundColor = NAVIGATION_BACK_COLOR
            view.addSubview(statusBarView)
        }
    }
    
    private func updateShowData() {
        yearth = []
        monthryCarryForwardGoals = []
        totalBalance = 0
        
        let str = UserDefaults.standard.object(forKey: "firstLaunchDate") as! String
        let firstLaunchDate: Date? = dateFuncs.convertStringToDate(str, format: "yyyy-MM")
        self.current = dateFuncs.convertStringFromDate(Date(), format: NSLocalizedString("yyyy-MM", comment: ""))
        
        // 今月の振替
        thisMonthBreakdowns = breakdownDao.getMonthryTransferOfBreakdowns(targetMonth: current)
        thisMonthBreakdowns.forEach { breakdown in
            self.totalBalance -= breakdown.amount
        }
        
        // 過去の繰越
        var idx = 0
        while true {
            let targetMonthDate = Calendar.current.date(byAdding: .month, value: idx, to: firstLaunchDate!)
            let targetMonth: String = dateFuncs.convertStringFromDate(targetMonthDate!, format: "yyyy-MM")
            if targetMonth == current {
                break
            }
            // 年
            let year = String(targetMonth.prefix(4))
            if yearth.count == 0 || year != yearth[0] {
                yearth.insert(year, at: 0)
                monthryCarryForwardGoals.insert([], at: 0)
            }
            
            UpdateGoals(targetMonth: targetMonth)
            // 繰越
            let goal: Goal! = goalDao.getTotalGoal(targetMonth: targetMonth)!
            let balance: Double! = goal.getAmount() + goal.getTransactionsAmountSum()
            monthryCarryForwardGoals[0].insert(goal, at: 0)
            self.totalBalance += balance
            
            idx += 1
        }
        
        self.label_balance.text = formatCurrency(amount: self.totalBalance)
    }
    
    private func setupViews() {
        view.addSubview(topView)
        view.addSubview(tableView)
        topView.addSubview(label_title)
        topView.addSubview(label_balance)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        label_title.translatesAutoresizingMaskIntoConstraints = false
        label_balance.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            topView.heightAnchor.constraint(equalToConstant: topViewHeight),
            
            tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // TOP VIEW
            label_title.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            label_title.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 32),
            
            label_balance.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            label_balance.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -16)
        ])
    }
}

extension BankAccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return thisMonthBreakdowns.count > 0 ? yearth.count + 1 : yearth.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)

        let title = UILabel()
        if thisMonthBreakdowns.count > 0 && section == 0 {
            title.text = current
        } else {
            title.text = yearth[thisMonthBreakdowns.count > 0 ? section - 1 : section] + NSLocalizedString("Year", comment: "")
        }
        title.font = UIFont.systemFont(ofSize: 24, weight: .light)
        title.textColor = .white
        title.sizeToFit()
        headerView.addSubview(title)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -4).isActive = true
        title.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24).isActive = true

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if thisMonthBreakdowns.count > 0 && section == 0 {
            return thisMonthBreakdowns.count
        } else {
            return monthryCarryForwardGoals[thisMonthBreakdowns.count > 0 ? section - 1 : section].count
        }
    }
    
    // セルの高さを指定するメソッド
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // タップされたセルの場合は高さを大きくし、それ以外の場合はデフォルトの高さを返す
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
            return CarryForwardCell.selectedHeight
        } else {
            return CarryForwardCell.defaultHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if thisMonthBreakdowns.count > 0 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.text = thisMonthBreakdowns[indexPath.row].title
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CarryForwardCell.identifier, for: indexPath) as! CarryForwardCell
            cell.selected(selected: selectedIndexPath == indexPath)
            cell.configure(goal: monthryCarryForwardGoals[thisMonthBreakdowns.count > 0 ? indexPath.section - 1 : indexPath.section][indexPath.row])
            cell.delegate = self
            return cell
        }
    }
    
    // セルが選択されたときに呼ばれるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beforeIndexPath: IndexPath? = selectedIndexPath
        if selectedIndexPath == indexPath {
            // もう一度同じセルがタップされた場合、セルの高さを元に戻す
            selectedIndexPath = nil
        } else {
            // タップされたセルのindexPathを保存して、セルの高さを変更する
            selectedIndexPath = indexPath
        }
        
        // タップされたセルの高さを更新する
        if beforeIndexPath == nil {
            tableView.reloadRows(at: [indexPath], with: .fade)
        } else {
            tableView.reloadRows(at: [beforeIndexPath!,indexPath], with: .fade)
        }
    }
}

extension BankAccountViewController: CarryForwardCellDelegate {
    func showDetail(targetMonth: String?) {
        self.tabBarController?.selectedIndex = 2
    }
}
