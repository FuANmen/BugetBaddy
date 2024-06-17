//
//  GoalViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/01.
//

import UIKit
import RealmSwift

class MonthlyViewController: UIViewController {
    private let realm = try! Realm()
    private let goalDao = GoalDao()
    private let categoryDao = CategoryDao()
    private let dateFuncs = DateFuncs()
    
    private var targetMonth: String = "" {
        didSet {
            navigationItem.title = String(format: NSLocalizedString("Year-Month", comment: ""),
                                          String(self.targetMonth.prefix(4)),
                                         String(self.targetMonth.suffix(2)))
            // 初期表示時はアニメーションなし
            if oldValue == "" {
                self.updateTotalGoal()
                self.goalsView.configure(targetMonth: self.targetMonth)
                return
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self.amountValue.alpha = 0.0
                self.balanceValue.alpha = 0.0
                self.goalsView.alpha = 0.0
                self.totalDetailView.alpha = 0.0
            }, completion: { finished in
                self.updateDatas()
                self.goalsView.scrollToTop()
                self.totalDetailView.scrollToTop()
                UIView.animate(withDuration: 0.3, animations: {
                    self.amountValue.alpha = 1.0
                    self.balanceValue.alpha = 1.0
                    self.goalsView.alpha = 1.0
                    self.totalDetailView.alpha = 1.0
                })
            })
        }
    }

    private var totalGoal: Goal?
    private var preview: PreviewStatus = .goalsView {
        didSet {
            if oldValue == preview {
                return
            }
            switch preview {
            case .goalsView:
                self.goalsView.configure(targetMonth: self.targetMonth)
                validViewHorizontalAlignment?.constant = view.frame.width / 4
                goalsViewLeadingConstraint?.constant = 0
                
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutIfNeeded()
                    self.mainViewLabel_1.textColor = .white
                    self.mainViewLabel_3.textColor = .systemGray4
                }
            case .totalDetail:
                self.totalDetailView.configure(targetMonth: self.targetMonth)
                validViewHorizontalAlignment?.constant = view.frame.width / 4 * 3
                goalsViewLeadingConstraint?.constant = -view.frame.width
                
                UIView.animate(withDuration: 0.4) {
                    self.view.layoutIfNeeded()
                    self.mainViewLabel_1.textColor = .systemGray4
                    self.mainViewLabel_3.textColor = .white
                }
            }
        }
    }
    enum PreviewStatus {
        case goalsView
        case totalDetail
    }
    
    // NAVIGATION
    private let previousButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .white
        button.image = UIImage(systemName: "arrowtriangle.backward.fill")
        button.action = #selector(previousButtonTapped)
        return button
    }()

    private let nextButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .white
        button.image = UIImage(systemName: "arrowtriangle.right.fill")
        button.action = #selector(nextButtonTapped)
        return button
    }()
    
    // TOP
    private let topViewHeight: CGFloat = 140
    private let topView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = false
        view.tag = 0
        return view
    }()
    
    private let horizonView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var validViewHorizontalAlignment: NSLayoutConstraint?
    private let validView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let mainViewLabel_1: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Goal", comment: "")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .white
        label.tag = 1
        return label
    }()
    
    private let mainViewLabel_3: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Breakdown", comment: "")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .systemGray6
        label.tag = 2
        return label
    }()
    
    private var transferLogsView: TransferLogsDetailView = {
        let view = TransferLogsDetailView()
        return view
    }()
    
    private var goalsViewLeadingConstraint: NSLayoutConstraint?
    private let goalsView: GoalsView = {
        let goalsView = GoalsView()
        return goalsView
    }()
    
    private let totalDetailView: TotalDetailView = {
        let view = TotalDetailView()
        return view
    }()
    
    // TOP
    private let topAriaHeight: CGFloat = 90
    private let topAria: UIView = {
        let view = UIView()
        view.backgroundColor = .customWhiteSmoke
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        return view
    }()
    
    // balance
    private let balanceView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = ": " + NSLocalizedString("Go_TopLabel_001", comment: "")
        label.textColor = .customSteelBlueLight1
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let balanceValue: UILabel = {
        let label = UILabel()
        label.textColor = .customRoyalBlueLight1
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let balanceIcon: UIImageView = {
        let icon = UIImageView()
         //icon.setSymbolImage(UIImage(systemName: "chevron.compact.right")!, contentTransition: .automatic)
        icon.tintColor = .systemGray4
        return icon
    }()
    
    // partition
    private var partitionCneterYAnchor: NSLayoutConstraint?
    private let partitionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    // amount
    private let amountView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        return view
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = ": " + NSLocalizedString("Go_TopLabel_002", comment: "")
        label.textColor = .customSteelBlueLight1
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    private let amountValue: UILabel = {
        let label = UILabel()
        label.textColor = .customRoyalBlueLight1
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let amountIcon: UIImageView = {
        let icon = UIImageView()
        // icon.setSymbolImage(UIImage(systemName: "chevron.compact.right")!, contentTransition: .automatic)
        icon.tintColor = .systemGray4
        return icon
    }()

    // DIALOG
    private let selectTargetMonthView: SelectTargetMonthView = {
        let view = SelectTargetMonthView()
        view.isHidden = true
        return view
    }()
    
    private let createBreakdownView: BreakdownEditorView = {
        let view = BreakdownEditorView()
        view.isHidden = true
        return view
    }()
    
    internal func updatePreview(to: Int) {
        switch to {
        case 0:
            self.preview = .goalsView
        case 1:
            self.preview = .totalDetail
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // common
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        self.targetMonth = dateFormatter.string(from: currentDate)
        // navigation
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        // top
        setupUI()
        updateButtonState()
        addGradientBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let tabBar = self.tabBarController as? MainTabBarController {
            updatePreview(to: tabBar.monthlyVC_preview)
        }
        
        updateTotalGoal()
        updateButtonState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func addGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.backGradientColorFrom.cgColor, UIColor.backGradientColorTo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // 既存のレイヤーの後ろにグラデーションレイヤーを追加
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupUI() {
        // navigation
        previousButton.target = self
        nextButton.target = self
        navigationItem.leftBarButtonItem = previousButton
        navigationItem.rightBarButtonItem = nextButton
        
        // view
        view.addSubview(topView)
        view.addSubview(transferLogsView)
        view.addSubview(goalsView)
        view.addSubview(totalDetailView)
        view.addSubview(horizonView)
        view.addSubview(validView)
        view.addSubview(mainViewLabel_1)
        view.addSubview(mainViewLabel_3)
        
        goalsView.delegate = self
        totalDetailView.delegate = self
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        transferLogsView.translatesAutoresizingMaskIntoConstraints = false
        goalsView.translatesAutoresizingMaskIntoConstraints = false
        totalDetailView.translatesAutoresizingMaskIntoConstraints = false
        horizonView.translatesAutoresizingMaskIntoConstraints = false
        validView.translatesAutoresizingMaskIntoConstraints = false
        mainViewLabel_1.translatesAutoresizingMaskIntoConstraints = false
        // mainViewLabel_2.translatesAutoresizingMaskIntoConstraints = false
        mainViewLabel_3.translatesAutoresizingMaskIntoConstraints = false
        
        goalsViewLeadingConstraint = goalsView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        validViewHorizontalAlignment = validView.centerXAnchor.constraint(equalTo: horizonView.leadingAnchor, constant: view.frame.width / 4 * 1)
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: topViewHeight),
            
            horizonView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            horizonView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            horizonView.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            horizonView.heightAnchor.constraint(equalToConstant: 2),
            
            validView.heightAnchor.constraint(equalToConstant: 2),
            validView.bottomAnchor.constraint(equalTo: horizonView.topAnchor),
            validViewHorizontalAlignment!,
            validView.widthAnchor.constraint(equalToConstant: view.frame.width / 4),
            
            mainViewLabel_1.bottomAnchor.constraint(equalTo: validView.topAnchor, constant: -1),
            mainViewLabel_1.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width / 4),
            mainViewLabel_1.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            
            mainViewLabel_3.bottomAnchor.constraint(equalTo: validView.topAnchor, constant: 1),
            mainViewLabel_3.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: view.frame.width / 4 * 3),
            mainViewLabel_3.widthAnchor.constraint(equalToConstant: view.frame.width / 2),
            
            goalsView.topAnchor.constraint(equalTo: horizonView.bottomAnchor),
            goalsViewLeadingConstraint!,
            goalsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            goalsView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            totalDetailView.topAnchor.constraint(equalTo: horizonView.bottomAnchor),
            totalDetailView.leadingAnchor.constraint(equalTo: goalsView.trailingAnchor),
            totalDetailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            totalDetailView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        topView.addSubview(topAria)
        topAria.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAria.topAnchor.constraint(equalTo: topView.topAnchor, constant: 12),
            topAria.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 36),
            topAria.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -36),
            topAria.heightAnchor.constraint(equalToConstant: topAriaHeight)
        ])
        
        // TopAria
        topAria.addSubview(balanceView)
        balanceView.addSubview(balanceLabel)
        balanceView.addSubview(balanceValue)
        balanceView.addSubview(balanceIcon)
        topAria.addSubview(partitionView)
        topAria.addSubview(amountView)
        amountView.addSubview(amountLabel)
        amountView.addSubview(amountValue)
        amountView.addSubview(amountIcon)
        
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceValue.translatesAutoresizingMaskIntoConstraints = false
        balanceIcon.translatesAutoresizingMaskIntoConstraints = false
        partitionView.translatesAutoresizingMaskIntoConstraints = false
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountValue.translatesAutoresizingMaskIntoConstraints = false
        amountIcon.translatesAutoresizingMaskIntoConstraints = false
        
        partitionCneterYAnchor = partitionView.centerYAnchor.constraint(equalTo: topAria.topAnchor, constant: topAriaHeight / 2)
        
        NSLayoutConstraint.activate([
            // AMOUNT
            amountView.topAnchor.constraint(equalTo: topAria.topAnchor),
            amountView.leadingAnchor.constraint(equalTo: topAria.leadingAnchor),
            amountView.trailingAnchor.constraint(equalTo: topAria.trailingAnchor),
            amountView.bottomAnchor.constraint(equalTo: partitionView.topAnchor),
            
            amountIcon.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
            amountIcon.leadingAnchor.constraint(equalTo: amountView.leadingAnchor, constant: 14),
            
            amountValue.centerYAnchor.constraint(equalTo: amountView.centerYAnchor),
            amountValue.leadingAnchor.constraint(equalTo: amountIcon.trailingAnchor, constant: 8),
            
            amountLabel.bottomAnchor.constraint(equalTo: amountValue.bottomAnchor, constant: -3),
            amountLabel.leadingAnchor.constraint(equalTo: amountView.centerXAnchor, constant: 32),

            // PARTITION
            partitionView.leadingAnchor.constraint(equalTo: topAria.leadingAnchor),
            partitionView.trailingAnchor.constraint(equalTo: topAria.trailingAnchor),
            partitionView.heightAnchor.constraint(equalToConstant: 1),
            partitionCneterYAnchor!,
            
            // BALANCE
            balanceView.topAnchor.constraint(equalTo: partitionView.bottomAnchor),
            balanceView.leadingAnchor.constraint(equalTo: topAria.leadingAnchor),
            balanceView.trailingAnchor.constraint(equalTo: topAria.trailingAnchor),
            balanceView.bottomAnchor.constraint(equalTo: topAria.bottomAnchor),
            
            balanceIcon.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            balanceIcon.leadingAnchor.constraint(equalTo: balanceView.leadingAnchor, constant: 14),
            
            balanceValue.centerYAnchor.constraint(equalTo: balanceView.centerYAnchor),
            balanceValue.leadingAnchor.constraint(equalTo: balanceIcon.trailingAnchor, constant: 8),
            
            balanceLabel.bottomAnchor.constraint(equalTo: balanceValue.bottomAnchor, constant: -3),
            balanceLabel.leadingAnchor.constraint(equalTo: balanceView.centerXAnchor, constant: 32)
        ])
        
        // MARK: - DIALOG
        // SelectTargetMonthView
        selectTargetMonthView.delegate = self
        selectTargetMonthView.translatesAutoresizingMaskIntoConstraints = false
        // CreateBreakdownView
        createBreakdownView.delegate = self
        createBreakdownView.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - GESTURE
        let tapGesture_mainViewLabel = UITapGestureRecognizer(target: self, action: #selector(mainViewLabelTapped(_:)))
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(tapGesture_mainViewLabel)
        let tapGesture_mainViewLabel_1 = UITapGestureRecognizer(target: self, action: #selector(mainViewLabelTapped(_:)))
        mainViewLabel_1.isUserInteractionEnabled = true
        mainViewLabel_1.addGestureRecognizer(tapGesture_mainViewLabel_1)
//        let tapGesture_mainViewLabel_2 = UITapGestureRecognizer(target: self, action: #selector(mainViewLabelTapped(_:)))
//        mainViewLabel_2.isUserInteractionEnabled = true
//        mainViewLabel_2.addGestureRecognizer(tapGesture_mainViewLabel_2)
        let tapGesture_mainViewLabel_3 = UITapGestureRecognizer(target: self, action: #selector(mainViewLabelTapped(_:)))
        mainViewLabel_3.isUserInteractionEnabled = true
        mainViewLabel_3.addGestureRecognizer(tapGesture_mainViewLabel_3)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewPanGesture(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(panGesture)
    }

    private func updateTotalGoal() {
        UpdateGoals(targetMonth: self.targetMonth)
        totalGoal = goalDao.getTotalGoal(targetMonth: self.targetMonth)
        
        balanceValue.text = formatCurrency(amount: totalGoal!.getBalance())
        amountValue.text = formatCurrency(amount: totalGoal!.getAmount())
        self.view.layoutIfNeeded()
    }
    
    private func updateButtonState() {
        //previousButton.isEnabled = (currentDate > Calendar.current.date(byAdding: .year, value: -1, to: Date())!)
        previousButton.isHidden = !previousButton.isEnabled
        
        //nextButton.isEnabled = (Date() >= Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!)
        nextButton.isHidden = !nextButton.isEnabled
    }
    
    private func updateDatas() {
        self.updateTotalGoal()
        self.transferLogsView.configure(targetMonth: self.targetMonth)
        self.goalsView.configure(targetMonth: self.targetMonth)
        self.totalDetailView.configure(targetMonth: self.targetMonth)
    }
    
    // MARK: - ActionEvent
    @objc func previousButtonTapped(_ sender: UIBarButtonItem) {
        let currentDate: Date = DateFuncs().convertStringToDate(self.targetMonth, format: "yyyy-MM")!
        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate),
              currentDate > Calendar.current.date(byAdding: .year, value: -1, to: Date())!  else {
            return
        }
        self.targetMonth = DateFuncs().convertStringFromDate(previousMonth, format: "yyyy-MM")
    }

    @objc private func nextButtonTapped(_ sender: UIBarButtonItem) {
        let currentDate: Date = DateFuncs().convertStringToDate(self.targetMonth, format: "yyyy-MM")!
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) // ,nextMonth <= Date()
        else {
            return
        }
        self.targetMonth = DateFuncs().convertStringFromDate(nextMonth, format: "yyyy-MM")
    }
    
    // MARK: - GestureEvent
    @objc private func targetMonthLabelTapped(_ gesture: UITapGestureRecognizer) {
        selectTargetMonthView.setupInit(targetMonth: self.targetMonth)
        
        selectTargetMonthView.alpha = 0
        self.view.addSubview(selectTargetMonthView)
        
        NSLayoutConstraint.activate([
            selectTargetMonthView.topAnchor.constraint(equalTo: self.view.topAnchor),
            selectTargetMonthView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            selectTargetMonthView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            selectTargetMonthView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.selectTargetMonthView.alpha = 1.0
        }
    }
    
    @objc private func mainViewLabelTapped(_ gesture: UITapGestureRecognizer) {
        switch gesture.view!.tag {
        case 0:
            self.preview = .totalDetail
        case 1:
            self.preview = .goalsView
        case 2:
            self.preview = .totalDetail
        default :
            break
        }
    }
    @objc private func viewPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        switch gesture.state {
        case .began, .changed:
            // ジェスチャの開始または変更時に実行するコード
            break
        case .ended:
            // パンジェスチャが終了したときの処理
            if translation.x > 0 {
                handleRightPan()
            } else {
                handleLeftPan()
            }
        default:
            break
        }
    }
    
    private func handleRightPan() {
        switch self.preview {
        case .goalsView:
            break
        case .totalDetail:
            self.preview = .goalsView
        }
    }
    
    private func handleLeftPan() {
        switch self.preview {
        case .goalsView:
            self.preview = .totalDetail
        case .totalDetail:
            break
        }
    }
}
 
