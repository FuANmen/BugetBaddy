//
//  CreateGoalViewController.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/01/17.
//

import UIKit

// MARK: - AddGoalViewController
protocol CreateTransferLogViewDelegate: AnyObject {
    func didAddTransferLog()
}

class CreateTransferLogViewController: UIViewController {
    weak var delegate: CreateTransferLogViewDelegate?
    var targetMonth: String = ""
    
    // TransferLog引数
    var destination: Category? = nil
    var source: Goal? = nil
    var amount: Double = 0.0
    
    var createDestFlg: Bool = false
    
    // ステータス
    var currentStatus: Status = .selectDestination {
        didSet {
            switch currentStatus {
            case .selectDestination:
                // StatusView
                state_1.tintColor = .systemGreen
                line_1to2.backgroundColor = .systemGray4
                state_2.tintColor = .systemGray4
                line_2to3.backgroundColor = .systemGray4
                state_3.tintColor = .systemGray4
                // Text
                destValue.text = NSLocalizedString("AdGo_Label_003", comment: "")
                sourceValue.text = NSLocalizedString("AdGo_Label_004", comment: "")
                operationMessageLabel.text = NSLocalizedString("AdGo_MS_SettingDestination", comment: "")
                // SelectViews
                selectDestTableLeadingConstraint?.constant = 0
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            case .selectSource:
                // StatusView
                state_1.tintColor = .systemGreen
                line_1to2.backgroundColor = .systemGreen
                state_2.tintColor = .systemGreen
                line_2to3.backgroundColor = .systemGray4
                state_3.tintColor = .systemGray4
                // Text
                destValue.text = self.destination!.name
                sourceValue.text = NSLocalizedString("AdGo_Label_003", comment: "")
                operationMessageLabel.text = NSLocalizedString("AdGo_MS_SettingSource", comment: "")
                // SelectViews
                selectDestTableLeadingConstraint?.constant = -view.frame.width
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            case .selectAmount:
                // StatusView
                state_1.tintColor = .systemGreen
                line_1to2.backgroundColor = .systemGreen
                state_2.tintColor = .systemGreen
                line_2to3.backgroundColor = .systemGreen
                state_3.tintColor = .systemGreen
                // Text
                destValue.text = self.destination!.name
                sourceValue.text = self.source!.category!.name
                operationMessageLabel.text = NSLocalizedString("AdGo_MS_SettingAmount", comment: "")
                // SelectViews
                selectDestTableLeadingConstraint?.constant = -view.frame.width * 2
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    enum Status {
        case selectDestination
        case selectSource
        case selectAmount
    }
    
    // HEADER VIEW
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = BACKGROUND_COLOR
        return view
    }()
    
    private let headerGroup_1: UIView = {
        let view = UIView()
        return view
    }()
    
    private let targetMonthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.text = NSLocalizedString("Target", comment: "") + ":"
        return label
    }()
    
    private let targetMonthValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    private let destLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.text = NSLocalizedString("AdGo_Label_001", comment: "") + ":"
        return label
    }()
    
