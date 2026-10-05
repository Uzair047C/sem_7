import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFDDDDDD),
        body: SafeArea(
          child: Card3D(
            front: const StudentCardFront(
              name: 'Muhammad Uzair',
              department: 'Electrical & Computer Engineering',
              campus: 'CUI, Lahore Campus',
              idText: 'CIIT/FA23-BCE-098/LHR',
              photo: AssetImage('assets/uz.jpeg'),   
              logo: AssetImage('assets/cui_logo.jpg'), 
            ),
            back: const StudentCardBack(
              // signature: AssetImage('assets/signature.png'), // <- optional
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets the user drag anywhere on the screen to spin the card in 3D.
/// - Drag: rotate in any direction
/// - Let go while moving: it keeps spinning and slows down
/// - Double tap: smoothly return to the front
class Card3D extends StatefulWidget {
  final Widget front;
  final Widget back;

  const Card3D({super.key, required this.front, required this.back});

  @override
  State<Card3D> createState() => _Card3DState();
}

class _Card3DState extends State<Card3D> with TickerProviderStateMixin {
  static const _dragSensitivity = 0.01; // radians per pixel
  static const _twoPi = 2 * math.pi;

  double _rx = 0; // rotation around the X axis (tilt up/down)
  double _ry = 0; // rotation around the Y axis (turn left/right)
  double _vx = 0; // angular velocities (rad/s) for the momentum effect
  double _vy = 0;

  late final Ticker _momentum;
  late final AnimationController _reset;
  Duration _lastTick = Duration.zero;
  double _fromX = 0, _fromY = 0, _toX = 0, _toY = 0;

  @override
  void initState() {
    super.initState();
    _momentum = createTicker(_onMomentumTick);
    _reset = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addListener(() {
        final t = Curves.easeOutCubic.transform(_reset.value);
        setState(() {
          _rx = _fromX + (_toX - _fromX) * t;
          _ry = _fromY + (_toY - _fromY) * t;
        });
      });
  }

  @override
  void dispose() {
    _momentum.dispose();
    _reset.dispose();
    super.dispose();
  }

  void _onMomentumTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    setState(() {
      _rx += _vx * dt;
      _ry += _vy * dt;
      final friction = math.exp(-2.5 * dt);
      _vx *= friction;
      _vy *= friction;
    });
    if (_vx.abs() < 0.02 && _vy.abs() < 0.02) {
      _momentum.stop();
    }
  }

  void _onPanStart(DragStartDetails d) {
    _momentum.stop();
    _reset.stop();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _ry -= d.delta.dx * _dragSensitivity;
      _rx += d.delta.dy * _dragSensitivity;
    });
  }

  void _onPanEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond;
    _vy = -v.dx * _dragSensitivity * 0.6;
    _vx = v.dy * _dragSensitivity * 0.6;
    if (_vx.abs() > 0.05 || _vy.abs() > 0.05) {
      _lastTick = Duration.zero;
      _momentum.start();
    }
  }

  void _resetToFront() {
    _momentum.stop();
    _fromX = _rx;
    _fromY = _ry;
    // Nearest full turn, so it doesn't unwind lots of spins.
    _toX = (_rx / _twoPi).roundToDouble() * _twoPi;
    _toY = (_ry / _twoPi).roundToDouble() * _twoPi;
    _reset.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateX(_rx)
      ..rotateY(_ry);

    // Which side is facing the viewer right now?
    final showingFront = math.cos(_rx) * math.cos(_ry) >= 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onDoubleTap: _resetToFront,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Transform(
              alignment: Alignment.center,
              transform: matrix,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: showingFront
                      ? widget.front
                      // The back is mirrored when seen from behind, so flip it once more.
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: widget.back,
                        ),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: IgnorePointer(
              child: Text(
                'Drag to rotate  •  Double-tap to reset',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Front of the card
// ---------------------------------------------------------------------------

class StudentCardFront extends StatelessWidget {
  final String name;
  final String department;
  final String campus;
  final String idText;
  final ImageProvider? photo;
  final ImageProvider? logo;

  const StudentCardFront({
    super.key,
    required this.name,
    required this.department,
    required this.campus,
    required this.idText,
    this.photo,
    this.logo,
  });

  static const _dark = Color(0xFF1C1C26);
  static const _panel = Color(0xFFF4EBEE);
  static const _titleColor = Color(0xFF2A2A2A);
  static const _greyText = Color(0xFF7A7A7A);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 54 / 85.6, // CR80 card size
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(w * 0.045),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(w * 0.045),
            child: Stack(
              children: [
                // Dark background (top area)
                Positioned.fill(child: Container(color: _dark)),

                // Light bottom panel
                Positioned(
                  top: h * 0.51,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(color: _panel),
                ),

                // Rounded "bump" of the panel rising behind STUDENT
                Positioned(
                  top: h * 0.49,
                  left: w * 0.23,
                  width: w * 0.565,
                  height: h * 0.06,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(w * 0.04)),
                    ),
                  ),
                ),

                // PHOTO area
                Positioned(
                  top: h * 0.073,
                  left: w * 0.18,
                  width: w * 0.65,
                  height: h * 0.437,
                  child: Container(
                    color: const Color(0xFF8C8C8C),
                    child: photo != null
                        ? Image(image: photo!, fit: BoxFit.cover)
                        : Icon(Icons.person, size: w * 0.35, color: Colors.white54),
                  ),
                ),

                // Vertical ID text on the right strip (reads bottom -> top)
                Positioned(
                  top: h * 0.07,
                  right: 0,
                  width: w * 0.16,
                  height: h * 0.31,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        idText,
                        style: const TextStyle(
                          color: Color(0xFFD9D9E6),
                          fontWeight: FontWeight.w600,
                          fontSize: 40,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                // STUDENT
                Positioned(
                  top: h * 0.522,
                  left: 0,
                  right: 0,
                  height: h * 0.085,
                  child: Center(
                    child: SizedBox(
                      width: w * 0.67,
                      child: const FittedBox(
                        child: Text(
                          'STUDENT',
                          style: TextStyle(
                            color: _titleColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 100,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Department
                Positioned(
                  top: h * 0.615,
                  left: 0,
                  right: 0,
                  height: h * 0.035,
                  child: Center(
                    child: SizedBox(
                      width: w * 0.89,
                      child: FittedBox(
                        child: Text(
                          department,
                          style: const TextStyle(
                            color: _greyText,
                            fontSize: 40,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Name
                Positioned(
                  top: h * 0.706,
                  left: 0,
                  right: 0,
                  height: h * 0.033,
                  child: Center(
                    child: SizedBox(
                      width: w * 0.57,
                      child: FittedBox(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 40,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Logo
                Positioned(
                  top: h * 0.784,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: w * 0.28,
                      height: w * 0.28,
                      child: logo != null
                          ? Image(image: logo!, fit: BoxFit.contain)
                          : const _FallbackLogo(),
                    ),
                  ),
                ),

                // Campus line
                Positioned(
                  top: h * 0.958,
                  left: 0,
                  right: 0,
                  height: h * 0.03,
                  child: Center(
                    child: SizedBox(
                      width: w * 0.44,
                      child: FittedBox(
                        child: Text(
                          campus,
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Simple approximation of the COMSATS seal until you add the real PNG.
class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, b) {
      final d = b.maxWidth;
      return Container(
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF7B1F4B)),
        padding: EdgeInsets.all(d * 0.14),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          padding: EdgeInsets.all(d * 0.03),
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1F4E9C)),
            child: Center(
              child: Container(
                width: d * 0.3,
                height: d * 0.36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(d),
                  border: Border.all(color: Colors.white, width: d * 0.025),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Back of the card
// ---------------------------------------------------------------------------

class StudentCardBack extends StatelessWidget {
  final String validity;
  final String emergency;
  final String website;
  final String regNo;
  final ImageProvider? signature;

  const StudentCardBack({
    super.key,
    this.validity = 'Sep 2023 - July 2027',
    this.emergency = '042-111-001-007',
    this.website = 'www.cuilahore.edu.pk',
    this.regNo = 'FA23-BCE-098',
    this.signature,
  });

  static const _dark = Color(0xFF1C1C26);
  static const _panel = Color(0xFFF4EBEE);
  static const _lightText = Color(0xFFE6E6F0);
  static const _dimLight = Color(0xFF9A9AAE);
  static const _greyText = Color(0xFF7A7A7A);
  static const _darkText = Color(0xFF444444);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 54 / 85.6, // CR80 card size
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;

        // Centered, auto-scaled text block at a given vertical position.
        Widget block({
          required double top,
          required double height,
          required double widthFactor,
          required String text,
          required TextStyle style,
        }) {
          return Positioned(
            top: h * top,
            left: 0,
            right: 0,
            height: h * height,
            child: Center(
              child: SizedBox(
                width: w * widthFactor,
                child: FittedBox(
                  child: Text(text, textAlign: TextAlign.center, style: style),
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(w * 0.045),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(w * 0.045),
            child: Stack(
              children: [
                // Dark background (top area)
                Positioned.fill(child: Container(color: _dark)),

                // Light bottom panel
                Positioned(
                  top: h * 0.51,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(color: _panel),
                ),

                // ---------------- Dark section ----------------
                block(
                  top: 0.145,
                  height: 0.04,
                  widthFactor: 0.22,
                  text: 'Validity',
                  style: const TextStyle(
                    color: _lightText,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                block(
                  top: 0.195,
                  height: 0.05,
                  widthFactor: 0.66,
                  text: validity,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                block(
                  top: 0.262,
                  height: 0.04,
                  widthFactor: 0.28,
                  text: 'Emergency',
                  style: const TextStyle(
                    color: _lightText,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                block(
                  top: 0.302,
                  height: 0.032,
                  widthFactor: 0.34,
                  text: emergency,
                  style: const TextStyle(
                    color: _dimLight,
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                block(
                  top: 0.375,
                  height: 0.025,
                  widthFactor: 0.42,
                  text: website,
                  style: const TextStyle(
                    color: _dimLight,
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                // ---------------- Light section ----------------
                block(
                  top: 0.54,
                  height: 0.05,
                  widthFactor: 0.34,
                  text: 'This card is\nnon transferable.',
                  style: const TextStyle(color: _greyText, fontSize: 30, height: 1.3),
                ),
                block(
                  top: 0.605,
                  height: 0.07,
                  widthFactor: 0.66,
                  text: 'This card is property of\nCOMSATS UNIVERSITY ISLAMABAD\nLahore Campus.',
                  style: const TextStyle(color: _greyText, fontSize: 30, height: 1.35),
                ),
                block(
                  top: 0.695,
                  height: 0.055,
                  widthFactor: 0.38,
                  text: 'In case of loss report to\nCUI, Lahore\nimmediately.',
                  style: const TextStyle(color: _greyText, fontSize: 30, height: 1.35),
                ),
                block(
                  top: 0.775,
                  height: 0.06,
                  widthFactor: 0.34,
                  text: 'Defence Road\nOff Raiwind Road,\nLahore.',
                  style: const TextStyle(color: _greyText, fontSize: 30, height: 1.35),
                ),

                // Issuing authority + signature
                Positioned(
                  top: h * 0.855,
                  left: w * 0.12,
                  right: w * 0.10,
                  height: h * 0.06,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: h * 0.008),
                            child: Text(
                              'Issuing Authority:',
                              style: TextStyle(
                                color: _darkText,
                                fontSize: w * 0.04,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: w * 0.02),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: h * 0.008),
                              child: Container(height: 1, color: _darkText),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        width: w * 0.36,
                        height: h * 0.07,
                        child: signature != null
                            ? Image(image: signature!, fit: BoxFit.contain)
                            : CustomPaint(painter: _ScribbleSignaturePainter()),
                      ),
                    ],
                  ),
                ),

                // Barcode
                Positioned(
                  top: h * 0.928,
                  left: w * 0.12,
                  right: w * 0.10,
                  height: h * 0.035,
                  child: CustomPaint(painter: _BarcodePainter(regNo)),
                ),

                // Reg number under barcode
                block(
                  top: 0.965,
                  height: 0.03,
                  widthFactor: 0.36,
                  text: regNo,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Decorative barcode generated from the text (won't scan).
class _BarcodePainter extends CustomPainter {
  final String data;
  _BarcodePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(data.hashCode);
    final paint = Paint()..color = const Color(0xFF222222);
    final unit = size.width / 110;
    double x = 0;
    bool bar = true;
    while (x < size.width) {
      final bw = (1 + rnd.nextInt(3)) * unit; // 1-3 units wide
      if (bar) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, math.min(bw, size.width - x), size.height),
          paint,
        );
      }
      x += bw;
      bar = !bar;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter old) => old.data != data;
}

/// Placeholder squiggle until you pass a real signature image.
class _ScribbleSignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1B1B3A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.05, h * 0.55)
      ..lineTo(w * 0.18, h * 0.05)
      ..quadraticBezierTo(w * 0.22, h * 0.7, w * 0.32, h * 0.55)
      ..quadraticBezierTo(w * 0.45, h * 0.3, w * 0.5, h * 0.65)
      ..quadraticBezierTo(w * 0.62, h * 0.4, w * 0.72, h * 0.6)
      ..quadraticBezierTo(w * 0.85, h * 0.45, w * 0.97, h * 0.55);
    canvas.drawPath(path, p);
    canvas.drawLine(Offset(w * 0.35, h * 0.85), Offset(w * 0.95, h * 0.85), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}