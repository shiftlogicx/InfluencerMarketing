import 'package:flutter/material.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'views/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CreatorPulseApp());
}

class CreatorPulseApp extends StatefulWidget {
  const CreatorPulseApp({super.key});

  @override
  State<CreatorPulseApp> createState() => _CreatorPulseAppState();
}

class _CreatorPulseAppState extends State<CreatorPulseApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Influencer Pulse — Regional Influencer Marketplace",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeShell(appState: _appState),
    );
  }
}
