import "package:flutter/material.dart";

import "package:loure/client/event.dart";
import "package:loure/client/event_kind.dart";
import "package:loure/client/filter.dart";
import "package:loure/client/nip02/contact.dart";
import "package:loure/client/relay/relay_pool.dart";
import "package:loure/data/event_mem_box.dart";
import "package:loure/main.dart";
import "package:loure/util/pendingevents_later_function.dart";

class FollowNewEventProvider extends ChangeNotifier
    with PendingEventsLaterFunction {
  EventMemBox eventMemBox = EventMemBox();

  int? _localSince;
  ManySubscriptionHandle? subHandle;

  void start() {
    _localSince =
        _localSince == null || followEventProvider.lastTime() > _localSince!
            ? followEventProvider.lastTime()
            : _localSince;

    final filter =
        Filter(since: _localSince! + 1, kinds: EventKind.SUPPORTED_EVENTS);

    Iterable<Contact> contactList = contactListProvider.list();
    Set<String> pubkeys = {};

    for (final Contact contact in contactList) {
      pubkeys.add(contact.publicKey);
    }
    pubkeys.add(nostr.publicKey);

    // TODO: outbox model
    filter.authors = pubkeys.toList();
    this.subHandle = pool.subscribeMany(["wss://relay.nostr.band"], [filter],
        onEvent: (final Event event) {
      later(event, handleEvents, null);
    });
  }

  void clear() {
    eventMemBox.clear();
    if (this.subHandle != null) this.subHandle!.close();
    notifyListeners();
  }

  handleEvents(final List<Event> events) {
    eventMemBox.addList(events);
    _localSince = eventMemBox.newestEvent!.createdAt;

    notifyListeners();
  }
}
