import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/models/o_feature_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeatureGridView extends StatelessWidget {
  final List<FeatureItem> featureItems;

  const FeatureGridView({
    required this.featureItems,
    Key? key,
  })  : assert(featureItems.length != 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(0.0),
      childAspectRatio: 0.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: featureItems.map((item) {
        return TextButton(
          onPressed: () {
            if (item.onPressed != null) {
              item.onPressed!();
            }
          },
          style: GlobalManager.styles.defaultTextButtonStyle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: item.imgSize,
                height: item.imgSize,
                alignment: Alignment.topCenter,
                child: ImageCacheManager.getImage(
                  url: item.imgURL,
                  width: item.imgSize,
                  height: item.imgSize,
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                child: Text(
                  item.title ?? '',
                  textScaleFactor: 1.0,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
