//
//  TransactionViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/06.
//

import UIKit
import Charts

protocol GoalDetailViewDelegate: AnyObject {
    func didUpdateTransactions(transactions: [Transaction])
    func didUpdateCategories(categories: [Category])
}

class GoalDetailViewController: UIViewController {    
    weak var delegate: GoalDetailViewDelegate?

    private var targetMonth: String
    private var wallet: Wallet
    private var category: Category
    private var goal: Goal
    private var transactions: [Transaction]
    
    // Navigation
    private let menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(menuButtonTapped))
        return button
    }()
    
    private let whitespace: CGFloat = 50
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    // Barance
    private let balanceViewHeaderHeight: CGFloat = 100
    private let balanceView: UIView = {
        let view = UIView()
        view.backgroundColor = .sectionBackColor
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 2
        return view
    }()
    
    private let titleIcon: UIImageView = {
        let icon = UIImageView()
        icon.setSymbolImage(UIImage(systemName: "dollarsign")!, contentTransition: .automatic)
        icon.tintColor = .customMediumSeaGreen
        return icon
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .customMediumSeaGreen
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    private let todayView: UIView = {
        let view = UIView()
        return view
    }()
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Remain", comment: "")
        label.textColor = .customDarkGray
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    private let balanceValue: UILabel = {
        let label = UILabel()
        label.textColor = .customMediumSeaGreen
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let targetDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .customDarkGrayLight4
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let selectedDayView: UIView = {
        let view = UIView()
        view.alpha = 0.0
        return view
    }()
    private let selectedDayBalanceLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Remain", comment: "")
        label.textColor = .customDarkGray
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    private let selectedDayBalanceValue: UILabel = {
        let label = UILabel()
        label.textColor = .customMediumSeaGreen
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let selectedDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .customDarkGrayLight4
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    private let selectedDayViewIcon: UIImageView = {
        let icon = UIImageView()
        icon.tintColor = .customMediumSeaGreen
        return icon
    }()
    
    // LineChartView
    private let lineChartHeight: CGFloat = 120
    private let lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .sectionBackColor
        chartView.layer.masksToBounds = true
        chartView.layer.cornerRadius = 9
        chartView.chartDescription.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.rightAxis.enabled = false
        return chartView
    }()
    
    // TransferLog
    private let amountViewHeight: CGFloat = 60
    private var amountViewHeightAnchor: NSLayoutConstraint?
    private let amountView: UIView = {
        let view = UIView()
        view.backgroundColor = .sectionBackColor
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        return view
    }()
    
    private let openAndCloseAmountAriaBtn: UIButton = {
        let button = UIButton()
        button.tintColor = .systemBlue
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.addTarget(self, action: #selector(openAndCloseAmountBtnTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Budget", comment: "") + " :"
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    private let amountValue: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        return label
    }()
    
    private let transLogsTableAriaHeaderHeight: CGFloat = 40
    private let transLogsTableAriaBottomHeight: CGFloat = 20
    private var transferLogsTableAriaHeightAnchor: NSLayoutConstraint?
    private let transferLogsTableAria: UIView = {
        let view = UIView()
        view.alpha = 0.0
        return view
    }()
    
    private let tranLogsAriaLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Breakdown", comment: "")
        label.textColor = .customDarkGray
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        return label
    }()
    
    private let addTransferLogButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .customDarkGray
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    // Expense
    private let expenseViewHeight: CGFloat = 60
    private var expenseViewHeightAnchor: NSLayoutConstraint?
    private let expenseView: UIView = {
        let view = UIView()
        view.backgroundColor = .sectionBackColor
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        return view
    }()
    
    private let expenseLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("TotalExpenses", comment: "") + " :"
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    private let expenseValue: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        return label
    }()
    
    private let transactionsViewHeaderHeight: CGFloat = 40
    private let transactionsViewBottomHeight: CGFloat = 20
    private var transactionsViewHeightAnchor: NSLayoutConstraint?
    private let transactionsView: UIView = {
        let view = UIView()
        view.alpha = 1.0
        return view
    }()
    
    private let transactionsLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Breakdown", comment: "")
        label.textColor = .customDarkGray
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        return label
    }()
    
    private let addTransactionButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(addTransactionButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .customDarkGray
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private let transactionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.tag = 1
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.isScrollEnabled = false
        tableView.layer.masksToBounds = false
        tableView.layer.shadowColor = UIColor.systemGray2.cgColor
        tableView.layer.shadowOffset = CGSize(width: 0, height: -1)
        tableView.layer.shadowOpacity = 0.4
        tableView.layer.shadowRadius = 2
        return tableView
    }()
    
    // Dialog
    private var deleteGoalView: DeleteGoalView = {
        let dialog = DeleteGoalView()
        dialog.translatesAutoresizingMaskIntoConstraints = false
        return dialog
    }()
    
    init(targetMonth: String, wallet: Wallet, goal: Goal, category: Category, transactions: [Transaction]) {
        self.targetMonth = targetMonth
        self.wallet = wallet
        self.goal = goal
        self.category = category
        self.transactions = transactions

        super.init(nibName: nil, bundle: nil)
        
        updateValues()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // NavigationBarの背景色とタイトルの色を設定
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.buttonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        // navigation
        self.navigationItem.title = self.category.name
        
        self.addGradientBackground()

        setupUI()
        
        setupChartData()
    }
    
    // BACKGROUND
    private func addGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.backGradientColorFrom.cgColor, UIColor.backGradientColorTo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.6, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // 既存のレイヤーの後ろにグラデーションレイヤーを追加
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupUI() {
        // Value
        titleLabel.text = self.category.name
        targetDateLabel.text = DateFuncs().convertStringFromDate(Date(), format: "yyyy/MM/dd")
        
        view.addSubview(scrollView)
        scrollView.addSubview(amountView)
        scrollView.addSubview(balanceView)
        scrollView.addSubview(expenseView)
        
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        
        amountView.translatesAutoresizingMaskIntoConstraints = false
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        expenseView.translatesAutoresizingMaskIntoConstraints = false
        
        amountViewHeightAnchor = amountView.heightAnchor.constraint(equalToConstant: amountViewHeight)
        expenseViewHeightAnchor = expenseView.heightAnchor.constraint(equalToConstant: expenseViewHeight)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            balanceView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            balanceView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            balanceView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            amountView.topAnchor.constraint(equalTo: balanceView.bottomAnchor, constant: 16),
            amountView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            amountView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            amountViewHeightAnchor!,
            
            expenseView.topAnchor.constraint(equalTo: amountView.bottomAnchor, constant: 24),
            expenseView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            expenseView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            expenseViewHeightAnchor!
        ])
        
        // BALANCE
        balanceView.addSubview(titleIcon)
        balanceView.addSubview(titleLabel)
        balanceView.addSubview(todayView)
        balanceView.addSubview(selectedDayView)
        
        todayView.addSubview(balanceLabel)
        todayView.addSubview(balanceValue)
        todayView.addSubview(targetDateLabel)
        
        selectedDayView.addSubview(selectedDayBalanceLabel)
        selectedDayView.addSubview(selectedDayBalanceValue)
        selectedDayView.addSubview(selectedDateLabel)
        selectedDayView.addSubview(selectedDayViewIcon)
        
        balanceView.addSubview(lineChartView)
        
        lineChartView.delegate = self
        
        titleIcon.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        todayView.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceValue.translatesAutoresizingMaskIntoConstraints = false
        targetDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        selectedDayView.translatesAutoresizingMaskIntoConstraints = false
        selectedDayBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedDayBalanceValue.translatesAutoresizingMaskIntoConstraints = false
        selectedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedDayViewIcon.translatesAutoresizingMaskIntoConstraints = false
        
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleIcon.topAnchor.constraint(equalTo: balanceView.topAnchor, constant: 12),
            titleIcon.leadingAnchor.constraint(equalTo: balanceView.leadingAnchor, constant: 16),
            
            titleLabel.centerYAnchor.constraint(equalTo: titleIcon.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleIcon.trailingAnchor, constant: 4),
            
            todayView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            todayView.leadingAnchor.constraint(equalTo: balanceView.centerXAnchor),
            todayView.trailingAnchor.constraint(equalTo: balanceView.trailingAnchor),
            todayView.bottomAnchor.constraint(equalTo: balanceView.topAnchor, constant: balanceViewHeaderHeight),
            
            selectedDayView.topAnchor.constraint(equalTo: todayView.topAnchor),
            selectedDayView.leadingAnchor.constraint(equalTo: balanceView.leadingAnchor),
            selectedDayView.trailingAnchor.constraint(equalTo: todayView.leadingAnchor),
            selectedDayView.bottomAnchor.constraint(equalTo: todayView.bottomAnchor),
            
            lineChartView.topAnchor.constraint(equalTo: balanceView.topAnchor, constant: balanceViewHeaderHeight),
            lineChartView.leadingAnchor.constraint(equalTo: balanceView.leadingAnchor, constant: 4),
            lineChartView.trailingAnchor.constraint(equalTo: balanceView.trailingAnchor, constant: -4),
            lineChartView.heightAnchor.constraint(equalToConstant: lineChartHeight),
            lineChartView.bottomAnchor.constraint(equalTo: balanceView.bottomAnchor, constant: -8),
            
            // TODAY
            balanceLabel.leadingAnchor.constraint(equalTo: todayView.leadingAnchor, constant: 4),
            balanceLabel.centerYAnchor.constraint(equalTo: balanceValue.topAnchor),
            
            balanceValue.bottomAnchor.constraint(equalTo: targetDateLabel.topAnchor, constant: 2),
            balanceValue.leadingAnchor.constraint(equalTo: balanceLabel.trailingAnchor),
            balanceValue.trailingAnchor.constraint(equalTo: targetDateLabel.trailingAnchor),
            
            targetDateLabel.trailingAnchor.constraint(equalTo: todayView.trailingAnchor, constant: -24),
            targetDateLabel.bottomAnchor.constraint(equalTo: todayView.bottomAnchor),
            
            // SELECTED DAY
            selectedDayBalanceLabel.leadingAnchor.constraint(equalTo: selectedDayView.leadingAnchor, constant: 12),
            selectedDayBalanceLabel.centerYAnchor.constraint(equalTo: selectedDayBalanceValue.topAnchor),
            
            selectedDayBalanceValue.bottomAnchor.constraint(equalTo: selectedDateLabel.topAnchor, constant: 2),
            selectedDayBalanceValue.leadingAnchor.constraint(equalTo: selectedDayBalanceLabel.trailingAnchor),
            selectedDayBalanceValue.trailingAnchor.constraint(equalTo: selectedDateLabel.trailingAnchor),
            
            selectedDateLabel.trailingAnchor.constraint(equalTo: selectedDayViewIcon.leadingAnchor, constant: -8),
            selectedDateLabel.bottomAnchor.constraint(equalTo: selectedDayView.bottomAnchor),
            
            selectedDayViewIcon.centerYAnchor.constraint(equalTo: selectedDayBalanceValue.centerYAnchor),
            selectedDayViewIcon.heightAnchor.constraint(equalToConstant: 16),
            selectedDayViewIcon.widthAnchor.constraint(equalToConstant: 16)
        ])
        
        // Amount
        amountView.addSubview(amountLabel)
        amountView.addSubview(amountValue)
        amountView.addSubview(transferLogsTableAria)
        amountView.addSubview(openAndCloseAmountAriaBtn)
        transferLogsTableAria.addSubview(addTransferLogButton)
        transferLogsTableAria.addSubview(tranLogsAriaLabel)
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountValue.translatesAutoresizingMaskIntoConstraints = false
        transferLogsTableAria.translatesAutoresizingMaskIntoConstraints = false
        openAndCloseAmountAriaBtn.translatesAutoresizingMaskIntoConstraints = false
        
        addTransferLogButton.translatesAutoresizingMaskIntoConstraints = false
        tranLogsAriaLabel.translatesAutoresizingMaskIntoConstraints = false
        
        transferLogsTableAriaHeightAnchor = transferLogsTableAria.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            openAndCloseAmountAriaBtn.centerYAnchor.constraint(equalTo: amountView.topAnchor, constant: amountViewHeight / 2),
            openAndCloseAmountAriaBtn.leadingAnchor.constraint(equalTo: amountView.leadingAnchor, constant: 12),
            openAndCloseAmountAriaBtn.widthAnchor.constraint(equalToConstant: 24),
            openAndCloseAmountAriaBtn.heightAnchor.constraint(equalToConstant: 24),
            
            amountLabel.centerYAnchor.constraint(equalTo: amountView.topAnchor, constant: amountViewHeight / 2),
            amountLabel.leadingAnchor.constraint(equalTo: openAndCloseAmountAriaBtn.trailingAnchor, constant: 12),
            
            amountValue.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
            amountValue.trailingAnchor.constraint(equalTo: amountView.trailingAnchor, constant: -24),
            
            transferLogsTableAria.bottomAnchor.constraint(equalTo: amountView.bottomAnchor, constant: -transLogsTableAriaBottomHeight),
            transferLogsTableAria.leadingAnchor.constraint(equalTo: amountView.leadingAnchor, constant: 32),
            transferLogsTableAria.trailingAnchor.constraint(equalTo: amountView.trailingAnchor, constant: -32),
            transferLogsTableAriaHeightAnchor!
        ])
        
        // EXPENSE
        expenseView.addSubview(expenseLabel)
        expenseView.addSubview(expenseValue)
        expenseView.addSubview(transactionsView)
        transactionsView.addSubview(transactionsLabel)
        transactionsView.addSubview(addTransactionButton)
        transactionsView.addSubview(transactionsTableView)
        
        expenseLabel.translatesAutoresizingMaskIntoConstraints = false
        expenseValue.translatesAutoresizingMaskIntoConstraints = false
        transactionsView.translatesAutoresizingMaskIntoConstraints = false
        
        transactionsLabel.translatesAutoresizingMaskIntoConstraints = false
        addTransactionButton.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        transactionsViewHeightAnchor = transactionsView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            expenseLabel.centerYAnchor.constraint(equalTo: expenseView.topAnchor, constant: expenseViewHeight / 2),
            expenseLabel.leadingAnchor.constraint(equalTo: expenseView.leadingAnchor, constant: 12),
            
            expenseValue.centerYAnchor.constraint(equalTo: expenseView.topAnchor, constant: expenseViewHeight / 2),
            expenseValue.trailingAnchor.constraint(equalTo: expenseView.trailingAnchor, constant: -24),
            
            transactionsView.bottomAnchor.constraint(equalTo: expenseView.bottomAnchor, constant: -transactionsViewBottomHeight),
            transactionsView.leadingAnchor.constraint(equalTo: expenseView.leadingAnchor, constant: 32),
            transactionsView.trailingAnchor.constraint(equalTo: expenseView.trailingAnchor, constant: -32),
            transactionsViewHeightAnchor!,
            
            transactionsLabel.centerYAnchor.constraint(equalTo: transactionsView.topAnchor, constant: transactionsViewHeaderHeight / 2),
            transactionsLabel.leadingAnchor.constraint(equalTo: transactionsTableView.leadingAnchor, constant: 4),
            
            addTransactionButton.centerYAnchor.constraint(equalTo: transactionsLabel.centerYAnchor),
            addTransactionButton.trailingAnchor.constraint(equalTo: transactionsTableView.trailingAnchor, constant: -4),
            
            transactionsTableView.topAnchor.constraint(equalTo: transactionsView.topAnchor, constant: transactionsViewHeaderHeight),
            transactionsTableView.leadingAnchor.constraint(equalTo: transactionsView.leadingAnchor),
            transactionsTableView.trailingAnchor.constraint(equalTo: transactionsView.trailingAnchor),
            transactionsTableView.bottomAnchor.constraint(equalTo: transactionsView.bottomAnchor, constant: -8)
        ])
        
        // DIALOG
        deleteGoalView.delegate = self
    }
    
    private func getBalance() -> Double {
        var expence = 0.0
        self.transactions.forEach { trans in
            expence += trans.amount
        }
        return self.goal.budget - expence
    }
    
    private func getExpense() -> Double {
        var expence = 0.0
        self.transactions.forEach { trans in
            expence += trans.amount
        }
        return expence
    }
    
    private func updateValues() {
        amountValue.text = formatCurrency(amount: self.goal.budget)
        
        let balance = getBalance()
        balanceValue.text = formatCurrency(amount: balance)
        if(balance < 0) {
            balanceValue.textColor = .systemRed
        } else {
            balanceValue.textColor = .systemGreen
        }
        updateChartData()
    }
    
    private func loadTransactions() {
        let transViewHeight = self.transactions.count == 0 ? 0.0 : TransactionTableViewCell.cellHeight * CGFloat(self.transactions.count) + transactionsViewHeaderHeight
        let transBtnImage = transViewHeight == 0.0 ? UIImage(systemName: "chevron.down") : UIImage(systemName: "chevron.up")
        self.transactionsView.alpha = transViewHeight == 0.0 ? 0.0 : 1.0
        UIView.animate(withDuration: 0, animations: { [self] in
            self.transactionsViewHeightAnchor!.constant = transViewHeight
            self.expenseViewHeightAnchor!.constant = transViewHeight == 0.0 ? self.expenseViewHeight : transViewHeight + self.expenseViewHeight + self.transactionsViewBottomHeight
            self.balanceValue.text = formatCurrency(amount: self.getBalance())
            self.expenseValue.text = formatCurrency(amount: self.getExpense())
            self.view.layoutIfNeeded()
        }, completion: { [self] finish in
            transactionsTableView.reloadData()

            let contentHeight: CGFloat = max(self.view.frame.height + 100, transactionsView.frame.maxY  + 100)
            scrollView.contentSize = CGSize(width: view.frame.width, height: contentHeight)
        })
    }
    
    private func setupChartData() {
        var dataEntries: [ChartDataEntry] = []

        // Here you can add your data points. For example:
        var values: [Double] = []
        var valueOfDay = self.goal.budget
        for idx in 1...DateFuncs.numberOfDaysInMonth(yearMonth: self.targetMonth)! {
            let dayStr = String(format: "%02d", idx)
            var dayTrans: [Transaction] = []
            self.transactions.forEach { trans in
                if DateFuncs().convertStringFromDate(trans.date, format: "yyyy-MM-dd") == self.targetMonth + "-" + dayStr {
                    valueOfDay -= trans.amount
                    dayTrans.append(trans)
                }
            }
            values.append(valueOfDay)
        }
        
        for (index, value) in values.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(index), y: value)
            dataEntries.append(dataEntry)
        }

        // 説明
        lineChartView.chartDescription.enabled = true
        lineChartView.chartDescription.text = ""
        lineChartView.chartDescription.font = UIFont.systemFont(ofSize: 14)
        lineChartView.chartDescription.textColor = .systemGray
        // データセット
        let lineDataSet = LineChartDataSet(entries: dataEntries, label: "Sample Data")
        lineDataSet.colors = [.systemGreen]
