import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/flutter_contact_index_host_api.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/hzm/flutter_contact_index/FlutterContactIndexHostChannel.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.hzm.flutter_contact_index'),
  swiftOut: 'ios/Classes/FlutterContactIndexHostChannel.g.swift',
  swiftOptions: SwiftOptions(),
  // cppHeaderOut: 'windows/track_service_host_channel.g.h',
  // cppSourceOut: 'windows/track_service_host_channel.g.cpp',
  // cppOptions: CppOptions(namespace: 'native_contacts_service'),
  // objcHeaderOut: 'ios/Classes/TrackServiceHostChannel.g.h',
  // objcSourceOut: 'ios/Classes/TrackServiceHostChannel.g.m',
  // objcOptions: ObjcOptions(prefix: 'TFL'),
))
class ContactsModel {
  final String sorKey;
  final String? displayName;
  final List<PhoneInfo>? phoneList;
  final Uint8List? avatar;

  const ContactsModel({
    required this.sorKey,
    required this.displayName,
    required this.phoneList,
    this.avatar,
  });
}

class PhoneInfo {
  final String label;
  final String number;

  const PhoneInfo({
    required this.label,
    required this.number,
  });
}

@HostApi()
abstract class FlutterContactIndexHostApi {
  @async
  List<ContactsModel> getAllContacts();
}
