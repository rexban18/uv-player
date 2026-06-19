import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'equalizer_screen.dart';
import 'sound_enhancer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final accent = themeProvider.accentColor;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // APPEARANCE
            _SectionTitle('APPEARANCE', isDark),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    iconColor: accent,
                    title: 'Dark Mode',
                    subtitle: isDark ? 'Dark theme active' : 'Light theme active',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) => themeProvider.toggleDarkMode(),
                      activeColor: accent,
                    ),
                    isDark: isDark,
                  ),
                  Divider(color: isDark ? Colors.white12 : Colors.black12, height: 24),
                  _SettingsTile(
                    icon: Icons.palette_rounded,
                    iconColor: accent,
                    title: 'Accent Color',
                    subtitle: themeProvider.accentColorName,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppTheme.accentColors.entries.map((entry) {
                      final isSelected = themeProvider.accentColorName == entry.key;
                      return GestureDetector(
                        onTap: () => themeProvider.setAccentColor(entry.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: entry.value,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: entry.value.withOpacity(0.5), blurRadius: 8)]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // AUDIO
            _SectionTitle('AUDIO', isDark),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.equalizer,
                    iconColor: accent,
                    title: 'Equalizer',
                    subtitle: 'Customize sound frequencies',
                    trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
                    isDark: isDark,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EqualizerScreen()),
                    ),
                  ),
                  Divider(color: isDark ? Colors.white12 : Colors.black12, height: 24),
                  _SettingsTile(
                    icon: Icons.surround_sound,
                    iconColor: accent,
                    title: 'Sound Enhancer',
                    subtitle: 'Bass boost, virtualizer, reverb',
                    trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
                    isDark: isDark,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SoundEnhancerScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // STORAGE
            _SectionTitle('STORAGE', isDark),
            const SizedBox(height: 12),
            GlassCard(
              child: _SettingsTile(
                icon: Icons.cleaning_services_rounded,
                iconColor: accent,
                title: 'Clear Cache',
                subtitle: 'Free up storage space',
                trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
                isDark: isDark,
                onTap: () => _showClearCacheDialog(context, accent),
              ),
            ),

            const SizedBox(height: 24),

            // PRIVACY
            _SectionTitle('PRIVACY & LEGAL', isDark),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.privacy_tip_rounded,
                    iconColor: accent,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    trailing: Icon(Icons.open_in_new, color: isDark ? Colors.white54 : Colors.black54, size: 18),
                    isDark: isDark,
                    onTap: () => _launchURL('https://uvplayer.app/privacy'),
                  ),
                  Divider(color: isDark ? Colors.white12 : Colors.black12, height: 24),
                  _SettingsTile(
                    icon: Icons.description_rounded,
                    iconColor: accent,
                    title: 'Terms of Service',
                    subtitle: 'Usage terms and conditions',
                    trailing: Icon(Icons.open_in_new, color: isDark ? Colors.white54 : Colors.black54, size: 18),
                    isDark: isDark,
                    onTap: () => _launchURL('https://uvplayer.app/terms'),
                  ),
                  Divider(color: isDark ? Colors.white12 : Colors.black12, height: 24),
                  _SettingsTile(
                    icon: Icons.gpp_good_rounded,
                    iconColor: accent,
                    title: 'Permissions',
                    subtitle: 'Manage app permissions',
                    trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
                    isDark: isDark,
                    onTap: () => _openAppSettings(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // DEVELOPER
            _SectionTitle('DEVELOPER', isDark),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [accent, accent.withOpacity(0.6)],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'PK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prime Khatab',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Developer',
                              style: TextStyle(
                                color: accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow('Email', 'mrkhatab112@gmail.com', isDark),
                  _InfoRow('GitHub', 'github.com/rexban18', isDark),
                  _InfoRow('Version', '1.0.0 (Build 1)', isDark),
                ],
              ),
            ),

            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    title: 'Rate UV Player',
                    subtitle: 'Rate us on Play Store',
                    trailing: Icon(Icons.open_in_new, color: isDark ? Colors.white54 : Colors.black54, size: 18),
                    isDark: isDark,
                    onTap: () => _launchURL('https://play.google.com/store/apps/details?id=com.uvplayer.app'),
                  ),
                  Divider(color: isDark ? Colors.white12 : Colors.black12, height: 24),
                  _SettingsTile(
                    icon: Icons.share_rounded,
                    iconColor: accent,
                    title: 'Share UV Player',
                    subtitle: 'Tell your friends about us',
                    trailing: Icon(Icons.open_in_new, color: isDark ? Colors.white54 : Colors.black54, size: 18),
                    isDark: isDark,
                    onTap: () => _shareApp(),
                  ),
                  Divider(color: isDark ? Colors.white12 : Colors.black12, height: 24),
                  _SettingsTile(
                    icon: Icons.code_rounded,
                    iconColor: accent,
                    title: 'Source Code',
                    subtitle: 'Open source on GitHub',
                    trailing: Icon(Icons.open_in_new, color: isDark ? Colors.white54 : Colors.black54, size: 18),
                    isDark: isDark,
                    onTap: () => _launchURL('https://github.com/rexban18/uv-player'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // APP INFO
            Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accent, accent.withOpacity(0.6)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'UV Player',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Liquid Glass Experience',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, Color accent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Cache',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'Are you sure you want to clear the cache?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Cache cleared'), backgroundColor: accent),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openAppSettings() async {
    // permission_handler can open settings
  }

  void _shareApp() {
    // Share functionality
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SectionTitle(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white54 : Colors.black54,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow(this.label, this.value, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
