import 'package:cached_network_image/cached_network_image.dart';
import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:anpha_petrol_smartgas/core/utils/validator.dart';
import 'package:anpha_petrol_smartgas/widgets/loading_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Codec;
import 'dart:convert';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

// Used for max age, the default is 30 days
const int IMAGE_DOWNLOAD_CACHE_MAX_AGE_HOUR = 24 * 30;

// Used for max age, approximately 100 years (Not use the default above)
const int IMAGE_PERSISTENT_CACHE_MAX_AGE_HOUR = 24 * 365 * 100;

// Used for max entries
const int IMAGE_CACHE_MAX_ENTRIES = 10000;

// Used for max size in bytes (100MB). If the image size is bigger than
// this number => Image won't be cached.
const int IMAGE_CACHE_MAX_SIZE_IN_BYTES = 1073741824;

//  ------------------------------------------------------------------------
//  IMAGE CACHE MANAGER
//  ------------------------------------------------------------------------

class ImageCacheManager {
  static final DiskCache _customDiskCache = DiskCache(
    isPersistent: false,
    maxEntries: IMAGE_CACHE_MAX_ENTRIES,
    maxAge: const Duration(hours: IMAGE_DOWNLOAD_CACHE_MAX_AGE_HOUR),
    maxSizeInBytes: IMAGE_CACHE_MAX_SIZE_IN_BYTES,
  );

  static final DiskCache _persistentDiskCache = DiskCache(
    isPersistent: true,
    maxEntries: IMAGE_CACHE_MAX_ENTRIES,
    maxAge: const Duration(hours: IMAGE_PERSISTENT_CACHE_MAX_AGE_HOUR),
    maxSizeInBytes: IMAGE_CACHE_MAX_SIZE_IN_BYTES,
  );

  static bool isAssetImage(String image) {
    return image.startsWith("assets/");
  }

  static bool isSvgImage(String image) {
    return image.endsWith("svg");
  }

  static bool isNetwork(String image) {
    String _value = image.trim();
    return (_value.startsWith('http') || _value.startsWith('https'));
  }

  static Widget getImage({
    required String? url,
    Key? key,
    double scale = 1.0,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    int? cacheWidth,
    int? cacheHeight,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit fit = BoxFit.cover,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    FilterQuality filterQuality = FilterQuality.low,
    fadeInDuration,
  }) {
    String defaultImage = GlobalManager.images.defaultImage;

    if (url == null || url.isEmpty) {
      return Image.asset(
        defaultImage,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
      );
    }

    if (isAssetImage(url)) {
      if (isSvgImage(url)) {
        return SvgPicture.asset(
          url,
          excludeFromSemantics: excludeFromSemantics,
          width: width,
          height: height,
          color: color,
          colorBlendMode: colorBlendMode ?? BlendMode.srcIn,
          fit: fit,
          alignment: alignment,
          matchTextDirection: matchTextDirection,
          semanticsLabel: semanticLabel,
        );
      }
      return Image.asset(
        url,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
      );
    } else {
      Widget image = FadeInImage.assetNetwork(
        placeholder: defaultImage,
        image: url,
        fit: fit,
        fadeInDuration: (fadeInDuration ?? const Duration(milliseconds: 100)),
        height: height,
        width: width,
        imageCacheWidth: cacheWidth,
        imageCacheHeight: cacheHeight,
        imageErrorBuilder: (_, __, ___) {
          return Image.asset(
            defaultImage,
            semanticLabel: semanticLabel,
            excludeFromSemantics: excludeFromSemantics,
            width: width,
            height: height,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            color: color,
            colorBlendMode: colorBlendMode,
            fit: fit,
            alignment: alignment,
            repeat: repeat,
            centerSlice: centerSlice,
            matchTextDirection: matchTextDirection,
            gaplessPlayback: gaplessPlayback,
            filterQuality: filterQuality,
          );
        },
        alignment: alignment,
        excludeFromSemantics: excludeFromSemantics,
        matchTextDirection: matchTextDirection,
        repeat: repeat,
        imageSemanticLabel: semanticLabel,
      );

      return image;
    }
  }

