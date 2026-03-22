//
//  LanguageDetector.swift
//  flutter_contact_index
//
//  Created by zhimin.huang on 2025/11/04.
//

import Foundation
import NaturalLanguage


/// 语言检测工具类
class LanguageDetector {
    
    // MARK: - Language Code Utilities
    
    /// 提取主语言代码（去掉地区和脚本标识）
    /// - Parameter languageCode: 完整的语言代码（如 "zh-Hant", "zh-Hans", "en-US"）
    /// - Returns: 主语言代码（如 "zh", "zh", "en"）
    static func extractPrimaryLanguageCode(_ languageCode: String) -> String {
        // 处理 BCP 47 格式：语言-脚本-地区
        // 例如：zh-Hant、zh-Hans、en-US、pt-BR
        
        if let separatorIndex = languageCode.firstIndex(of: "-") {
            return String(languageCode[..<separatorIndex])
        }
        
        return languageCode
    }
    
    /// 判断两个语言代码是否匹配（支持简体/繁体中文等变体）
    /// - Parameters:
    ///   - code1: 语言代码1
    ///   - code2: 语言代码2
    /// - Returns: 是否匹配
    private static func languageCodesMatch(_ code1: String, _ code2: String) -> Bool {
        // 提取主语言代码
        let primary1 = extractPrimaryLanguageCode(code1)
        let primary2 = extractPrimaryLanguageCode(code2)
        
        return primary1 == primary2
    }
    
    // MARK: - Public Methods
    
    /// 检测字符属于哪种文字系统
    /// - Parameter char: 要检测的字符
    /// - Returns: 语言代码或文字系统标识
    static func detectScript(for char: Character) -> String {
        // 1. 拉丁字母系统
        if char.isLatin {
            return "latin"
        }
        
        // 2. CJK（中日韩）
        else if char.isHiragana || char.isKatakana {
            return "ja"
        }
        else if char.isHangul {
            return "ko"
        }
        else if char.isChinese {
            return "zh"
        }
        
        // 3. 西里尔文
        else if char.isCyrillic {
            return "cyrillic"
        }
        
        // 4. 阿拉伯文
        else if char.isArabic {
            return "arabic"
        }
        
        // 5. 天城文
        else if char.isDevanagari {
            return "devanagari"
        }
        
        // 6. 南亚语系
        else if char.isBengali {
            return "bengali"
        }
        else if char.isTamil {
            return "ta"
        }
        else if char.isTelugu {
            return "te"
        }
        else if char.isKannada {
            return "kn"
        }
        else if char.isMalayalam {
            return "ml"
        }
        else if char.isGujarati {
            return "gu"
        }
        else if char.isGurmukhi {
            return "pa"
        }
        else if char.isSinhala {
            return "si"
        }
        else if char.isOriya {
            return "or"
        }
        
        // 7. 东南亚语系
        else if char.isThai {
            return "th"
        }
        else if char.isLao {
            return "lo"
        }
        else if char.isMyanmar {
            return "my"
        }
        else if char.isKhmer {
            return "km"
        }
        
        // 8. 非洲语系
        else if char.isEthiopic {
            return "ethiopic"
        }
        
        // 9. 中东/其他
        else if char.isHebrew {
            return "he"
        }
        else if char.isGreek {
            return "el"
        }
        
        return "unknown"
    }
    
    /// 检测完整名字的语言（混合判断方案）
    /// - Parameter name: 联系人名字
    /// - Returns: 语言代码
    static func detectNameLanguage(name: String) -> String {
        guard !name.isEmpty, let firstChar = name.first else {
            return "unknown"
        }
        
        // 快速判断非汉字的情况
        let script = detectScript(for: firstChar)
        
        // 如果不是汉字，直接返回
        if script != "zh" {
            return script
        }
        
        // 汉字情况 - 检查是否混合了其他文字
        let hasKana = name.contains { $0.isHiragana || $0.isKatakana }
        if hasKana {
            return "ja"
        }
        
        let hasHangul = name.contains { $0.isHangul }
        if hasHangul {
            return "ko"
        }
        
        // 纯汉字 - 使用 NLLanguageRecognizer
        if #available(iOS 12.0, *) {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(name)
            recognizer.languageConstraints = [
                .simplifiedChinese,
                .traditionalChinese,
                .japanese,
                .korean
            ]
            
            if let language = recognizer.dominantLanguage {
                return language.rawValue
            }
        }
        
