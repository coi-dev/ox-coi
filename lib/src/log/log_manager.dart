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
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:ox_coi/src/extensions/numbers_apis.dart';
import 'package:ox_coi/src/log/log_bloc_delegate.dart';
import 'package:ox_coi/src/platform/files.dart';
import 'package:ox_coi/src/platform/preferences.dart';
import 'package:path_provider/path_provider.dart';

class LogManager {
  static const maxLogFileCount = 10;

  static LogManager _instance;

  File _logFile;

  factory LogManager() {
    if (_instance == null) {
      _instance = LogManager._internal();
    }
    return _instance;
  }

  LogManager._internal();

  get currentLogFile => _logFile;

  void setup({@required bool logToFile, @required Level logLevel}) async {
    BlocSupervisor.delegate = LogBlocDelegate();
    if (logToFile) {
      _logFile = await _setupLogFile();
      await manageLogFiles();
    }
    setupLogger(logLevel, logToFile);
  }

  Future<File> _setupLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/log_${getDateTimeFileFormTimestamp()}.txt');
  }

  Future manageLogFiles() async {
    List<String> logFiles = List();
    List<String> currentLogFiles = await getLogFiles();
    logFiles.addAll(currentLogFiles);
    logFiles.add(_logFile.path);
    if (logFiles.length > maxLogFileCount) {
      deleteLogFile(logFiles[0]);
      logFiles.removeAt(0);
    }
    setPreference(preferenceLogFiles, logFiles);
  }

  void setupLogger(Level logLevel, bool logToFile) {
    Logger.root.level = logLevel;
    Logger.root.onRecord.listen((LogRecord logRecord) {
      print(_logTemplatePrint(logRecord));
      if (logToFile) {
        _writeToLogFile(logRecord);
      }
    });
  }

  String _logTemplatePrint(LogRecord logRecord) {
    var errorInformation = "";
    if (logRecord.error != null || logRecord.stackTrace != null) {
      errorInformation = "\n- Error:\n${logRecord.error}\n- Stack trace:\n(${logRecord.stackTrace})";
    }
    return '[COI - ${logRecord.loggerName}] ${logRecord.message}$errorInformation';
  }

  Future<void> _writeToLogFile(LogRecord logRecord) async {
    var content = _logTemplateFile(logRecord);
    writeToFile(_logFile, content);
  }

  String _logTemplateFile(LogRecord logRecord) {
    return '${logRecord.time} ${logRecord.level.name} [${logRecord.loggerName}] ${logRecord.message}\n';
  }

  void deleteAllLogFiles() async {
    List<String> logFiles = await getLogFiles();
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

  Future<dynamic> getLogFiles() {
    return getPreference(preferenceLogFiles) ?? List<String>();
  }
}
