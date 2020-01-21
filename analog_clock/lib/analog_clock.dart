// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  var _textColor = Color(0xFF000000);
  var _secondHandColor = Color(0xFF000000);
  var _hourMinuteHandColor = Color(0xFF000000);
  var _gradientstart = Color(0xFF223344);
  var _gradientend = Color(0xFF446688);

  String _weatherIcon = 'assets/sunny.svg';

  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..addListener(() => setState(() {}));

    animation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(animationController);

    animationController.repeat();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
      _updateImage();
    });
  }

  void _updateImage() {
    switch (_condition) {
      case "cloudy":
        {
          _textColor = Color(0xFF011E42);
          _gradientstart = Color(0xFFE7F1F3);
          _gradientend = Color(0xFF80909D);
          _weatherIcon = 'assets/cloudy.svg';
          _secondHandColor = Color(0xB4151515);
          _hourMinuteHandColor = Color(0xFF151515);
        }
        break;
      case "foggy":
        {
          _textColor = Color(0xFFFFFFF5);
          _gradientstart = Color(0xFF828282);
          _gradientend = Color(0xFF4A545E);
          _weatherIcon = 'assets/foggy.svg';
          _secondHandColor = Color(0xB4151515);
          _hourMinuteHandColor = Color(0xFF151515);
        }
        break;
      case "rainy":
        {
          _textColor = Color(0xFFCECECE);
          _gradientstart = Color(0xFF828282);
          _gradientend = Color(0xFF111255);
          _weatherIcon = 'assets/rainy.svg';
          _secondHandColor = Color(0xB4151515);
          _hourMinuteHandColor = Color(0xFF151515);
        }
        break;

      case "snowy":
        {
          _textColor = Color(0xFF015808);
          _gradientstart = Color(0xFFFFFAFA);
          _gradientend = Color(0xFFE5F3FB);
          _weatherIcon = 'assets/snowy.svg';
          _secondHandColor = Color(0xB4151515);
          _hourMinuteHandColor = Color(0xFF151515);
        }
        break;
      case "sunny":
        {
          _textColor = Color(0xFF151515);
          _gradientstart = Color(0xFFFFDF00);
          _gradientend = Color(0xFFFF7A03);
          _weatherIcon = 'assets/sunny.svg';
          _secondHandColor = Color(0xB4151515);
          _hourMinuteHandColor = Color(0xFF151515);
        }
        break;
      case "thunderstorm":
        {
          _textColor = Color(0xFFFAF2F2);
          _gradientstart = Color(0xFF202223);
          _gradientend = Color(0xFF001C3D);
          _weatherIcon = 'assets/thunderstorm.svg';
          _secondHandColor = Color(0xB4CECECE);
          _hourMinuteHandColor = Color(0xFFCECECE);
        }
        break;
      case "windy":
        {
          _textColor = Color(0xFF070505);
          _gradientstart = Color(0xFFE1CD9D);
          _gradientend = Color(0xFFA79E88);
          _weatherIcon = 'assets/windy.svg';
          _secondHandColor = Color(0xB4151515);
          _hourMinuteHandColor = Color(0xFF151515);
        }
    }
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.

      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hms().format(DateTime.now());

    final dateInfo = DefaultTextStyle(
      style: TextStyle(color: _textColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat.yMd().format(_now),
            textScaleFactor: 2.0,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            DateFormat(widget.model.is24HourFormat ? 'Hms' : 'jms')
                .format(_now),
            textScaleFactor: 1.5,
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );

    final tempInfo = DefaultTextStyle(
      style: TextStyle(color: _textColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _temperature,
            textScaleFactor: 2.0,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            _temperatureRange,
            textScaleFactor: 1.5,
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );

    final locationInfo = DefaultTextStyle(
      style: TextStyle(color: _textColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _location,
            textScaleFactor: 2.0,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(
          colors: [_gradientstart, _gradientend],
        )),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 5,
              child: FadeTransition(
                opacity: animation,
                child: SvgPicture.asset(
                  _weatherIcon,
                  color: _textColor,
                  height: 60,
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 80,
              child: Text(
                _condition,
                textScaleFactor: 1.2,
                style:
                    TextStyle(fontWeight: FontWeight.normal, color: _textColor),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  DateFormat.EEEE().format(_now),
                  textScaleFactor: 2.5,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 5,
              child: dateInfo,
            ),
            DrawnHand(
              color: _secondHandColor,
              thickness: 4,
              size: .8,
              angleRadians: _now.second * radiansPerTick,
            ),
            DrawnHand(
              color: _hourMinuteHandColor,
              thickness: 8,
              size: 0.6,
              angleRadians: _now.minute * radiansPerTick,
            ),
            DrawnHand(
              color: _hourMinuteHandColor,
              thickness: 16,
              size: 0.4,
              angleRadians: _now.hour * radiansPerTick,
            ),
            Positioned(
              left: 10,
              bottom: 5,
              child: tempInfo,
            ),
            Positioned(
              right: 10,
              bottom: 5,
              child: locationInfo,
            ),
          ],
        ),
      ),
    );
  }
}
