//
//  DeleteGoalView.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/03/09.
//

import UIKit

protocol DeleteGoalDelegate: AnyObject {
    func okButtonTapped()
    func cancelButtonTapped()
}

class DeleteGoalView: UIView {
    weak var delegate: DeleteGoalDelegate?
    
    var walletId: String = ""
    var targetMonth: String = ""
    var thisGoal: Goal? = nil
    
    private var dialogView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private var view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var label1: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("DelGoal_MS_001", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    var radioSelectedFlg_1: Bool = false
    private lazy var radioArie_1: UIView = {
        let view = UIView()
        view.tag = 1
        view.isUserInteractionEnabled = true
        let target = UITapGestureRecognizer(target: self, action: #selector(radioAriaTapped(_:)))
        view.addGestureRecognizer(target)
        return view
    }()
    private var radioButton_1: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    private var radioLabel_1: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("DelGoalRadio_MS_001", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    var radioSelectedFlg_2: Bool = false
    private lazy var radioArie_2: UIView = {
        let view = UIView()
        view.tag = 2
        view.isUserInteractionEnabled = true
        let target = UITapGestureRecognizer(target: self, action: #selector(radioAriaTapped(_:)))
        view.addGestureRecognizer(target)
        return view
    }()
    private var radioButton_2: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    private var radioLabel_2: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("DelGoalRadio_MS_002", comment: "")
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private var okButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var horizonLine: UIView = {
        let line = UIView()
        line.backgroundColor = .systemGray3
        return line
    }()
    
    private var verticalLine: UIView = {
        let line = UIView()
        line.backgroundColor = .systemGray3
        return line
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDialogView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        setupDialogView()
    }
    
    func setInit(goal: Goal) {
        self.thisGoal = goal
        updateRadioButtons(tag: 1)
    }
    
    // MARK: - Setup
    private func setupDialogView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        self.addSubview(dialogView)
        dialogView.addSubview(horizonLine)
        dialogView.addSubview(verticalLine)
        dialogView.addSubview(view)
        dialogView.addSubview(okButton)
        dialogView.addSubview(cancelButton)
        
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        horizonLine.translatesAutoresizingMaskIntoConstraints = false
        verticalLine.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        okButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        let viewWidth =  UIScreen.main.bounds.size.width * 0.85
        
        NSLayoutConstraint.activate([
            dialogView.widthAnchor.constraint(equalToConstant: viewWidth),
            dialogView.heightAnchor.constraint(equalToConstant: 160),
            dialogView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            dialogView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            horizonLine.heightAnchor.constraint(equalToConstant: 1),
            horizonLine.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            horizonLine.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            horizonLine.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor, constant: -40),
            
            verticalLine.widthAnchor.constraint(equalToConstant: 1),
            verticalLine.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            verticalLine.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor),
            verticalLine.centerXAnchor.constraint(equalTo: dialogView.centerXAnchor),
            
            view.topAnchor.constraint(equalTo: dialogView.topAnchor),
            view.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: horizonLine.topAnchor),
            
            okButton.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            okButton.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor),
            okButton.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor),
            okButton.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: horizonLine.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: verticalLine.trailingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor),
        ])
        
        // View
        view.addSubview(label1)
        view.addSubview(radioArie_1)
        view.addSubview(radioArie_2)
        
        label1.translatesAutoresizingMaskIntoConstraints = false
        radioArie_1.translatesAutoresizingMaskIntoConstraints = false
        radioArie_2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            label1.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            
            radioArie_1.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 18),
            radioArie_1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            radioArie_1.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            radioArie_1.heightAnchor.constraint(equalToConstant: 18),
            
            radioArie_2.topAnchor.constraint(equalTo: radioArie_1.bottomAnchor, constant: 8),
            radioArie_2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            radioArie_2.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            radioArie_2.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        // RadioArie
        radioArie_1.addSubview(radioButton_1)
        radioArie_1.addSubview(radioLabel_1)
        radioArie_2.addSubview(radioButton_2)
        radioArie_2.addSubview(radioLabel_2)
        
        radioButton_1.translatesAutoresizingMaskIntoConstraints = false
        radioLabel_1.translatesAutoresizingMaskIntoConstraints = false
        radioButton_2.translatesAutoresizingMaskIntoConstraints = false
        radioLabel_2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            radioButton_1.centerYAnchor.constraint(equalTo: radioArie_1.centerYAnchor),
            radioButton_1.leadingAnchor.constraint(equalTo: radioArie_1.leadingAnchor),
            
            radioLabel_1.centerYAnchor.constraint(equalTo: radioArie_1.centerYAnchor),
            radioLabel_1.leadingAnchor.constraint(equalTo: radioButton_1.trailingAnchor),
            
            radioButton_2.centerYAnchor.constraint(equalTo: radioArie_2.centerYAnchor),
            radioButton_2.leadingAnchor.constraint(equalTo: radioArie_2.leadingAnchor),
            
            radioLabel_2.centerYAnchor.constraint(equalTo: radioArie_2.centerYAnchor),
            radioLabel_2.leadingAnchor.constraint(equalTo: radioButton_2.trailingAnchor)
        ])
    }
    
    private func updateRadioButtons(tag: Int) {
        switch tag {
        case 1:
            radioSelectedFlg_1 = true
            radioButton_1.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            radioLabel_1.textColor = .black
            radioSelectedFlg_2 = false
            radioButton_2.setImage(UIImage(systemName: "square"), for: .normal)
            radioLabel_2.textColor = .systemGray2
        case 2:
            radioSelectedFlg_2 = true
            radioButton_2.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            radioLabel_2.textColor = .black
            radioSelectedFlg_1 = false
            radioButton_1.setImage(UIImage(systemName: "square"), for: .normal)
            radioLabel_1.textColor = .systemGray2
        default:
            break
        }
    }
    
    // MARK: - Button Actions
    @objc private func okButtonTapped() {
        if radioSelectedFlg_1 {
            // 今月のGoalのみ削除
            MonthlyGoalsDao.removeGoalFromMonthlyGoals(walletId: self.walletId, targetMonth: self.targetMonth, goal: self.thisGoal!)
        }
//        else if radioSelectedFlg_2 {
//            // 今月以降のGoalを削除
//            let thisMonth = DateFuncs().convertStringToDate(self.thisGoal!.targetMonth, format: "yyyy-MM")!
//            let goals = GoalDao().getGoalsByCategory(category: self.thisGoal!.category!)
//            goals.forEach { goal in
//                let targetMonth = DateFuncs().convertStringToDate(goal.targetMonth, format: "yyyy-MM")!
//                
//                if thisMonth <= targetMonth {
//                    GoalDao().deleteGoal(goal: goal)
//                }
//            }
//        }
        // 削除後のイベント発火
        delegate?.okButtonTapped()
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.cancelButtonTapped()
    }
    
    @objc private func radioAriaTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        self.updateRadioButtons(tag: tappedView.tag)
    }
}
