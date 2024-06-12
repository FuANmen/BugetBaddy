//
//  DataAriaView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/30.
//

import UIKit
import Charts

protocol DataAriaDelegate: AnyObject {
    func thisWeekTapped()
    func thisMonthTapped()
    func createTranTapped()
}

class DataAriaView: UIView {
    weak var delegate: DataAriaDelegate?
    
    // ThisWeek
    private let thisWeekDateViewHeight: CGFloat = 100
    private let thisWeekDataView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.systemCyan.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 1
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let weekIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let weekTitle: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("1Week", comment: "")
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemTeal
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weekExpenseLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("TotalExpenses", comment: "")
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weekExpenseValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .light)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weekDetailIcon: UIImageView = {
        let image = UIImageView()
        image.setSymbolImage(UIImage(systemName: "chevron.right")!, contentTransition: .automatic)
        image.tintColor = .systemGray4
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let weekBarChartView: BarChartView = {
        let chart = BarChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    
    // Data ThisMonth
    private let thisMonthDateViewHeight: CGFloat = 100
    private let thisMonthDataView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.systemCyan.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 1
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let monthIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let monthTitle: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("1Month", comment: "")
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let monthExpenseLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("TotalExpenses", comment: "")
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let monthExpenseValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .light)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let monthDetailIcon: UIImageView = {
        let image = UIImageView()
        image.setSymbolImage(UIImage(systemName: "chevron.right")!, contentTransition: .automatic)
        image.tintColor = .systemGray4
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let monthPieChart: PieChartView = {
        let chart = PieChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    
    // CreateTransaction
    private let createTransactionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.6)
        view.layer.cornerRadius = 18
        view.layer.shadowColor = UIColor.systemCyan.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 1
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let createTranIcon: UIImageView = {
        let image = UIImageView()
        image.setSymbolImage(UIImage(systemName: "pencil.line")!, contentTransition: .automatic)
        image.tintColor = .systemTeal
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let createTranLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("CreateTransactionLabel", comment: "")
        label.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        label.textColor = .systemTeal
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Dummy
    private let dummyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        setupUI()
        chartSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func configure() {
        // week
        var week: [String] = []
        for i in 1...7 {
            let day = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: i))!
            week.append(DateFuncs().getShortDayOfWeek(from: day))
        }
        
        var value: Double = 0.0
        var weekValue: [Double] = [0,0,0,0,0,0,0]
        let dayOfWeek = DateFuncs().getShortDayOfWeek(from: Date())
        
        var idx: Int = week.firstIndex(of: dayOfWeek)!
        for i in 0..<7 {
            let targetDay = Calendar.current.date(byAdding: .day, value: -idx, to: Date())
            let transactions = TransactionDao().getTransactionsAtDate(category: nil, date: targetDay!)
            transactions.forEach { tran in
                value += tran.amount
                weekValue[i] += tran.amount
            }
            idx -= 1
        }
        weekExpenseValue.text = formatCurrency(amount: value)
        
        let weekEntries = weekValue.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: Double($0.element)) }
        let weekDataSet = BarChartDataSet(entries: weekEntries)
        weekDataSet.drawValuesEnabled = false
        weekDataSet.colors = [.systemTeal]
        
        let highlight = Highlight(x: Double(week.firstIndex(of: dayOfWeek)!), y: weekEntries[week.firstIndex(of: dayOfWeek)!].y, dataSetIndex: 0)
        weekBarChartView.highlightValues([highlight])
        
        weekBarChartView.data = BarChartData(dataSet: weekDataSet)
        weekBarChartView.leftAxis.axisMaximum = weekValue.max()!
        
        // month
        let thisMonth: String = DateFuncs().convertStringFromDate(Date(), format: "yyyy-MM")
        
        var monthEntries: [PieChartDataEntry] = []
        var categories: [Category] = CategoryDao().getUserCategories()
        categories.append(CategoryDao().getOrCreateOtherCategory())
        categories.forEach { category in
            var value: Double = 0.0
            let trans = TransactionDao().getTransactionsForCategory(category: category, targetMonth: thisMonth)
            trans.forEach { tran in
                value += tran.amount
            }
            monthEntries.append(PieChartDataEntry(value: value, label: ""))
        }
        let monthDataSet = PieChartDataSet(entries: monthEntries)
        monthDataSet.colors = ChartColorTemplates.vordiplom()
        monthDataSet.drawValuesEnabled = false
        
        let monthData = PieChartData(dataSet: monthDataSet)
        monthPieChart.data = monthData
        
        if let totalGoal = GoalDao().getTotalGoal(targetMonth: thisMonth) {
            thisMonthDataView.isHidden = false
            monthExpenseValue.text = formatCurrency(amount: totalGoal.getTransactionsAmountSum())
        } else {
            thisMonthDataView.isHidden = true
        }
    }
    
    internal func getViewHeight() -> CGFloat {
        return dummyView.frame.maxY
    }
    
    private func setupUI() {
        self.addSubview(thisWeekDataView)
        self.addSubview(thisMonthDataView)
        self.addSubview(createTransactionView)
        self.addSubview(dummyView)
        
        NSLayoutConstraint.activate([
            thisWeekDataView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            thisWeekDataView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            thisWeekDataView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            thisWeekDataView.heightAnchor.constraint(equalToConstant: thisWeekDateViewHeight),
            
            thisMonthDataView.topAnchor.constraint(equalTo: thisWeekDataView.bottomAnchor, constant: 12),
            thisMonthDataView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            thisMonthDataView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            thisMonthDataView.heightAnchor.constraint(equalToConstant: thisMonthDateViewHeight),
            
            createTransactionView.topAnchor.constraint(equalTo: thisMonthDataView.bottomAnchor, constant: 16),
            createTransactionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 48),
            createTransactionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -48),
            createTransactionView.heightAnchor.constraint(equalToConstant: 40),
            
            dummyView.topAnchor.constraint(equalTo: createTransactionView.bottomAnchor, constant: 12),
            dummyView.heightAnchor.constraint(equalToConstant: 0)
        ])
        
        // Week
        thisWeekDataView.addSubview(weekIcon)
        thisWeekDataView.addSubview(weekTitle)
        thisWeekDataView.addSubview(weekExpenseLabel)
        thisWeekDataView.addSubview(weekExpenseValue)
        thisWeekDataView.addSubview(weekDetailIcon)
        thisWeekDataView.addSubview(weekBarChartView)
        
        NSLayoutConstraint.activate([
            weekDetailIcon.topAnchor.constraint(equalTo: thisWeekDataView.topAnchor, constant: 8),
            weekDetailIcon.trailingAnchor.constraint(equalTo: thisWeekDataView.trailingAnchor, constant: -12),
            
            weekIcon.centerYAnchor.constraint(equalTo: weekDetailIcon.centerYAnchor),
            weekIcon.leadingAnchor.constraint(equalTo: thisWeekDataView.leadingAnchor, constant: 12),
            
            weekTitle.centerYAnchor.constraint(equalTo: weekIcon.centerYAnchor),
            weekTitle.leadingAnchor.constraint(equalTo: weekIcon.trailingAnchor, constant: 8),
            
            weekExpenseValue.bottomAnchor.constraint(equalTo: thisWeekDataView.bottomAnchor, constant: -8),
            weekExpenseValue.leadingAnchor.constraint(equalTo: thisWeekDataView.leadingAnchor, constant: 32),
            
            weekExpenseLabel.bottomAnchor.constraint(equalTo: weekExpenseValue.topAnchor, constant: -4),
            weekExpenseLabel.leadingAnchor.constraint(equalTo: weekExpenseValue.leadingAnchor, constant: -8),
            
            weekBarChartView.topAnchor.constraint(equalTo: thisWeekDataView.topAnchor, constant: 8),
            weekBarChartView.bottomAnchor.constraint(equalTo: thisWeekDataView.bottomAnchor, constant: -4),
            weekBarChartView.trailingAnchor.constraint(equalTo: thisWeekDataView.trailingAnchor, constant: -16),
            weekBarChartView.leadingAnchor.constraint(equalTo: weekExpenseValue.trailingAnchor, constant: 12)
        ])
        
        // Month
        thisMonthDataView.addSubview(monthIcon)
        thisMonthDataView.addSubview(monthTitle)
        thisMonthDataView.addSubview(monthExpenseLabel)
        thisMonthDataView.addSubview(monthExpenseValue)
        thisMonthDataView.addSubview(monthDetailIcon)
        thisMonthDataView.addSubview(monthPieChart)
        
        NSLayoutConstraint.activate([
            monthDetailIcon.topAnchor.constraint(equalTo: thisMonthDataView.topAnchor, constant: 8),
            monthDetailIcon.trailingAnchor.constraint(equalTo: thisMonthDataView.trailingAnchor, constant: -12),
            
            monthIcon.centerYAnchor.constraint(equalTo: monthDetailIcon.centerYAnchor),
            monthIcon.leadingAnchor.constraint(equalTo: thisMonthDataView.leadingAnchor, constant: 12),
            
            monthTitle.centerYAnchor.constraint(equalTo: monthDetailIcon.centerYAnchor),
            monthTitle.leadingAnchor.constraint(equalTo: monthIcon.trailingAnchor, constant: 8),
            
            monthExpenseValue.bottomAnchor.constraint(equalTo: thisMonthDataView.bottomAnchor, constant: -8),
            monthExpenseValue.leadingAnchor.constraint(equalTo: thisMonthDataView.leadingAnchor, constant: 32),
            
            monthExpenseLabel.bottomAnchor.constraint(equalTo: monthExpenseValue.topAnchor, constant: -4),
            monthExpenseLabel.leadingAnchor.constraint(equalTo: monthExpenseValue.leadingAnchor, constant: -8),
            
            monthPieChart.topAnchor.constraint(equalTo: thisMonthDataView.topAnchor, constant: 0),
            monthPieChart.bottomAnchor.constraint(equalTo: thisMonthDataView.bottomAnchor, constant: 0),
            monthPieChart.trailingAnchor.constraint(equalTo: thisMonthDataView.trailingAnchor, constant: 0),
            monthPieChart.leadingAnchor.constraint(equalTo: monthExpenseValue.trailingAnchor, constant: 0)
        ])
        
        // CreateTran
        createTransactionView.addSubview(createTranIcon)
        createTransactionView.addSubview(createTranLabel)
        
        NSLayoutConstraint.activate([
            createTranIcon.centerYAnchor.constraint(equalTo: createTransactionView.centerYAnchor),
            createTranIcon.leadingAnchor.constraint(equalTo: createTransactionView.leadingAnchor, constant: 48),
            createTranIcon.widthAnchor.constraint(equalToConstant: 24),
            createTranIcon.heightAnchor.constraint(equalToConstant: 24),
            
            createTranLabel.centerYAnchor.constraint(equalTo: createTranIcon.centerYAnchor),
            createTranLabel.trailingAnchor.constraint(equalTo: createTransactionView.trailingAnchor, constant: -48)
        ])
        
        // Gesture
        let tapGesture_atThisWeek = UITapGestureRecognizer(target: self, action: #selector(thisWeekTapped))
        thisWeekDataView.isUserInteractionEnabled = true
        thisWeekDataView.addGestureRecognizer(tapGesture_atThisWeek)
        let tapGesture_atThisMonth = UITapGestureRecognizer(target: self, action: #selector(thisMonthTapped))
        thisMonthDataView.isUserInteractionEnabled = true
        thisMonthDataView.addGestureRecognizer(tapGesture_atThisMonth)
        let tapGesture_atCreateTran = UITapGestureRecognizer(target: self, action: #selector(createTranTapped))
        createTransactionView.isUserInteractionEnabled = true
        createTransactionView.addGestureRecognizer(tapGesture_atCreateTran)
    }
    
    private func chartSetup() {
        // week
        weekBarChartView.xAxis.labelPosition = .bottom
        weekBarChartView.xAxis.drawGridLinesEnabled = false
        weekBarChartView.xAxis.drawAxisLineEnabled = false
        weekBarChartView.xAxis.valueFormatter = WeekBarChartXAxisFormatter()
        weekBarChartView.xAxis.labelTextColor = .systemGray3
        weekBarChartView.leftAxis.drawLabelsEnabled = false
        weekBarChartView.leftAxis.drawAxisLineEnabled = false
        weekBarChartView.rightAxis.enabled = false
        weekBarChartView.legend.enabled = false
        
        weekBarChartView.highlightPerTapEnabled = false
        weekBarChartView.highlightPerDragEnabled = false
        weekBarChartView.isUserInteractionEnabled = false
        weekBarChartView.doubleTapToZoomEnabled = false
        weekBarChartView.pinchZoomEnabled = false
        weekBarChartView.dragEnabled = false
        weekBarChartView.scaleXEnabled = false
        weekBarChartView.scaleYEnabled = false
        
        // month
        monthPieChart.holeRadiusPercent = 0.0
        monthPieChart.transparentCircleRadiusPercent = 0.0
        monthPieChart.legend.enabled = false
        monthPieChart.isUserInteractionEnabled = false
    }
    
    // MARK: - GESTURE EVENT
    @objc private func thisWeekTapped() {
        self.delegate!.thisWeekTapped()
    }
    
    @objc private func thisMonthTapped() {
        self.delegate!.thisMonthTapped()
    }
    
    @objc private func createTranTapped() {
        self.delegate!.createTranTapped()
    }
}

class WeekBarChartXAxisFormatter: IndexAxisValueFormatter {
    private var week: [String] = []
    
    override init() {
        super.init()
        for i in 1...7 {
            let day = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: i))!
            week.append(DateFuncs().getShortDayOfWeek(from: day))
        }
    }
    
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return self.week[Int(value)]
    }
}
