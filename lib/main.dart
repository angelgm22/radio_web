import 'package:flutter/material.dart';
import 'package:radio_web/presentation/configuration/configure_web.dart';
import 'package:radio_web/presentation/widget/main_app.dart';
import 'package:radio_web/presentation/configuration/configure_nonweb.dart'
  if (dart.library.html) 'package:radio_web/presentation/configuration/configure_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  configureApp();
  runApp(MainApp());
}