    private let destValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.text = NSLocalizedString("AdGo_Label_003", comment: "")
        label.setLine(color: .white, bottom: true)
        return label
    }()
    
    private let destIcon: UIImageView = {
        let image = UIImageView()
        image.setSymbolImage(UIImage(systemName: "arrow.right")!, contentTransition: .automatic)
        image.tintColor = .white
        return image
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.text = NSLocalizedString("AdGo_Label_002", comment: "") + ":"
        return label
    }()
    
    private let sourceValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.text = NSLocalizedString("AdGo_Label_004", comment: "")
        label.setLine(color: .white, top: true)
        return label
    }()
    
    private let sourceIcon: UIImageView = {
        let image = UIImageView()
        // image.setSymbolImage(UIImage(systemName: "arrow.right")!, contentTransition: .automatic)
        image.tintColor = .white
        return image
    }()
    
    // STEPVIEW
    private let stepView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let state_1: UIImageView = {
        let view = UIImageView()
        view.setSymbolImage(UIImage(systemName: "1.circle.fill")!, contentTransition: .automatic)
        view.contentMode = .scaleAspectFit
        view.tintColor = .systemGreen
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let line_1to2: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let state_2: UIImageView = {
        let view = UIImageView()
        view.setSymbolImage(UIImage(systemName: "2.circle.fill")!, contentTransition: .automatic)
        view.contentMode = .scaleAspectFit
        view.tintColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let line_2to3: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let state_3: UIImageView = {
        let view = UIImageView()
        view.setSymbolImage(UIImage(systemName: "3.circle.fill")!, contentTransition: .automatic)
        view.contentMode = .scaleAspectFit
        view.tintColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    // COMMENT AREA
    private let commentArea: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.shadowColor = UIColor.systemGray3.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.6
        view.layer.shadowRadius = 2
        return view
    }()
    
    private let operationMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.text = NSLocalizedString("AdGo_MS_SettingDestination", comment: "")
        return label
    }()
    
    // MAIN VIEW
    private var selectDestTableLeadingConstraint: NSLayoutConstraint?
    private let selectDestTable: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tag = 0
        return tableView
    }()
    
    private let selectSourceTable: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(IconTableCell.self, forCellReuseIdentifier: IconTableCell.identifier)
        tableView.register(TranLogDestinationCategoryCell.self, forCellReuseIdentifier: TranLogDestinationCategoryCell.identifier)
        tableView.register(TranLogSourceGoalCell.self, forCellReuseIdentifier: TranLogSourceGoalCell.identifier)
        tableView.tag = 1
        return tableView
    }()
    
    private let setAmountView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let amountField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("TransferAmount", comment: "")
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        button.backgroundColor = .systemGreen
        button.titleLabel!.textColor = .white
        return button
    }()
    
    // BOTTOM VIEW
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.shadowColor = UIColor.systemGray3.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.6
        view.layer.shadowRadius = 1
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        button.tintColor = .systemBlue
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitle(NSLocalizedString("Back", comment: ""), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    // Dialog
    private let categoryCreateDialog: CreateCategoryDialogView = {
        let view = CreateCategoryDialogView()
        view.isHidden = true
        return view
    }()
    
    internal func configure(targetMonth: String, destCategory: Category? = nil) {
        self.targetMonth = targetMonth
        self.source = GoalDao().getTotalGoal(targetMonth: targetMonth)
        self.targetMonthValue.text = String(self.targetMonth.suffix(2)) + NSLocalizedString("Month", comment: "")
        self.destination = destCategory
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if self.destination == nil {
            self.currentStatus = .selectDestination
        } else {
            self.currentStatus = .selectSource
        }
    }
    
    private func setupUI() {
        // VIEW
        view.addSubview(headerView)
        view.addSubview(selectSourceTable)
        view.addSubview(selectDestTable)
        view.addSubview(stepView)
        view.addSubview(commentArea)
        view.addSubview(setAmountView)
        view.addSubview(bottomView)
        view.addSubview(categoryCreateDialog)
        
        selectSourceTable.delegate = self
        selectSourceTable.dataSource = self
        selectDestTable.delegate = self
        selectDestTable.dataSource = self
        categoryCreateDialog.delegate = self
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        stepView.translatesAutoresizingMaskIntoConstraints = false
        commentArea.translatesAutoresizingMaskIntoConstraints = false
        setAmountView.translatesAutoresizingMaskIntoConstraints = false
        selectSourceTable.translatesAutoresizingMaskIntoConstraints = false
        selectDestTable.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        categoryCreateDialog.translatesAutoresizingMaskIntoConstraints = false
        
        // 可変レイアウト設定
        selectDestTableLeadingConstraint = selectDestTable.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 76),
            
            stepView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            stepView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stepView.heightAnchor.constraint(equalToConstant: 56),
            
            commentArea.topAnchor.constraint(equalTo: stepView.bottomAnchor),
            commentArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commentArea.heightAnchor.constraint(equalToConstant: 32),
            
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 60),
            
            selectDestTable.topAnchor.constraint(equalTo: commentArea.bottomAnchor),
            selectDestTable.widthAnchor.constraint(equalTo: view.widthAnchor),
            selectDestTableLeadingConstraint!,
            selectDestTable.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            selectSourceTable.topAnchor.constraint(equalTo: commentArea.bottomAnchor),
            selectSourceTable.widthAnchor.constraint(equalTo: view.widthAnchor),
            selectSourceTable.leadingAnchor.constraint(equalTo: selectDestTable.trailingAnchor),
            selectSourceTable.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            setAmountView.topAnchor.constraint(equalTo: commentArea.bottomAnchor),
            setAmountView.widthAnchor.constraint(equalTo: view.widthAnchor),
            setAmountView.leadingAnchor.constraint(equalTo: selectSourceTable.trailingAnchor),
            setAmountView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
        ])
        
        // STEPVIEW
        stepView.addSubview(line_1to2)
        stepView.addSubview(line_2to3)
        stepView.addSubview(state_1)
        stepView.addSubview(state_2)
        stepView.addSubview(state_3)
        
        state_1.translatesAutoresizingMaskIntoConstraints = false
        line_1to2.translatesAutoresizingMaskIntoConstraints = false
        state_2.translatesAutoresizingMaskIntoConstraints = false
        line_2to3.translatesAutoresizingMaskIntoConstraints = false
        state_3.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            state_1.centerYAnchor.constraint(equalTo: stepView.centerYAnchor),
            state_1.centerXAnchor.constraint(equalTo: stepView.leadingAnchor, constant: view.frame.width / 8),
            state_1.heightAnchor.constraint(equalToConstant: 24),
            state_1.widthAnchor.constraint(equalToConstant: 24),
            
            line_1to2.centerYAnchor.constraint(equalTo: stepView.centerYAnchor),
            line_1to2.leadingAnchor.constraint(equalTo: state_1.trailingAnchor, constant: -4),
            line_1to2.trailingAnchor.constraint(equalTo: state_2.leadingAnchor, constant: 4),
            line_1to2.heightAnchor.constraint(equalToConstant: 2),
        
            state_2.centerYAnchor.constraint(equalTo: stepView.centerYAnchor),
            state_2.centerXAnchor.constraint(equalTo: stepView.centerXAnchor),
            state_2.heightAnchor.constraint(equalToConstant: 24),
            state_2.widthAnchor.constraint(equalToConstant: 24),
            
            line_2to3.centerYAnchor.constraint(equalTo: stepView.centerYAnchor),
            line_2to3.leadingAnchor.constraint(equalTo: state_2.trailingAnchor, constant: -4),
            line_2to3.trailingAnchor.constraint(equalTo: state_3.leadingAnchor, constant: 4),
            line_2to3.heightAnchor.constraint(equalToConstant: 2),
            
            state_3.centerYAnchor.constraint(equalTo: stepView.centerYAnchor),
            state_3.centerXAnchor.constraint(equalTo: stepView.leadingAnchor, constant: view.frame.width / 8 * 7),
            state_3.heightAnchor.constraint(equalToConstant: 24),
            state_3.widthAnchor.constraint(equalToConstant: 24),
        ])
        
        // COMENT AREA
        commentArea.addSubview(operationMessageLabel)
        
        operationMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            operationMessageLabel.centerYAnchor.constraint(equalTo: commentArea.centerYAnchor),
            operationMessageLabel.leadingAnchor.constraint(equalTo: commentArea.leadingAnchor, constant: 8)
        ])
        
        // HEADER VIEW
        headerView.addSubview(headerGroup_1)
        headerGroup_1.addSubview(targetMonthLabel)
        headerGroup_1.addSubview(targetMonthValue)
        headerGroup_1.addSubview(destLabel)
        headerGroup_1.addSubview(destValue)
        headerGroup_1.addSubview(destIcon)
        headerGroup_1.addSubview(sourceLabel)
        headerGroup_1.addSubview(sourceValue)
        headerGroup_1.addSubview(sourceIcon)
        
        headerGroup_1.translatesAutoresizingMaskIntoConstraints = false
        targetMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        targetMonthValue.translatesAutoresizingMaskIntoConstraints = false
        destLabel.translatesAutoresizingMaskIntoConstraints = false
        destValue.translatesAutoresizingMaskIntoConstraints = false
        destIcon.translatesAutoresizingMaskIntoConstraints = false
        sourceLabel.translatesAutoresizingMaskIntoConstraints = false
        sourceValue.translatesAutoresizingMaskIntoConstraints = false
        sourceIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerGroup_1.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerGroup_1.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 12),
            headerGroup_1.heightAnchor.constraint(equalToConstant: 44),
            
            targetMonthLabel.topAnchor.constraint(equalTo: headerGroup_1.topAnchor),
            targetMonthLabel.leadingAnchor.constraint(equalTo: headerGroup_1.leadingAnchor),
            
            targetMonthValue.centerYAnchor.constraint(equalTo: targetMonthLabel.centerYAnchor),
            targetMonthValue.leadingAnchor.constraint(equalTo: targetMonthLabel.trailingAnchor, constant: 2),
            
            sourceLabel.centerYAnchor.constraint(equalTo: targetMonthLabel.centerYAnchor),
            sourceLabel.leadingAnchor.constraint(equalTo: targetMonthValue.trailingAnchor, constant: 20),
            
            sourceValue.centerYAnchor.constraint(equalTo: sourceLabel.centerYAnchor),
            sourceValue.leadingAnchor.constraint(equalTo: sourceLabel.trailingAnchor, constant: 8),
            
            sourceIcon.centerYAnchor.constraint(equalTo: sourceValue.centerYAnchor),
            sourceIcon.leadingAnchor.constraint(equalTo: sourceValue.trailingAnchor, constant: 6),
            
            destIcon.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor, constant: 4),
            destIcon.leadingAnchor.constraint(equalTo: targetMonthValue.trailingAnchor, constant: 28),
            
            destLabel.centerYAnchor.constraint(equalTo: destIcon.centerYAnchor),
            destLabel.leadingAnchor.constraint(equalTo: destIcon.trailingAnchor, constant: 4),
            
            destValue.centerYAnchor.constraint(equalTo: destLabel.centerYAnchor),
            destValue.leadingAnchor.constraint(equalTo: destLabel.trailingAnchor, constant: 8)
        ])
        
        // SET AMOUNT VIEW
        setAmountView.addSubview(amountField)
        setAmountView.addSubview(saveButton)
        
        amountField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            amountField.topAnchor.constraint(equalTo: setAmountView.topAnchor, constant: 42),
            amountField.leadingAnchor.constraint(equalTo: setAmountView.leadingAnchor, constant: 32),
            amountField.trailingAnchor.constraint(equalTo: setAmountView.trailingAnchor, constant: -32),
            amountField.widthAnchor.constraint(equalToConstant: setAmountView.frame.width * 0.7),
            
            saveButton.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 64),
            saveButton.centerXAnchor.constraint(equalTo: setAmountView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        // BOTTOM VIEW
        bottomView.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // キーボードを閉じるためのジェスチャーを追加
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        setAmountView.addGestureRecognizer(tapGesture)
    }
    
    private func showCateCreateDialog() {
        categoryCreateDialog.isHidden = false
        categoryCreateDialog.alpha = 0
        self.view.addSubview(categoryCreateDialog)
        
        NSLayoutConstraint.activate([
            categoryCreateDialog.topAnchor.constraint(equalTo: self.view.topAnchor),
            categoryCreateDialog.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            categoryCreateDialog.heightAnchor.constraint(equalTo: self.view.heightAnchor)
        ])
        
        UIView.animate(withDuration: 0.3) {
            self.categoryCreateDialog.alpha = 1.0
        }
    }
    
    // MARK: - Button Actions
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Action
extension CreateTransferLogViewController {
    // ステータスの更新
    private func updateStatus(indexPath: IndexPath) {
        switch self.currentStatus {
        case .selectDestination:
            self.currentStatus = .selectSource
        case .selectSource:
            self.currentStatus = .selectAmount
        case .selectAmount:
            break
        }
    }
    
