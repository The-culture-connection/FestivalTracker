import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

bool _firebaseConfigured() {
  final projectId = DefaultFirebaseOptions.web.projectId;
  return projectId.isNotEmpty && projectId != 'YOUR_PROJECT_ID';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  if (_firebaseConfigured()) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  }

  runApp(FestMapApp(firebaseReady: firebaseReady));
}
