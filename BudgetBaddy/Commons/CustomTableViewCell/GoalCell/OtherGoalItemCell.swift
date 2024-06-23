//
//  OtherGoalCollectionViewCell.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/25.
//

import UIKit

class OtherGoalItemCell: UICollectionViewCell {
    static let identifier = "OtherGoalItemCell"
    static let itemHeight: CGFloat = 100
    
    private var otherGoal: Goal? = nil
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = .customSteelBlueLight2
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        return label
    }()

    private let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Other", comment: "")
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .customRoyalBlueLight2
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
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
        label.textColor = .customDarkGray
        return label
    }()
    
    private let minScaleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.textColor = .customDarkGray
        return label
    }()
    
    private let colorPallet: [UIColor] = [.systemRed,
                                          .systemOrange,
                                          .systemYellow,
                                          .systemGreen,
                                          .systemTeal]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // contentViewの角丸
        contentView.layer.cornerRadius = 24
        // contentViewに影を設定
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 5

        // セルの背景色とcontentViewの背景色を設定
        backgroundColor = .clear

        // マスクを外して影を描画
        contentView.layer.masksToBounds = false
        
        contentView.addSubview(balanceLabel)
        contentView.addSubview(categoryNameLabel)
        contentView.addSubview(progressBar)
        contentView.addSubview(maxScaleLabel)
        contentView.addSubview(minScaleLabel)
        
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        maxScaleLabel.translatesAutoresizingMaskIntoConstraints = false
        minScaleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryNameLabel.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: OtherGoalItemCell.itemHeight/2 - 4),
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            categoryNameLabel.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -4),
            
            balanceLabel.centerYAnchor.constraint(equalTo: categoryNameLabel.centerYAnchor),
            balanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -34),
            balanceLabel.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 4),
            
            progressBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: OtherGoalItemCell.itemHeight/2 + 4),
            progressBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 28),
            progressBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
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
        
        var imageColor: UIColor = .clear
        switch percentage {
        case 0.8...1.0:
            imageColor = .otherBalanceHigh
        case 0.6..<0.8:
            imageColor = .otherBalanceMediumHigh
        case 0.4..<0.6:
            imageColor = .otherBalanceMedium
        case 0.2..<0.4:
            imageColor = .otherBalanceLow
        case 0.0..<0.2:
            imageColor = .otherBalanceVeryLow
        default:
            imageColor = .clear
        }
        
        progressBar.setColor(trackColor: .customDarkGrayLight5, progressColor: imageColor)
        
        maxScaleLabel.text = String(round(Float(goalAmount / 1000)) / 10) + NSLocalizedString("Money_2", comment: "")
        minScaleLabel.text = "0"
        
        self.layoutIfNeeded()
    }
}
    
    
