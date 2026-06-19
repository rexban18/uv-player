import 'package:flutter/material.dart';
import 'dart:ui';

class EqualizerScreen extends StatefulWidget {
  const EqualizerScreen({super.key});

  @override
  State<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends State<EqualizerScreen> {
  final List<double> _bands = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  final List<String> _bandLabels = [
    '31', '62', '125', '250', '500',
    '1K', '2K', '4K', '8K', '16K'
  ];
  String _selectedPreset = 'Custom';
  bool _isEnabled = true;

  final Map<String, List<double>> _presets = {
    'Custom': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    'Bass Boost': [6, 5, 4, 2, 0, 0, 0, 0, 0, 0],
    'Treble Boost': [0, 0, 0, 0, 0, 0, 2, 4, 5, 6],
    'Vocal': [0, 0, 0, 2, 4, 5, 4, 2, 0, 0],
    'Rock': [4, 3, 1, 0, -1, 0, 2, 3, 4, 5],
    'Jazz': [3, 2, 0, 2, -1, -1, 0, 2, 3, 4],
    'Classical': [4, 3, 2, 1, -1, -1, 0, 2, 3, 4],
    'Pop': [1, 2, 3, 4, 3, 0, -1, -1, 1, 2],
    'Electronic': [5, 4, 2, 0, -2, 0, 2, 4, 5, 5],
    'Flat': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0D0D1A), const Color(0xFF1A0D2E)]
                : [const Color(0xFFF0F0F5), const Color(0xFFE8E8F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Equalizer',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isEnabled,
                      onChanged: (v) => setState(() => _isEnabled = v),
                      activeColor: accent,
                    ),
                  ],
                ),
              ),

              // Preset Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.6),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08),
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedPreset,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    items: _presets.keys.map((preset) {
                      return DropdownMenuItem(
                        value: preset,
                        child: Text(preset),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPreset = value;
                          _bands.clear();
                          _bands.addAll(_presets[value]!);
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Visualizer
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.4),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: CustomPaint(
                  painter: EqualizerPainter(
                    bands: _bands,
                    accentColor: accent,
                    isEnabled: _isEnabled,
                  ),
                  size: const Size(double.infinity, double.infinity),
                ),
              ),

              const SizedBox(height: 24),

              // Band Sliders
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _bands.length,
                  itemBuilder: (context, index) {
                    return _BandSlider(
                      value: _bands[index],
                      label: _bandLabels[index],
                      accent: accent,
                      isDark: isDark,
                      isEnabled: _isEnabled,
                      onChanged: (value) {
                        setState(() {
                          _bands[index] = value;
                          _selectedPreset = 'Custom';
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // dB Labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '+12 dB',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '0 dB',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '-12 dB',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BandSlider extends StatelessWidget {
  final double value;
  final String label;
  final Color accent;
  final bool isDark;
  final bool isEnabled;
  final ValueChanged<double> onChanged;

  const _BandSlider({
    required this.value,
    required this.label,
    required this.accent,
    required this.isDark,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            '${value > 0 ? '+' : ''}${value.round()}',
            style: TextStyle(
              color: isEnabled ? accent : (isDark ? Colors.white38 : Colors.black38),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  activeTrackColor: isEnabled ? accent : Colors.grey,
                  inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                  thumbColor: isEnabled ? accent : Colors.grey,
                ),
                child: Slider(
                  value: value,
                  min: -12,
                  max: 12,
                  onChanged: isEnabled ? onChanged : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class EqualizerPainter extends CustomPainter {
  final List<double> bands;
  final Color accentColor;
  final bool isEnabled;

  EqualizerPainter({
    required this.bands,
    required this.accentColor,
    required this.isEnabled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    if (!isEnabled) {
      paint.color = Colors.grey.withOpacity(0.3);
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }

    final path = Path();
    final segmentWidth = size.width / (bands.length - 1);

    for (int i = 0; i < bands.length; i++) {
      final x = i * segmentWidth;
      final normalizedValue = (bands[i] + 12) / 24;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * segmentWidth;
        final prevNormalized = (bands[i - 1] + 12) / 24;
        final prevY = size.height - (prevNormalized * size.height);
        final controlX = (prevX + x) / 2;
        path.cubicTo(controlX, prevY, controlX, y, x, y);
      }
    }

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        accentColor,
        accentColor.withOpacity(0.3),
      ],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < bands.length; i++) {
      final x = i * segmentWidth;
      final normalizedValue = (bands[i] + 12) / 24;
      final y = size.height - (normalizedValue * size.height);
      dotPaint.color = accentColor;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
