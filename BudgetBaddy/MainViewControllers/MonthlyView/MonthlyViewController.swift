//
//  GoalViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/01.
//

import UIKit
import RealmSwift

class MonthlyViewController: UIViewController {
    internal var user: User?
    private var userWallets: [Wallet] = []
    private var sharedWallets: [Wallet] = []
    
    private var selectedWallet: Wallet?
    private var monthlyGoalsArray: [MonthlyGoals] = []
    private var monthlyTransactionsArray: [MonthlyTransactions] = []
    
    private let realm = try! Realm()
    private let dateFuncs = DateFuncs()
    
    private var targetMonth: String = "" {
        didSet {
            self.monthValue.text = String(self.targetMonth.suffix(2))
            // 初期表示時はアニメーションなし
            if oldValue == "" {
                return
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self.amountValue.alpha = 0.0
                self.balanceValue.alpha = 0.0
                self.goalsView.alpha = 0.0
                self.totalDetailView.alpha = 0.0
            }, completion: { finished in
                self.updateDataSet()
                self.scrollToTop()
                UIView.animate(withDuration: 0.3, animations: {
                    self.amountValue.alpha = 1.0
                    self.balanceValue.alpha = 1.0
                    self.goalsView.alpha = 1.0
                    self.totalDetailView.alpha = 1.0
                })
            })
        }
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private var totalGoal: Goal?
    
    enum PreviewStatus {
        case goalsView
        case totalDetail
    }
    private var preview: PreviewStatus = .goalsView {
        didSet {
            if oldValue == preview {
                return
            }
            if self.selectedWallet != nil {
                let monthlyGoals: MonthlyGoals?
                let monthlyTransactions: MonthlyTransactions?
                
                if let index = self.monthlyGoalsArray.firstIndex(where: {
                    $0.targetMonth == self.targetMonth && $0.walletId == self.selectedWallet!.walletId })
                {
                    monthlyGoals = self.monthlyGoalsArray[index]
                } else {
                    return
                }
                
                if let index = self.monthlyTransactionsArray.firstIndex(where: {
                    $0.targetMonth == self.targetMonth && $0.walletId == self.selectedWallet!.walletId })
                {
                    monthlyTransactions = self.monthlyTransactionsArray[index]
                } else {
                    return
                }
                
                switch preview {
                case .goalsView:
                    self.goalsView.configure(wallet: self.selectedWallet!,
                                             monthlyGoals: monthlyGoals!,
                                             monthlyTransactions: monthlyTransactions!)
                    validViewHorizontalAlignment?.constant = view.frame.width / 4
                    goalsViewLeadingConstraint?.constant = 0
                    
                    UIView.animate(withDuration: 0.4, animations: {
                        self.view.layoutIfNeeded()
                        self.mainViewLabel_1.textColor = .white
                        self.mainViewLabel_3.textColor = .systemGray6
                    }, completion: { finished in
                        self.scrollToTop()
                    })
                case .totalDetail:
                    self.totalDetailView.configure(monthlyGoals: monthlyGoals!,
                                                   monthlyTransactions: monthlyTransactions!)
                    validViewHorizontalAlignment?.constant = view.frame.width / 4 * 3
                    goalsViewLeadingConstraint?.constant = -view.frame.width
                    
                    UIView.animate(withDuration: 0.4, animations: {
                        self.view.layoutIfNeeded()
                        self.mainViewLabel_1.textColor = .systemGray6
                        self.mainViewLabel_3.textColor = .white
                    }, completion: { finished in
                        self.scrollToTop()
                    })
                }
            }
        }
    }
    
    enum HamburgerMenuClosedType {
        case logout
        case def
    }
    private var hamburgerMenuClosedType: HamburgerMenuClosedType = .def
    
