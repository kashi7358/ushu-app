import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/utils/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.init();
  runApp(const UshuApp());
}
