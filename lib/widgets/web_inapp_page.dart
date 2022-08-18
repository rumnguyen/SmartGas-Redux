import 'dart:async';

import 'package:anpha_petrol_smartgas/core/global_manager.dart';
import 'package:anpha_petrol_smartgas/core/helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebInAppPage extends StatefulWidget {
  final String webUrl;
  final double webBodyRadius;
  final BoxShadow webBodyBoxShadow;
  final BoxBorder? webBodyBoxBorder;
  final Color? webBodyColor;
  final EdgeInsets? webBodyMargin;
  final EdgeInsets? webBodyPadding;
  final bool enableAppBar;
  final Color? appBarBackgroundColor;
  final String appBarTitle;
  final bool? appBarCenterTitle;
  final TextStyle? appBarTextStyle;
  final Brightness? appBarBrightness;
  final Gradient? appBarBackgroundGradient;
  final bool hasLoadingIndicator;
  final List<JavascriptChannel>? jsChannels;
  final bool clearCacheWhenWebViewCreated;
  final Color? scaffoldBackgroundColor;

  const WebInAppPage({
    Key? key,
    required this.webUrl,
    this.webBodyRadius = 0.0,
    this.webBodyBoxShadow = const BoxShadow(
      offset: Offset(0.0, 0.0),
      blurRadius: 0.0,
      color: Colors.transparent,
    ),
    this.webBodyBoxBorder,
    this.webBodyColor,
    this.webBodyMargin = const EdgeInsets.all(0),
    this.webBodyPadding = const EdgeInsets.all(0),
    this.enableAppBar = true,
    this.appBarBackgroundColor,
    this.appBarTitle = "",
    this.appBarCenterTitle = true,
    this.appBarTextStyle,
    this.appBarBrightness,
    this.appBarBackgroundGradient,
    this.hasLoadingIndicator = true,
    this.jsChannels,
    this.clearCacheWhenWebViewCreated = false,
    this.scaffoldBackgroundColor = Colors.white,
  })  : assert(appBarCenterTitle != null &&
            webUrl.length != 0 &&
            scaffoldBackgroundColor != null &&
            webBodyRadius >= 0.0),
        super(key: key);

  @override
  _WebInAppPageState createState() => _WebInAppPageState();
}

class _WebInAppPageState extends State<WebInAppPage> {
  final CookieManager _cookieManager = CookieManager();

  bool _isLoading = false;
  double _loadingValue = 0.0;
  bool _canGoBack = false;
  bool _canForward = false;
  WebViewController? _wvController;

  Future<void> reloadWebView() async {
    await _wvController?.reload();
  }

  Future<bool> canGoBack() async {
    return await _wvController?.canGoBack() ?? false;
  }

  Future<void> goBack() async {
    await _wvController?.goBack();
  }

  Future<bool> canGoForward() async {
    return await _wvController?.canGoForward() ?? false;
  }

  Future<void> goForward() async {
    await _wvController?.goForward();
  }

  Future<void> scrollTo(int x, int y) async {
    await _wvController?.scrollTo(x, y);
  }

  Future<String?> evaluateJs(String javascriptString) async {
    // Another way not use evaludateJavascript:
    // ==> loadUrl: "javascript:updateNotificationToken('$token')"
    if (javascriptString.isEmpty) return null;
    return await _wvController?.evaluateJavascript(javascriptString);
  }

  Future<List<String>> getAllCookies() async {
    final String? cookies =
        await _wvController?.evaluateJavascript('document.cookie');
    List<String> cookieList = cookies?.split(';') ?? [];
    return cookieList;
  }

  Future<void> clearCache() async {
    await _wvController?.clearCache();
  }

  void clearAllCookies() async {
    await _cookieManager.clearCookies();
  }