    // NAVIGATION
    private let hamburgerButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .customWhiteSmoke
        button.image = UIImage(systemName: "line.3.horizontal")
        button.action = #selector(hamburgerButtonTapped)
        return button
    }()
    
    private let walletSettingBtn: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.tintColor = .customWhiteSmoke
        button.image = UIImage(systemName: "gearshape.fill")
        button.action = #selector(showWalletEditor)
        return button
    }()
    
    // TOP
    private let topViewHeight: CGFloat = 150
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
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.tag = 1
        return label
    }()
    
    private let mainViewLabel_3: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Breakdown", comment: "")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray6
        label.tag = 2
        return label
    }()
    
    private var goalsViewLeadingConstraint: NSLayoutConstraint?
    private var goalsViewHeightConstraint: NSLayoutConstraint?
    private let goalsView: GoalsView = {
        let goalsView = GoalsView()
        return goalsView
    }()
    
    private var totalDetailViewHeightConstraint: NSLayoutConstraint?
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
    
    private let previousButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "arrowtriangle.backward.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.setImage(UIImage(systemName: "arrowtriangle.right.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Month
    private let monthViewWidth: CGFloat = 80
    private let monthView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOpacity = 0.2
//        view.layer.shadowOffset = CGSize(width: 0, height: 1)
//        view.layer.shadowRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let monthValue: UILabel = {
        let label = UILabel()
        label.textColor = .customMediumSeaGreen
        label.font = UIFont.systemFont(ofSize: 64, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Month", comment: "")
        label.textColor = .customDarkGrayLight4
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let verticalView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
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
        label.text = NSLocalizedString("Go_TopLabel_001", comment: "") + ":"
        label.textColor = .customSteelBlue
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    private let amountValue: UILabel = {
        let label = UILabel()
        label.textColor = .customSteelBlue
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // balance
    private let balanceView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Go_TopLabel_002", comment: "") + ":"
        label.textColor = .customSlateGreen
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textAlignment = .left
        return label
    }()
    
    private let balanceValue: UILabel = {
        let label = UILabel()
        label.textColor = .customSlateGreen
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    // partition
    private var partitionCneterYAnchor: NSLayoutConstraint?
    private let partitionView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
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
        // Data
        self.updateDataSet(updateWallets: true, updateMonthlyGoals: true, updateMonthlyTransactions: true)
        // View
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        setupUI()
        addGradientBackground()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func updateDataSet(updateWallets: Bool = false,
                               updateMonthlyGoals: Bool = false,
                               updateMonthlyTransactions: Bool = false)
    {
        Task {
            /// データの取得・設定
            // TargetMonth: 初期値の設定のみ
            if self.targetMonth == "" 
            {
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM"
                self.targetMonth = dateFormatter.string(from: currentDate)
            }
            // UserWallets: 引数によって更新を明示された時のみ
            if updateWallets 
            {
                self.userWallets = await self.user!.fetchUserWallets()
                if self.selectedWallet == nil && self.userWallets.count > 0 {
                    self.selectedWallet = self.userWallets[0]
                }
                self.sharedWallets = await self.user!.fetchSharedWallets()
                if self.selectedWallet == nil && self.sharedWallets.count > 0 {
                    self.selectedWallet = self.sharedWallets[0]
                }
            }
            // MonthlyGoals: 選択中Walletがあるとき
            if self.selectedWallet != nil
            {
                if let index = self.monthlyGoalsArray.firstIndex(where: {
                    $0.targetMonth == self.targetMonth && $0.walletId == self.selectedWallet!.walletId })
                {
                    // すでにtargetMonthのMonthlyGoalsがり、引数によって更新を明示された時のみ
                    if updateMonthlyGoals {
                        let target = await MonthlyGoalsDao.fetchMonthlyGoals(walletId: self.selectedWallet!.walletId, 
                                                                             targetMonth: self.targetMonth)
                        self.monthlyGoalsArray[index] = target!
                    }
                } 
                else
                {
                    // targetMonthのMonthlyGoalsが未取得とき、データを取得する
                    let target = await MonthlyGoalsDao.fetchMonthlyGoals(walletId: self.selectedWallet!.walletId,
                                                                         targetMonth: self.targetMonth)
                    if let target = target {
                        self.monthlyGoalsArray.append(target)
                    } else {
                        // MonthlyGoalsが未登録のとき、データを作成する
                        let target = MonthlyGoals(walletId: self.selectedWallet!.walletId,
                                                  targetMonth: self.targetMonth,
                                                  budgetBreakdowns: [],
                                                  goals: [])
                        self.monthlyGoalsArray.append(target)
                        MonthlyGoalsDao.addMonthlyGoals(monthlyGoals: target)
                    }
                }
            }
            // MonthlyTransactions: 選択中Walletがあるとき
            if self.selectedWallet != nil 
            {
                if let index = self.monthlyTransactionsArray.firstIndex(where: {
                    $0.targetMonth == self.targetMonth && $0.walletId == self.selectedWallet!.walletId })
                {
                    // すでにtargetMonthのMonthlyTransactionsがあり、引数によって更新を明示された時のみ
                    if updateMonthlyTransactions {
                        let target = await MonthlyTransactionsDao.fetchMonthlyTransactions(walletId: self.selectedWallet!.walletId,
                                                                                           targetMonth: self.targetMonth)
                        self.monthlyTransactionsArray[index] = target!
                    }
                } 
                else
                {
                    // targetMonthのMonthlyGoalsが未取得のとき、データを取得する
                    let target = await MonthlyTransactionsDao.fetchMonthlyTransactions(walletId: self.selectedWallet!.walletId,
                                                                                       targetMonth: self.targetMonth)
                    if let target = target {
                        self.monthlyTransactionsArray.append(target)
                    } else {
                        // MonthlyGoalsが未登録のとき、データを作成する
                        let target = MonthlyTransactions(walletId: self.selectedWallet!.walletId,
                                                         targetMonth: self.targetMonth,
                                                         transactions: [])
                        self.monthlyTransactionsArray.append(target)
                        MonthlyTransactionsDao.addMonthlyTransactions(monthlyTransactions: target)
                    }
                }
            }
            
            /// データ取得に伴うViewの更新
            if self.selectedWallet == nil {
                return 
            }
            // 対象月のMonthlyGoals, MonthryTransactionsが取得された時のみ（バカ避け）
            if let monthlyGoals = self.getThisMonthGoals(),
               let monthlyTransactions = self.getThisMonthTransactions() {
                // TopView:
                amountValue.text = formatCurrency(amount: monthlyGoals.getTotalBudget())
                balanceValue.text = formatCurrency(amount: monthlyGoals.getTotalBudget() - monthlyTransactions.getExpense())
                
                // MainView: GoalsView, TotalDetailView
                switch preview {
                case .goalsView:
                    self.goalsView.configure(wallet: self.selectedWallet!, monthlyGoals: monthlyGoals, monthlyTransactions: monthlyTransactions)
                case.totalDetail :
                    self.totalDetailView.configure(monthlyGoals: monthlyGoals, monthlyTransactions: monthlyTransactions)
                }
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func addGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.backGradientColorFrom.cgColor, UIColor.backGradientColorTo.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // 既存のレイヤーの後ろにグラデーションレイヤーを追加
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupUI() {
        // navigation
        hamburgerButton.target = self
        walletSettingBtn.target = self
        navigationItem.leftBarButtonItem = hamburgerButton
        navigationItem.rightBarButtonItem = walletSettingBtn
        
        // view
        view.addSubview(scrollView)
        scrollView.addSubview(topView)
        scrollView.addSubview(goalsView)
        scrollView.addSubview(totalDetailView)
        scrollView.addSubview(horizonView)
        scrollView.addSubview(validView)
        scrollView.addSubview(mainViewLabel_1)
        scrollView.addSubview(mainViewLabel_3)
        
        scrollView.delegate = self
        goalsView.delegate = self
        totalDetailView.delegate = self
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        topView.translatesAutoresizingMaskIntoConstraints = false
        goalsView.translatesAutoresizingMaskIntoConstraints = false
        totalDetailView.translatesAutoresizingMaskIntoConstraints = false
        horizonView.translatesAutoresizingMaskIntoConstraints = false
        validView.translatesAutoresizingMaskIntoConstraints = false
        mainViewLabel_1.translatesAutoresizingMaskIntoConstraints = false
        mainViewLabel_3.translatesAutoresizingMaskIntoConstraints = false
        
        goalsViewLeadingConstraint = goalsView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        validViewHorizontalAlignment = validView.centerXAnchor.constraint(equalTo: horizonView.leadingAnchor, constant: view.frame.width / 4 * 1)
        goalsViewHeightConstraint = goalsView.heightAnchor.constraint(equalToConstant: 0)
        totalDetailViewHeightConstraint = totalDetailView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            topView.topAnchor.constraint(equalTo: scrollView.topAnchor),
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
            goalsViewHeightConstraint!,
            goalsView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            totalDetailView.topAnchor.constraint(equalTo: horizonView.bottomAnchor),
            totalDetailView.leadingAnchor.constraint(equalTo: goalsView.trailingAnchor),
            totalDetailViewHeightConstraint!,
            totalDetailView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        topView.addSubview(topAria)
        topView.addSubview(previousButton)
        topView.addSubview(nextButton)
        
        topAria.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topAria.topAnchor.constraint(equalTo: topView.topAnchor, constant: 22),
            topAria.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 36),
            topAria.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -36),
            topAria.heightAnchor.constraint(equalToConstant: topAriaHeight),
            
            nextButton.centerYAnchor.constraint(equalTo: topAria.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: topAria.trailingAnchor, constant: 6),
            nextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -6),
            
            previousButton.centerYAnchor.constraint(equalTo: topAria.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 6),
            previousButton.trailingAnchor.constraint(equalTo: topAria.leadingAnchor, constant: -6)
        ])
        
        // TopAria
        topAria.addSubview(monthView)
        monthView.addSubview(monthValue)
        monthView.addSubview(monthLabel)
        topAria.addSubview(verticalView)
        topAria.addSubview(balanceView)
        balanceView.addSubview(balanceLabel)
        balanceView.addSubview(balanceValue)
        topAria.addSubview(partitionView)
        topAria.addSubview(amountView)
        amountView.addSubview(amountLabel)
        amountView.addSubview(amountValue)
        
        monthView.translatesAutoresizingMaskIntoConstraints = false
        monthValue.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        verticalView.translatesAutoresizingMaskIntoConstraints = false
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceValue.translatesAutoresizingMaskIntoConstraints = false
        partitionView.translatesAutoresizingMaskIntoConstraints = false
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountValue.translatesAutoresizingMaskIntoConstraints = false
        
        partitionCneterYAnchor = partitionView.centerYAnchor.constraint(equalTo: topAria.topAnchor, constant: topAriaHeight / 2)
        
        NSLayoutConstraint.activate([
            // Month
            monthView.topAnchor.constraint(equalTo: topAria.topAnchor),
            monthView.leadingAnchor.constraint(equalTo: topAria.leadingAnchor),
            monthView.bottomAnchor.constraint(equalTo: topAria.bottomAnchor),
            monthView.widthAnchor.constraint(equalToConstant: monthViewWidth),
            
            monthValue.centerYAnchor.constraint(equalTo: monthView.centerYAnchor),
            monthValue.leadingAnchor.constraint(equalTo: monthView.leadingAnchor, constant: 18),
            monthValue.trailingAnchor.constraint(equalTo: monthView.trailingAnchor, constant: -18),
            
            monthLabel.bottomAnchor.constraint(equalTo: monthView.bottomAnchor, constant: -8),
            monthLabel.trailingAnchor.constraint(equalTo: monthView.trailingAnchor, constant: -8),
            
            verticalView.leadingAnchor.constraint(equalTo: monthView.trailingAnchor),
            verticalView.topAnchor.constraint(equalTo: topAria.topAnchor),
            verticalView.bottomAnchor.constraint(equalTo: topAria.bottomAnchor),
            verticalView.widthAnchor.constraint(equalToConstant: 1),
            
            // AMOUNT
            amountView.topAnchor.constraint(equalTo: topAria.topAnchor),
            amountView.leadingAnchor.constraint(equalTo: verticalView.trailingAnchor),
            amountView.trailingAnchor.constraint(equalTo: topAria.trailingAnchor),
            amountView.bottomAnchor.constraint(equalTo: partitionView.topAnchor),
            
            amountLabel.centerYAnchor.constraint(equalTo: amountView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(equalTo: amountView.leadingAnchor, constant: 24),
            
            amountValue.centerYAnchor.constraint(equalTo: amountView.centerYAnchor),
            amountValue.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 8),
            amountValue.trailingAnchor.constraint(equalTo: amountView.trailingAnchor, constant: -16),

            // PARTITION
            partitionView.leadingAnchor.constraint(equalTo: verticalView.trailingAnchor),
            partitionView.trailingAnchor.constraint(equalTo: topAria.trailingAnchor),
            partitionView.heightAnchor.constraint(equalToConstant: 1),
            partitionCneterYAnchor!,
            
            // BALANCE
            balanceView.topAnchor.constraint(equalTo: partitionView.bottomAnchor),
            balanceView.leadingAnchor.constraint(equalTo: verticalView.trailingAnchor),
            balanceView.trailingAnchor.constraint(equalTo: topAria.trailingAnchor),
            balanceView.bottomAnchor.constraint(equalTo: topAria.bottomAnchor),
            
            balanceLabel.centerYAnchor.constraint(equalTo: balanceView.centerYAnchor),
            balanceLabel.leadingAnchor.constraint(equalTo: balanceView.leadingAnchor, constant: 24),
            
            balanceValue.centerYAnchor.constraint(equalTo: balanceView.centerYAnchor),
            balanceValue.leadingAnchor.constraint(equalTo: balanceLabel.trailingAnchor, constant: 8),
            balanceValue.trailingAnchor.constraint(equalTo: balanceView.trailingAnchor, constant: -16),
        ])
        
        // MARK: - DIALOG
        // CreateBreakdownView
        createBreakdownView.delegate = self
        createBreakdownView.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - GESTURE
        let tapGesture_mainViewLabel_1 = UITapGestureRecognizer(target: self, action: #selector(mainViewLabelTapped(_:)))
        mainViewLabel_1.isUserInteractionEnabled = true
        mainViewLabel_1.addGestureRecognizer(tapGesture_mainViewLabel_1)
        let tapGesture_mainViewLabel_3 = UITapGestureRecognizer(target: self, action: #selector(mainViewLabelTapped(_:)))
        mainViewLabel_3.isUserInteractionEnabled = true
        mainViewLabel_3.addGestureRecognizer(tapGesture_mainViewLabel_3)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewPanGesture(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(panGesture)
    }
    
    private func scrollToTop() {
        self.scrollView.scrollRectToVisible(.init(x: scrollView.contentOffset.x
                                                  , y: 0
                                                  , width: scrollView.frame.width
                                                  , height: scrollView.frame.height)
                                            , animated: true)
    }
    
    private func updateScrollViewContentHeight(height: CGFloat) {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: height)
    }
    
    private func hamburgerMenuClosedEvent() {
        switch self.hamburgerMenuClosedType {
        case .logout:
            dismiss(animated: true)
        case .def:
            break
        }
    }
    
    private func getThisMonthGoalsIndex() -> Int? {
        if let index = self.monthlyGoalsArray.firstIndex(where: {
            $0.targetMonth == self.targetMonth && $0.walletId == self.selectedWallet!.walletId })
        {
            return index
        } else {
            return nil
        }
    }
    
    private func getThisMonthGoals() -> MonthlyGoals? {
        if let index = self.monthlyGoalsArray.firstIndex(where: {
            $0.targetMonth == self.targetMonth && $0.walletId == self.selectedWallet!.walletId })
        {
            return self.monthlyGoalsArray[index]
        } else {
            return nil
        }
    }
    
    private func getThisMonthTransactionsIndex() -> Int? {
        if let index = self.monthlyTransactionsArray.firstIndex(where: {
            $0.targetMonth == self.targetMonth && $0.walletId == self.selectedWallet!.walletId })
        {
            return index
        } else {
            return nil
        }
    }
    
    private func getThisMonthTransactions() -> MonthlyTransactions? {
        if let index = self.monthlyTransactionsArray.firstIndex(where: {
            $0.targetMonth == self.targetMonth && $0.walletId == self.selectedWallet!.walletId })
        {
            return self.monthlyTransactionsArray[index]
        } else {
            return nil
        }
    }
    
    // MARK: - ActionEvent
    @objc func hamburgerButtonTapped(_ sender: UIBarButtonItem) {
        self.hamburgerMenuClosedType = .def
        let hamburgerMenuVC = HamburgerMenuViewController(loginUserInfo: self.user!, userWallets: self.userWallets, sharedWallets: self.sharedWallets, selectedWallet: self.selectedWallet ?? nil)
        hamburgerMenuVC.delegate = self
        hamburgerMenuVC.modalPresentationStyle = .overFullScreen
        hamburgerMenuVC.completion = { [weak self] in
            self?.hamburgerMenuClosedEvent()
        }
        self.present(hamburgerMenuVC, animated: false, completion: nil)
    }
    
    @objc func showWalletEditor(_ sender: UIBarButtonItem) {
        if self.selectedWallet != nil {
            let modalViewController = WalletEditorViewController(wallet: self.selectedWallet!)
            modalViewController.modalPresentationStyle = .automatic
            self.present(modalViewController, animated: true, completion: nil)
        }
    }
    
    @objc func previousButtonTapped() {
        let currentDate: Date = DateFuncs().convertStringToDate(self.targetMonth, format: "yyyy-MM")!
        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate),
              currentDate > Calendar.current.date(byAdding: .year, value: -1, to: Date())!  else {
            return
        }
        self.targetMonth = DateFuncs().convertStringFromDate(previousMonth, format: "yyyy-MM")
    }

    @objc private func nextButtonTapped() {
        let currentDate: Date = DateFuncs().convertStringToDate(self.targetMonth, format: "yyyy-MM")!
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) // ,nextMonth <= Date()
        else {
            return
        }
        self.targetMonth = DateFuncs().convertStringFromDate(nextMonth, format: "yyyy-MM")
    }
    
    // MARK: - GestureEvent
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
// MARK: - HamburgerMenu
extension MonthlyViewController: HamburgerMenuViewDelegate {
    func walletSelected(wallet: Wallet) {
        if self.selectedWallet?.walletId != wallet.walletId {
            self.selectedWallet = wallet
            self.updateDataSet(updateMonthlyGoals: true, updateMonthlyTransactions: true)
        }
    }
    
