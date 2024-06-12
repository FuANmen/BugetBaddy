//
//  MyProgressBar.swift
//  BudgetBuddy
//
//  Created by 柴田健作 on 2024/01/12.
//
import UIKit

class MyProgressBar: UIView {

    public let trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 5.0
        return view
    }()
    
    private let trackCoverView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.layer.opacity = 0.1
        return view
    }()

    let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemTeal
        view.layer.cornerRadius = 5.0
        
        return view
    }()
    
    private var progress: Float = 0.0
    private var firstAnimation: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    private func setupUI() {
        self.addSubview(trackView)
        trackView.addSubview(trackCoverView)
        trackView.addSubview(progressView)

        trackView.translatesAutoresizingMaskIntoConstraints = false
        trackCoverView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            trackView.topAnchor.constraint(equalTo: self.topAnchor),
            trackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            trackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            trackView.widthAnchor.constraint(equalToConstant: 0),
            
            trackCoverView.topAnchor.constraint(equalTo: trackView.topAnchor),
            trackCoverView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            trackCoverView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            trackCoverView.trailingAnchor.constraint(equalTo: trackView.trailingAnchor),

            progressView.topAnchor.constraint(equalTo: trackView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 0)
        ])
    }
    
    public func initUI(trackPerscentage: Float, isSaving: Bool? = false) {
        self.layoutIfNeeded()
        
        // TrackView
        var trackWidthConstraint: NSLayoutConstraint?
        for constraint in trackView.constraints {
            if constraint.firstAttribute == .width {
                trackWidthConstraint = constraint
                break
            }
        }
        if let widthConstraint = trackWidthConstraint {
            widthConstraint.constant = CGFloat(Float(self.bounds.width) * trackPerscentage)
            self.layoutIfNeeded()
        }
        
        // ProgressView
        var progressWidthConstraint: NSLayoutConstraint?
        for constraint in progressView.constraints {
            if constraint.firstAttribute == .width {
                progressWidthConstraint = constraint
                break
            }
        }
        if let widthConstraint = progressWidthConstraint {
            if isSaving! {
                widthConstraint.constant = 0
            } else {
                widthConstraint.constant = CGFloat(trackView.bounds.width)
            }
            self.layoutIfNeeded()
        }
    }
    
    public func setColor(trackColor: UIColor, progressColor: UIColor) {
        trackView.backgroundColor = trackColor
        progressView.backgroundColor = progressColor
    }

    public func updateProgress(percentage: Float, animation: Bool) {
        self.progress = percentage
        
        var widthConstraint: NSLayoutConstraint?
        for constraint in progressView.constraints {
            if constraint.firstAttribute == .width {
                widthConstraint = constraint
                break
            }
        }
        if let widthConstraint = widthConstraint {
            widthConstraint.constant = CGFloat(Float(self.bounds.width) * progress)
            if animation {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                    self.layoutIfNeeded()
                }, completion: nil)
            } else {
                self.layoutIfNeeded()
            }
        }
    }
}
