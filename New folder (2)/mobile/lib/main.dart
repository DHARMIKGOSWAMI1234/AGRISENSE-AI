import 'package:flutter/material.dart';
import 'app/app.dart';
import 'data/local/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local ACID database
  await AppDatabase().initialize();

  runApp(const SmritiApp());
}
