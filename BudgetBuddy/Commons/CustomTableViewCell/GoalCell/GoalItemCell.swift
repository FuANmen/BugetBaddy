//
//  GoalTableViewCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/04.
//

import Foundation
import UIKit

class GoalItemCell: UICollectionViewCell {
    static let identifier = "GoalItemCell"
    static let itemHeight: CGFloat = 78
    
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
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .systemGray2
        return label
    }()
    
    internal var imageColor: UIColor = .white
    private let progressBarHight: CGFloat = 14.0
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
    
    private let colorPallet: [UIColor] = [
                                            .systemTeal,
                                            .systemGreen,
                                            .systemYellow,
                                            .systemOrange,
                                            .systemPink,
                                            .systemRed]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // contentViewに影を設定
        contentView.layer.cornerRadius = 24
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 5

        // セルの背景色とcontentViewの背景色を設定
        backgroundColor = .clear

        // マスクを外して影を描画
        contentView.layer.masksToBounds = false
        
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
    
    func configure(with goal: Goal, targetMonth: String) {
        let balance = goal.getBalance()
        balanceLabel.text = formatCurrency(amount: balance)
        percentLabel.text = goal.getAmount() == 0 ? "" : "(\(Int(round(balance / goal.getAmount() * 100)))%)"
        if let category = goal.category {
            categoryNameLabel.text = category.name + " :"
        }
        
        if let totalGoal = GoalDao().getTotalGoal(targetMonth: targetMonth) {
            let totalAmount = totalGoal.getAmount()
            self.updateView(goalAmount: Int(goal.getAmount()), balance: Int(balance), totalAmount: Int(totalAmount))
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryNameLabel.text = nil
        self.updateView(goalAmount: 1, balance: 1, totalAmount: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateView(goalAmount: Int, balance: Int, totalAmount: Int) {
        progressBar.initUI(trackPerscentage:goalAmount == 0 ? 0.0 : 1.0)
        
        let percentage = goalAmount == 0 ? 0.0 : Double(Float(balance) / Float(goalAmount))
        
        progressBar.updateProgress(percentage: Float(percentage), animation: true)
        
        if percentage > 0.8 {
            imageColor = colorPallet[0]
        } else if percentage > 0.6 {
            imageColor = colorPallet[1]
        } else if percentage > 0.4 {
            imageColor = colorPallet[2]
        } else if percentage > 0.2 {
            imageColor = colorPallet[3]
        } else if percentage > 0.1 {
            imageColor = colorPallet[4]
        } else {
            imageColor = colorPallet[5]
        }
        progressBar.setColor(trackColor: .systemGray5, progressColor: imageColor)
        
        maxScaleLabel.text = String(round(Float(goalAmount / 1000)) / 10) + NSLocalizedString("Money_2", comment: "")
        minScaleLabel.text = "0"
        
        self.layoutIfNeeded()
    }
}
