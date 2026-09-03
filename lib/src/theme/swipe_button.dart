import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SwipeButton extends StatefulWidget {
  const SwipeButton({
    super.key,
    required this.label,
    required this.onSwipe,
    this.isWorking = false,
    this.icon = PhosphorIconsBold.caretDoubleRight,
    this.activeColor,
  });

  final String label;
  final VoidCallback? onSwipe;
  final bool isWorking;
  final IconData icon;
  final Color? activeColor;

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton>
    with SingleTickerProviderStateMixin {
  double _position = 0.0;
  bool _completed = false;

  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = const AlwaysStoppedAnimation(0.0);
    _controller.addListener(() {
      if (_controller.isAnimating) {
        setState(() {
          _position = _animation.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SwipeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isWorking && oldWidget.isWorking) {
      _reset();
    }
  }

  void _reset() {
    setState(() {
      _position = 0.0;
      _completed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final primaryColor = widget.activeColor ?? cs.primary;
    final isDisabled = widget.onSwipe == null || widget.isWorking;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double trackWidth = constraints.maxWidth;
        const double buttonHeight = 60.0;
        const double padding = 5.0;
        const double thumbSize = buttonHeight - (padding * 2); // 50.0
        final double maxPosition = trackWidth - thumbSize - (padding * 2);

        return Container(
          height: buttonHeight,
          width: trackWidth,
          decoration: BoxDecoration(
            color: isDisabled
                ? cs.surfaceContainerLow.withValues(alpha: 0.5)
                : primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDisabled
                  ? cs.outlineVariant.withValues(alpha: 0.5)
                  : primaryColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.2 : 0.03,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Filled Track background as thumb drags
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: _position + thumbSize + padding * 2,
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? Colors.transparent
                        : primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.horizontal(
                      left: const Radius.circular(30),
                      right: Radius.circular(
                        _position > maxPosition * 0.95 ? 30 : 15,
                      ),
                    ),
                  ),
                ),
              ),
              // Shimmering Label Text
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 48, right: 12),
                  child: _ShimmeringText(
                    text: widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDisabled
                          ? cs.onSurfaceVariant.withValues(alpha: 0.4)
                          : primaryColor.withValues(alpha: 0.85),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Thumb Drag Handle
              Positioned(
                left: padding + _position,
                top: padding,
                bottom: padding,
                child: GestureDetector(
                  onHorizontalDragUpdate: isDisabled || _completed
                      ? null
                      : (details) {
                          setState(() {
                            _position += details.primaryDelta!;
                            if (_position < 0.0) _position = 0.0;
                            if (_position > maxPosition) {
                              _position = maxPosition;
                            }
                          });
                          // Provide light tick haptic on movement
                          if (_position > 0 && _position % 30 < 2) {
                            HapticFeedback.selectionClick();
                          }
                        },
                  onHorizontalDragEnd: isDisabled || _completed
                      ? null
                      : (details) {
                          if (_position > maxPosition * 0.88) {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _position = maxPosition;
                              _completed = true;
                            });
                            if (widget.onSwipe != null) {
                              widget.onSwipe!();
                            }
                          } else {
                            _animation =
                                Tween<double>(
                                  begin: _position,
                                  end: 0.0,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _controller,
                                    curve: Curves.easeOutCubic,
                                  ),
                                );
                            _controller.value = 1.0;
                            _controller.reverse();
                          }
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDisabled
                            ? [
                                cs.surfaceContainerHighest,
                                cs.surfaceContainerHighest,
                              ]
                            : [
                                primaryColor,
                                primaryColor.withValues(alpha: 0.85),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (!isDisabled)
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Center(
                      child: widget.isWorking
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: cs.onPrimary,
                              ),
                            )
                          : Icon(
                              widget.icon,
                              color: isDisabled
                                  ? cs.onSurfaceVariant
                                  : cs.onPrimary,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmeringText extends StatefulWidget {
  const _ShimmeringText({required this.text, required this.style});
  final String text;
  final TextStyle style;

  @override
  State<_ShimmeringText> createState() => _ShimmeringTextState();
}

class _ShimmeringTextState extends State<_ShimmeringText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.style.color ?? Colors.white,
                Colors.white.withValues(alpha: 0.9),
                widget.style.color ?? Colors.white,
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlidingGradientTransform(value: _controller.value),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.value});
  final double value;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final double width = bounds.width;
    return Matrix4.translationValues(width * (value - 0.5) * 2, 0.0, 0.0);
  }
}