        // 降级方案：根据系统语言推断
        let systemLang = Locale.current.languageCode ?? "en"
        if systemLang == "ja" { return "ja" }
        if systemLang == "ko" { return "ko" }
        return "zh"
    }
    
    /// 判断文字系统是否与系统语言匹配
    /// - Parameters:
    ///   - script: 文字系统标识
    ///   - systemLanguage: 系统语言代码
    /// - Returns: 是否匹配
    static func isScriptMatch(_ script: String, systemLanguage: String) -> Bool {
        
        // 标准化脚本代码（提取主语言部分）
        let normalizedScript = extractPrimaryLanguageCode(script)
        let normalizedSystemLang = extractPrimaryLanguageCode(systemLanguage)
        
        
        // 拉丁字母 - 支持所有使用拉丁字母的语言
        if normalizedScript == "latin" {
            return LanguageMappings.latinLanguages.contains(normalizedSystemLang)
        }
        
        // 西里尔文 - 多语言共享
        if normalizedScript == "cyrillic" {
            return LanguageMappings.cyrillicLanguages.contains(normalizedSystemLang)
        }
        
        // 阿拉伯文 - 多语言共享
        if normalizedScript == "arabic" {
            return LanguageMappings.arabicLanguages.contains(normalizedSystemLang)
        }
        
        // 天城文 - 多语言共享
        if normalizedScript == "devanagari" {
            return LanguageMappings.devanagariLanguages.contains(normalizedSystemLang)
        }
        
        // 孟加拉文 - 多语言共享
        if normalizedScript == "bengali" {
            return LanguageMappings.bengaliLanguages.contains(normalizedSystemLang)
        }
        
        // 埃塞俄比亚文 - 多语言共享
        if normalizedScript == "ethiopic" {
            return LanguageMappings.ethiopicLanguages.contains(normalizedSystemLang)
        }
        
        // 独立文字系统 - 精确匹配
        if let supportedLanguages = LanguageMappings.uniqueScriptLanguages[normalizedScript] {
            return supportedLanguages.contains(normalizedSystemLang)
        }
        
        return false
    }
    
    
    /// 只能在zh的情况下使用
    /// 判断是否为简体中文拼音索引（sectionTitles 只有 A-Z）
    static func isSimplifiedChinesePinyinIndex() -> Bool {
        let collation = UILocalizedIndexedCollation.current()
        let sectionTitles = collation.sectionTitles
        
        // 简体中文的 sectionTitles 应该只包含：
        // - A-Z（26个拉丁字母）
        // - # （特殊字符）
        
        for title in sectionTitles {
            // 跳过 # 符号
            if title == "#" {
                continue
            }
            
            // 检查是否为单个 A-Z 字母
            if title.count == 1,
               let char = title.first,
               char >= "A" && char <= "Z" {
                continue
            }
            
            // 如果遇到其他字符（注音符号、笔画等），说明不是简体中文
            return false
        }
        
        // 额外验证：应该包含 A 和 Z
        return true
    }
}

// MARK: - Language Mappings
private struct LanguageMappings {
    // 拉丁字母语言列表
    static let latinLanguages: Set<String> = [
        "en", "es", "fr", "de", "it", "pt", "pl", "nl", "sv", "no", "da", "fi",
        "id", "ms", "vi", "tl", "sw", "tr", "ha", "yo", "ig", "so",
        "cs", "sk", "sl", "hr", "sq", "ro", "hu", "et", "lv", "lt",
        "is", "lb", "uz", "tk", "az"
    ]
    
    // 西里尔文语言列表
    static let cyrillicLanguages: Set<String> = [
        "ru", "uk", "bg", "kk", "tg", "mk", "mn"
    ]
    
    // 阿拉伯文语言列表
    static let arabicLanguages: Set<String> = [
        "ar", "fa", "ur", "ckb", "ks"
    ]
    
    // 天城文语言列表
    static let devanagariLanguages: Set<String> = [
        "hi", "mr", "ne", "ks"
    ]
    
    // 孟加拉文语言列表
    static let bengaliLanguages: Set<String> = [
        "bn", "as"
    ]
    
    // 埃塞俄比亚文语言列表
    static let ethiopicLanguages: Set<String> = [
        "am", "ti", "om"
    ]
    
    // 独立文字系统映射
    static let uniqueScriptLanguages: [String: Set<String>] = [
        "zh": ["zh"],
        "ja": ["ja"],
        "ko": ["ko"],
        "ta": ["ta"],
        "te": ["te"],
        "kn": ["kn"],
        "ml": ["ml"],
        "gu": ["gu"],
        "pa": ["pa"],
        "si": ["si"],
        "or": ["or"],
        "th": ["th"],
        "lo": ["lo"],
        "my": ["my"],
        "km": ["km"],
        "he": ["he", "iw"],
        "el": ["el"]
    ]
}
