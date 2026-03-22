import 'dart:typed_data';

import 'package:azlistview/azlistview.dart';
import 'package:flutter_contact_index/flutter_contact_index_host_api.g.dart';

class ContactListItem extends ISuspensionBean {
  ContactListItem({
    required this.tag,
    required this.displayName,
    this.phonePreview,
    this.avatar,
  }) {
    isShowSuspension = false;
  }

  factory ContactListItem.fromModel(ContactsModel model) {
    final name = (model.displayName ?? '').trim();
    return ContactListItem(
      tag: _extractTag(model.sorKey),
      displayName: name,
      phonePreview: _firstPhone(model.phoneList),
      avatar: model.avatar,
    );
  }

  final String tag;
  final String displayName;
  final String? phonePreview;
  final Uint8List? avatar;

  @override
  String getSuspensionTag() => tag;

  static String _extractTag(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '#';
    }
    final upper = trimmed[0].toUpperCase();
    return _tagPattern.hasMatch(upper) ? upper : '#';
  }

  static String? _firstPhone(List<PhoneInfo>? phones) {
    if (phones == null || phones.isEmpty) {
      return null;
    }
    return phones.first.number;
  }

  static final RegExp _tagPattern = RegExp(r'^[A-Z]$');
}