  static CustomImageProvider getImageProvider({required String url}) {
    assert(url.isNotEmpty);
    return CustomImageProvider(
      url,
      cache: isAssetImage(url) ? _persistentDiskCache : _customDiskCache,
    );
  }

  static Widget getCachedImage({required String url}) {
    assert(url.isNotEmpty);
    CustomImageProvider imageProvider = getImageProvider(url: url);
    return ImageProviderWidget(imageProvider: imageProvider);
  }

  static Widget getCachedImage02({
    String? url,
    Key? key,
    double scale = 1.0,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    BoxFit fit = BoxFit.cover,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gapLessPlayback = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    CustomImageProvider? image;

    if (checkStringNullOrEmpty(url)) {
      String defaultImage = GlobalManager.images.defaultImage;

      return Image.asset(
        defaultImage,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gapLessPlayback,
        filterQuality: filterQuality,
      );
    }

    if (isAssetImage(url ?? "")) {
      image = CustomImageProvider(
        url!,
        scale: scale,
        cache: _persistentDiskCache,
      );
    } else {
      image = CustomImageProvider(
        url ?? "",
        scale: scale,
        cache: _customDiskCache,
      );
    }

    return Image(
      key: key,
      image: image,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gapLessPlayback,
      filterQuality: filterQuality,
    );
  }

  static getCachedImage03({
    String? url,
    Key? key,
    double scale = 1.0,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? width,
    double? height,
    Color? color,
    BlendMode? colorBlendMode,
    int? cacheWidth,
    int? cacheHeight,
    BoxFit fit = BoxFit.cover,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    Widget _defaultAssetImage = Image.asset(
      GlobalManager.images.defaultImage,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      width: width,
      height: height,
      color: color,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      filterQuality: filterQuality,
    );
    if (checkStringNullOrEmpty(url)) return _defaultAssetImage;

    if (isAssetImage(url!)) {
      if (isSvgImage(url)) {
        return SvgPicture.asset(
          url,
          excludeFromSemantics: excludeFromSemantics,
          width: width,
          height: height,
          color: color,
          colorBlendMode: colorBlendMode ?? BlendMode.srcIn,
          fit: fit,
          alignment: alignment,
          matchTextDirection: matchTextDirection,
          semanticsLabel: semanticLabel,
        );
      }
      return Image.asset(
        url,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      // alignment: alignment,
      color: color,
      height: height,
      width: width,
      fit: fit,
      fadeInDuration: const Duration(microseconds: 300),
      fadeOutDuration: const Duration(microseconds: 300),
      placeholderFadeInDuration: const Duration(microseconds: 300),
      maxHeightDiskCache: cacheHeight,
      maxWidthDiskCache: cacheWidth,
      memCacheHeight: cacheHeight,
      memCacheWidth: cacheWidth,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      colorBlendMode: colorBlendMode,
      filterQuality: filterQuality,
      key: key,
      placeholder: (_, __) => const LoadingIndicator(radius: 10),
      errorWidget: (_, __, ___) => _defaultAssetImage,
    );
  }

  static Future<String?> getImageLocalPath(String? url) async {
    if (checkStringNullOrEmpty(url)) {
      return "";
    }

    String uId = url.hashCode.toString();

    String? filePath = await _customDiskCache.loadPath(uId);
    if (checkStringNullOrEmpty(filePath)) {
      await _downloadAndSaveFile(url!, uId);
      filePath = await _customDiskCache.loadPath(uId);
    }
    return filePath;
  }

  static Future<void> _downloadAndSaveFile(String url, String uId) async {
    try {
      final http.Response response = await http.get(Uri.parse(url));
      await _customDiskCache.save(uId, response.bodyBytes);
    } on Exception catch (_) {
      showLog(msg: "download image failed");
    }
  }

  static void clear() {
    _customDiskCache.clear();
  }
}

//  ------------------------------------------------------------------------
//  CUSTOM IMAGE PROVIDER
//  ------------------------------------------------------------------------

class CustomImageProvider extends ImageProvider<CustomImageProvider> {
  CustomImageProvider(
    this.url, {
    this.scale = 1.0,
    this.cache,
  });

  final String url;
  final double scale;
  final DiskCache? cache;

  @override
  Future<CustomImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CustomImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(CustomImageProvider key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(CustomImageProvider key) async {
    assert(key == this);

    String uId = key.url.hashCode.toString();

    Uint8List _cacheData = await _loadFromDiskCache(key, uId);
    return await PaintingBinding.instance!.instantiateImageCodec(_cacheData);
  }

  Future<Uint8List> _loadFromDiskCache(
    CustomImageProvider key,
    String uId,
  ) async {
    String defaultImage = GlobalManager.images.defaultImage;

    Uint8List? data = await cache?.load(uId);
    if (data != null) {
      return data;
    }

    if (cache!.isPersistent) {
      ByteData bytes = await rootBundle.load(url);
      Uint8List rawPath = bytes.buffer.asUint8List();
      return rawPath;
    } else {
      Uint8List? imageData = await _loadFromRemote(key.url);
      if (imageData != null) {
        await cache!.save(uId, imageData);
        return imageData;
      } else {
        ByteData bytes = await rootBundle.load(defaultImage);
        Uint8List rawPath = bytes.buffer.asUint8List();
        return rawPath;
      }
    }
  }

  Future<Uint8List?> _loadFromRemote(String url) async {
    http.Response _response = await http.get(Uri.parse(url));
    if (_response.statusCode == 200) {
      return _response.bodyBytes;
    }

    return null;
  }
}

class DiskCache {
  DiskCache({
    this.maxEntries = IMAGE_CACHE_MAX_ENTRIES,
    this.maxAge = const Duration(hours: IMAGE_DOWNLOAD_CACHE_MAX_AGE_HOUR),
    this.isPersistent = false,
    this.maxSizeInBytes = IMAGE_CACHE_MAX_SIZE_IN_BYTES,
  });

  final int maxEntries;
  final Duration maxAge;
  final bool isPersistent;
  final int maxSizeInBytes;

  Map<String, dynamic>? _metadata;

  String _metaDataFileName() {
    return 'imagecache_metadata${isPersistent ? '_persistent' : ''}.json';
  }

  Future<void> _initMetaData() async {
    Directory dir = await getApplicationDocumentsDirectory();
    File path = File(join(dir.path, _metaDataFileName()));
    if (path.existsSync()) {
      _metadata = json.decode(await path.readAsString());
    } else {
      _metadata = {};
    }
  }

  Future<void> _commitMetaData() async {
    File path = File(join(
        (await getApplicationDocumentsDirectory()).path, _metaDataFileName()));
    await path.writeAsString(json.encode(_metadata));
  }

  Future<Uint8List?> load(String uid) async {
    if (_metadata == null) {
      await _initMetaData();
    }

    if (_metadata!.containsKey(uid)) {
      if (!File(_metadata![uid]['path']).existsSync()) {
        _metadata!.remove(uid);
        await _commitMetaData();
        return null;
      }

      if (DateTime.fromMillisecondsSinceEpoch(
              _metadata![uid]['createdTime'] + _metadata![uid]['maxAge'])
          .isBefore(DateTime.now())) {
        await File(_metadata![uid]['path']).delete();
        _metadata!.remove(uid);
        await _commitMetaData();
        return null;
      }

      Uint8List data = await File(_metadata![uid]['path']).readAsBytes();
      return data;
    } else {
      return null;
    }
  }

  Future<String?> loadPath(String uid) async {
    if (_metadata == null) {
      await _initMetaData();
    }

    if (_metadata!.containsKey(uid)) {
      if (!File(_metadata![uid]['path']).existsSync()) {
        _metadata!.remove(uid);
        await _commitMetaData();
        return null;
      }

      if (DateTime.fromMillisecondsSinceEpoch(
              _metadata![uid]['createdTime'] + _metadata![uid]['maxAge'])
          .isBefore(DateTime.now())) {
        await File(_metadata![uid]['path']).delete();
        _metadata!.remove(uid);
        await _commitMetaData();
        return null;
      }

      return _metadata![uid]['path'];
    } else {
      return null;
    }
  }

  Future<void> save(String uid, Uint8List data) async {
    if (_metadata == null) {
      await _initMetaData();
    }

    Directory dir = Directory(join(
        (await getApplicationDocumentsDirectory()).path,
        'imagecache${isPersistent ? '_persistent' : ''}'));

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    if (data.lengthInBytes > maxSizeInBytes) {
      return;
    }

    await File(join(dir.path, uid)).writeAsBytes(data);

    Map<String, dynamic> metadata = {
      'path': join(dir.path, uid),
      'createdTime': DateTime.now().millisecondsSinceEpoch,
      'maxAge': maxAge.inMilliseconds,
    };

    _metadata![uid] = metadata;
    await _checkCacheEntryQuantity();
    await _commitMetaData();
  }

  Future<void> _checkCacheEntryQuantity() async {
    while (_metadata!.length > maxEntries) {
      String key = _metadata!.keys.first;
      if (File(_metadata![key]['path']).existsSync()) {
        await File(_metadata![key]['path']).delete();
      }

      _metadata!.remove(key);
    }
  }

  void clear() async {
    Directory appDir = Directory(join(
        (await getApplicationDocumentsDirectory()).path,
        'imagecache${isPersistent ? '_persistent' : ''}'));

    File metadataFile = File(join(
        (await getApplicationDocumentsDirectory()).path, _metaDataFileName()));

    if (appDir.existsSync()) {
      await appDir.delete(recursive: true);
      if (metadataFile.existsSync()) {
        await metadataFile.delete();
      }

      _metadata = {};
    }
  }
}

//  ------------------------------------------------------------------------
//  LOAD IMAGE FROM IMAGE-PROVIDER
//  ------------------------------------------------------------------------

class ImageProviderWidget extends StatefulWidget {
  const ImageProviderWidget({
    Key? key,
    required this.imageProvider,
  }) : super(key: key);

  final ImageProvider imageProvider;

  @override
  _ImageProviderWidgetState createState() => _ImageProviderWidgetState();
}

class _ImageProviderWidgetState extends State<ImageProviderWidget> {
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;

  @override
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We call _getImage here because createLocalImageConfiguration() needs to
    // be called again if the dependencies changed, in case the changes relate
    // to the DefaultAssetBundle, MediaQuery, etc, which that method uses.
    _getImage();
  }

  @override
  void didUpdateWidget(ImageProviderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) {
      _getImage();
    }
  }

  void _getImage() {
    final ImageStream? oldImageStream = _imageStream;
    _imageStream = widget.imageProvider
        .resolve(createLocalImageConfiguration(this.context));
    if (_imageStream?.key != oldImageStream?.key) {
      // If the keys are the same, then we got the same image back, and so we don't
      // need to update the listeners. If the key changed, though, we must make sure
      // to switch our listeners to the new image stream.
      final ImageStreamListener listener = ImageStreamListener(_updateImage);
      oldImageStream?.removeListener(listener);
      _imageStream?.addListener(listener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    if (!mounted) return;
    setState(() {
      // Trigger a build whenever the image changes.
      _imageInfo = imageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawImage(
      image: _imageInfo?.image, // this is a dart:ui Image object
      scale: _imageInfo?.scale ?? 1.0,
    );
  }
}
