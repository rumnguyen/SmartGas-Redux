import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/image_cache_manager.dart';
import 'package:anpha_petrol_smartgas/widgets/nuts_activity_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageGalleryScreen extends StatefulWidget {
  final List<String> items;
  final int? currentIndex;

  ImageGalleryScreen({
    Key? key,
    required this.items,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  _ImageGalleryScreenState createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final PhotoViewComputedScale minScale = PhotoViewComputedScale.contained * 1;
  final PhotoViewComputedScale maxScale = PhotoViewComputedScale.covered * 8;

  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.currentIndex ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          GlobalManager.strings.viewPhoto ?? '',
          textScaleFactor: 1.0,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: TextButton(
          onPressed: () => pop(context),
          style: GlobalManager.styles.defaultTextButtonStyle,
          child: const FaIcon(
            FontAwesomeIcons.solidCircleLeft,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: _buildImage,
        itemCount: widget.items.length,
        loadingBuilder: (context, event) => Center(
      child: SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          value: event == null
              ? 0
              : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
        ),
      ),
        ),
        // backgroundDecoration: widget.backgroundDecoration,
        pageController: _controller,
        // onPageChanged: onPageChanged,
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildImage(BuildContext context, int index) {
    final image = widget.items[index];

    Widget child({double? width}) {
      if (!ImageCacheManager.isAssetImage(image) &&
          !ImageCacheManager.isNetwork(image)) {
        return Image.file(
          File(image),
          width: width,
        );
      }
      return CachedNetworkImage(
        imageUrl: image,
        placeholder: (context, url) => const Center(
          child: NutsActivityIndicator(
            radius: 15,
          ),
        ),
        errorWidget: (context, url, error) =>
            ImageCacheManager.getImage(url: GlobalManager.images.defaultImage),
        fit: BoxFit.contain,
        width: width,
      );
    }

    return PhotoViewGalleryPageOptions.customChild(
      initialScale: PhotoViewComputedScale.contained,
      minScale: minScale,
      maxScale: maxScale,
      heroAttributes: PhotoViewHeroAttributes(tag: image),
      child: child(),
    );
  }
}
