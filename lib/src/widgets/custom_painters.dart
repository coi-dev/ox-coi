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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ox_coi/src/ui/dimensions.dart';

class CurvePainter extends CustomPainter {
  final color;

  CurvePainter({@required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill;

    var path = Path();
    path.lineTo(0, size.height * 0.9);
    path.cubicTo(size.width * 0.33, size.height * -1, size.width * 0.66, size.height * 2.5, size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BarPainter extends CustomPainter {
  final List<double> peakLevel;
  final Function callback;
  final Color color;
  double barWidth;

  BarPainter({@required this.peakLevel, @required this.callback, @required this.color, this.barWidth = 2.0});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = barWidth;

    var x = 0.0;
    var y = 0.0;

    peakLevel?.forEach((peak) {
      y = peak > barPainterHeight ? y : peak;
      canvas.drawLine(Offset(x, y), Offset(x, -y), paint);
      x = (x + barWidth + barPainterSpaceWidth);
    });

    if (x >= size.width) {
      var cutoff = x - size.width;

      int cutoffIndex = (cutoff / (barWidth + barPainterSpaceWidth)).round();

      callback(cutoffIndex);
    } else {
      callback(0);
    }
  }

  @override
  bool shouldRepaint(BarPainter oldDelegate) {
    return true;
  }
}

class HorizontalLinePainter extends CustomPainter {
  Paint _paint;

  HorizontalLinePainter({@required color}) {
    _paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(zero, zero), Offset(size.width, zero), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class VerticalLinePainter extends CustomPainter {
  Paint _paint;

  VerticalLinePainter({@required color}) {
    _paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(zero, verticalLinePainterPositiveY), Offset(zero, verticalLinePainterNegativeY), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