// MARK: - GoalsViewDelegate
extension MonthlyViewController: GoalsViewDelegate {
    func addGoalButtonTapped() {
        let addGoalViewController = CreateTransferLogViewController()
        addGoalViewController.configure(targetMonth: self.targetMonth)
        addGoalViewController.delegate = self
        present(addGoalViewController, animated: true, completion: nil)
    }
    
    func showGoalDetail(goal: Goal, imageColor: UIColor) {
        let goalDetailViewController = GoalDetailViewController(category: goal.category!, targetMonth: goal.targetMonth, imageColor: imageColor)
        goalDetailViewController.delegate = self
        navigationController?.pushViewController(goalDetailViewController, animated: true)
    }
}

// MARK: - GoalDetailView
extension MonthlyViewController: GoalDetailViewDelegate {
    func didUpdateTransactions() {
        self.updateDatas()
    }
}

// MARK: - TotalDetailView
extension MonthlyViewController: TotalDetailDelegate {
    internal func addBreakdownTapped() {
        createBreakdownView.configure(targetMonth: self.targetMonth)
        createBreakdownView.isHidden = false
        createBreakdownView.alpha = 0
        self.view.addSubview(createBreakdownView)
        
        NSLayoutConstraint.activate([
            createBreakdownView.topAnchor.constraint(equalTo: self.view.topAnchor),
            createBreakdownView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            createBreakdownView.heightAnchor.constraint(equalTo: self.view.heightAnchor)
        ])
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.createBreakdownView.alpha = 1.0
        }
    }
    
    internal func breakdownSelected(target: Breakdown) {
        createBreakdownView.configure(targetMonth: self.targetMonth, breakdown: target)
        createBreakdownView.isHidden = false
        createBreakdownView.alpha = 0
        self.view.addSubview(createBreakdownView)
        
        NSLayoutConstraint.activate([
            createBreakdownView.topAnchor.constraint(equalTo: self.view.topAnchor),
            createBreakdownView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            createBreakdownView.heightAnchor.constraint(equalTo: self.view.heightAnchor)
        ])
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        UIView.animate(withDuration: 0.3) {
            self.createBreakdownView.alpha = 1.0
        }
    }
    
    internal func addTransactionTapped() {
        let createTransactionView = TransactionEditorViewController()
        createTransactionView.configure(targetMonth: self.targetMonth)
        createTransactionView.delegate = self
        present(createTransactionView, animated: true, completion: nil)
    }
    
    internal func transactionSelected(target: Transaction) {
        let createTransactionView = TransactionEditorViewController()
        createTransactionView.configure(targetMonth: self.targetMonth, transaction: target)
        createTransactionView.delegate = self
        present(createTransactionView, animated: true, completion: nil)
    }
}

// MARK: - CreateGoal
extension MonthlyViewController: CreateTransferLogViewDelegate {
    internal func didAddTransferLog() {
        self.updateDatas()
    }
}

// MARK: - SelectTargetMonthView
extension MonthlyViewController: SelectTargetMonthDelegate {
    internal func okButtonTapped(targetMonth: String) {
        // TODO
    }
    
    internal func cancelButtonTapped() {
        // TODO
    }
}
// MARK: - BreakdownEditorView
extension MonthlyViewController: BreakdownEditorViewDelegate {
    internal func okButtonTapped_atBreakdownEditor() {
        self.updateDatas()
        
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.createBreakdownView.alpha = 0.0
        }, completion: { finished in
            self.createBreakdownView.isHidden = true
            self.createBreakdownView.removeFromSuperview()
        })
    }
    
    internal func cancelButtonTapped_atBreakdownEditor() {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.createBreakdownView.alpha = 0.0
        }, completion: { finished in
            self.createBreakdownView.isHidden = true
            self.createBreakdownView.removeFromSuperview()
        })
    }
}

extension MonthlyViewController: TransactionEditorViewDelegate {
    func saveBtnTapped_atTransactionEditor() {
        self.updateDatas()
    }
}
