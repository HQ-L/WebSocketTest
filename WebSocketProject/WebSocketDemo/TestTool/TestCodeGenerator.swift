//
//  TestCodeGenerator.swift
//  TestTool
//
//  Created by 张斌 on 2023/2/10.
//

import Foundation
import UIKit

class TestCodeGenerator {
    static func generateCode(for view: UIView) -> String? {
        guard view.accessibilityLabel != nil else {
            return nil
        }

        if let label = view as? UILabel {
            return generateCodeForLabel(label)
        } else if let imageView = view as? UIImageView {
            return generateCodeForImageView(imageView)
        } else if let button = view as? UIButton {
            return generateCodeForButton(button)
        } else if view.bounds.size.height <= 1 {
            return generateCodeForSeparator(view)
        }

        return nil
    }
}

private extension TestCodeGenerator {
    static func generateCodeForSeparator(_ separator: UIView) -> String {
        var code = generateTestFunctionNormalHeader(for: separator, name: "separator", type: "UIView")


        code += "    XCTAssert(separator.bounds.size.height == \(separator.bounds.size.height))\n"

        if let color = separator.backgroundColor {
            code += "    XCTAssert(separator.backgroundColor?.isEqualToColor(otherColor: \(colorString(for: color))) == true)\n"
        } else {
            code += "    XCTAssert(separator.backgroundColor == nil)\n"
        }

        code += "}\n"

        return code
    }
    static func generateCodeForButton(_ button: UIButton) -> String {
        var code = generateTestFunctionNormalHeader(for: button, name: "button", type: "UIButton")

        let generateStates: [(UIControl.State, String)] = [(.normal, ".normal"), (.highlighted, ".highlighted"), (.disabled, ".disabled")]
        for (state, stateString) in generateStates {
            if let title = button.title(for: state) {
                code += "    XCTAssert(button.title(for: \(stateString)) == \"\(title)\")\n"
            } else {
                code += "    XCTAssert(button.title(for: \(stateString)) == nil)\n"
            }

            if let titleColor = button.titleColor(for: state) {
                code += "    XCTAssert(button.titleColor(for: \(stateString))?.isEqualToColor(otherColor:\(colorString(for: titleColor))) == true)\n"
            } else {
                code += "    XCTAssert(button.titleColor(for: \(stateString)) == nil)\n"
            }

            if let titleShadowColor = button.titleShadowColor(for: state) {
                code += "    XCTAssert(button.titleShadowColor(for: \(stateString))?.isEqualToColor(otherColor:\(colorString(for: titleShadowColor))) == true)\n"
            } else {
                code += "    XCTAssert(button.titleShadowColor(for: \(stateString)) == nil)\n"
            }

            if let backgroundImage = button.backgroundImage(for: state) {
                code += imageDataString(for: backgroundImage, indent: "        ")
                code += "    XCTAssert(button.backgroundImage(for: \(stateString))?.pngData() == data)\n"
            } else {
                code += "    XCTAssert(button.backgroundImage(for: \(stateString)) == nil)\n"
            }

            if let image = button.image(for: state) {
                code += imageDataString(for: image, indent: "        ")
                code += "    XCTAssert(button.image(for: \(stateString))?.pngData() == data)\n"
            } else {
                code += "    XCTAssert(button.image(for: \(stateString)) == nil)\n"
            }
        }

        code += "}"


        return code
    }

    static func generateCodeForImageView(_ imageView: UIImageView) -> String {
        var code = generateTestFunctionNormalHeader(for: imageView, name: "imageView", type: "UIImageView")

        if let image = imageView.image {
            code += imageDataString(for: image, indent: "    ")
            code += "    XCTAssert(imageView.image?.pngData() == data)"
        } else {
            code += "    XCTAssert(imageView.image == nil)"
        }

        code += """

            XCTAssert(imageView.bounds.size == CGSize(width: \(imageView.bounds.size.width), height: \(imageView.bounds.size.height)))
            XCTAssert(imageView.contentMode.rawValue == \(imageView.contentMode.rawValue))
        }
        """


        return code
    }

    static func generateCodeForLabel(_ label: UILabel) -> String {
        var code = generateTestFunctionNormalHeader(for: label, name: "label", type: "UILabel")

        if label.text != label.accessibilityLabel {
            code += """
                XCTAssert(label.text == "\(label.text ?? "")"\n
            """
        }

        code += """
            XCTAssert(label.textColor.isEqualToColor(otherColor: \(colorString(for: label.textColor))))
        \(fontString(from: label.font))
            XCTAssert(label.font == font)
        }\n
        """
        return code
    }

    static func generateTestFunctionNormalHeader(for view: UIView, name: String, type: String) -> String {
        guard let accessibilityLabel = view.accessibilityLabel else {
            return ""
        }

        let function = functionName(from: accessibilityLabel)

        var typeConvertString = ""
        if type != "UIView" {
            typeConvertString = " as? \(type)"
        }
        return """
        func testUIOf\(function)() {
            let tester = tester()
            guard let \(name) = tester.waitForView(withAccessibilityLabel: \\"\(accessibilityLabel)\\")\(typeConvertString) else {
                tester.fail()
                return
            }\n
        """
    }

    static func functionName(from accessibilityLabel: String) -> String {
        let set = CharacterSet(charactersIn: " -:.(){}+")
        return accessibilityLabel.components(separatedBy: set).joined(separator: "_")
    }

    static func fontString(from font: UIFont) -> String {
        var attributesCode: String = ""
        for attribute in font.fontDescriptor.fontAttributes {
            let key = attribute.key
            var keyString = ""
            var valueString = ""
            switch key {
            case .textStyle:
                keyString = ".textStyle"
                valueString = "UIFont.TextStyle(rawValue: \"\(attribute.value)\")"
            case .name:
                keyString = ".name"
                valueString = "\"\(attribute.value)\""
            case .family:
                keyString = ".family"
                valueString = "\"\(attribute.value)\""
            default:
                continue
            }

            attributesCode += """
                \(keyString): \(valueString),
            """
        }


        return """
            var fontDescriptor = UIFontDescriptor(name: "\(font.fontName)", size: 17)
            fontDescriptor = fontDescriptor.addingAttributes([
            \(attributesCode)
            ])
            let font = UIFont(descriptor: fontDescriptor, size: \(font.pointSize))
        """
    }

    static func imageDataString(for image: UIImage, indent: String) -> String {
        var code = ""
        if let asset = image.imageAsset,
           let name = asset.value(forKey: "_assetName") as? String,
           let bundle = asset.value(forKey: "_containingBundle") as? Bundle,
           let identifier = bundle.bundleIdentifier {
            code += """

            \(indent)let bundle = Bundle(identifier: "\(identifier)")
            \(indent)let data = UIImage(named: "\(name)", in: bundle, compatibleWith: nil)?.pngData()
            """
        } else {
            var imageDataString = ""
            if let data = image.pngData() {
                imageDataString = data.base64EncodedString(options: .endLineWithLineFeed)
            }

            code += """

            \(indent)let imageDataString = "\(imageDataString)"
            \(indent)let data = Data(base64Encoded: imageDataString, options: .ignoreUnknownCharacters)
            """
        }

        return code + "\n"
    }

    static func colorString(for color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return "UIColor(red: \(red), green: \(green), blue: \(blue), alpha: \(alpha))"
    }
}
