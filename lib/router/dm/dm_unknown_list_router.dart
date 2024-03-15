import 'package:flutter/material.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:provider/provider.dart';

import 'package:loure/provider/dm_provider.dart';
import 'package:loure/router/dm/dm_session_list_item_component.dart';

class DMUnknownListRouter extends StatefulWidget {
  ECDHBasicAgreement agreement;

  DMUnknownListRouter({super.key, required this.agreement});

  @override
  State<StatefulWidget> createState() {
    return _DMUnknownListRouter();
  }
}

class _DMUnknownListRouter extends State<DMUnknownListRouter> {
  @override
  Widget build(BuildContext context) {
    var dmProvider = Provider.of<DMProvider>(context);
    var details = dmProvider.unknownList;

    return Container(
      child: ListView.builder(
        itemBuilder: (context, index) {
          if (index >= details.length) {
            return null;
          }

          var detail = details[index];
          return DMSessionListItemComponent(
            detail: detail,
            agreement: widget.agreement,
          );
        },
        itemCount: details.length,
      ),
    );
  }
}
