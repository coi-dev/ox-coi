/*
 * OPEN-XCHANGE legal information
 *
 * All intellectual property rights in the Software are protected by
 * international copyright laws.
 *
 *
 * In some countries OX, OX Open-Xchange and open xchange
 * as well as the corresponding Logos OX Open-Xchange and OX are registered
 * trademarks of the OX Software GmbH group of companies.
 * The use of the Logos is not covered by the Mozilla Public License 2.0 (MPL 2.0).
 * Instead, you are allowed to use these Logos according to the terms and
 * conditions of the Creative Commons License, Version 2.5, Attribution,
 * Non-commercial, ShareAlike, and the interpretation of the term
 * Non-commercial applicable to the aforementioned license is published
 * on the web site https://www.open-xchange.com/terms-and-conditions/.
 *
 * Please make sure that third-party modules and libraries are used
 * according to their respective licenses.
 *
 * Any modifications to this package must retain all copyright notices
 * of the original copyright holder(s) for the original code used.
 *
 * After any such modifications, the original and derivative code shall remain
 * under the copyright of the copyright holder(s) and/or original author(s) as stated here:
 * https://www.open-xchange.com/legal/. The contributing author shall be
 * given Attribution for the derivative code and a license granting use.
 *
 * Copyright (C) 2016-2020 OX Software GmbH
 * Mail: info@open-xchange.com
 *
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the Mozilla Public License 2.0
 * for more details.
 */

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:delta_chat_core/delta_chat_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:ox_coi/src/extensions/numbers_apis.dart';
import 'package:ox_coi/src/log/log_bloc_delegate.dart';
import 'package:ox_coi/src/platform/files.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:ox_coi/src/platform/system_information.dart';
import 'package:rxdart/subjects.dart';
import 'package:synchronized/extension.dart';

class LogManager {
  static const _coreLoggerName = "dcc";
  static const _logManagerLoggerName = "logManager";
  static const _maxLogFileCount = 10;
  static const _logFolder = "logs";
  static LogManager _instance;

  final _coreLoggerSubject = PublishSubject<Event>();
  final _core = DeltaChatCore();

  File _logFile;

  factory LogManager() {
    _instance ??= LogManager._internal();
    return _instance;
  }

  LogManager._internal();

  get currentLogFile => _logFile;

  Future<void> setup({@required bool logToFile, @required Level logLevel}) async {
    BlocSupervisor.delegate = LogBlocDelegate();
    if (logToFile) {
      _logFile = await _setupAndGetLogFile();
      await manageLogFiles();
    }
    setupLogger(logLevel, logToFile);
    setupCoreListener();
    await logDeviceInfo();
  }

  Future<File> _setupAndGetLogFile() async {
    final userVisiblePath = await getUserVisibleDirectoryPath();
    final path = userVisiblePath + Platform.pathSeparator + _logFolder;
    final logFile = '$path/log_${getDateTimeFileFormTimestamp()}.txt';
    print('File logging enabled and started. Session is logged in $logFile');
    return File(logFile).create(recursive: true);
  }

  Future manageLogFiles() async {
    final logFiles = <String>[];
    final List<String> currentLogFiles = await getLogFiles();
    logFiles.addAll(currentLogFiles);
    logFiles.add(_logFile.path);
    if (logFiles.length > _maxLogFileCount) {
      deleteLogFile(logFiles[0]);
      logFiles.removeAt(0);
    }
    setPreference(preferenceLogFiles, logFiles);
  }

  void setupLogger(Level logLevel, bool logToFile) {
    Logger.root.level = logLevel;
    Logger.root.onRecord.listen((LogRecord logRecord) {
      _logEntry(logRecord, logToFile);
    });
  }

  void _logEntry(LogRecord logRecord, bool logToFile) {
    debugPrint(_logTemplatePrint(logRecord));
    if (logToFile) {
      _writeToLogFile(logRecord);
    }
  }

  String _logTemplatePrint(LogRecord logRecord) {
    var errorInformation = "";
    if (logRecord.error != null || logRecord.stackTrace != null) {
      errorInformation = "\n- Error:\n${logRecord.error}\n- Stack trace:\n(${logRecord.stackTrace})";
    }
    return '[COI - ${logRecord.loggerName}] ${logRecord.message}$errorInformation';
  }

  Future<void> _writeToLogFile(LogRecord logRecord) async {
    final content = _logTemplateFile(logRecord);
    synchronized(() async => await _logFile.writeAsString(content, mode: FileMode.append));
  }

  String _logTemplateFile(LogRecord logRecord) {
    return '${logRecord.time} ${logRecord.level.name} [${logRecord.loggerName}] ${logRecord.message}\n';
  }

  void deleteAllLogFiles() async {
    final List<String> logFiles = await getLogFiles();
    logFiles.forEach((logFile) {
      deleteLogFile(logFile);
    });
    logFiles.clear();
    await setPreference(preferenceLogFiles, logFiles);
  }

  void deleteLogFile(String logFile) async {
    try {
      File(logFile).delete();
    } catch (error) {}
  }

  Future<List<String>> getLogFiles() async {
    return await getPreference(preferenceLogFiles) ?? <String>[];
  }

  void setupCoreListener() {
    _coreLoggerSubject.listen(_loggingCallback);
    _core.addListener(eventIdList: [Event.info, Event.warning, Event.error, Event.errorNoNetwork], streamController: _coreLoggerSubject);
  }

  void _loggingCallback(Event event) {
    final dccLogMessage = event.data1;
    final dccLogLevel = event.data2;
    final message = "$dccLogLevel: $dccLogMessage";
    final logRecord = LogRecord(Level.INFO, message, _coreLoggerName);
    _writeToLogFile(logRecord);
  }

  Future<void> logDeviceInfo() async {
    final deviceName = await getDeviceName();
    final deviceOs = await getDeviceOsVersion();
    final message = "Device: $deviceName, $deviceOs";
    final logRecord = LogRecord(Level.INFO, message, _logManagerLoggerName);
    _writeToLogFile(logRecord);
  }
}
