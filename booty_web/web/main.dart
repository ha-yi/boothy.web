// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:booty_web/firebase_helper.dart';
import 'package:flutter_web_ui/ui.dart' as ui;
import 'package:booty_web/main.dart' as app;

main() async {
  await ui.webOnlyInitializePlatform();
  initApp();
  app.main();
}