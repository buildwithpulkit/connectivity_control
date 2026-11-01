import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_control/connectivity_control.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connectivity Control Demo',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const DemoPage(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final palette = _Palette.of(brightness);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accent,
        brightness: brightness,
        surface: palette.surface,
      ),
      splashFactory: NoSplash.splashFactory,
    );
  }
}

// ─── Palette ─────────────────────────────────────────────────────────────────

class _Palette {
  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color positive;
  final Color caution;

  const _Palette({
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.positive,
    required this.caution,
  });

  static const _light = _Palette(
    background: Color(0xFFF6F7F9),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE6E8EC),
    textPrimary: Color(0xFF111418),
    textSecondary: Color(0xFF5F6670),
    textTertiary: Color(0xFF9AA0A8),
    accent: Color(0xFF3B6FE0),
    positive: Color(0xFF2F9E6B),
    caution: Color(0xFFC98A1B),
  );

  static const _dark = _Palette(
    background: Color(0xFF0E1013),
    surface: Color(0xFF171A1F),
    border: Color(0xFF262A31),
    textPrimary: Color(0xFFF2F3F5),
    textSecondary: Color(0xFFA2A8B1),
    textTertiary: Color(0xFF6B717A),
    accent: Color(0xFF7DA2F0),
    positive: Color(0xFF5BC296),
    caution: Color(0xFFE0AE55),
  );

  static _Palette of(Brightness brightness) =>
      brightness == Brightness.dark ? _dark : _light;

  static _Palette ofContext(BuildContext context) =>
      of(Theme.of(context).brightness);
}