//        lineDataSet.circleColors = [self.imageColor]
//        lineDataSet.circleRadius = 1
        lineDataSet.drawCirclesEnabled = false
        lineDataSet.lineWidth = 1.0
        lineDataSet.mode = .horizontalBezier
        lineDataSet.drawValuesEnabled = false
        
        let lineChartData = LineChartData(dataSet: lineDataSet)
        lineChartView.data = lineChartData
        // グラフの線の下に色をつける設定
        lineDataSet.drawFilledEnabled = true
        lineDataSet.fillColor = .systemGreen
        // X軸
        print(values.count)
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.axisMinimum = 1.0
        lineChartView.xAxis.labelTextColor = .customDarkGray
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.axisLineColor = .black
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelCount = values.count + 1
        lineChartView.xAxis.valueFormatter = CustomXAxisFormatter(targetMonth: self.targetMonth)
        // Y軸
        lineChartView.leftAxis.axisMinimum = values.min()! >= 0 ? 0 : 10000.0 * Double(floor(values.min()! / 10000.0))
        lineChartView.leftAxis.axisMaximum = self.goal.budget
        lineChartView.leftAxis.drawZeroLineEnabled = true
        lineChartView.leftAxis.labelCount = 4
        lineChartView.leftAxis.labelTextColor = .customDarkGray
        lineChartView.leftAxis.zeroLineColor = .customDarkGray
        lineChartView.leftAxis.valueFormatter = CustomYAxisFormatter()
        
        lineChartView.rightAxis.enabled = false
        // 凡例
        lineChartView.legend.enabled = false
        // 余白
        lineChartView.setExtraOffsets(left: 4, top: 4, right: 12, bottom: 4)
        // インタラクション
        lineChartView.scaleYEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.highlightPerDragEnabled = true
        lineChartView.highlightPerTapEnabled = true
        // アニメーション
        // lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 0.0, easingOption: .linear)
        
        // 更新
        lineChartView.notifyDataSetChanged()
    }
    
    private func updateChartData() {
        var dataEntries: [ChartDataEntry] = []
        
        // Here you can add your data points. For example:
        var values: [Double] = []
        var valueOfDay = self.goal.budget
        for idx in 1...DateFuncs.numberOfDaysInMonth(yearMonth: self.targetMonth)! {let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dayStr = String(format: "%02d", idx)
            var dayTrans: [Transaction] = []
            self.transactions.forEach { trans in
                if DateFuncs().convertStringFromDate(trans.date, format: "yyyy-MM-dd") == self.targetMonth + "-" + dayStr {
                    valueOfDay -= trans.amount
                    dayTrans.append(trans)
                }
            }
            values.append(valueOfDay)
        }
        
        for (index, value) in values.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(index), y: value)
            dataEntries.append(dataEntry)
        }
        
        // 説明
        lineChartView.chartDescription.text = ""
        // データセット
        let lineDataSet = LineChartDataSet(entries: dataEntries, label: "Sample Data")
        lineDataSet.colors = [.systemGreen]
        //        lineDataSet.circleColors = [NSUIColor.systemBlue]
        //        lineDataSet.circleRadius = 0
        lineDataSet.drawCirclesEnabled = false
        lineDataSet.lineWidth = 1.0
        lineDataSet.mode = .horizontalBezier
        lineDataSet.drawValuesEnabled = false
        
        let lineChartData = LineChartData(dataSet: lineDataSet)
        lineChartView.data = lineChartData
        // グラフの線の下に色をつける設定
        lineDataSet.drawFilledEnabled = true
        lineDataSet.fillColor = .systemGreen
        // Y軸
        lineChartView.leftAxis.axisMinimum = values.min()! >= 0 ? 0 : 10000.0 * Double(floor(values.min()! / 10000.0))
        lineChartView.leftAxis.axisMaximum = self.goal.budget
        
        // 更新
        lineChartView.notifyDataSetChanged()
    }
    
    private func updateAndRefreshChart() {
        updateChartData()
        lineChartView.notifyDataSetChanged()
    }
    
    // MARK: - Action
    @objc private func menuButtonTapped() {
        // メニューのアクションを作成
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // アクション
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [self] (action) in
            self.deleteGoalView.setInit(goal: self.goal)
            self.deleteGoalView.alpha = 0
            self.view.addSubview(deleteGoalView)
            NSLayoutConstraint.activate([
                self.deleteGoalView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.deleteGoalView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.deleteGoalView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.deleteGoalView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.tabBarController?.tabBar.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.deleteGoalView.alpha = 1.0
            }
        }
        // アクションを追加
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        // アラートコントローラを表示
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func deleteGoalTapped() {
    }
    
    @objc private func openAndCloseAmountBtnTapped() {
        if transferLogsTableAriaHeightAnchor!.constant == 0 {
            UIView.animate(withDuration: 0.3, animations: { [self] in
                let tableAriaHeight: CGFloat = transLogsTableAriaHeaderHeight
                self.transferLogsTableAriaHeightAnchor!.constant = tableAriaHeight
                self.amountViewHeightAnchor!.constant = tableAriaHeight + self.amountViewHeight + self.transLogsTableAriaBottomHeight
                self.openAndCloseAmountAriaBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                self.view.layoutIfNeeded()
            }, completion: { [self] finished in
                UIView.animate(withDuration: 0.2) {
                    self.transferLogsTableAria.alpha = 1.0
                }
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.transferLogsTableAria.alpha = 0.0
            }, completion: { [self] finished in
                UIView.animate(withDuration: 0.3) { [self] in
                    self.transferLogsTableAriaHeightAnchor!.constant = 0
                    self.amountViewHeightAnchor!.constant = amountViewHeight
                    self.openAndCloseAmountAriaBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                    self.view.layoutIfNeeded()
                }
            })
        }
    }
    
    @objc private func openAndCloseExpenseBtnTapped() {
        if transactionsViewHeightAnchor!.constant == 0 {
            UIView.animate(withDuration: 0.3, animations: { [self] in
                let transViewHeight: CGFloat = CGFloat(transactions.count) * TransactionTableViewCell.cellHeight + transactionsViewHeaderHeight
                self.transactionsViewHeightAnchor!.constant = transViewHeight
                self.expenseViewHeightAnchor!.constant = transViewHeight + self.expenseViewHeight + self.transactionsViewBottomHeight
                self.view.layoutIfNeeded()
            }, completion: { [self] finished in
                UIView.animate(withDuration: 0.2) {
                    self.transactionsView.alpha = 1.0
                }
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.transactionsView.alpha = 0.0
            }, completion: { [self] finished in
                UIView.animate(withDuration: 0.3) { [self] in
                    self.transactionsViewHeightAnchor!.constant = 0
                    self.expenseViewHeightAnchor!.constant = amountViewHeight
                    self.view.layoutIfNeeded()
                }
            })
        }
    }
    
    @objc private func addTransactionButtonTapped() {
        let createTransactionView = TransactionEditorViewController(wallet: self.wallet, targetMonth: self.targetMonth, transaction: nil)
        createTransactionView.delegate = self
        present(createTransactionView, animated: true, completion: nil)
    }
    
    // MARK: - Gesture
    @objc private func closeAmountAria() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transferLogsTableAria.alpha = 0.0
        }, completion: { [self] finished in
            UIView.animate(withDuration: 0.4) { [self] in
                self.transferLogsTableAriaHeightAnchor!.constant = 0
                self.amountViewHeightAnchor!.constant = amountViewHeight
                self.openAndCloseAmountAriaBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                self.view.layoutIfNeeded()
            }
        })
    }
}

