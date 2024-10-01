import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hands_user_app/utils/colors.dart';

class TotalRevenueWidget extends StatefulWidget {
  @override
  _TotalRevenueWidgetState createState() => _TotalRevenueWidgetState();
}

class _TotalRevenueWidgetState extends State<TotalRevenueWidget> {
  double _currentSliderValue = 10;
  Color greylight = Color.fromARGB(255, 191, 185, 185);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            color: Color.fromARGB(255, 191, 185, 185),
            blurRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      height: 320,
      width: 371,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Revenue in AED',
            style: GoogleFonts.almarai(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 30,
            width: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 1,
                  color: Colors.black,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'AED ${_currentSliderValue.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          CustomPaint(
            size: const Size(double.infinity, 150),
            painter: BarChartPainter(_currentSliderValue),
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).colorScheme.onSecondary,
              inactiveTrackColor: Colors.grey.shade700,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 15),
            ),
            child: Slider(
              value: _currentSliderValue,
              min: 10,
              max: 10000,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AED10',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'AED10,000',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final double sliderValue;

  BarChartPainter(this.sliderValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    double barWidth = size.width / 40;
    double maxHeight = size.height;

    int whiteBarCount = ((sliderValue / 10000) * 40).toInt();

    for (int i = 0; i < 40; i++) {
      double x = barWidth * i;
      double height = (i / 40) * maxHeight;

      paint.color = i < whiteBarCount ? Colors.white : Colors.grey.shade700;

      canvas.drawLine(
        Offset(x, maxHeight),
        Offset(x, maxHeight - height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