    @objc private func backButtonTapped() {
        switch self.currentStatus{
        case .selectDestination:
            dismiss(animated: true, completion: nil)
        case .selectSource:
            self.currentStatus = .selectDestination
        case .selectAmount:
            self.currentStatus = .selectSource
        }
    }
    
    @objc private func saveButtonTapped() {
        // TODO: 入力チェック
        
        TransferLogDao().createTransferLog(targetMonth: self.targetMonth
                                           , sourCategory: self.source!.category!
                                           , destCategory: self.destination!
                                           , amount: Double(amountField.text!)!
                                           , title: NSLocalizedString("DefaultValue", comment: ""))
        self.delegate?.didAddTransferLog()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension CreateTransferLogViewController: UITableViewDelegate, UITableViewDataSource {
    // テーブルビューのセクション数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // テーブルビューの行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return destinationCategory.count + 1
        case 1:
            return sourceGoal.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0 {
            if indexPath.row < destinationCategory.count {
                return TranLogDestinationCategoryCell.cellHeight
            } else {
                return 60
            }
        }
        if tableView.tag == 1 {
            return TranLogSourceGoalCell.cellHeight
        }
        return 20
    }
    
    // テーブルビューのセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            if indexPath.row < destinationCategory.count {
                let cell = TranLogDestinationCategoryCell(style: .default, reuseIdentifier: TranLogSourceGoalCell.identifier)
                cell.configure(category: self.destinationCategory[indexPath.row])
                
                let target = GoalDao().getGoalsByCategory(category: self.destinationCategory[indexPath.row], targetMonth: self.targetMonth)
                if target.count > 0 {
                    cell.infoLabel.text = NSLocalizedString("AdGo_CellLabel_001", comment: "")
                    cell.iconImage.setSymbolImage(UIImage(systemName: "checkmark.seal.fill")!, contentTransition: .automatic)
                    cell.tintColor = .systemYellow
                } else {
                    cell.infoLabel.text = NSLocalizedString("AdGo_CellLabel_002", comment: "")
                    cell.iconImage.setSymbolImage(UIImage(systemName: "seal")!, contentTransition: .automatic)
                    cell.iconImage.tintColor = .systemGray5
                }
                return cell
            } else {
                let cell = IconTableCell(style: .default, reuseIdentifier: IconTableCell.identifier)
                cell.configure(image: UIImage(systemName: "square.grid.3x1.folder.badge.plus")!, title: NSLocalizedString("AdGo_CellLabel_003", comment: ""))
                return cell
            }
        }
        if tableView.tag == 1 {
            let cell = TranLogSourceGoalCell(style: .default, reuseIdentifier: TranLogSourceGoalCell.identifier)
            cell.configure(goal: self.sourceGoal[indexPath.row])
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        return cell
    }
    
    // セルが選択されたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView.tag {
        case 0:
            // 宛先カテゴリ選択時
            if indexPath.row < destinationCategory.count {
                self.createDestFlg = false
                self.destination = self.destinationCategory[indexPath.row]
            } else {
                self.showCateCreateDialog()
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
        case 1:
            // 送信元Goal選択時
            self.source = self.sourceGoal[indexPath.row]
            sourceValue.text = self.source!.category!.name
        default:
            break
        }
        updateStatus(indexPath: indexPath)
    }
}

// ステータスごとのデータ
extension CreateTransferLogViewController {
    var sourceGoal: [Goal] {
        var goals: [Goal] = []
        let goal: Goal? = GoalDao().getOtherGoal(targetMonth: self.targetMonth)
        if goal != nil {
            goals.append(goal!)
        }
        return goals
    }
    var destinationCategory: [Category] {
        var categories: [Category] = []
        
        let inExCategories = CategoryDao().getUserCategories()
        inExCategories.forEach { category in
            categories.append(category)
        }
        return categories
    }
}

extension CreateTransferLogViewController: CreateCategoryDialogViewDelegate {
    func okButtonTapped() {
        self.selectSourceTable.reloadData()
        self.selectDestTable.reloadData()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.categoryCreateDialog.alpha = 0.0
        }, completion: { finished in
            self.categoryCreateDialog.isHidden = true
            self.categoryCreateDialog.removeFromSuperview()
        })
    }
    
    func cancelButtonTapped() {
        UIView.animate(withDuration: 0.2, animations: {
            self.categoryCreateDialog.alpha = 0.0
        }, completion: { finished in
            self.categoryCreateDialog.isHidden = true
            self.categoryCreateDialog.removeFromSuperview()
        })
    }
}
