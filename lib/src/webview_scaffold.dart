import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class WebviewScaffold extends StatefulWidget {
  final PreferredSizeWidget appBar;
  final String url;
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
  final bool enableAppScheme;
  final String userAgent;
  final bool primary;
  final List<Widget> persistentFooterButtons;
  final Widget bottomNavigationBar;
  final bool withZoom;
  final bool withLocalStorage;
  final bool withLocalUrl;
  final bool scrollBar;
  final String stopUrlRegex;
  final dynamic webViewCallback;
  final dynamic webViewOnCloseCallback;
  final FlutterWebviewPlugin webviewReference;

  final Map<String, String> headers;

    WebviewScaffold(
      {Key key,
      this.appBar,
      @required this.url,
      this.headers,
      this.withJavascript,
      this.clearCache,
      this.clearCookies,
      this.enableAppScheme,
      this.userAgent,
      this.primary = true,
      this.persistentFooterButtons,
      this.bottomNavigationBar,
      this.withZoom,
      this.withLocalStorage,
      this.withLocalUrl,
      this.scrollBar,
      this.webviewReference,
      this.stopUrlRegex,
      this.webViewCallback,
      this.webViewOnCloseCallback})
      : super(key: key) {
          assert(webviewReference != null);
      }

  @override
  _WebviewScaffoldState createState() => new _WebviewScaffoldState();
}

class _WebviewScaffoldState extends State<WebviewScaffold> {
  Rect _rect;
  Timer _resizeTimer;

  @override
  void initState() {
    super.initState();
    widget.webviewReference.close();
  }

  @override
  void dispose() {
    super.dispose();
    widget.webviewReference.close();
    if(widget.webViewOnCloseCallback != null) {
        widget.webViewOnCloseCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_rect == null) {
      _rect = _buildRect(context);
      widget.webviewReference.launch(widget.url,
          headers: widget.headers,
          withJavascript: widget.withJavascript,
          clearCache: widget.clearCache,
          clearCookies: widget.clearCookies,
          enableAppScheme: widget.enableAppScheme,
          userAgent: widget.userAgent,
          rect: _rect,
          withZoom: widget.withZoom,
          withLocalStorage: widget.withLocalStorage,
          withLocalUrl: widget.withLocalUrl,
          scrollBar: widget.scrollBar);
    } else {
      final rect = _buildRect(context);
      if (_rect != rect) {
        _rect = rect;
        _resizeTimer?.cancel();
        _resizeTimer = new Timer(new Duration(milliseconds: 300), () {
          // avoid resizing to fast when build is called multiple time
          widget.webviewReference.resize(_rect);
        });
      }
    }

    if ( (widget.stopUrlRegex != null) && (widget.webViewCallback != null) ) {
        widget.webviewReference.onApptivateDataMessage.listen((messageData) {
            widget.webViewCallback["callback"](messageData);
        });
    }

    return new Scaffold(
        appBar: widget.appBar,
        persistentFooterButtons: widget.persistentFooterButtons,
        bottomNavigationBar: widget.bottomNavigationBar,
        body: const Center(child: const CircularProgressIndicator()));
  }

  Rect _buildRect(BuildContext context) {
    final fullscreen = widget.appBar == null;

    final mediaQuery = MediaQuery.of(context);
    final topPadding = widget.primary ? mediaQuery.padding.top : 0.0;
    final top =
        fullscreen ? 0.0 : widget.appBar.preferredSize.height + topPadding;

    var height = mediaQuery.size.height - top;

    if (widget.bottomNavigationBar != null) {
      height -= 56.0 +
          mediaQuery.padding
              .bottom; // todo(lejard_h) find a way to determine bottomNavigationBar programmatically
    }

    if (widget.persistentFooterButtons != null) {
      height -=
          53.0; // todo(lejard_h) find a way to determine persistentFooterButtons programmatically
      if (widget.bottomNavigationBar == null) {
        height -= mediaQuery.padding.bottom;
      }
    }

    if (height < 0.0) {
      height = 0.0;
    }

    return new Rect.fromLTWH(0.0, top, mediaQuery.size.width, height);
  }
}
