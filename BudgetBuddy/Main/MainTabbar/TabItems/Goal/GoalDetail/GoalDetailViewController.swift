//
//  TransactionViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/06.
//

import UIKit
import Charts

protocol GoalDetailViewDelegate: AnyObject {
    func didUpdateTransactions()
}

class GoalDetailViewController: UIViewController {    
    weak var delegate: GoalDetailViewDelegate?

    private var category: Category
    private var targetMonth: String
    private var goal: Goal? = nil
    
    private var imageColor: UIColor
    
    private var transactions: [Transaction] = [] {
        didSet {
            
        }
    }
    
    // Navigation
    private let menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(menuButtonTapped))
        return button
    }()
    
    private let whitespace: CGFloat = 50
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = BACKGROUND_COLOR
        return scrollView
    }()
    
    // TransferLog
    private let amountViewHeight: CGFloat = 40
    private var amountViewHeightAnchor: NSLayoutConstraint?
    private let amountView: UIView = {
        let view = UIView()
        view.backgroundColor = NAVIGATION_BACK_COLOR
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.6
        view.layer.shadowRadius = 2
        return view
    }()
    
    private let openAndCloseAmountAriaBtn: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.alpha = 0.6
        button.addTarget(self, action: #selector(openAndCloseAmountAriaBtnTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Budget", comment: "") + " :"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        return label
    }()
    
    private let amountValue: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28, weight: .light)
        return label
    }()

    private let addTransferLogButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.alpha = 0.6
        button.addTarget(self, action: #selector(addTransLogBtnTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()
    
    private let transLogsTableAriaHeaderHeight: CGFloat = 40
    private let transLogsTableAriaBottomHeight: CGFloat = 20
    private var transferLogsTableAriaHeightAnchor: NSLayoutConstraint?
    private let transferLogsTableAria: UIView = {
        let view = UIView()
        view.alpha = 0.0
        view.layer.masksToBounds = true
        return view
    }()
    
    private let tranLogsAriaLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Breakdown", comment: "") + " :"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        return label
    }()
    
    private let transferLogsTableView: UITableView = {
        let tableView = UITableView()
        tableView.tag = 0
        tableView.register(TransferLogTableCell.self, forCellReuseIdentifier: TransferLogTableCell.identifier)
        tableView.layer.cornerRadius = 18
        return tableView
    }()
    
    // LineChartView
    private let lineChartHeight: CGFloat = 120
    private let lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .white
        chartView.layer.masksToBounds = true
        chartView.layer.cornerRadius = 9
        chartView.chartDescription.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        chartView.rightAxis.enabled = false
        return chartView
    }()

    // Barance
    private let balanceView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 2
        return view
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("RemainingBudget", comment: "") + " :"
        label.textColor = .systemGray2
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        return label
    }()
    
    private let balanceValue: UILabel = {
        let label = UILabel()
        label.textColor = .systemGreen
        label.font = UIFont.systemFont(ofSize: 28, weight: .light)
        return label
    }()
    
    private let horizonLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    // Expense
    private let expenseView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 2
        return view
    }()
    
    private let expenseLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("TotalExpenses", comment: "") + " :"
        label.textColor = .systemGray2
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        return label
    }()
    
    private let expenseValue: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 28, weight: .light)
        return label
    }()
    
    // Transactions
    private let transactionsViewHeaderHeight: CGFloat = 40
    private var transactionsViewHeightAnchor: NSLayoutConstraint?
    private let transactionsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 9
        view.layer.masksToBounds = true
        return view
    }()
    
    private let transactionsLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Breakdown", comment: "") + " :"
        label.textColor = .systemGray2
        label.font = UIFont.systemFont(ofSize: 24, weight: .light)
        return label
    }()
    
    private let addTransactionButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(addTransactionButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .systemGray
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
    
    init(category: Category, targetMonth: String, imageColor: UIColor) {
        self.category = category
        self.targetMonth = targetMonth
        self.goal = GoalDao().getGoalsByCategory(category: category, targetMonth: targetMonth).first!
        self.imageColor = imageColor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = self.category.name
        view.backgroundColor = BACKGROUND_COLOR

        setupUI()
        updateValues()
        loadTransactions()
        
        setupChartData()
    }
    
    private func setupUI() {
        // navigation
        if !self.goal!.is_other {
            menuButton.target = self
            navigationItem.rightBarButtonItem = menuButton
        }
        
        view.addSubview(amountView)
        view.addSubview(horizonLineView)
        view.addSubview(scrollView)
        scrollView.addSubview(balanceView)
        scrollView.addSubview(lineChartView)
        scrollView.addSubview(expenseView)
        scrollView.addSubview(transactionsView)
        
        lineChartView.delegate = self
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        
        amountView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        horizonLineView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        transactionsView.translatesAutoresizingMaskIntoConstraints = false
        expenseView.translatesAutoresizingMaskIntoConstraints = false
        
        amountViewHeightAnchor = amountView.heightAnchor.constraint(equalToConstant: amountViewHeight)
        transactionsViewHeightAnchor = transactionsView.heightAnchor.constraint(equalToConstant: view.frame.height)
        NSLayoutConstraint.activate([
            amountView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            amountView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            amountView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            amountViewHeightAnchor!,
            
            horizonLineView.topAnchor.constraint(equalTo: amountView.bottomAnchor, constant: 0),
            horizonLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            horizonLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            horizonLineView.heightAnchor.constraint(equalToConstant: 0),
            
            scrollView.topAnchor.constraint(equalTo: horizonLineView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            balanceView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            balanceView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            balanceView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            balanceView.heightAnchor.constraint(equalToConstant: 50),
            
            lineChartView.topAnchor.constraint(equalTo: balanceView.bottomAnchor, constant: 12),
            lineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            lineChartView.heightAnchor.constraint(equalToConstant: lineChartHeight),
            
            expenseView.topAnchor.constraint(equalTo: lineChartView.bottomAnchor, constant: 24),
            expenseView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            expenseView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            expenseView.heightAnchor.constraint(equalToConstant: 50),
            
            transactionsView.topAnchor.constraint(equalTo: expenseView.bottomAnchor, constant: 12),
            transactionsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            transactionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            transactionsViewHeightAnchor!
        ])
        
        // Amount
        amountView.addSubview(amountLabel)
        amountView.addSubview(amountValue)
        amountView.addSubview(transferLogsTableAria)
        amountView.addSubview(openAndCloseAmountAriaBtn)
        
        transferLogsTableAria.addSubview(addTransferLogButton)
        transferLogsTableAria.addSubview(tranLogsAriaLabel)
        transferLogsTableAria.addSubview(transferLogsTableView)
        
        transferLogsTableView.delegate = self
        transferLogsTableView.dataSource = self
        
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountValue.translatesAutoresizingMaskIntoConstraints = false
        transferLogsTableAria.translatesAutoresizingMaskIntoConstraints = false
        openAndCloseAmountAriaBtn.translatesAutoresizingMaskIntoConstraints = false
        
        addTransferLogButton.translatesAutoresizingMaskIntoConstraints = false
        tranLogsAriaLabel.translatesAutoresizingMaskIntoConstraints = false
        transferLogsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        openAndCloseAmountAriaBtn.isHidden = self.goal!.is_other
        
        transferLogsTableAriaHeightAnchor = transferLogsTableAria.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            openAndCloseAmountAriaBtn.centerYAnchor.constraint(equalTo: amountView.topAnchor, constant: amountViewHeight / 2),
            openAndCloseAmountAriaBtn.leadingAnchor.constraint(equalTo: amountView.leadingAnchor, constant: 24),
            
            amountLabel.centerYAnchor.constraint(equalTo: amountView.topAnchor, constant: amountViewHeight / 2),
            amountLabel.leadingAnchor.constraint(equalTo: openAndCloseAmountAriaBtn.trailingAnchor, constant: 12),
            
            amountValue.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
            amountValue.trailingAnchor.constraint(equalTo: amountView.trailingAnchor, constant: -44),
            
            transferLogsTableAria.bottomAnchor.constraint(equalTo: amountView.bottomAnchor, constant: -transLogsTableAriaBottomHeight),
            transferLogsTableAria.leadingAnchor.constraint(equalTo: amountView.leadingAnchor, constant: 32),
            transferLogsTableAria.trailingAnchor.constraint(equalTo: amountView.trailingAnchor, constant: -32),
            transferLogsTableAriaHeightAnchor!,
            
            tranLogsAriaLabel.centerYAnchor.constraint(equalTo: transferLogsTableAria.topAnchor, constant: transLogsTableAriaHeaderHeight / 2),
            tranLogsAriaLabel.leadingAnchor.constraint(equalTo: transferLogsTableView.leadingAnchor, constant: 18),
            
            addTransferLogButton.centerYAnchor.constraint(equalTo: transferLogsTableAria.topAnchor, constant: transLogsTableAriaHeaderHeight / 2),
            addTransferLogButton.trailingAnchor.constraint(equalTo: transferLogsTableView.trailingAnchor, constant: -18),

            transferLogsTableView.topAnchor.constraint(equalTo: transferLogsTableAria.topAnchor, constant: transLogsTableAriaHeaderHeight),
            transferLogsTableView.leadingAnchor.constraint(equalTo: transferLogsTableAria.leadingAnchor, constant: 16),
            transferLogsTableView.trailingAnchor.constraint(equalTo: transferLogsTableAria.trailingAnchor, constant: -16),
            transferLogsTableView.bottomAnchor.constraint(equalTo: transferLogsTableAria.bottomAnchor)
        ])
        
        // BALANCE
        balanceView.addSubview(balanceLabel)
        balanceView.addSubview(balanceValue)
        
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceValue.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            balanceLabel.centerYAnchor.constraint(equalTo: balanceView.centerYAnchor),
            balanceLabel.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor),
            
            balanceValue.centerYAnchor.constraint(equalTo: balanceView.centerYAnchor),
            balanceValue.trailingAnchor.constraint(equalTo: amountValue.trailingAnchor)
        ])
        
        // EXPENSE
        expenseView.addSubview(expenseLabel)
        expenseView.addSubview(expenseValue)
        
        expenseLabel.translatesAutoresizingMaskIntoConstraints = false
        expenseValue.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            expenseLabel.centerYAnchor.constraint(equalTo: expenseView.centerYAnchor),
            expenseLabel.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor),
            
            expenseValue.centerYAnchor.constraint(equalTo: expenseView.centerYAnchor),
            expenseValue.trailingAnchor.constraint(equalTo: amountValue.trailingAnchor)
        ])
        
        // TRANSACTIONS
        transactionsView.addSubview(transactionsLabel)
        transactionsView.addSubview(addTransactionButton)
        transactionsView.addSubview(transactionsTableView)
        
        transactionsLabel.translatesAutoresizingMaskIntoConstraints = false
        addTransactionButton.translatesAutoresizingMaskIntoConstraints = false
        transactionsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            transactionsLabel.centerYAnchor.constraint(equalTo: transactionsView.topAnchor, constant: transactionsViewHeaderHeight / 2),
            transactionsLabel.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor),
            
            addTransactionButton.centerYAnchor.constraint(equalTo: transactionsLabel.centerYAnchor),
            addTransactionButton.trailingAnchor.constraint(equalTo: amountValue.trailingAnchor),
            
            transactionsTableView.topAnchor.constraint(equalTo: transactionsView.topAnchor, constant: transactionsViewHeaderHeight),
            transactionsTableView.leadingAnchor.constraint(equalTo: transactionsView.leadingAnchor),
            transactionsTableView.trailingAnchor.constraint(equalTo: transactionsView.trailingAnchor),
            transactionsTableView.bottomAnchor.constraint(equalTo: transactionsView.bottomAnchor, constant: -8)
        ])
        
        // DIALOG
        deleteGoalView.delegate = self
    }
    
    private func updateValues() {
        self.goal = GoalDao().getGoalsByCategory(category: self.category, targetMonth: self.targetMonth).first!
        amountValue.text = formatCurrency(amount: goal!.getAmount())
        balanceValue.text = formatCurrency(amount: goal!.getBalance())
        if(goal!.getBalance() < 0) {
            balanceValue.textColor = .systemRed
        } else {
            balanceValue.textColor = .systemGreen
        }
        transferLogsTableView.reloadData()
        updateChartData()
    }
    
    private func loadTransactions() {
        transactions = self.goal!.getTransactions(sortedBy: "date", ascending_flg: true)
        let transViewHeight = TransactionTableViewCell.cellHeight * CGFloat(self.transactions.count) + transactionsViewHeaderHeight
        UIView.animate(withDuration: 0, animations: { [self] in
            self.transactionsViewHeightAnchor!.constant = transViewHeight
            self.balanceValue.text = formatCurrency(amount: goal!.getBalance())
            if(goal!.getBalance() < 0) {
                balanceValue.textColor = .systemRed
            } else {
                balanceValue.textColor = .systemGreen
            }
            self.expenseValue.text = formatCurrency(amount: goal!.getTransactionsAmountSum())
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
        var valueOfDay = self.goal!.getAmount()
        for idx in 1...DateFuncs.numberOfDaysInMonth(yearMonth: self.targetMonth)! {let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dayStr = String(format: "%02d", idx)
            let dayTrans = self.goal?.getTransactionsAtDate(date: dateFormatter.date(from: self.targetMonth + "-" + dayStr)!)
            dayTrans!.forEach { tran in
                valueOfDay -= tran.amount
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
        lineDataSet.colors = [self.imageColor]
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
        lineDataSet.fillColor = self.imageColor
        lineDataSet.fillAlpha = 0.3
        // X軸
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.axisMinimum = 1.0
        lineChartView.xAxis.labelTextColor = .systemGray
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.axisLineColor = .black
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelCount = values.count
        lineChartView.xAxis.valueFormatter = CustomXAxisFormatter(targetMonth: self.targetMonth)
        // Y軸
        lineChartView.leftAxis.axisMinimum = values.min()! >= 0 ? 0 : 10000.0 * Double(floor(values.min()! / 10000.0))
        lineChartView.leftAxis.axisMaximum = self.goal!.getAmount() + self.goal!.getAmount() / 8
        lineChartView.leftAxis.drawZeroLineEnabled = true
        lineChartView.leftAxis.labelTextColor = .systemGray
        lineChartView.leftAxis.zeroLineColor = .systemGray
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
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 0.0, easingOption: .linear)
        
        // 更新
        lineChartView.notifyDataSetChanged()
    }
    
    private func updateChartData() {
        var dataEntries: [ChartDataEntry] = []
        
        // Here you can add your data points. For example:
        var values: [Double] = []
        var valueOfDay = self.goal!.getAmount()
        for idx in 1...DateFuncs.numberOfDaysInMonth(yearMonth: self.targetMonth)! {let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dayStr = String(format: "%02d", idx)
            let dayTrans = self.goal?.getTransactionsAtDate(date: dateFormatter.date(from: self.targetMonth + "-" + dayStr)!)
            dayTrans!.forEach { tran in
                valueOfDay -= tran.amount
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
        lineDataSet.colors = [self.imageColor]
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
        lineDataSet.fillColor = self.imageColor
        lineDataSet.fillAlpha = 0.3
        // Y軸
        lineChartView.leftAxis.axisMinimum = values.min()! >= 0 ? 0 : 10000.0 * Double(floor(values.min()! / 10000.0))
        lineChartView.leftAxis.axisMaximum = self.goal!.getAmount() + self.goal!.getAmount() / 8
        
        // 更新
        lineChartView.notifyDataSetChanged()
    }
    
    private func updateAndRefreshChart() {
        updateChartData()
        lineChartView.notifyDataSetChanged()
    }
    
    // MARK: - Action
    @objc private func addTransLogBtnTapped() {
        let addGoalViewController = CreateTransferLogViewController()
        addGoalViewController.configure(targetMonth: self.targetMonth, destCategory: self.category)
        addGoalViewController.delegate = self
        present(addGoalViewController, animated: true, completion: nil)
    }
    
    @objc private func menuButtonTapped() {
        // メニューのアクションを作成
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // アクション
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { [self] (action) in
            self.deleteGoalView.setInit(goal: self.goal!)
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
    
    @objc private func alertSettingButtonTapped() {
        let alertSetVC = GoalAlertSettingViewController(goal: self.goal!)
        // ハーフモーダル設定
        alertSetVC.modalPresentationStyle = .popover
        if let popover = alertSetVC.popoverPresentationController {
            let sheet = popover.adaptiveSheetPresentationController
            sheet.detents = [.medium()]
            
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        present(alertSetVC, animated: true, completion: nil)
    }
    
    @objc private func settingGoalButtonTapped() {
        let settingGoalVC = SettingGoalViewController(category: self.category)
        // ハーフモーダル設定
        settingGoalVC.modalPresentationStyle = .popover
        if let popover = settingGoalVC.popoverPresentationController {
            let sheet = popover.adaptiveSheetPresentationController
            sheet.detents = [.large()]
            
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        present(settingGoalVC, animated: true, completion: nil)
    }
    
    @objc private func deleteGoalTapped() {
    }
    
    @objc private func openAndCloseAmountAriaBtnTapped() {
        if transferLogsTableView.frame.height == 0 {
            UIView.animate(withDuration: 0.3, animations: { [self] in
                let tableAriaHeight: CGFloat = CGFloat(self.goal!.transLogsAsDest.count) * TransferLogTableCell.cellHeight + transLogsTableAriaHeaderHeight
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
    
    @objc private func addTransactionButtonTapped() {
        let createTransactionView = TransactionEditorViewController()
        createTransactionView.configure(targetMonth: self.targetMonth, defaultCategory: self.category)
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
        switch tableView.tag {
        case 0:
            return self.goal!.transLogsAsDest.count
        case 1:
            return transactions.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 0:
            return TransferLogTableCell.cellHeight
        case 1:
            return TransactionTableViewCell.cellHeight
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: TransferLogTableCell.identifier, for: indexPath) as! TransferLogTableCell
            cell.configure(transferLog: self.goal!.transLogsAsDest[indexPath.row])
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
            cell.configure(with: transactions[indexPath.row], categoryName: self.goal!.category!.name)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView.tag {
        case 0:
            return
        case 1:
            showEditDialog(transaction: transactions[indexPath.row])
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.showDeleteAlert(at: self!.transactions[indexPath.row])
            completion(true)
        }

        switch tableView.tag {
        case 1:
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        default:
            let configuration = UISwipeActionsConfiguration(actions: [])
            return configuration
        }
    }
    
    private func showDeleteAlert(at transaction: Transaction) {
        let alert = UIAlertController(title: "Delete Transaction", message: "Are you sure you want to delete this transaction?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            TransactionDao().deleteTransaction(transaction: transaction)
            self!.loadTransactions()
            self!.updateAndRefreshChart()
            self!.delegate!.didUpdateTransactions()
        }))
        
        present(alert, animated: true, completion: nil)
    }

    private func showEditDialog(transaction: Transaction) {
        let createTransactionView = TransactionEditorViewController()
        createTransactionView.configure(targetMonth: self.targetMonth, transaction: transaction)
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
        chartView.chartDescription.text = "\(Int(entry.x) + 1)\(NSLocalizedString("Day", comment: "")): \(formatCurrency(amount: entry.y)!)"
        // チャート説明の位置を設定（右上）
        let xPos = chartView.frame.width - 20
        let yPos = 1.4
        chartView.chartDescription.position = CGPoint(x: xPos, y: yPos)
    }
}

// MARK: -
extension GoalDetailViewController: CreateTransferLogViewDelegate {
    func didAddTransferLog() {
        self.updateValues()
    }
}

extension GoalDetailViewController: TransactionEditorViewDelegate {
    func saveBtnTapped_atTransactionEditor() {
        loadTransactions()
        updateAndRefreshChart()
        self.delegate!.didUpdateTransactions()
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