    internal func logout() {
        self.hamburgerMenuClosedType = .logout
    }
}

// MARK: - NAVIGATIONVIEW
extension MonthlyViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // スクロール時イベント
    }
}

// MARK: - GoalsViewDelegate
extension MonthlyViewController: GoalsViewDelegate {
    internal func updatedGoalsViewHeight(viewHeight: CGFloat) {
        self.goalsViewHeightConstraint?.constant = viewHeight
        self.updateScrollViewContentHeight(height: self.horizonView.frame.maxY + viewHeight)
    }
    
    internal func addGoalButtonTapped() {
//        let addGoalViewController = CreateTransferLogViewController()
//        addGoalViewController.configure(targetMonth: self.targetMonth)
//        addGoalViewController.delegate = self
//        present(addGoalViewController, animated: true, completion: nil)
    }
    
    internal func showGoalDetail(goal: Goal) {
        if let category = self.selectedWallet?.getCategoryById(categoryId: goal.categoryId),
           let monthlyTransactions = self.getThisMonthTransactions()
        {
            
            let goalDetailViewController = GoalDetailViewController(targetMonth: self.targetMonth,
                                                                    wallet: self.selectedWallet!,
                                                                    goal: goal,
                                                                    category: category,
                                                                    transactions: monthlyTransactions.getCategoryOfTransactions(categoryId: category.categoryId))
            goalDetailViewController.delegate = self
            navigationController?.pushViewController(goalDetailViewController, animated: true)
        }
    }
}

