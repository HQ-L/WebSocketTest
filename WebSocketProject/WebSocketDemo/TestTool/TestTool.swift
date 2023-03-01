//
//  TestTool.swift
//  TestTool
//
//  Created by 张斌 on 2023/2/10.
//

import Foundation
import UIKit

public class TestTool {
    public static func printViewHierachy() -> [String] {
        return UIViewTools.printViewHierachy()
    }

    public static func generateCode(for view: UIView) {
        print(TestCodeGenerator.generateCode(for: view))
    }

    public static func generateCodeForAllViewsWithAccessibilityLabel() -> String {
        var functions: [String] = []
        for view in UIViewTools.allVisibleViewsHasAccessibilityLabel() {
            if let code = TestCodeGenerator.generateCode(for: view) {
                functions.append(code)
            }
        }
        print(functions.joined(separator: "\n"))
        return functions.joined(separator: "\n")
    }
}
