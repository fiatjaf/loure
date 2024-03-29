import "dart:async";
import "dart:convert";
import "dart:isolate";

import "package:loure/main.dart";
import "package:loure/client/event.dart";

import "package:loure/client/relay/relay.dart";
import "package:loure/client/relay/relay_isolate_worker.dart";

// The real relay, which is run in other isolate.
// It can move jsonDecode and event id check and sign check from main Isolate
class RelayIsolate extends Relay {
  RelayIsolate(
    final String url,
    final RelayStatus relayStatus, {
    final bool assumeValid = true,
    final Event Function(List<List<String>>)? makeAuthEvent,
  }) : super(url, relayStatus, assumeValid, makeAuthEvent);

  Isolate? isolate;
  ReceivePort? subToMainReceivePort;
  SendPort? mainToSubSendPort;
  Completer<bool>? relayConnectResultComplete;

  @override
  Future<bool> connect() async {
    if (subToMainReceivePort == null) {
      relayStatus.connected = ConnState.CONNECTING;

      // never run isolate, begin to run
      subToMainReceivePort = ReceivePort("relay_stm_$url");
      subToMainListener();

      relayConnectResultComplete = Completer();
      isolate = await Isolate.spawn(
        RelayIsolateWorker.runRelayIsolate,
        RelayIsolateConfig(
          url: url,
          subToMainSendPort: subToMainReceivePort!.sendPort,
          network: settingProvider.network,
        ),
      );
      // isolate has run and return a completer.future, wait for subToMain msg to complete this completer.
      return relayConnectResultComplete!.future;
    } else {
      // the isolate had been run
      if (relayStatus.connected == ConnState.CONNECTED) {
        // relay has bean connected, return true, but also send a connect message.
        mainToSubSendPort!.send(RelayIsolateMsgs.CONNECT);
        return true;
      } else {
        // haven't connected
        if (relayConnectResultComplete != null) {
          return relayConnectResultComplete!.future;
        } else {
          // this maybe relay had disconnect after connected, try to connected again.
          if (mainToSubSendPort != null) {
            relayStatus.connected = ConnState.CONNECTING;
            // send connect msg
            mainToSubSendPort!.send(RelayIsolateMsgs.CONNECT);
            // wait connected msg.
            relayConnectResultComplete = Completer();
            return relayConnectResultComplete!.future;
          }
        }
      }
    }

    return false;
  }

  @override
  Future<void> disconnect() async {
    if (relayStatus.connected != ConnState.DISCONNECTED) {
      relayStatus.connected = ConnState.DISCONNECTED;
      if (mainToSubSendPort != null) {
        mainToSubSendPort!.send(RelayIsolateMsgs.DIS_CONNECT);
      }
    }
  }

  @override
  send(final List message) {
    if (mainToSubSendPort != null &&
        relayStatus.connected == ConnState.CONNECTED) {
      final encoded = jsonEncode(message);
      mainToSubSendPort!.send(encoded);
    } else {
      print("[$url]: can't send '$message' not connected");
    }
  }

  void subToMainListener() {
    subToMainReceivePort!.listen((final message) {
      if (message is int) {
        if (message == RelayIsolateMsgs.CONNECTED) {
          relayStatus.connected = ConnState.CONNECTED;
          _relayConnectComplete(true);
        } else if (message == RelayIsolateMsgs.DIS_CONNECTED) {
          this.handleError("websocket disconnected");
          _relayConnectComplete(false);
        }
      } else if (message is String) {
        onMessage(message);
      } else if (message is SendPort) {
        mainToSubSendPort = message;
      }
    });
  }

  void _relayConnectComplete(final bool result) {
    if (relayConnectResultComplete != null) {
      relayConnectResultComplete!.complete(result);
      relayConnectResultComplete = null;
    }
  }

  @override
  void dispose() {
    if (isolate != null) {
      isolate!.kill();
    }
  }
}

class RelayIsolateConfig {
  RelayIsolateConfig({
    required this.url,
    required this.subToMainSendPort,
    this.network,
  });
  final String url;
  final SendPort subToMainSendPort;
  String? network;
}

class RelayIsolateMsgs {
  static const int CONNECT = 1;
  static const int DIS_CONNECT = 2;
  static const int CONNECTED = 101;
  static const int DIS_CONNECTED = 102;
}
