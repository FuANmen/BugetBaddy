//
//  Extensions.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2023/12/22.
//

import Foundation
import UIKit
extension Notification.Name {
    static let languageDidChange = Notification.Name("LanguageDidChangeNotification")
}

// MARK: - UIColor
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}

// MARK: - UIKit
extension UIView {
    func setLine(color: UIColor, top: Bool? = false, right: Bool? = false, bottom: Bool? = false, left: Bool? = false) {
        if top! {
            let line = UIView()
            line.frame = CGRect(x: 0, y: 0, width: frame.width, height: 0.5)
            line.backgroundColor = color
            addSubview(line)
            bringSubviewToFront(line)
        }
        if right! {
            let line = UIView()
            line.frame = CGRect(x: frame.width, y: 0, width: 0.5, height: frame.height)
            line.backgroundColor = color
            addSubview(line)
            bringSubviewToFront(line)
        }
        if bottom! {
            let line = UIView()
            line.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: 0.5)
            line.backgroundColor = color
            addSubview(line)
            bringSubviewToFront(line)
        }
        if left! {
            let line = UIView()
            line.frame = CGRect(x: 0, y: 0, width: 0.5, height: frame.height)
            line.backgroundColor = color
            addSubview(line)
            bringSubviewToFront(line)
        }
    }
    
    func addBackground(name: String) {
        // スクリーンサイズの取得
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        // スクリーンサイズにあわせてimageViewの配置
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        //imageViewに背景画像を表示
        imageViewBackground.image = UIImage(named: name)

        // 画像の表示モードを変更。
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill

        // subviewをメインビューに追加
        self.addSubview(imageViewBackground)
        // 加えたsubviewを、最背面に設置する
        self.sendSubviewToBack(imageViewBackground)
    }
}

extension UITextField {
    func setUnderLine() {
        // 枠線を非表示にする
        borderStyle = .none
        let underline = UIView()
        underline.frame = CGRect(x: 0, y: frame.height, width: textWidth(), height: 0.5)
        underline.backgroundColor = .systemGray4
        addSubview(underline)
        // 枠線を最前面に
        bringSubviewToFront(underline)
    }
    
    func textWidth() -> CGFloat {
        guard let text = self.text, let font = self.font else {
            return frame.width
        }
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)

        return size.width
    }
}

extension UITextView {
    func textHeight() -> CGFloat {
        guard let text = self.text, let font = self.font else {
            return frame.height
        }
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)

        return size.height
    }
}

extension UILabel {
    func textWidth() -> CGFloat {
        guard let text = self.text, let font = self.font else {
            return frame.width
        }
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)

        return size.width + 2
    }
    
    func textHeight() -> CGFloat {
        guard let text = self.text, let font = self.font else {
            return frame.height
        }
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).size(withAttributes: attributes)

        return size.height
    }
}
