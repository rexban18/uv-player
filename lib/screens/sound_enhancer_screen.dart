import 'dart:ui';
import 'package:flutter/material.dart';

class SoundEnhancerScreen extends StatefulWidget {
  const SoundEnhancerScreen({super.key});

  @override
  State<SoundEnhancerScreen> createState() => _SoundEnhancerScreenState();
}

class _SoundEnhancerScreenState extends State<SoundEnhancerScreen> {
  double _bassBoost = 0.0;
  double _virtualizer = 0.0;
  double _loudnessEnhancer = 0.0;
  bool _bassEnabled = false;
  bool _virtualizerEnabled = false;
  bool _loudnessEnabled = false;
  bool _reverbEnabled = false;
  String _reverbPreset = 'None';

  final Map<String, int> _reverbPresets = {
    'None': 0,
    'Small Room': 1,
    'Medium Room': 2,
    'Large Room': 3,
    'Small Hall': 4,
    'Medium Hall': 5,
    'Large Hall': 6,
    'Plate': 7,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Sound Enhancer',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Bass Boost
                _EnhancerCard(
                  title: 'Bass Boost',
                  subtitle: 'Enhance low-frequency sounds',
                  icon: Icons.surround_sound,
                  enabled: _bassEnabled,
                  value: _bassBoost,
                  maxValue: 20,
                  accent: accent,
                  isDark: isDark,
                  onEnabledChanged: (v) => setState(() => _bassEnabled = v),
                  onValueChanged: (v) => setState(() => _bassBoost = v),
                ),

                const SizedBox(height: 12),

                // Virtualizer
                _EnhancerCard(
                  title: 'Stereo Virtualizer',
                  subtitle: 'Create wider stereo image',
                  icon: Icons.surround_sound_outlined,
                  enabled: _virtualizerEnabled,
                  value: _virtualizer,
                  maxValue: 1000,
                  accent: accent,
                  isDark: isDark,
                  onEnabledChanged: (v) => setState(() => _virtualizerEnabled = v),
                  onValueChanged: (v) => setState(() => _virtualizer = v),
                ),

                const SizedBox(height: 12),

                // Loudness Enhancer
                _EnhancerCard(
                  title: 'Loudness Enhancer',
                  subtitle: 'Boost overall volume',
                  icon: Icons.volume_up,
                  enabled: _loudnessEnabled,
                  value: _loudnessEnhancer,
                  maxValue: 100,
                  accent: accent,
                  isDark: isDark,
                  onEnabledChanged: (v) => setState(() => _loudnessEnabled = v),
                  onValueChanged: (v) => setState(() => _loudnessEnhancer = v),
                ),

                const SizedBox(height: 12),

                // Reverb
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.12)
                              : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.spatial_audio,
                                color: accent,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reverb',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Add spatial effects to audio',
                                      style: TextStyle(
                                        color: isDark ? Colors.white54 : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _reverbEnabled,
                                onChanged: (v) => setState(() => _reverbEnabled = v),
                                activeColor: accent,
                              ),
                            ],
                          ),
                          if (_reverbEnabled) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.03),
                              ),
                              child: DropdownButton<String>(
                                value: _reverbPreset,
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                items: _reverbPresets.keys.map((preset) {
                                  return DropdownMenuItem(
                                    value: preset,
                                    child: Text(preset),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _reverbPreset = value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Reset Button
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _bassBoost = 0;
                        _bassEnabled = false;
                        _virtualizer = 0;
                        _virtualizerEnabled = false;
                        _loudnessEnhancer = 0;
                        _loudnessEnabled = false;
                        _reverbEnabled = false;
                        _reverbPreset = 'None';
                      });
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset All'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EnhancerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final double value;
  final double maxValue;
  final Color accent;
  final bool isDark;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onValueChanged;

  const _EnhancerCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.value,
    required this.maxValue,
    required this.accent,
    required this.isDark,
    required this.onEnabledChanged,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: onEnabledChanged,
                    activeColor: accent,
                  ),
                ],
              ),
              if (enabled) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 10,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: accent,
                          inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                          thumbColor: accent,
                        ),
                        child: Slider(
                          value: value,
                          max: maxValue,
                          onChanged: onValueChanged,
                        ),
                      ),
                    ),
                    Text(
                      '${maxValue.round()}',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
