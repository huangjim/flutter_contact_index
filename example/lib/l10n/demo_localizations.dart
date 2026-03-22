import 'package:flutter/widgets.dart';

class DemoLocalizations {
  const DemoLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
    Locale('ja'),
  ];

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations)!;
  }

  static const LocalizationsDelegate<DemoLocalizations> delegate =
      _DemoLocalizationsDelegate();

  static const _localizedValues = {
    'en': {
      'appTitle': 'Contact Index Demo',
      'contactsCount': 'Contacts synced: {count}',
      'loadingContacts': 'Fetching contacts…',
      'emptyContacts': 'No contacts available.',
      'fetchContactsFailed': 'Failed to fetch contacts: {error}',
      'contactsPermissionDenied': 'Contacts permission denied. Please grant permission and retry.',
      'noPhoneNumber': 'No phone number',
    },
    'zh_CN': {
      'appTitle': '通讯录示例',
      'contactsCount': '已同步 {count} 个联系人',
      'loadingContacts': '正在读取联系人…',
      'emptyContacts': '暂无联系人可展示。',
      'fetchContactsFailed': '读取联系人失败：{error}',
      'contactsPermissionDenied': '联系人权限被拒绝，请授权后重试。',
      'noPhoneNumber': '暂无号码',
    },
    'zh_TW': {
      'appTitle': '通訊錄範例',
      'contactsCount': '已同步 {count} 位聯絡人',
      'loadingContacts': '正在讀取聯絡人…',
      'emptyContacts': '目前沒有可顯示的聯絡人。',
      'fetchContactsFailed': '讀取聯絡人失敗：{error}',
      'contactsPermissionDenied': '聯絡人權限被拒絕，請授權後重試。',
      'noPhoneNumber': '暫無號碼',
    },
    'ja': {
      'appTitle': '連絡先デモ',
      'contactsCount': '同期済みの連絡先: {count}',
      'loadingContacts': '連絡先を取得しています…',
      'emptyContacts': '表示できる連絡先がありません。',
      'fetchContactsFailed': '連絡先の取得に失敗しました: {error}',
      'contactsPermissionDenied': '連絡先の権限が拒否されました。権限を許可して再試行してください。',
      'noPhoneNumber': '電話番号なし',
    },
  };

  Map<String, String> get _strings {
    final key = _localeKey(locale);
    return _localizedValues[key] ?? _localizedValues['en']!;
  }

  String get appTitle => _strings['appTitle']!;

  String contactsCount(int count) {
    return _strings['contactsCount']!.replaceFirst('{count}', '$count');
  }

  String get loadingContacts => _strings['loadingContacts']!;

  String get emptyContacts => _strings['emptyContacts']!;

  String fetchContactsFailed(String error) {
    return _strings['fetchContactsFailed']!.replaceFirst('{error}', error);
  }

  String get contactsPermissionDenied => _strings['contactsPermissionDenied']!;

  String get noPhoneNumber => _strings['noPhoneNumber']!;

  static String _localeKey(Locale locale) {
    final buffer = StringBuffer(locale.languageCode);
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      buffer.write('_');
      buffer.write(locale.countryCode);
      return buffer.toString();
    }
    if (locale.scriptCode != null && locale.scriptCode!.isNotEmpty) {
      buffer.write('_');
      buffer.write(locale.scriptCode);
    }
    return buffer.toString();
  }
}

class _DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalizations> {
  const _DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return DemoLocalizations.supportedLocales.any(
      (supported) =>
          supported.languageCode == locale.languageCode &&
          (supported.countryCode == null ||
              supported.countryCode!.isEmpty ||
              supported.countryCode == locale.countryCode),
    );
  }

  @override
  Future<DemoLocalizations> load(Locale locale) async {
    return DemoLocalizations(locale);
  }

  @override
  bool shouldReload(_DemoLocalizationsDelegate old) => false;
}
