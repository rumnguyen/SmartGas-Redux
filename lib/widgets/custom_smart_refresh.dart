import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/widgets/loading_dot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CustomSmartRefresh extends StatefulWidget {
  final Function(RefreshController)? onRefresh;
  final Function(RefreshController)? onLoading;
  final Widget? child;
  final RefreshController? controller;
  final bool? enablePullUp;

  const CustomSmartRefresh({
    Key? key,
    this.onRefresh,
    this.onLoading,
    this.child,
    this.controller,
    this.enablePullUp = false,
  }) : super(key: key);

  @override
  _CustomSmartRefreshState createState() => _CustomSmartRefreshState();
}

class _CustomSmartRefreshState extends State<CustomSmartRefresh> {
  RefreshController? refreshController;

  @override
  void initState() {
    super.initState();
    refreshController = widget.controller ?? RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullUp: widget.enablePullUp!,
      controller: refreshController!,
      physics: const BouncingScrollPhysics(),
      header: MaterialClassicHeader(
        backgroundColor: GlobalManager.colors.colorAccent,
      ),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget? body;
          if (mode == LoadStatus.loading) {
            body = const LoadingIndicator(radius: 12);
          } else if (mode == LoadStatus.failed) {
            body = const Text("Load Failed!Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = const LoadingIndicator(radius: 12);
          }
          if (body == null) return Container();
          return SizedBox(
            height: 40.0,
            child: Center(child: body),
          );
        },
      ),
      onRefresh: () => widget.onRefresh != null
          ? widget.onRefresh!(refreshController!)
          : null,
      onLoading: () => widget.onLoading != null
          ? widget.onLoading!(refreshController!)
          : null,
      child: widget.child,
    );
  }
}
