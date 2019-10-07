import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jvx_mobile_v3/logic/bloc/close_screen_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/close_screen_view_model.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/menu_item.dart';
import 'package:jvx_mobile_v3/ui/component/jvx_component.dart';
import 'package:jvx_mobile_v3/ui/screen/screen.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import 'package:jvx_mobile_v3/ui/widgets/custom_bottom_modal.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class OpenScreenPage extends StatefulWidget {
  final String title;
  final List<ChangedComponent> changedComponents;
  final List<JVxData> data;
  final List<JVxMetaData> metaData;
  final Key componentId;
  final List<MenuItem> items;

  OpenScreenPage(
      {Key key,
      this.changedComponents,
      this.data,
      this.metaData,
      this.componentId,
      this.title,
      this.items})
      : super(key: key);

  _OpenScreenPageState createState() => _OpenScreenPageState();
}

class _OpenScreenPageState extends State<OpenScreenPage> {
  void rebuildOpenScreen(List<ChangedComponent> changedComponents) {
    this.setState(() {
      getIt.get<JVxScreen>("screen").updateComponents(changedComponents);
    });
  }

  void rebuild() {
    this.setState(() {});
  }

  @override
  void initState() {
    setState(() {
      getIt.get<JVxScreen>("screen").componentId = widget.componentId;
      getIt.get<JVxScreen>("screen").context = context;
      getIt.get<JVxScreen>("screen").buttonCallback = (List<ChangedComponent> data) {
        if (data != null)
          rebuildOpenScreen(data);
        else
          rebuild();
      };

      getIt.get<JVxScreen>("screen").components = <String, JVxComponent>{};
      getIt.get<JVxScreen>("screen").data = widget.data;
      getIt.get<JVxScreen>("screen").metaData = widget.metaData;
      getIt.get<JVxScreen>("screen").title = widget.title;
      getIt.get<JVxScreen>("screen").updateComponents(widget.changedComponents);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        key: widget.componentId,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.ellipsisV),
              onPressed: () => showCustomBottomModalMenu(context, widget.items, widget.componentId),
            )
          ],
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              CloseScreenBloc closeScreenBloc = CloseScreenBloc();
              StreamSubscription<FetchProcess> apiStreamSubscription;

              apiStreamSubscription =
                  apiSubscription(closeScreenBloc.apiResult, context);

              closeScreenBloc.closeScreenController.add(new CloseScreenViewModel(
                  clientId: globals.clientId, componentId: widget.componentId));
            },
          ),
          title: Text(getIt.get<JVxScreen>("screen").title),
        ),
        body: getIt.get<JVxScreen>("screen").getWidget(),
      ),
    );
  }
}
