//
//  TotalGoalTableCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/25.
//

import UIKit

class OtherGoalTableCell: UITableViewCell {
    static let identifier = "OtherGoalTableCell"
    static let cellHeight: CGFloat = 80
    
    private var otherGoal: Goal? = nil
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .systemGray2
        return label
    }()
    
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .systemGray3
        return label
    }()

    private let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Other", comment: "")
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .systemGray2
        return label
    }()
    
    private let progressBarHight: CGFloat = 16.0
    private let progressBar: MyProgressBar = {
        let progressBar = MyProgressBar()
        return progressBar
    }()
    
    private let maxScaleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .systemGray3
        return label
    }()
    
    private let minScaleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .systemGray3
        return label
    }()
    
    private let colorPallet: [UIColor] = [.systemRed,
                                          .systemOrange,
                                          .systemYellow,
                                          .systemGreen,
                                          .systemTeal]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(balanceLabel)
        contentView.addSubview(percentLabel)
        contentView.addSubview(categoryNameLabel)
        contentView.addSubview(progressBar)
        contentView.addSubview(maxScaleLabel)
        contentView.addSubview(minScaleLabel)
        
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        percentLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        maxScaleLabel.translatesAutoresizingMaskIntoConstraints = false
        minScaleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            
            percentLabel.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: balanceLabel.leadingAnchor, constant: -4),
            
            balanceLabel.bottomAnchor.constraint(equalTo: categoryNameLabel.bottomAnchor),
            balanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            progressBar.topAnchor.constraint(equalTo: categoryNameLabel.bottomAnchor, constant: 6),
            progressBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            progressBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            progressBar.heightAnchor.constraint(equalToConstant: progressBarHight),
            
            maxScaleLabel.centerXAnchor.constraint(equalTo: progressBar.trackView.trailingAnchor),
            maxScaleLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 2),
            
            minScaleLabel.centerXAnchor.constraint(equalTo: progressBar.leadingAnchor),
            minScaleLabel.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 2)
        ])
    }
    
    func configure(targetMonth: String) {
        self.otherGoal = GoalDao().getOtherGoal(targetMonth: targetMonth)
        
        let balance = self.otherGoal!.getBalance()
        let amount = self.otherGoal!.getAmount()
        balanceLabel.text = formatCurrency(amount: balance)
        percentLabel.text = self.otherGoal!.getAmount() == 0 ? "" : "(\(Int(round(balance / amount * 100)))%)"
        
        self.updateView(goalAmount: Int(amount), balance: Int(balance))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.updateView(goalAmount: 1, balance: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateView(goalAmount: Int, balance: Int) {
        progressBar.initUI(trackPerscentage:goalAmount == 0 ? 0.0 : 1.0)
        
        let percentage = goalAmount == 0 ? 0.0 : Double(Float(balance) / Float(goalAmount))
        
        progressBar.updateProgress(percentage: Float(percentage), animation: true)
        
        if percentage > 0.8 {
            progressBar.setColor(trackColor: .systemGray5, progressColor: colorPallet[4])
        } else if percentage > 0.6 {
            progressBar.setColor(trackColor: .systemGray5, progressColor: colorPallet[3])
        } else if percentage > 0.4 {
            progressBar.setColor(trackColor: .systemGray5, progressColor: colorPallet[2])
        } else if percentage > 0.2 {
            progressBar.setColor(trackColor: .systemGray5, progressColor: colorPallet[1])
        } else if percentage > 0.1 {
            progressBar.setColor(trackColor: .systemGray5, progressColor: colorPallet[0])
        }
        
        maxScaleLabel.text = String(round(Float(goalAmount / 1000)) / 10) + NSLocalizedString("Money_2", comment: "")
        minScaleLabel.text = "0"
        
        self.layoutIfNeeded()
    }
}
