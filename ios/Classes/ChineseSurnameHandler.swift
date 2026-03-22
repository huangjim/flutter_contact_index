//
//  ChineseSurnameHandler.swift
//  Pods
//
//  Created by zhimin.huang on 2025/11/4.
//

//
//  ChineseSurnameHandler.swift
//  flutter_contact_index
//
//  Created by zhimin.huang on 2025/11/04.
//

import Foundation

/// 中文姓氏多音字处理工具
class ChineseSurnameHandler {
    
    /// 中文姓氏多音字映射表（姓氏 → 正确拼音首字母）
    private static let surnameMap: [String: String] = [
        // 常见多音姓氏
        "曾": "Z",  // zeng，不是 ceng
        "仇": "Q",  // qiu，不是 chou
        "单": "S",  // shan，不是 dan
        "区": "O",  // ou，不是 qu
        "查": "Z",  // zha，不是 cha
        "句": "G",  // gou，不是 ju
        "乐": "Y",  // yue，不是 le
        "覃": "Q",  // qin，不是 tan
        "佘": "S",  // she，不是 yu
        // 复姓
        "万俟": "M", // moqi
        "尉迟": "Y", // yuchi
        "长孙": "Z", // zhangsun
        "澹台": "T", // tantai
        "呼延": "H", // huyan
        "东方": "D", // dongfang
        "欧阳": "O", // ouyang
        "上官": "S", // shangguan
        "司马": "S", // sima
        "诸葛": "Z", // zhuge
    ]
    
    /// 获取中文姓氏的正确索引字母
    /// - Parameter name: 中文名字
    /// - Returns: 索引字母（A-Z），如果不是多音姓氏返回 nil
    static func getSurnameIndex(for name: String) -> String? {
        guard !name.isEmpty else { return nil }
        
        // 优先检查复姓（2个字）
        if name.count >= 2 {
            let twoCharPrefix = String(name.prefix(2))
            if let index = surnameMap[twoCharPrefix] {
                return index
            }
        }
        
        // 检查单姓（1个字）
        let firstChar = String(name.prefix(1))
        return surnameMap[firstChar]
    }
    
    /// 判断名字的第一个字是否为中文
    /// - Parameter name: 名字
    /// - Returns: 是否为中文
    static func startsWithChinese(_ name: String) -> Bool {
        guard let firstChar = name.first else { return false }
        return firstChar.isChinese
    }
}
