import 'package:loure/client/event.dart';
import 'package:loure/util/find_event_interface.dart';

/// a memory event box
/// use to hold event received from relay and offer event List to ui
class EventMemBox implements FindEventInterface {
  final List<Event> _eventList = [];
  final Map<String, Event> _idMap = {};
  bool sortAfterAdd;
  EventMemBox({this.sortAfterAdd = true});

  @override
  List<Event> findEvent(String str, {int? limit = 5}) {
    List<Event> list = [];
    for (var event in _eventList) {
      if (event.content.contains(str)) {
        list.add(event);

        if (limit != null && list.length >= limit) {
          break;
        }
      }
    }
    return list;
  }

  Event? get newestEvent {
    if (_eventList.isEmpty) {
      return null;
    }
    return _eventList.first;
  }

  Event? get oldestEvent {
    if (_eventList.isEmpty) {
      return null;
    }
    return _eventList.last;
  }

  // find event oldest createdAt by relay
  OldestCreatedAtByRelayResult oldestCreatedAtByRelay(List<String> relayURLs,
      [int? initTime]) {
    OldestCreatedAtByRelayResult result = OldestCreatedAtByRelayResult();

    var length = _eventList.length;
    for (var index = length - 1; index > -1; index--) {
      var event = _eventList[index];
      for (var source in event.sources) {
        var idx = relayURLs.indexOf(source);
        if (idx != -1) {
          // log("$source findCreatedAt $length $index ${length - index}");
          result.createdAtMap[source] = event.createdAt;
          relayURLs.removeAt(idx);
        }
      }

      if (relayURLs.length == 0) {
        break;
      }
    }

    if (relayURLs.length > 0 && initTime != null) {
      for (var url in relayURLs) {
        result.createdAtMap[url] = initTime;
      }
    }

    // count av createdAt
    var it = result.createdAtMap.values;
    var relayNum = it.length;
    double counter = 0;
    for (var value in it) {
      counter += value;
    }
    result.avCreatedAt = counter ~/ relayNum;

    return result;
  }

  void sort() {
    _eventList.sort((event1, event2) {
      return event2.createdAt - event1.createdAt;
    });
  }

  bool delete(String id) {
    if (_idMap[id] == null) {
      return false;
    }

    _idMap.remove(id);
    _eventList.removeWhere((element) => element.id == id);

    return true;
  }

  bool add(Event event) {
    var oldEvent = _idMap[event.id];
    if (oldEvent != null) {
      if (event.sources.isNotEmpty &&
          !oldEvent.sources.contains(event.sources.first)) {
        oldEvent.sources.add(event.sources.first);
      }
      return false;
    }

    _idMap[event.id] = event;
    _eventList.add(event);
    if (sortAfterAdd) {
      sort();
    }
    return true;
  }

  bool addList(List<Event> list) {
    bool added = false;
    for (var event in list) {
      var oldEvent = _idMap[event.id];
      if (oldEvent == null) {
        _idMap[event.id] = event;
        _eventList.add(event);
        added = true;
      } else {
        if (event.sources.isNotEmpty &&
            !oldEvent.sources.contains(event.sources.first)) {
          oldEvent.sources.add(event.sources.first);
        }
      }
    }

    if (added && sortAfterAdd) {
      sort();
    }

    return added;
  }

  void addBox(EventMemBox b) {
    var all = b.all();
    addList(all);
  }

  bool isEmpty() {
    return _eventList.isEmpty;
  }

  int length() {
    return _eventList.length;
  }

  List<Event> all() {
    return _eventList;
  }

  List<Event> listByPubkey(String pubkey) {
    List<Event> list = [];
    for (var event in _eventList) {
      if (event.pubKey == pubkey) {
        list.add(event);
      }
    }
    return list;
  }

  List<Event> suList(int start, int limit) {
    var length = _eventList.length;
    if (start > length) {
      return [];
    }
    if (start + limit > length) {
      return _eventList.sublist(start, length);
    }
    return _eventList.sublist(start, limit);
  }

  Event? get(int index) {
    if (_eventList.length < index) {
      return null;
    }

    return _eventList[index];
  }

  void clear() {
    _eventList.clear();
    _idMap.clear();
  }
}

class OldestCreatedAtByRelayResult {
  Map<String, int> createdAtMap = {};

  int avCreatedAt = 0;
}
