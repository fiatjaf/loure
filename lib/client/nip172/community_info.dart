import "package:loure/client/event.dart";
import "package:loure/client/input.dart";
import "package:loure/client/event_kind.dart";
import "package:loure/util/string_util.dart";

class CommunityInfo {
  CommunityInfo({
    required this.createdAt,
    required this.aId,
    this.description,
    this.image,
    this.event,
  });

  int createdAt;
  AddressPointer aId;
  String? description;
  String? image;
  Event? event;

  static CommunityInfo? fromEvent(final Event event) {
    if (event.kind == EventKind.COMMUNITY_DEFINITION) {
      String title = "";
      String description = "";
      String image = "";
      for (final tag in event.tags) {
        if (tag.length > 1) {
          final tagKey = tag[0];
          final tagValue = tag[1];

          if (tagKey == "d") {
            title = tagValue;
          } else if (tagKey == "description") {
            description = tagValue;
          } else if (tagKey == "image") {
            image = tagValue;
          }
        }
      }

      if (StringUtil.isNotBlank(title)) {
        final id = AddressPointer(
          kind: EventKind.COMMUNITY_DEFINITION,
          pubkey: event.pubkey,
          identifier: title,
          relays: [],
        );
        return CommunityInfo(
          createdAt: event.createdAt,
          aId: id,
          description: description,
          image: image,
          event: event,
        );
      }
    }

    return null;
  }
}
