import "dart:convert";

import "package:web_socket_channel/web_socket_channel.dart";

import "package:loure/client/event.dart";
import "package:loure/client/relay/relay.dart";

class RelayBase extends Relay {
  RelayBase(
    final String url,
    final RelayStatus relayStatus, {
    final bool assumeValid = true,
    final Event Function(List<List<String>>)? makeAuthEvent,
  }) : super(url, relayStatus, assumeValid, makeAuthEvent);

  WebSocketChannel? _wsChannel;

  @override
  Future<bool> connect() async {
    if (_wsChannel != null && _wsChannel!.closeCode == null) {
      print("connect break: $url");
      return true;
    }

    try {
      relayStatus.connected = ConnState.CONNECTING;

      final wsUrl = Uri.parse(url);
      _wsChannel = WebSocketChannel.connect(wsUrl);
      await _wsChannel!.ready;

      _wsChannel!.stream.listen((final message) {
        onMessage(jsonDecode(message));
      }, onError: (final error) async {
        print(error);
        onError("Websocket error $url", reconnect: true);
      }, onDone: () {
        onError("Websocket stream closed by remote: $url", reconnect: true);
      });
      relayStatus.connected = ConnState.CONNECTED;
      return true;
    } catch (e) {
      onError(e.toString(), reconnect: true);
    }
    return false;
  }

  @override
  send(final List<dynamic> message) {
    if (_wsChannel != null && relayStatus.connected == ConnState.CONNECTED) {
      try {
        final encoded = jsonEncode(message);
        _wsChannel!.sink.add(encoded);
      } catch (e) {
        onError(e.toString(), reconnect: true);
      }
    } else {
      print("[$url]: can't send '$message' not connected");
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      relayStatus.connected = ConnState.UN_CONNECT;
      if (_wsChannel != null) {
        await _wsChannel!.sink.close();
      }
    } finally {
      _wsChannel = null;
    }
  }
}
