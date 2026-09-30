// import 'package:pairspace_client/pairspace_client.dart';
// import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
// import 'package:serverpod_flutter/serverpod_flutter.dart';

// final serverUrl = getServerUrl();
// late final Client client;

// Future<void> initializeClient() async {
//   client = Client(await serverUrl)
//     ..connectivityMonitor = FlutterConnectivityMonitor()
//     ..authSessionManager = FlutterAuthSessionManager();
//   unawaited(client.auth.initialize());
//   client.auth.initializeGoogleSignIn(
//     clientId: '<your-client-id>.apps.googleusercontent.com',
//     redirectUri: 'http://localhost:8082/auth/callback',
//   );
// }

import 'dart:async';

import 'package:pairspace_client/pairspace_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

final serverUrl = getServerUrl();
late final Client client;

Future<void> initializeClient() async {
  client = Client(await serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  unawaited(client.auth.initialize());
  client.auth.initializeGoogleSignIn(
    clientId:
        '984826556449-a7t9tue1es34jqtqpm7674bg9je4a6pa.apps.googleusercontent.com',
    redirectUri: 'http://localhost:8082/auth/callback',
  );
}