extension GoalDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionTableViewCell.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
        cell.configure(with: transactions[indexPath.row], categoryName: self.category.name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showEditDialog(transaction: transactions[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.showDeleteAlert(at: self!.transactions[indexPath.row])
            completion(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func showDeleteAlert(at transaction: Transaction) {
        let alert = UIAlertController(title: "Delete Transaction", message: "Are you sure you want to delete this transaction?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            if let index = self!.transactions.firstIndex(where: { $0.id == transaction.id }) {
                self!.transactions.remove(at: index)
                MonthlyTransactionsDao.removeTransactionFromMonthlyTransactions(walletId: self!.wallet.walletId,
                                                                                targetMonth: self!.targetMonth,
                                                                                transactionToRemove: transaction)
                self!.loadTransactions()
                self!.updateAndRefreshChart()
                self!.delegate!.didUpdateTransactions(transactions: self!.transactions)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }

    private func showEditDialog(transaction: Transaction) {
        let createTransactionView = TransactionEditorViewController(wallet: self.wallet, targetMonth: self.targetMonth, transaction: transaction)
        createTransactionView.delegate = self
        present(createTransactionView, animated: true, completion: nil)
    }
}

// MARK: - ABOUT LINECHART
// カスタムX軸フォーマッター
class CustomXAxisFormatter: IndexAxisValueFormatter {
    private var daysNum: Int
    
    init(targetMonth: String) {
        daysNum = DateFuncs.numberOfDaysInMonth(yearMonth: targetMonth)!
        super.init()
    }
    
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var day = Int(value)
        if day == 1 || day % 5 == 0 {
            if day == self.daysNum - 1 {
                day = self.daysNum
            }
            return String(day) + NSLocalizedString("Day", comment: "")
        } else {
            return ""
        }
    }
}

// カスタムY軸フォーマッター
class CustomYAxisFormatter: IndexAxisValueFormatter {
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(value / 10000)\(NSLocalizedString("Money_2", comment: ""))"
    }
}

extension GoalDetailViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let selectedDate: String = String(format: "%02d", Int(entry.x) + 1)
        let selectedDayString: String = "\(self.targetMonth)-\(selectedDate)"
        let selectedDay: Date = DateFuncs().convertStringToDate(selectedDayString, format: "yyyy-MM-dd")!
        
        selectedDayViewIcon.setSymbolImage(Date() > selectedDay ? UIImage(systemName: "arrow.forward")! : UIImage(systemName: "arrow.backward")!, contentTransition: .automatic)
        selectedDayBalanceValue.text = formatCurrency(amount: entry.y)!
        selectedDateLabel.text = DateFuncs().convertStringFromDate(selectedDay, format: "yyyy/MM/dd")!
        
        UIView.animate(withDuration: 0.2, animations: {
            let thisDay = DateFuncs().convertStringFromDate(Date(), format: "yyyy-MM-dd")
            self.selectedDayView.alpha = thisDay == selectedDayString ? 0.0 : 1.0
        })
    }
}

// MARK: -
extension GoalDetailViewController: TransactionEditorViewDelegate {
    func addCategory(category: Category) {
        self.wallet.categories.append(category)
        self.delegate!.didUpdateCategories(categories: self.wallet.categories)
    }
    
    func addTransaction(transaction: Transaction) {
        self.transactions.append(transaction)
        loadTransactions()
        updateAndRefreshChart()
        self.delegate!.didUpdateTransactions(transactions: self.transactions)
    }
    
    func updateTransaction(transaction: Transaction) {
        if let index = self.transactions.firstIndex(where: { $0.id == transaction.id }) {
            self.transactions[index] = transaction
            loadTransactions()
            updateAndRefreshChart()
            self.delegate!.didUpdateTransactions(transactions: self.transactions)
        }
    }
}

extension GoalDetailViewController: DeleteGoalDelegate {
    func okButtonTapped() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func cancelButtonTapped() {
        UIView.animate(withDuration: 0.2, animations: {
            self.deleteGoalView.removeFromSuperview()
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.tabBarController?.tabBar.isHidden = false
        })
    }
}
