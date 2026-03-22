//
//  NativeContactsServiceHostImpl.swift
//  Pods
//
//  Created by zhimin.huang on 2025/10/15.
//

import Foundation
import Contacts
import ContactsUI
import Flutter
import NaturalLanguage


class FlutterContactIndexHostImpl: NSObject, FlutterContactIndexHostApi {
    func getAllContacts(completion: @escaping (Result<[ContactsModel], Error>) -> Void) {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(PigeonError(
                        code: "ACCESS_ERROR",
                        message: "Failed to request contacts access: \(error.localizedDescription)",
                        details: nil
                    )))
                }
                return
            }
            
            guard granted else {
                DispatchQueue.main.async {
                    completion(.failure(PigeonError(
                        code: "PERMISSION_DENIED",
                        message: "Permission to access contacts was denied",
                        details: nil
                    )))
                }
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                var keysToFetch = [
                    CNContactGivenNameKey,
                    CNContactFamilyNameKey,
                    CNContactPhoneNumbersKey,
                    CNContactThumbnailImageDataKey, // 添加获取缩略图数据的键
                ] as [CNKeyDescriptor]
                
                // 添加CNContactFormatter需要的键
                keysToFetch.append(CNContactFormatter.descriptorForRequiredKeys(for: .fullName))
                
                let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                request.sortOrder = .userDefault
                
                do {
                    var contacts = [ContactsModel]()
                    
                    try store.enumerateContacts(with: request) { contact, _ in
                        // 跳过没有电话号码的联系人
                        guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else {
                            return
                        }
                        
                        
                        // 获取所有电话号码及其类型
                        let phoneInfos = contact.phoneNumbers.map { labeledValue -> PhoneInfo in
                            let number = labeledValue.value.stringValue
                            
                            // 获取标签类型
                            var label = "other"
                            if let phoneLabel = labeledValue.label {
                                // 将系统标签转换为更友好的形式
                                switch phoneLabel {
                                case CNLabelPhoneNumberMobile:
                                    label = "mobile"
                                case CNLabelPhoneNumberiPhone:
                                    label = "iPhone"
                                case CNLabelPhoneNumberMain:
                                    label = "main"
                                case CNLabelHome:
                                    label = "home"
                                case CNLabelWork:
                                    label = "work"
                                case CNLabelOther:
                                    label = "other"
                                default:
                                    // 处理自定义标签
                                    label = CNLabeledValue<NSString>.localizedString(forLabel: phoneLabel)
                                }
                            }
                            
                            return PhoneInfo(label: label,number: number)
                        }
                        
                        // 从名字和姓氏创建显示名称
                        let givenName = contact.givenName
                        let familyName = contact.familyName
                        
                        // 获取排序键，如果为空则使用名称首字母
                        var sorKey = "#"
                        
                        
                        let displayName = CNContactFormatter.string(from: contact, style: CNContactFormatterStyle.fullName)
                        
                        // 用于排序的名字（优先使用姓氏）
                        let sortName = contact.familyName
                        
                        sorKey = FlutterContactIndexHostImpl.getLocalizedIndex(for: sortName)
                        
                        
                        // 获取联系人头像
                        var avatarData: FlutterStandardTypedData? = nil
                        if let thumbnailImageData = contact.thumbnailImageData {
                            avatarData=FlutterStandardTypedData(bytes:thumbnailImageData)
                        }
                        
                        let contactModel = ContactsModel(
                            sorKey: sorKey,
                            displayName: displayName,
                            phoneList: phoneInfos,
                            avatar: avatarData
                        )
                        
                        contacts.append(contactModel)
                    }
                    
                    DispatchQueue.main.async {
                        completion(.success(contacts))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(PigeonError(
                            code: "FETCH_ERROR",
                            message: "Failed to fetch contacts: \(error.localizedDescription)",
                            details: nil
                        )))
                    }
                }
            }
            
        }
    }
    
    
    
    // 1. 优先看是否是拉丁字母，即名字第一个字符在sectionTitles里面，使用A-Z
    // 2. 如果名字等于系统语言，使用Unicode划分来判断，使用UILocalizedIndexedCollation来获取索引
    // 3. 不满足上面两个条件的使用#分组
    // MARK: - 使用UILocalizedIndexedCollation获取本地化索引
    static func getLocalizedIndex(for text: String?) -> String {
        // 处理空值情况
        guard let text = text, !text.isEmpty else {
            return "#"
        }
        
        // 获取第一个字符
        guard let firstChar = text.first else {
            return "#"
        }
        
        // 获取当前本地化索引排序系统
        let collation = UILocalizedIndexedCollation.current()
        let sectionTitles = collation.sectionTitles
        
        
        let firstCharString = String(firstChar).uppercased()
        
        // 步骤1: 处理拉丁字符（包括扩展拉丁字符）
        if firstChar.isLatin {
            let firstCharString = String(firstChar).uppercased()
            
            // 检查是否在 sectionTitles 中
            if sectionTitles.contains(firstCharString) {
                return firstCharString
            }
            
            // 如果不在，尝试基础字母（去除音标）
            // 例如：É → E, Ñ → N
            let folded = firstCharString.folding(options: .diacriticInsensitive, locale: nil)
            if folded != firstCharString && sectionTitles.contains(folded) {
                return folded
            }
            
        }
        
        // 步骤2: 判断第一个字符的语言是否与系统语言匹配
        let systemLanguage = Locale.current.languageCode ?? "en"
        let charLanguage = LanguageDetector.detectNameLanguage(name: firstCharString)
        
        if charLanguage == "unknown" {
            return "#"
        }
        let normalizedDetected = LanguageDetector.extractPrimaryLanguageCode(charLanguage)
        // 中文特殊处理 - 多音姓氏
        if normalizedDetected == "zh" && LanguageDetector.isSimplifiedChinesePinyinIndex(){
            // 优先检查是否为多音姓氏
            if let surnameIndex = ChineseSurnameHandler.getSurnameIndex(for: text) {
                return surnameIndex
            }
        }
        
        // 只有当字符语言与系统语言匹配时，才使用UILocalizedIndexedCollation
        if LanguageDetector.isScriptMatch(charLanguage, systemLanguage: systemLanguage) {
            // 使用UILocalizedIndexedCollation获取索引
            let nsText = NSString(string: text)
            let section = collation.section(
                for: nsText,
                collationStringSelector: #selector(NSString.description)
            )
            
            // 确保索引在有效范围内
            if section >= 0 && section < sectionTitles.count {
                return sectionTitles[section]
            }
        }
        
        // 步骤3: 默认返回#
        return "#"
        
    }
    
}
