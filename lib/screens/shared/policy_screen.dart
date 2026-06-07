import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/policy_service.dart';
import '../../theme/design_system.dart';

enum PolicyType { privacy, terms }

/// Displays a platform legal policy (Privacy Policy or Terms of Service),
/// fetched from `/settings/policies/public`. Built on the design system.
class PolicyScreen extends StatefulWidget {
  final PolicyType type;
  const PolicyScreen({super.key, required this.type});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  final _service = PolicyService();
  Policies? _policies;
  bool _loading = true;
  String? _error;

  bool get _isPrivacy => widget.type == PolicyType.privacy;
  String get _title => _isPrivacy ? 'Privacy Policy' : 'Terms of Service';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await _service.getPolicies();
      if (mounted) {
        setState(() {
          _policies = p;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.bg,
      appBar: AppBar(
        backgroundColor: AppPalette.card,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppPalette.textDark),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        title: Text(_title, style: AppText.h2),
      ),
      body: _loading
          ? const AppLoading()
          : _error != null
              ? AppErrorState(message: _error!, onRetry: _fetch)
              : _content(),
    );
  }

  Widget _content() {
    final raw = _isPrivacy
        ? _policies!.privacyPolicy
        : _policies!.termsOfService;
    final text = _stripHtml(raw);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        if (_policies?.lastUpdated != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Last updated: ${_fmtDate(_policies!.lastUpdated!)}',
                style: AppText.caption),
          ),
        AppCard(
          child: text.isEmpty
              ? Text(
                  'The $_title is not available right now. Please check back later.',
                  style: AppText.bodySm)
              : Text(text, style: AppText.bodySm),
        ),
      ],
    );
  }

  String _stripHtml(String html) {
    var s = html.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    s = s.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    s = s.replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n\n');
    s = s.replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n•  ');
    s = s.replaceAll(RegExp(r'<[^>]+>'), '');
    s = s
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return s.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final l = d.toLocal();
    return '${m[l.month - 1]} ${l.day}, ${l.year}';
  }
}
