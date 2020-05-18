import 'package:aldea/models/community_request.dart';
import 'package:aldea/ui/shared/ui_helpers.dart';
import 'package:aldea/ui/widgets/bottom_filler.dart';
import 'package:aldea/ui/widgets/notch_filler.dart';
import 'package:aldea/ui/widgets/swipe_item.dart';
import 'package:aldea/viewmodels/requests_view_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import "../shared/app_colors.dart";

class RequestsView extends StatelessWidget {
  final List<CommunityRequest> requests;

  const RequestsView({this.requests});
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RequestsViewModel>.reactive(
      viewModelBuilder: () => RequestsViewModel(requests),
      builder: (ctx, model, child) => Scaffold(
        backgroundColor: Color(0xff0F1013),
        body: Column(
          children: <Widget>[
            NotchFiller(),
            Container(
              height: usableScreenHeight(context) * 0.08,
              width: double.infinity,
              color: blueishGreyColor,
              alignment: Alignment.center,
              child: Text(
                "Solicitudes",
                style: TextStyle(color: Colors.white, fontSize: 23),
              ),
            ),
            Container(
                width: double.infinity,
                height: usableScreenHeight(context) * 0.46,
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                    itemCount: requests.length,
                    itemBuilder: (context, i) {
                      return SwipeItem(data: requests[i], isEven: i.isEven );
                    })),
            Container(
              height: usableScreenHeight(context) * 0.46,
              width: double.infinity,
            ),
            BottomFiller()
          ],
        ),
      ),
    );
  }
}