  void _updateLoading(bool status) {
    if (!widget.hasLoadingIndicator) return;
    if (_isLoading == status) return;
    if (!mounted) return;
    if (status) {
      setState(() {
        _isLoading = status;
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;

        setState(() {
          _loadingValue = 0.25;
        });
      });
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!mounted) return;

        setState(() {
          _loadingValue = 0.45;
        });
      });
      Future.delayed(const Duration(milliseconds: 180), () {
        if (!mounted) return;

        setState(() {
          _loadingValue = 0.65;
        });
      });
    } else {
      if (!mounted) return;

      Future.delayed(const Duration(milliseconds: 250), () {
        setState(() {
          _loadingValue = 1.0;
        });
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;

        setState(() {
          _isLoading = status;
          _loadingValue = 0.0;
        });
      });
    }
  }

  void _updateBackButtonState({bool state = false}) {
    if (!mounted) return;
    if (_canGoBack == state) return;
    setState(() {
      _canGoBack = state;
    });
  }

  void _updateForwardButtonState({bool state = false}) {
    if (!mounted) return;
    if (_canForward == state) return;
    setState(() {
      _canForward = state;
    });
  }

  Future<void> _checkCanGoBackOrForward() async {
    bool res = await canGoBack();
    _updateBackButtonState(state: res);
    res = await canGoForward();
    _updateForwardButtonState(state: res);
  }

  Widget _renderWebBackButton() {
    return SizedBox(
      width: 40,
      child: TextButton(
        onPressed: () async {
          await goBack();
          await _checkCanGoBackOrForward();
        },
        style: TextButton.styleFrom(
            primary: GlobalManager.colors.majorColor(opacity: 0.1),
            textStyle: const TextStyle(color: Colors.white)),
        child: FaIcon(
          FontAwesomeIcons.chevronLeft,
          size: 20,
          color: (_canGoBack ? Colors.white : GlobalManager.colors.grayABABAB),
        ),
      ),
    );
  }

  Widget _renderWebForwardButton() {
    return SizedBox(
      width: 40,
      child: TextButton(
        onPressed: () async {
          await goForward();
          await _checkCanGoBackOrForward();
        },
        style: TextButton.styleFrom(
            primary: GlobalManager.colors.majorColor(opacity: 0.1),
            textStyle: const TextStyle(color: Colors.white)),
        child: FaIcon(
          FontAwesomeIcons.chevronRight,
          size: 20,
          color: (_canForward ? Colors.white : GlobalManager.colors.grayABABAB),
        ),
      ),
    );
  }

  Widget _renderWebReloadButton() {
    return SizedBox(
      width: 40,
      child: TextButton(
        onPressed: () async {
          await reloadWebView();
          await scrollTo(0, 0);
        },
        style: TextButton.styleFrom(
            primary: GlobalManager.colors.majorColor(opacity: 0.1),
            textStyle: const TextStyle(color: Colors.white)),
        child: const FaIcon(
          FontAwesomeIcons.arrowRotateRight,
          size: 17,
          color: Colors.white,
        ),
      ),
    );
  }

  PreferredSizeWidget _renderAppBar() {
    if (!widget.enableAppBar) {
      return PreferredSize(
        preferredSize: const Size(0, 0),
        child: Container(),
      );
    }

    if (widget.appBarBackgroundGradient != null) {
      return AppBar(
        title: Text(
          widget.appBarTitle,
          textScaleFactor: 1.0,
          style: widget.appBarTextStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: widget.appBarCenterTitle,
        titleSpacing: 0,
        // brightness: widget.appBarBrightness ?? Brightness.dark,
        leading: TextButton(
          onPressed: () => pop(context),
          style: TextButton.styleFrom(
              primary: GlobalManager.colors.majorColor(opacity: 0.1),
              textStyle: const TextStyle(color: Colors.white)),
          child: const FaIcon(
            FontAwesomeIcons.solidCircleLeft,
            size: 20,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          _renderWebBackButton(),
          _renderWebForwardButton(),
          _renderWebReloadButton(),
        ],
      );
    }

    return AppBar(
      title: Text(
        widget.appBarTitle,
        textScaleFactor: 1.0,
        style: widget.appBarTextStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
      ),
      centerTitle: widget.appBarCenterTitle,
      // brightness: widget.appBarBrightness ?? Brightness.dark,
      backgroundColor: widget.appBarBackgroundColor ?? GlobalManager.colors.majorColor(),
      leading: TextButton(
        onPressed: () => pop(context),
        style: TextButton.styleFrom(
            primary: GlobalManager.colors.majorColor(opacity: 0.1),
            textStyle: const TextStyle(color: Colors.white)),
        child: const FaIcon(
          FontAwesomeIcons.solidCircleLeft,
          size: 20,
          color: Colors.white,
        ),
      ),
      actions: <Widget>[
        _renderWebBackButton(),
        _renderWebForwardButton(),
        _renderWebReloadButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildElement = Scaffold(
      appBar: _renderAppBar(),
      backgroundColor: widget.scaffoldBackgroundColor,
      body: Container(
        margin: widget.webBodyMargin,
        padding: widget.webBodyPadding,
        decoration: BoxDecoration(
          color: widget.webBodyColor,
          border: widget.webBodyBoxBorder,
          boxShadow: [widget.webBodyBoxShadow],
          borderRadius: BorderRadius.all(Radius.circular(widget.webBodyRadius)),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(widget.webBodyRadius),
              ),
              child: WebView(
                initialUrl: widget.webUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) async {
                  _updateLoading(true);
                  _wvController = webViewController;
                  if (widget.clearCacheWhenWebViewCreated) {
                    await clearCache();
                  }
                },
                onPageStarted: (url) {
                  _updateLoading(true);
                },
                onPageFinished: (value) async {
                  _updateLoading(false);
                  await _checkCanGoBackOrForward();
                },
                javascriptChannels:
                    (widget.jsChannels != null && widget.jsChannels!.isNotEmpty
                        ? widget.jsChannels?.toSet()
                        : null),
              ),
            ),
            (_isLoading
                ? LinearProgressIndicator(
                    backgroundColor: GlobalManager.colors.majorColor(opacity: 0.25),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        GlobalManager.colors.majorColor(opacity: 0.9)),
                    value: _loadingValue,
                  )
                : Container()),
          ],
        ),
      ),
    );

    _buildElement = WillPopScope(
      onWillPop: () async {
        bool _canGoBack = await canGoBack();
        if (_canGoBack) {
          goBack();
          return Future.value(false);
        } else {
          pop(context, object: true);
          return Future.value(true);
        }
      },
      child: _buildElement,
    );

    return _buildElement;
  }
}
