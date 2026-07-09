import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/profile_notifier.dart';
import '../../../core/auth_service.dart';

class UserHeaderWidget extends StatefulWidget {
  const UserHeaderWidget({super.key});

  @override
  State<UserHeaderWidget> createState() => _UserHeaderWidgetState();
}

class _UserHeaderWidgetState extends State<UserHeaderWidget> {
  String _name = 'User';
  String _imageUrl =
      'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=200';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    ProfileNotifier.instance.addListener(_loadProfile);
  }

  @override
  void dispose() {
    ProfileNotifier.instance.removeListener(_loadProfile);
    super.dispose();
  }

  void _loadProfile() {
    final auth = AuthService.instance;
    if (mounted) {
      setState(() {
        if (auth.fullName != null && auth.fullName!.trim().isNotEmpty) {
          _name = auth.fullName!.trim();
        }
        if (auth.profileImageUrl != null && auth.profileImageUrl!.trim().isNotEmpty) {
          _imageUrl = auth.profileImageUrl!.trim();
        }
      });
    }
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Image.asset(
            'assets/images/ChatGPT_Image_Jun_30__2026__01_15_02_PM__1_-1782807334638.png',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
            semanticLabel: 'Jivandhara brand logo',
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withAlpha(77),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CustomImageWidget(
                imageUrl: _imageUrl,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                semanticLabel: 'Profile photo of $_name',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _greeting(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Online',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
