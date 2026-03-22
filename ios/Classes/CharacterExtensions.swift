//
//  CharacterExtensions.swift
//  flutter_contact_index
//
//  Created by zhimin.huang on 2025/11/04.
//

import Foundation

extension Character {
    // ============ 拉丁字母系统 ============
    var isLatin: Bool {
        return ("\u{0041}"..."\u{005A}").contains(String(self)) || 
               ("\u{0061}"..."\u{007A}").contains(String(self)) ||
               ("\u{00C0}"..."\u{00FF}").contains(String(self)) || // 拉丁扩展-A（带音标）
               ("\u{0100}"..."\u{017F}").contains(String(self))    // 拉丁扩展-B
    }
    
    // ============ CJK（中日韩）============
    var isHiragana: Bool { 
        return ("\u{3040}"..."\u{309F}").contains(String(self)) 
    }
    
    var isKatakana: Bool { 
        return ("\u{30A0}"..."\u{30FF}").contains(String(self)) 
    }
    
    var isHangul: Bool { 
        return ("\u{AC00}"..."\u{D7AF}").contains(String(self)) 
    }
    
    // ============ 西里尔文系统 ============
    // 俄语、乌克兰语、保加利亚语、哈萨克语、塔吉克语、马其顿语、蒙古语
    var isCyrillic: Bool { 
        return ("\u{0400}"..."\u{04FF}").contains(String(self)) ||
               ("\u{0500}"..."\u{052F}").contains(String(self))
    }
    
    // ============ 阿拉伯文系统 ============
    // 阿拉伯语、波斯语、乌尔都语、库尔德语、克什米尔语
    var isArabic: Bool { 
        return ("\u{0600}"..."\u{06FF}").contains(String(self)) ||
               ("\u{0750}"..."\u{077F}").contains(String(self)) ||
               ("\u{08A0}"..."\u{08FF}").contains(String(self))
    }
    
    // ============ 天城文系统（Devanagari）============
    // 印地语、马拉地语、尼泊尔语、克什米尔语
    var isDevanagari: Bool { 
        return ("\u{0900}"..."\u{097F}").contains(String(self)) ||
               ("\u{A8E0}"..."\u{A8FF}").contains(String(self))
    }
    
    // ============ 南亚语系 ============
    // 孟加拉语、阿萨姆语
    var isBengali: Bool { 
        return ("\u{0980}"..."\u{09FF}").contains(String(self)) 
    }
    
    // 泰米尔语
    var isTamil: Bool { 
        return ("\u{0B80}"..."\u{0BFF}").contains(String(self)) 
    }
    
    // 泰卢固语
    var isTelugu: Bool { 
        return ("\u{0C00}"..."\u{0C7F}").contains(String(self)) 
    }
    
    // 卡纳达语
    var isKannada: Bool { 
        return ("\u{0C80}"..."\u{0CFF}").contains(String(self)) 
    }
    
    // 马拉雅拉姆语
    var isMalayalam: Bool { 
        return ("\u{0D00}"..."\u{0D7F}").contains(String(self)) 
    }
    
    // 古吉拉特语
    var isGujarati: Bool { 
        return ("\u{0A80}"..."\u{0AFF}").contains(String(self)) 
    }
    
    // 旁遮普语（古木基文 Gurmukhi）
    var isGurmukhi: Bool { 
        return ("\u{0A00}"..."\u{0A7F}").contains(String(self)) 
    }
    
    // 僧伽罗语
    var isSinhala: Bool { 
        return ("\u{0D80}"..."\u{0DFF}").contains(String(self)) 
    }
    
    // 奥里亚语
    var isOriya: Bool { 
        return ("\u{0B00}"..."\u{0B7F}").contains(String(self)) 
    }
    
    // ============ 东南亚语系 ============
    // 泰语
    var isThai: Bool { 
        return ("\u{0E00}"..."\u{0E7F}").contains(String(self)) 
    }
    
    // 老挝语
    var isLao: Bool { 
        return ("\u{0E80}"..."\u{0EFF}").contains(String(self)) 
    }
    
    // 缅甸语
    var isMyanmar: Bool { 
        return ("\u{1000}"..."\u{109F}").contains(String(self)) ||
               ("\u{AA60}"..."\u{AA7F}").contains(String(self))
    }
    
    // 高棉语
    var isKhmer: Bool { 
        return ("\u{1780}"..."\u{17FF}").contains(String(self)) 
    }
    
    // ============ 非洲语系 ============
    // 埃塞俄比亚语系（阿姆哈拉语、提格雷尼亚语、奥罗莫语）
    var isEthiopic: Bool { 
        return ("\u{1200}"..."\u{137F}").contains(String(self)) ||
               ("\u{1380}"..."\u{139F}").contains(String(self)) ||
               ("\u{2D80}"..."\u{2DDF}").contains(String(self))
    }
    
    // ============ 中东/其他 ============
    // 希伯来语
    var isHebrew: Bool { 
        return ("\u{0590}"..."\u{05FF}").contains(String(self)) 
    }
    
    // 希腊语
    var isGreek: Bool { 
        return ("\u{0370}"..."\u{03FF}").contains(String(self)) ||
               ("\u{1F00}"..."\u{1FFF}").contains(String(self))
    }
    
    // 检查是否为中文字符
    var isChinese: Bool {
        let unicodeScalars = String(self).unicodeScalars
        for scalar in unicodeScalars {
            if (0x4E00...0x9FFF).contains(scalar.value) ||
               (0x3400...0x4DBF).contains(scalar.value) ||
               (0x20000...0x2A6DF).contains(scalar.value) {
                return true
            }
        }
        return false
    }
}
