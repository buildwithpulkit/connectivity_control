import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_control/connectivity_control.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _connectivityControlPlugin = ConnectivityControl.instance;
  StreamSubscription<List<NetworkInfo>>? _subscription;

  @override
  void initState() {
    super.initState();
    _fetchActiveNetworks();
    _listenToNetworkChanges();
  }

  Future<void> _fetchActiveNetworks() async {
    try {
      final networks = await _connectivityControlPlugin.getActiveNetworks();
      log('[getActiveNetworks] $networks');
    } on PlatformException catch (e) {
      log('[getActiveNetworks] Platform Exception -> $e');
    }
  }

  void _listenToNetworkChanges() {
    _subscription = _connectivityControlPlugin.onActiveNetworksChanged.listen((
      networks,
    ) {
      log('[onActiveNetworksChanged] $networks');
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Connectivity Control')),
        body: Center(child: Text('Running on console')),
      ),
    );
  }
}
