import 'dart:async';
import 'dart:io' show Platform;

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_contact_index/flutter_contact_index.dart';
import 'package:permission_handler/permission_handler.dart';

import 'l10n/demo_localizations.dart';
import 'models/contact_list_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _contactsPermissionDeniedCode = '__contacts_permission_denied__';
  final _flutterContactIndexPlugin = FlutterContactIndex();
  List<ContactListItem> _contacts = const [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      if (Platform.isAndroid) {
        final permission = await Permission.contacts.request();
        if (!permission.isGranted) {
          if (!mounted) return;
          setState(() {
            _contacts = const [];
            _loading = false;
            _errorMessage = _contactsPermissionDeniedCode;
          });
          return;
        }
      }

      final contacts = await _flutterContactIndexPlugin.getAllContacts();
      final items = contacts.map(ContactListItem.fromModel).toList();
      SuspensionUtil.sortListBySuspensionTag(items);
      SuspensionUtil.setShowSuspensionStatus(items);

      if (!mounted) return;
      setState(() {
        _contacts = items;
        _loading = false;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _contacts = const [];
        _loading = false;
        _errorMessage = e.message ?? e.code;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _contacts = const [];
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        DemoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: DemoLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final strings = DemoLocalizations.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(strings.appTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loading ? null : initPlatformState,
                  tooltip: MaterialLocalizations.of(context)
                      .refreshIndicatorSemanticLabel,
                ),
              ],
            ),
            body: _buildBody(strings),
          );
        },
      ),
    );
  }

  Widget _buildBody(DemoLocalizations strings) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(strings.loadingContacts),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      final message = _errorMessage == _contactsPermissionDeniedCode
          ? strings.contactsPermissionDenied
          : strings.fetchContactsFailed(_errorMessage!);
      return _MessagePlaceholder(
        icon: Icons.error_outline,
        message: message,
        onRetry: initPlatformState,
      );
    }

    if (_contacts.isEmpty) {
      return _MessagePlaceholder(
        icon: Icons.contact_page_outlined,
        message: strings.emptyContacts,
        onRetry: initPlatformState,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            strings.contactsCount(_contacts.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: AzListView(
            data: _contacts,
            itemCount: _contacts.length,
            indexBarData: _buildIndexTags(),
            indexBarWidth: 20,
            indexBarItemHeight: 20,
            itemBuilder: (context, index) {
              final item = _contacts[index];
              return _ContactTile(
                item: item,
                fallbackPhone: strings.noPhoneNumber,
              );
            },
            susItemBuilder: (context, index) {
              final tag = _contacts[index].getSuspensionTag();
              return _SuspensionHeader(label: tag);
            },
            physics: const BouncingScrollPhysics(),
            indexBarMargin: const EdgeInsets.all(8),
            indexBarOptions: const IndexBarOptions(
              needRebuild: true,
              textStyle: TextStyle(
                fontSize: 12,
                height: 1,
                color: Color(0xFF666666),
              ),
              selectTextStyle:
                  TextStyle(
                    fontSize: 12,
                    height: 1,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
              selectItemDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _buildIndexTags() {
    final seen = <String>{};
    final tags = <String>[];
    for (final item in _contacts) {
      final tag = item.getSuspensionTag();
      if (seen.add(tag)) {
        tags.add(tag);
      }
    }
    return tags;
  }
}

class _MessagePlaceholder extends StatelessWidget {
  const _MessagePlaceholder({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(MaterialLocalizations.of(context)
                    .refreshIndicatorSemanticLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.item,
    required this.fallbackPhone,
  });

  final ContactListItem item;
  final String fallbackPhone;

  @override
  Widget build(BuildContext context) {
    final subtitle = item.phonePreview ?? fallbackPhone;
    return Column(
      children: [
        ListTile(
          leading: _Avatar(avatar: item.avatar, name: item.displayName),
          title:
              Text(item.displayName.isEmpty ? fallbackPhone : item.displayName),
          subtitle: Text(subtitle),
        ),
        const Divider(height: 1, indent: 72),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.avatar,
    required this.name,
  });

  final Uint8List? avatar;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (avatar != null && avatar!.isNotEmpty) {
      return CircleAvatar(backgroundImage: MemoryImage(avatar!));
    }

    final initial = name.trim().isEmpty ? '#' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      ),
    );
  }
}

class _SuspensionHeader extends StatelessWidget {
  const _SuspensionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return SizedBox(
          width: width,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
