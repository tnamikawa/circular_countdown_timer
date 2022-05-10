library circular_countdown_timer;

import 'package:flutter/material.dart';
import 'custom_timer_painter.dart';

/// Create a Circular Countdown Timer.
class CircularCountDownTimer extends StatefulWidget {
  /// Key for Countdown Timer.
  final Key? key;

  /// Filling Color for Countdown Widget.
  final Color fillColor;

  /// Filling Gradient for Countdown Widget.
  final Gradient? fillGradient;

  /// Ring Color for Countdown Widget.
  final Color ringColor;

  /// Ring Gradient for Countdown Widget.
  final Gradient? ringGradient;

  /// Background Color for Countdown Widget.
  final Color? backgroundColor;

  /// Background Gradient for Countdown Widget.
  final Gradient? backgroundGradient;

  /// This Callback will execute when the Countdown Ends.
  final VoidCallback? onComplete;

  /// This Callback will execute when the Countdown Starts.
  final VoidCallback? onStart;

  /// Countdown duration in Seconds.
  final int duration;

  /// Countdown offset in Seconds.
  final int offset;

  /// Countdown initial elapsed Duration in Seconds.
  final int initialDuration;

  /// Width of the Countdown Widget.
  final double width;

  /// Height of the Countdown Widget.
  final double height;

  /// Border Thickness of the Countdown Ring.
  final double strokeWidth;

  /// Begin and end contours with a flat edge and no extension.
  final StrokeCap strokeCap;

  /// Text Style for Countdown Text.
  final TextStyle? textStyle;

  /// Format for the Countdown Text.
  final String? textFormat;

  /// Handles visibility of the Countdown Text.
  final bool isTimerTextShown;

  /// Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
  final CountDownController? controller;

  /// Handles the timer start.
  final bool autoStart;

  CircularCountDownTimer(
      {required this.width,
      required this.height,
      required this.duration,
      required this.offset,
      required this.fillColor,
      required this.ringColor,
      this.backgroundColor,
      this.fillGradient,
      this.ringGradient,
      this.backgroundGradient,
      this.initialDuration = 0,
      this.onComplete,
      this.onStart,
      this.strokeWidth = 5.0,
      this.strokeCap = StrokeCap.butt,
      this.textStyle,
      this.key,
      this.isTimerTextShown = true,
      this.autoStart = true,
      this.textFormat,
      this.controller})
      : assert(initialDuration <= duration),
        super(key: key);

  @override
  CircularCountDownTimerState createState() => CircularCountDownTimerState();
}

class CircularCountDownTimerState extends State<CircularCountDownTimer>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _countDownAnimation;

  String get time {
    Duration duration = _controller!.duration! * _controller!.value;
    return _getTime(duration);
  }

  void _setAnimation() {
    if (widget.autoStart) {
      _controller!.forward();
    }
  }

  void _setAnimationDirection() {
    // if ((!widget.isReverse && widget.isReverseAnimation) ||
    //     (widget.isReverse && !widget.isReverseAnimation)) {
    //   _countDownAnimation =
    //       Tween<double>(begin: 1, end: 0).animate(_controller!);
    // }
  }

  void _setController() {
    widget.controller?._state = this;
    widget.controller?._initialDuration = widget.initialDuration;
    widget.controller?._duration = widget.duration;

    if (widget.initialDuration > 0 && widget.autoStart) {
      _controller?.value = (widget.initialDuration / widget.duration);

      widget.controller?.start();
    }
  }

  String _getTime(Duration duration) {
    return '${duration.inSeconds % 60 + widget.offset}';
  }

  void _onStart() {
    if (widget.onStart != null) widget.onStart!();
  }

  void _onComplete() {
    if (widget.onComplete != null) widget.onComplete!();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );

    _controller!.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          _onStart();
          break;

        case AnimationStatus.reverse:
          _onStart();
          break;

        case AnimationStatus.dismissed:
          _onComplete();
          break;
        case AnimationStatus.completed:

          /// [AnimationController]'s value is manually set to [1.0] that's why [AnimationStatus.completed] is invoked here this animation is [isReverse]
          /// Only call the [_onComplete] block when the animation is not reversed.
          _onComplete();
          break;
        default:
        // Do nothing
      }
    });

    _setAnimation();
    _setAnimationDirection();
    _setController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
          animation: _controller!,
          builder: (context, child) {
            return Align(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CustomTimerPainter(
                            animation: _countDownAnimation ?? _controller,
                            fillColor: widget.fillColor,
                            fillGradient: widget.fillGradient,
                            ringColor: widget.ringColor,
                            ringGradient: widget.ringGradient,
                            strokeWidth: widget.strokeWidth,
                            strokeCap: widget.strokeCap,
                            backgroundColor: widget.backgroundColor,
                            backgroundGradient: widget.backgroundGradient),
                      ),
                    ),
                    widget.isTimerTextShown
                        ? Align(
                            alignment: FractionalOffset.center,
                            child: Text(
                              time,
                              style: widget.textStyle ??
                                  TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    _controller!.stop();
    _controller!.dispose();
    super.dispose();
  }
}

/// Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
class CountDownController {
  late CircularCountDownTimerState _state;
  int? _initialDuration, _duration;

  /// This Method Starts the Countdown Timer
  void start() {
    _state._controller?.forward(
        from: _initialDuration == 0 ? 0 : (_initialDuration! / _duration!));
  }

  /// This Method returns the **Current Time** of Countdown Timer i.e
  /// Time Used in terms of **Forward Countdown** and Time Left in terms of **Reverse Countdown**

  String getTime() {
    return _state
        ._getTime(_state._controller!.duration! * _state._controller!.value);
  }
}
