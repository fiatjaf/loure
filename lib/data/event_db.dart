import "dart:convert";

import "package:sqflite/sqflite.dart";

import "package:loure/client/event.dart";
import "package:loure/util/string_util.dart";
import "package:loure/data/db.dart";

class EventDB {
  static Future<List<Event>> list(
      final int keyIndex, final int kind, final int skip, final limit,
      {DatabaseExecutor? db, final String? pubkey}) async {
    db = DB.getDB(db);
    List<Event> l = [];
    List<dynamic> args = [];

    var sql = "select * from event where key_index = ? and kind = ? ";
    args.add(keyIndex);
    args.add(kind);
    if (StringUtil.isNotBlank(pubkey)) {
      sql += " and pubkey = ? ";
      args.add(pubkey);
    }
    sql += " order by created_at desc limit ?, ?";
    args.add(skip);
    args.add(limit);

    List<Map<String, dynamic>> list = await db.rawQuery(sql, args);
    for (final listObj in list) {
      l.add(loadFromJson(listObj));
    }
    return l;
  }

  static Future<int> insert(final int keyIndex, final Event o,
      {DatabaseExecutor? db}) async {
    db = DB.getDB(db);
    final jsonObj = o.toJson();
    final tags = jsonEncode(o.tags);
    jsonObj["tags"] = tags;
    jsonObj.remove("sig");
    jsonObj["key_index"] = keyIndex;
    return await db.insert("event", jsonObj);
  }

  static Future<Event?> get(final int keyIndex, final String id,
      {DatabaseExecutor? db}) async {
    db = DB.getDB(db);
    final list = await db.query("event",
        where: "key_index = ? and id = ?", whereArgs: [keyIndex, id]);
    if (list.isNotEmpty) {
      return Event.fromJson(list[0]);
    }
    return null;
  }

  static Future<void> deleteAll(final int keyIndex,
      {DatabaseExecutor? db}) async {
    db = DB.getDB(db);
    db.execute("delete from event where key_index = ?", [keyIndex]);
  }

  static Event loadFromJson(final Map<String, dynamic> data) {
    Map<String, dynamic> m = {};
    m.addAll(data);

    final tagsStr = data["tags"];
    final tagsObj = jsonDecode(tagsStr);
    m["tags"] = tagsObj;
    m["sig"] = "";
    return Event.fromJson(m);
  }
}
