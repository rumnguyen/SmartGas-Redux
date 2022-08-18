import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:flutter/material.dart';

class CustomInfoWidget extends StatelessWidget {
  final String title;
  final List<ObjectInfoItem> infoList;

  final double _smallSpacing = GlobalManager.styles.smallSpacing;
  final double _mediumSpacing = GlobalManager.styles.mediumSpacing;
  final double _bigSpacing = GlobalManager.styles.bigSpacing;

  CustomInfoWidget({required this.title, required this.infoList});

  Widget _renderInfoItem(ObjectInfoItem infoItem) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          infoItem.label,
          textScaleFactor: 1.0,
          style: TextStyle(
            color: GlobalManager.colors.grayAEAEB2,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          infoItem.content,
          textScaleFactor: 1.0,
          style: TextStyle(
            color: GlobalManager.colors.black2C394B,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _renderRowInfo(ObjectInfoItem leftItem, {ObjectInfoItem? rightItem}) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: GlobalManager.colors.grayCAC1C1,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
          vertical: _mediumSpacing, horizontal: _smallSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _renderInfoItem(leftItem)),
          SizedBox(
            width: _smallSpacing,
          ),
          rightItem != null
              ? Expanded(
                  child: _renderInfoItem(rightItem),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (infoList.isEmpty) return const SizedBox();
    List<Widget> rowsInfo = [];
    int size = infoList.length;
    for (int i = 0; i < size; i += 2) {
      ObjectInfoItem leftItem = infoList[i];
      ObjectInfoItem? rightItem = (i + 1 == size) ? null : infoList[i + 1];
      rowsInfo.add(_renderRowInfo(leftItem, rightItem: rightItem));
    }
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _mediumSpacing,
              vertical: _smallSpacing,
            ),
            child: Text(
              title,
              textScaleFactor: 1.0,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: GlobalManager.colors.black052525,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Divider(
            thickness: 0.5,
            color: GlobalManager.colors.grayCAC1C1,
            height: 1,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _mediumSpacing),
            child: Column(
              children: rowsInfo,
            ),
          ),
          SizedBox(
            height: _bigSpacing,
          ),
        ],
      ),
    );
  }
}

class ObjectInfoItem {
  final String label;
  final String content;

  ObjectInfoItem({
    required this.label,
    required this.content,
  });
}
