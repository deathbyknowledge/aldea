import 'package:aldea/ui/widgets/feed_widget.dart';
import 'package:aldea/viewmodels/feed_view_model.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:stacked/stacked.dart';
import "../shared/app_colors.dart" as custcolor;
import "../shared/ui_helpers.dart" as devicesize;

class FeedView extends StatefulWidget {
  @override
  _FeedViewState createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with AutomaticKeepAliveClientMixin {
  static final _containerHeight = 100.0 / 800;

  // You don't need to change any of these variables
  var _fromTop = -_containerHeight;
  var _controller = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var _allowReverse = true, _allowForward = true;
  var _prevOffset = 0.0;
  var _prevForwardOffset = -_containerHeight;
  var _prevReverseOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_listener);
  }

  void _listener() {
    double offset = _controller.offset / 800;

    var direction = _controller.position.userScrollDirection;

    if (direction == ScrollDirection.reverse) {
      _allowForward = true;
      if (_allowReverse) {
        _allowReverse = false;
        _prevOffset = offset;
        _prevForwardOffset = _fromTop;
      }

      var difference = offset - _prevOffset;
      _fromTop = _prevForwardOffset + difference;
      if (_fromTop > 0) _fromTop = 0;
    } else if (direction == ScrollDirection.forward) {
      _allowReverse = true;
      if (_allowForward) {
        _allowForward = false;
        _prevOffset = offset;
        _prevReverseOffset = _fromTop;
      }

      var difference = offset - _prevOffset;
      _fromTop = _prevReverseOffset + difference;
      if (_fromTop < -_containerHeight) _fromTop = -_containerHeight;
    }

    setState(
        () {}); // for simplicity I'm calling setState here, you  can put bool values to only call setState when there is a genuine change in _fromTop
  }

  @override
  bool get wantKeepAlive => true;
  @override
  // ignore: must_call_super
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FeedViewModel>.reactive(
      viewModelBuilder: () => FeedViewModel(),
      onModelReady: (model) {
        model.fetchPosts();
        _controller.addListener(() async {
          if (_controller.position.pixels /
                      _controller.position.maxScrollExtent >=
                  0.6 &&
              model.isLoadingMore == false) {
            await model.loadMorePosts();
            model.setIsLoading(false);
          }
        });
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: model.onWillPop,
        child: Scaffold(
          backgroundColor: custcolor.backgroundColor,
          body: Stack(
            children: <Widget>[
              model.posts != null
                  ? SmartRefresher(
                      controller: _refreshController,
                      header: CustomHeader(
                        height: model.refreshing ? 0 : 40,
                        builder: (context, mode) {
                          Widget body;
                          if (mode == RefreshStatus.idle) {
                            body = Text("pull down refresh");
                          } else if (mode == RefreshStatus.refreshing) {
                            body = CupertinoActivityIndicator();
                          } else if (mode == RefreshStatus.canRefresh) {
                            body = Text("release to refresh");
                          } else if (mode == RefreshStatus.completed) {
                            body = Text("refreshCompleted!");
                          }
                          return Container(
                            height: 0.0,
                            child: Center(
                              child: body,
                            ),
                          );
                        },
                      ),
                      onRefresh: () async {
                        print("started refreshing");
                        model.refreshingFeed();
                        await model.fetchPosts();
                        _refreshController.refreshCompleted();
                        model.refreshingFeedEnded();
                        _fromTop = -0.125;
                      },
                      child: ListView.builder(
                        controller: _controller,
                        padding: EdgeInsets.all(0),
                        itemCount: model.posts.length,
                        itemBuilder: (context, index) => index == 0
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: devicesize.screenHeight(context) *
                                        0.125),
                                child: FeedWidget(
                                    navigateToCommunity: () =>
                                        model.communityFromFeed(
                                            model.posts[index].communityId),
                                    navigateToComments: () => model
                                        .goToComments(model.posts[index].id),
                                    postModel: model.posts[index],
                                    likeFunction: () => model.likePost(
                                        model.posts[index].id,
                                        model.isLiked(model.posts[index].likes),
                                        model.posts[index].likes),
                                    isLiked: model.isLiked(
                                      model.posts[index].likes,
                                    ),
                                    deleteAllowed: model.currentUser.mod
                                        .contains(
                                            model.posts[index].communityId),
                                    deletePost: () => model.deletePost(
                                        model.posts[index].id,
                                        model.posts[index].communityId)),
                              )
                            : FeedWidget(
                                navigateToCommunity: () =>
                                    model.communityFromFeed(
                                        model.posts[index].communityId),
                                navigateToComments: () =>
                                    model.goToComments(model.posts[index].id),
                                postModel: model.posts[index],
                                likeFunction: () => model.likePost(
                                    model.posts[index].id,
                                    model.isLiked(model.posts[index].likes),
                                    model.posts[index].likes),
                                isLiked: model.isLiked(
                                  model.posts[index].likes,
                                ),
                                deleteAllowed: model.currentUser.mod
                                    .contains(model.posts[index].communityId),
                                deletePost: () => model.deletePost(
                                    model.posts[index].id,
                                    model.posts[index].communityId)),
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(custcolor.blueishGreyColor),
                      ),
                    ),
              model.refreshing
                  ? Positioned(
                      left: devicesize.screenWidth(context) * 0.45,
                      top: devicesize.screenHeight(context) * 0.4,
                      child: Container(
                        width: devicesize.screenWidth(context) * 0.15,
                        height: devicesize.screenWidth(context) * 0.15,
                        child: CircularProgressIndicator(
                          strokeWidth: 12,
                          valueColor: AlwaysStoppedAnimation(
                            custcolor.blueTheme,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              model.communityList != null
                  ? Positioned(
                      top: devicesize.screenHeight(context) *
                          (-0.125 - _fromTop),
                      child: Container(
                        color: custcolor.darkGrey,
                        width: devicesize.screenWidth(context),
                        height:
                            devicesize.screenHeight(context) * _containerHeight,
                        child: Align(
                          child: Container(
                            //height: devicesize.screenHeight(context) * 0.09,
                            child: model.communityList.length < 7
                                ? ListView.builder(
                                    padding: EdgeInsets.only(
                                        left: devicesize.screenWidth(context) *
                                            0.022),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 6,
                                    itemBuilder: (context, index) {
                                      return index < model.communityList.length
                                          ? Padding(
                                              padding:
                                                  EdgeInsets.only(right: 8.0),
                                              child: GestureDetector(
                                                onTap: () =>
                                                    model.goToCommunity(
                                                        model.communityList[0]),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: custcolor
                                                          .blueishGreyColor,
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              model
                                                                  .communityList[
                                                                      index]
                                                                  .iconPicUrl),
                                                          fit: BoxFit.cover),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.5),
                                                          spreadRadius: 3,
                                                          blurRadius: 7,
                                                          offset: Offset(8,
                                                              10), // changes position of shadow
                                                        ),
                                                      ]),
                                                  width:
                                                      devicesize.screenHeight(
                                                              context) *
                                                          0.09,
                                                ),
                                              ),
                                            )
                                          : Padding(
                                              padding:
                                                  EdgeInsets.only(right: 8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: custcolor
                                                        .blueishGreyColor,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                        spreadRadius: 3,
                                                        blurRadius: 7,
                                                        offset: Offset(8,
                                                            10), // changes position of shadow
                                                      ),
                                                    ]),
                                                width: devicesize
                                                        .screenHeight(context) *
                                                    0.09,
                                              ),
                                            );
                                    })
                                : ListView.builder(
                                    padding: EdgeInsets.only(
                                        left: devicesize.screenWidth(context) *
                                            0.02),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: model.communityList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: GestureDetector(
                                          onTap: () => model.goToCommunity(
                                              model.communityList[index]),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    model.communityList[index]
                                                        .iconPicUrl,
                                                  ),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    spreadRadius: 3,
                                                    blurRadius: 7,
                                                    offset: Offset(8,
                                                        10), // changes position of shadow
                                                  ),
                                                ]),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: devicesize
                                                        .screenWidth(context) *
                                                    0),
                                            height: devicesize
                                                    .screenHeight(context) *
                                                0.09,
                                            width: devicesize
                                                    .screenHeight(context) *
                                                0.09,
                                          ),
                                        ),
                                      );
                                    }),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
