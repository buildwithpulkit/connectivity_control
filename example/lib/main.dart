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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final _plugin = ConnectivityControl();
  StreamSubscription<List<NetworkInfo>>? _sub;

  // getActiveNetworks state
  List<NetworkInfo>? _snapshotNetworks;
  bool _snapshotLoading = false;

  // onActiveNetworksChanged state
  List<NetworkInfo> _liveNetworks = [];

  @override
  void initState() {
    super.initState();
    _fetchSnapshot();
    _startListening();
  }

  Future<void> _fetchSnapshot() async {
    setState(() => _snapshotLoading = true);
    try {
      final networks = await _plugin.getActiveNetworks();
      setState(() {
        _snapshotNetworks = networks;
        _snapshotLoading = false;
      });
    } catch (_) {
      setState(() => _snapshotLoading = false);
    }
  }

  void _startListening() {
    _sub = _plugin.onActiveNetworksChanged.listen((networks) {
      setState(() => _liveNetworks = networks);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'connectivity_control',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            label: 'getActiveNetworks()',
            labelColor: const Color(0xFF34D399),
            trailing: IconButton(
              onPressed: _snapshotLoading ? null : _fetchSnapshot,
              icon: _snapshotLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF34D399)),
                    )
                  : const Icon(Icons.refresh_rounded, color: Color(0xFF34D399)),
              tooltip: 'Refresh',
            ),
            child: _snapshotNetworks == null
                ? const _EmptyHint(text: 'Fetching…')
                : _snapshotNetworks!.isEmpty
                    ? const _EmptyHint(text: 'No active networks found')
                    : Column(
                        children: _snapshotNetworks!
                            .map((n) => _NetworkCard(info: n))
                            .toList(),
                      ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            label: 'onActiveNetworksChanged',
            labelColor: const Color(0xFF818CF8),
            trailing: _LiveDot(active: _sub != null),
            child: _liveNetworks.isEmpty
                ? const _EmptyHint(text: 'Waiting for network changes…')
                : Column(
                    children: _liveNetworks.map((n) => _NetworkCard(info: n)).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Section wrapper ─────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.label,
    required this.labelColor,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                ?trailing,
              ],
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Network card ─────────────────────────────────────────────────────────────

class _NetworkCard extends StatelessWidget {
  final NetworkInfo info;

  const _NetworkCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeIcon(type: info.type),
              const SizedBox(width: 8),
              Text(
                info.type.name.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _BoolChip(label: 'internet', value: info.hasInternet),
              _BoolChip(label: 'validated', value: info.isValidated),
              _BoolChip(label: 'metered', value: info.isMetered),
            ],
          ),
          if (info.downLinkKbps != null || info.upLinkKbps != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (info.downLinkKbps != null)
                  _BandwidthPill(
                    icon: Icons.arrow_downward_rounded,
                    color: const Color(0xFF34D399),
                    value: info.downLinkKbps!,
                  ),
                if (info.downLinkKbps != null && info.upLinkKbps != null)
                  const SizedBox(width: 8),
                if (info.upLinkKbps != null)
                  _BandwidthPill(
                    icon: Icons.arrow_upward_rounded,
                    color: const Color(0xFFF472B6),
                    value: info.upLinkKbps!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Type icon ────────────────────────────────────────────────────────────────

class _TypeIcon extends StatelessWidget {
  final NetworkType type;

  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      NetworkType.wifi => (Icons.wifi_rounded, const Color(0xFF60A5FA)),
      NetworkType.cellular => (Icons.signal_cellular_alt_rounded, const Color(0xFFFBBF24)),
      NetworkType.vpn => (Icons.vpn_lock_rounded, const Color(0xFFA78BFA)),
      NetworkType.ethernet => (Icons.cable_rounded, const Color(0xFF34D399)),
      NetworkType.other => (Icons.device_hub_rounded, const Color(0xFF94A3B8)),
    };
    return Icon(icon, color: color, size: 20);
  }
}

// ─── Bool chip ────────────────────────────────────────────────────────────────

class _BoolChip extends StatelessWidget {
  final String label;
  final bool? value;

  const _BoolChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = value == null
        ? (const Color(0xFF1E293B), const Color(0xFF64748B), Icons.remove)
        : value!
            ? (const Color(0xFF14532D), const Color(0xFF86EFAC), Icons.check_rounded)
            : (const Color(0xFF450A0A), const Color(0xFFFCA5A5), Icons.close_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: fg, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

// ─── Bandwidth pill ───────────────────────────────────────────────────────────

class _BandwidthPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;

  const _BandwidthPill({required this.icon, required this.color, required this.value});

  String get _formatted {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)} Mbps';
    return '$value Kbps';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(_formatted, style: TextStyle(fontSize: 12, color: color, fontFamily: 'monospace')),
      ],
    );
  }
}

// ─── Live dot ────────────────────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  final bool active;

  const _LiveDot({required this.active});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween(begin: 0.3, end: 1.0).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _opacity,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF818CF8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF818CF8),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'monospace'),
      ),
    );
  }
}

