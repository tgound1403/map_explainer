import 'dart:io';

import 'package:intl/intl.dart';

enum LogLevel { verbose, debug, info, warning, error }

class Logger {
  Logger._internal();

  static final _red = Platform.isAndroid ? '\u001b[31m' : '';

  // static final _green = Platform.isAndroid ? '\u001b[32m' : '';
  static final _yellow = Platform.isAndroid ? '\u001b[33m' : '';
  static final _blue = Platform.isAndroid ? '\u001b[34m' : '';
  static final _magenta = Platform.isAndroid ? '\u001b[35m' : '';
  static final _cyan = Platform.isAndroid ? '\u001b[36m' : '';
  static final _reset = Platform.isAndroid ? '\u001b[0m' : '';

  static final _formatLogTime = DateFormat('yyyy-MM-dd hh:mm:ss');

  static void _log(
    String level,
    Object? object, {
    String? trackingEventName,
    Map<String, Object?>? params,
  }) {
    print(
      '[${_formatLogTime.format(DateTime.now())}] $level $object ${trackingEventName == null ? '' : '(event name: $trackingEventName)'}',
    );
  }

  static void v(
    Object? object, {
    String? trackingEventName,
    Map<String, Object?>? params,
  }) =>
      _log(
        '$_yellow[Verbose]$_reset',
        object,
        trackingEventName: trackingEventName,
        params: params,
      );

  static void d(
    Object? object, {
    String? trackingEventName,
    Map<String, Object?>? params,
  }) =>
      _log(
        '$_cyan[Debug]$_reset',
        object,
        trackingEventName: trackingEventName,
        params: params,
      );

  static void i(
    Object? object, {
    String? trackingEventName,
    Map<String, Object?>? params,
  }) =>
      _log(
        '$_blue[Info]$_reset',
        object,
        trackingEventName: trackingEventName,
        params: params,
      );

  static void w(
    Object? object, {
    String? trackingEventName,
    Map<String, Object?>? params,
  }) =>
      _log(
        '$_magenta[Warning]$_reset',
        object,
        trackingEventName: trackingEventName,
        params: params,
      );

  static Future<void> e(
    message, {
    bool trackCrash = false,
    StackTrace? stackTrace,
    reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
  }) async {
    _log('$_red[Error]$_reset', message);
  }
}
