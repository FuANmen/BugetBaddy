//
//  MainTabBarController.swift
//  BudgetBuddy
//
//  このコードでは、MainTabBarControllerがタブバーコントローラを表し、ダッシュボード、目標設定、履歴確認、設定の各画面を持っています。各画面はUINavigationControllerでラップされ、それぞれのタイトルとアイコンが設定されています。createNavigationControllerメソッドは、渡されたルートビューコントローラをナビゲーションコントローラで包み、タイトルとアイコンを設定して返す補助メソッドです。

// このタブバーコントローラを使って、ユーザーはダッシュボード、目標設定、履歴確認、設定の各画面を簡単に切り替えることができます。MainTabBarControllerをアプリのメイン画面として使い、スタート画面から遷移すると良いでしょう。
//

import UIKit

class MainTabBarController: UITabBarController {

    // Monthly
    var monthlyVC_preview: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        tabBar.backgroundColor = .white
        tabBar.alpha = 0.8
        tabBar.layer.shadowColor = UIColor.systemGray3.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowOpacity = 0.5
        tabBar.layer.shadowRadius = 1

        // Dashboard
        let dashboardViewController = DashboardViewController()
        dashboardViewController.title = "Home"
        // Monthly
        let goalsViewController = MonthlyViewController()
        goalsViewController.title = ""
        // Bank
        let bankAccountViewController = BankAccountViewController()
        bankAccountViewController.title = NSLocalizedString("Icon_4", comment: "")
        
        let thisMonth = DateFuncs().convertStringFromDate(Date(), format: "MM")
        viewControllers = [
            createNavigationController(for: dashboardViewController, title: NSLocalizedString("Icon_1", comment: ""), image: "house"),
            createNavigationController(for: goalsViewController, title: thisMonth! + NSLocalizedString("Month", comment: ""), image: "calendar"),
            createNavigationController(for: bankAccountViewController, title: NSLocalizedString("Icon_4", comment: ""), image: "list.bullet.rectangle.portrait")
        ]
    }
    private func createNavigationController(for rootViewController: UIViewController, title: String, image: String) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(systemName: image)
        
        // 影を設定
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navController.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        navController.navigationBar.layer.shadowOpacity = 0.2
        navController.navigationBar.layer.shadowRadius = 2
        
        // タイトルの文字色を白色に設定
        navController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes
        = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32, weight: .medium)]
        
        return navController
    }
    
    func setSelectedIndex(_ index: Int) {
        guard index != selectedIndex, let fromViewController = selectedViewController, let toViewController = viewControllers?[index] else {
            return
        }
        
        // 遷移アニメーションを実行
        UIView.transition(from: fromViewController.view, to: toViewController.view, duration: 0.2, options: [.transitionCrossDissolve], completion: { _ in
            self.selectedIndex = index
        })
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false
        }
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.2, options: [.transitionCrossDissolve], completion: nil)
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // タブが切り替わった時の処理
        if let vc = selectedViewController as? MonthlyViewController {
            vc.updatePreview(to: self.monthlyVC_preview)
        }
    }
}
