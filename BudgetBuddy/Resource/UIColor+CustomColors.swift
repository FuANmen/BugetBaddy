//
//  CommonValues.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/05/19.
//

import UIKit


let BACKGROUND_COLOR: UIColor = UIColor.rgb(red: 160, green: 180, blue: 255)
let NAVIGATION_BACK_COLOR: UIColor = UIColor.rgb(red: 121, green: 140, blue: 255)

let DASHBOARD_BACKGROUND_COLOR: UIColor =  UIColor.rgb(red: 220, green: 240, blue: 255)

extension UIColor {
    // 背景色
    static let backGradientColorTo = UIColor(red: 244/255, green: 244/255, blue: 215/255, alpha: 1.0)
    static let backGradientColorFrom = UIColor(red: 135/255, green: 226/255, blue: 205/255, alpha: 1.0)
    
    // セクション
    static let sectionBackColor = UIColor(red: 244/255, green: 255/255, blue: 244/255, alpha: 1.0)
    static let sectionMainLabelColor = UIColor(red: 125/255, green: 211/255, blue: 170/255, alpha: 1.0)
    
    // GoaiItemCellBar
    static let balanceHigh = UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1.0)
    static let balanceMediumHigh = UIColor(red: 157/255, green: 192/255, blue: 76/255, alpha: 1.0)
    static let balanceMedium = UIColor(red: 186/255, green: 211/255, blue: 0/255, alpha: 1.0)
    static let balanceLow = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0)
    static let balanceVeryLow = UIColor(red: 237/255, green: 109/255, blue: 61/255, alpha: 1.0)
    // OtherGoalItemCellBar
    static let otherBalanceHigh = UIColor(red: 0/255, green: 101/255, blue: 203/255, alpha: 1.0)
    static let otherBalanceMediumHigh = UIColor(red: 0/255, green: 152/255, blue: 203/255, alpha: 1.0)
    static let otherBalanceMedium = UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 1.0)
    static let otherBalanceLow = UIColor(red: 50/255, green: 204/255, blue: 255/255, alpha: 1.0)
    static let otherBalanceVeryLow = UIColor(red: 101/255, green: 216/255, blue: 255/255, alpha: 1.0)
    
    // カラーセット 1: 落ち着いたブルー系
    static let customSkyBlue = UIColor(red: 135/255, green: 206/255, blue: 235/255, alpha: 1.0)
    static let customDodgerBlue = UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 1.0)
    static let customWhiteSmoke = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
    static let customNavy = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 1.0)
    static let customRedOrange = UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1.0)
    static let customDarkBlue = UIColor(red: 25/255, green: 25/255, blue: 112/255, alpha: 1.0)
    static let customMediumBlue = UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 1.0)
    static let customDarkBlue2 = UIColor(red: 0/255, green: 0/255, blue: 139/255, alpha: 0.8)
    static let customSlateBlue = UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1.0)
    static let customRoyalBlue = UIColor(red: 65/255, green: 105/255, blue: 225/255, alpha: 1.0)
    static let customRoyalBlueDark1 = UIColor(red: 52/255, green: 84/255, blue: 180/255, alpha: 1.0)
    static let customRoyalBlueDark2 = UIColor(red: 41/255, green: 68/255, blue: 144/255, alpha: 1.0)
    static let customRoyalBlueDark3 = UIColor(red: 31/255, green: 52/255, blue: 108/255, alpha: 1.0)
    static let customRoyalBlueLight1 = UIColor(red: 97/255, green: 127/255, blue: 242/255, alpha: 1.0)
    static let customRoyalBlueLight2 = UIColor(red: 130/255, green: 150/255, blue: 255/255, alpha: 1.0)
    static let customRoyalBlueLight3 = UIColor(red: 162/255, green: 172/255, blue: 255/255, alpha: 1.0)
    static let customSteelBlue = UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1.0)
    static let customSteelBlueDark1 = UIColor(red: 56/255, green: 104/255, blue: 144/255, alpha: 1.0)
    static let customSteelBlueDark2 = UIColor(red: 45/255, green: 84/255, blue: 115/255, alpha: 1.0)
    static let customSteelBlueDark3 = UIColor(red: 36/255, green: 67/255, blue: 92/255, alpha: 1.0)
    static let customSteelBlueLight1 = UIColor(red: 102/255, green: 156/255, blue: 210/255, alpha: 1.0)
    static let customSteelBlueLight2 = UIColor(red: 133/255, green: 178/255, blue: 225/255, alpha: 1.0)
    static let customSteelBlueLight3 = UIColor(red: 163/255, green: 200/255, blue: 240/255, alpha: 1.0)

    // カラーセット 2: フレッシュなグリーン系
    static let customIvory = UIColor(red: 255/255, green: 255/255, blue: 240/255, alpha: 1.0)
    static let customGreenYellow = UIColor(red: 173/255, green: 255/255, blue: 47/255, alpha: 1.0)
    static let customPaleGreen = UIColor(red: 152/255, green: 251/255, blue: 152/255, alpha: 1.0)
    static let customLightGreen = UIColor(red: 144/255, green: 238/255, blue: 144/255, alpha: 1.0)
    static let customYellowGreen = UIColor(red: 154/255, green: 205/255, blue: 50/255, alpha: 1.0)
    static let customSpringGreen = UIColor(red: 0/255, green: 255/255, blue: 127/255, alpha: 1.0)
    static let customMediumSeaGreen = UIColor(red: 60/255, green: 179/255, blue: 113/255, alpha: 1.0)
    static let customSeaGreen = UIColor(red: 46/255, green: 139/255, blue: 87/255, alpha: 1.0)
    static let customOliveDrab = UIColor(red: 107/255, green: 142/255, blue: 35/255, alpha: 1.0)
    static let customLimeGreen = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1.0)
    static let customSlateGreen = UIColor(red: 0.0/255.0, green: 153.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static let customForestGreen = UIColor(red: 34/255, green: 139/255, blue: 34/255, alpha: 1.0)
    static let customDarkGreen = UIColor(red: 34/255, green: 139/255, blue: 34/255, alpha: 1.0)
    static let customGold = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1.0)
    static let celadon = UIColor(red: 211/255, green: 223/255, blue: 194/255, alpha: 1.0)

    // カラーセット 3: 柔らかなオレンジ系
    static let customLightSalmon = UIColor(red: 255/255, green: 160/255, blue: 122/255, alpha: 1.0)
    static let customOrangeRed = UIColor(red: 255/255, green: 69/255, blue: 0/255, alpha: 1.0)
    static let customFloralWhite = UIColor(red: 255/255, green: 250/255, blue: 240/255, alpha: 1.0)
    static let customTomato = UIColor(red: 255/255, green: 99/255, blue: 71/255, alpha: 1.0)
    static let customDarkOrange = UIColor(red: 255/255, green: 140/255, blue: 0/255, alpha: 1.0)
    static let customCoral = UIColor(red: 255/255, green: 127/255, blue: 80/255, alpha: 1.0)
    static let customPeachPuff = UIColor(red: 255/255, green: 218/255, blue: 185/255, alpha: 1.0)
    static let customMoccasin = UIColor(red: 255/255, green: 228/255, blue: 181/255, alpha: 1.0)
    static let customPapayaWhip = UIColor(red: 255/255, green: 239/255, blue: 213/255, alpha: 1.0)
    static let customBlanchedAlmond = UIColor(red: 255/255, green: 235/255, blue: 205/255, alpha: 1.0)
    static let customBisque = UIColor(red: 255/255, green: 228/255, blue: 196/255, alpha: 1.0)

    // グレー
    static let customDarkGray = UIColor(red: 105/255, green: 105/255, blue: 105/255, alpha: 1.0)
    static let customDarkGrayLight1 = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1.0)
    static let customDarkGrayLight2 = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1.0)
    static let customDarkGrayLight3 = UIColor(red: 165/255, green: 165/255, blue: 165/255, alpha: 1.0)
    static let customDarkGrayLight4 = UIColor(red: 185/255, green: 185/255, blue: 185/255, alpha: 1.0)
    static let customDarkGrayLight5 = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1.0)
}