// MARK: - GoalDetailView
extension MonthlyViewController: GoalDetailViewDelegate {
    func didUpdateCategories(categories: [Category]) {
        self.selectedWallet!.categories = categories
        updateDataSet()
    }
    
    func didUpdateTransactions(transactions: [Transaction]) {
        if let index = self.getThisMonthTransactionsIndex() {
            self.monthlyTransactionsArray[index].transactions = transactions
            updateDataSet()
        }
    }
}

// MARK: - TotalDetailView
extension MonthlyViewController: TotalDetailDelegate {
    internal func updatedTotalDetailViewHeight(viewHeight: CGFloat) {
        self.totalDetailViewHeightConstraint?.constant = viewHeight
        self.updateScrollViewContentHeight(height: self.horizonView.frame.maxY + viewHeight)
    }
    
    internal func addBreakdownTapped() {
        if let walletId = self.selectedWallet?.walletId {
            createBreakdownView.configure(walletId: walletId, targetMonth: self.targetMonth)
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
    }
    
    internal func breakdownSelected(target: BudgetBreakdown) {
        if let walletId = self.selectedWallet?.walletId {
            createBreakdownView.configure(walletId: walletId, targetMonth: self.targetMonth, breakdown: target)
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
    }
    
    internal func addTransactionTapped() {
        if self.selectedWallet != nil {
            let createTransactionView = TransactionEditorViewController(wallet: self.selectedWallet!,
                                                                        targetMonth: self.targetMonth)
            createTransactionView.delegate = self
            present(createTransactionView, animated: true, completion: nil)
        }
    }
    
    internal func transactionSelected(target: Transaction) {
        if self.selectedWallet != nil {
            let createTransactionView = TransactionEditorViewController(wallet: self.selectedWallet!,
                                                                        targetMonth: self.targetMonth,
                                                                        transaction: target)
            createTransactionView.delegate = self
            present(createTransactionView, animated: true, completion: nil)
        }
    }
}

// MARK: - BreakdownEditorView
extension MonthlyViewController: BreakdownEditorViewDelegate {
    internal func createdBreakdown(target: BudgetBreakdown) {
        if let index = self.monthlyGoalsArray.firstIndex(where: { $0.walletId == self.selectedWallet?.walletId
            && $0.targetMonth == self.targetMonth })
        {
            self.monthlyGoalsArray[index].budgetBreakdowns.append(target)
        }
        updateDataSet()
        closecreateBreakdownView()
    }
    
    internal func updatedBreakdonw(target: BudgetBreakdown) {
        if let index = self.monthlyGoalsArray.firstIndex(where: { $0.walletId == self.selectedWallet?.walletId
            && $0.targetMonth == self.targetMonth })
        {
            if let targetIndex = self.monthlyGoalsArray[index].budgetBreakdowns.firstIndex(where: { $0.id == target.id })
            {
                self.monthlyGoalsArray[index].budgetBreakdowns[targetIndex] = target
            }
        }
        updateDataSet()
        closecreateBreakdownView()
    }
    
    internal func cancelButtonTapped_atBreakdownEditor() {
        closecreateBreakdownView()
    }
    
    private func closecreateBreakdownView() {
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
    func addCategory(category: Category) {
        if self.selectedWallet != nil {
            self.updateDataSet()
        }
    }
    
    func addTransaction(transaction: Transaction) {
        if let index = self.getThisMonthTransactionsIndex() {
            self.monthlyTransactionsArray[index].transactions.append(transaction)
            self.updateDataSet()
        }
    }
    
    func updateTransaction(transaction: Transaction) {
        if let index = self.getThisMonthTransactionsIndex() {
            if let transIndex = self.monthlyTransactionsArray[index].transactions.firstIndex(where: { $0.id == transaction.id })
            {
                self.monthlyTransactionsArray[index].transactions[transIndex] = transaction
                self.updateDataSet()
            }
        }
    }
    
    func saveBtnTapped_atTransactionEditor() {
        self.updateDataSet(updateMonthlyTransactions: true)
    }
}