// ─── Page ────────────────────────────────────────────────────────────────────

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _plugin = ConnectivityControl();
  StreamSubscription<List<NetworkInfo>>? _sub;

  // getActiveNetworks() state; only changes when refreshed.
  List<NetworkInfo>? _snapshotNetworks;
  bool _snapshotLoading = false;

  // onActiveNetworksChanged state; null until the first event arrives.
  List<NetworkInfo>? _liveNetworks;

  @override
  void initState() {
    super.initState();
    _fetchSnapshot();
    _sub = _plugin.onActiveNetworksChanged.listen((networks) {
      if (mounted) setState(() => _liveNetworks = networks);
    });
  }

  Future<void> _fetchSnapshot() async {
    setState(() => _snapshotLoading = true);
    List<NetworkInfo> networks;
    try {
      networks = await _plugin.getActiveNetworks();
    } catch (_) {
      networks = _snapshotNetworks ?? const [];
    }
    if (!mounted) return;
    setState(() {
      _snapshotNetworks = networks;
      _snapshotLoading = false;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.ofContext(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchSnapshot,
          color: palette.accent,
          backgroundColor: palette.surface,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              _Header(count: (_liveNetworks ?? _snapshotNetworks)?.length),
              const SizedBox(height: 28),
              _SectionHeader(
                title: 'getActiveNetworks()',
                caption: 'Snapshot at the time of the call',
                trailing: _RefreshButton(
                  loading: _snapshotLoading,
                  onPressed: _fetchSnapshot,
                ),
              ),
              const SizedBox(height: 12),
              _NetworkList(
                networks: _snapshotNetworks,
                pendingText: 'Reading network state…',
              ),
              const SizedBox(height: 28),
              const _SectionHeader(
                title: 'onActiveNetworksChanged',
                caption: 'Updates as soon as the system reports a change',
                trailing: _LiveBadge(),
              ),
              const SizedBox(height: 12),
              _NetworkList(
                networks: _liveNetworks,
                pendingText: 'Waiting for the first update…',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int? count;

  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.ofContext(context);
    final status = switch (count) {
      null => 'Reading network state',
      1 => '1 active network',
      final n => '$n active networks',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'connectivity_control',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: palette.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Networks',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            status,
            key: ValueKey(status),
            style: TextStyle(fontSize: 14, color: palette.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String caption;
  final Widget trailing;

  const _SectionHeader({
    required this.title,
    required this.caption,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.ofContext(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                style: TextStyle(fontSize: 12, color: palette.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _RefreshButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.ofContext(context);
    return TextButton.icon(
      onPressed: loading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: palette.accent,
        disabledForegroundColor: palette.textTertiary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      icon: loading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: palette.textTertiary,
              ),
            )
          : const Icon(Icons.refresh_rounded, size: 16),
      label: const Text('Refresh'),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.ofContext(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulseDot(color: palette.positive),
          const SizedBox(width: 6),
          Text(
            'Live',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.positive,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Network list ────────────────────────────────────────────────────────────

class _NetworkList extends StatelessWidget {
  final List<NetworkInfo>? networks;
  final String pendingText;

  const _NetworkList({required this.networks, required this.pendingText});

  @override
  Widget build(BuildContext context) {
    final networks = this.networks;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: networks == null
          ? _EmptyState(icon: Icons.more_horiz_rounded, text: pendingText)
          : networks.isEmpty
          ? const _EmptyState(
              icon: Icons.cloud_off_rounded,
              text: 'No active networks',
            )
          : Column(
              children: [
                for (final n in networks)
                  _NetworkCard(key: ValueKey(n.type), info: n),
              ],
            ),
    );
  }
}

// ─── Surface ─────────────────────────────────────────────────────────────────

class _Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Surface({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.ofContext(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: child,
    );
  }
}

// ─── Network card ────────────────────────────────────────────────────────────

class _NetworkCard extends StatelessWidget {
  final NetworkInfo info;

  const _NetworkCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.ofContext(context);
    final hasBandwidth = info.downLinkKbps != null || info.upLinkKbps != null;

    return _FadeIn(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _Surface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: palette.accent.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _icon(info.type),
                      size: 20,
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _label(info.type),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _summary(info),
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(online: info.hasInternet == true),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, thickness: 1, color: palette.border),
              const SizedBox(height: 14),
              Row(
                children: [
                  _Metric(label: 'Internet', value: _yesNo(info.hasInternet)),
                  _Metric(label: 'Validated', value: _yesNo(info.isValidated)),
                  _Metric(label: 'Metered', value: _yesNo(info.isMetered)),
                ],
              ),
              if (hasBandwidth) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Metric(
                      label: 'Downlink',
                      value: _formatKbps(info.downLinkKbps),
                    ),
                    _Metric(
                      label: 'Uplink',
                      value: _formatKbps(info.upLinkKbps),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _summary(NetworkInfo info) {
    final parts = [
      if (info.isValidated == true)
        'Validated'
      else if (info.isValidated == false)
        'Not validated',
      if (info.isMetered == true)
        'Metered'
      else if (info.isMetered == false)
        'Unmetered',
    ];
    return parts.isEmpty ? 'Active' : parts.join(' · ');
  }
}

class _StatusBadge extends StatelessWidget {
  final bool online;

  const _StatusBadge({required this.online});

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.ofContext(context);
    final color = online ? palette.positive : palette.caution;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            online ? 'Online' : 'No internet',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.ofContext(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: palette.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: palette.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final palette = _Palette.ofContext(context);
    return _Surface(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(icon, size: 22, color: palette.textTertiary),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Motion ──────────────────────────────────────────────────────────────────

/// Fades and slightly lifts its child the first time it is built.
class _FadeIn extends StatelessWidget {
  final Widget child;

  const _FadeIn({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 8),
          child: child,
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;

  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_controller.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 6 + 8 * t,
                height: 6 + 8 * t,
                decoration: BoxDecoration(
                  color: widget.color.withAlpha((90 * (1 - t)).round()),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Formatting ──────────────────────────────────────────────────────────────

String _label(NetworkType type) => switch (type) {
  NetworkType.wifi => 'Wi-Fi',
  NetworkType.cellular => 'Cellular',
  NetworkType.vpn => 'VPN',
  NetworkType.ethernet => 'Ethernet',
  NetworkType.other => 'Other',
};

IconData _icon(NetworkType type) => switch (type) {
  NetworkType.wifi => Icons.wifi_rounded,
  NetworkType.cellular => Icons.signal_cellular_alt_rounded,
  NetworkType.vpn => Icons.lock_outline_rounded,
  NetworkType.ethernet => Icons.settings_ethernet_rounded,
  NetworkType.other => Icons.lan_outlined,
};

String _yesNo(bool? value) => switch (value) {
  true => 'Yes',
  false => 'No',
  null => '—',
};

String _formatKbps(int? kbps) {
  if (kbps == null) return '—';
  if (kbps >= 1000) return '${(kbps / 1000).toStringAsFixed(1)} Mbps';
  return '$kbps Kbps';
}
