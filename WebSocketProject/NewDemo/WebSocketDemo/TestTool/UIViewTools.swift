//
//  UIViewTools.swift
//  TestTool
//
//  Created by 张斌 on 2023/2/9.
//

import Foundation
import UIKit

class UIViewTools {
    static func printViewHierachy() {
        guard let view = UIApplication.shared.keyWindow else {
            return
        }

        printViewHierachy(for: view, level: 0)

    }

    static func allVisibleViewsHasAccessibilityLabel() -> [UIView] {
        guard let view = UIApplication.shared.keyWindow else {
            return []
        }

        return subViewsHasAccessibilityLabel(for: view)
    }
}

private extension UIViewTools {
    static func subViewsHasAccessibilityLabel(for view: UIView) -> [UIView] {
        let subviews = view.subviews

        guard subviews.count > 0 else {
            return []
        }

        var views: [UIView] = []

        for subView in subviews {
            if subView.isHidden || subView.bounds.size == .zero {
                continue
            }

            if subView.accessibilityLabel != nil {
                views.append(subView)
            }

            if subView.isKind(of: UIButton.self) {
                continue
            }
            views += subViewsHasAccessibilityLabel(for: subView)
        }

        return views
    }

    static func printViewHierachy(for view: UIView, level: Int) {
        printDetail(for: view, level: level)

        let subviews = view.subviews

        guard subviews.count > 0 else {
            return
        }

        for childView in subviews.reversed() {
            printViewHierachy(for: childView, level: level + 1)
        }
    }

    static func printDetail(for view: UIView, level: Int) {
        guard needPrint(view) else {
            return
        }

        let accessibilityLabel = view.accessibilityLabel ?? ""
        let indent = String(repeating: "----", count: level)
        print("\(indent)\(accessibilityLabel)(\(detail(for: view)))")
    }

    static func needPrint(_ view: UIView) -> Bool {
        if isInTypeBlackList(view) {
            return false
        }

        return view.accessibilityLabel != nil
    }

    static func isInTypeBlackList(_ view: UIView) -> Bool {
        let blackListTypes = [
            "_UILayoutGuide",
            "_UINavigationBarContentView",
            "_UIVisualEffectBackdropView",
            "_UIBarBackgroundShadowView",
        ]

        return blackListTypes.contains(detail(for: view))
    }

    static func detail(for view: UIView) -> String {
        return NSStringFromClass(view.classForCoder)
    }
}
