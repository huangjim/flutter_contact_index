import 'package:flutter_contact_index/flutter_contact_index_host_api.g.dart';

class FlutterContactIndex {
  static final FlutterContactIndex _service = FlutterContactIndex._();

  factory FlutterContactIndex() => _service;

  FlutterContactIndex._();

  final _api = FlutterContactIndexHostApi();

  Future<List<ContactsModel>> getAllContacts() {
    return _api.getAllContacts();
  }
}
