
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SecurityEmblem extends StatelessWidget {
  const SecurityEmblem({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 184,
      height: 184,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 174,
            height: 174,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.cyan.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
          ),
          Container(
            width: 142,
            height: 142,
            decoration: BoxDecoration(
              color: AppTheme.panelDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.purple.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cyan.withValues(alpha: 0.12),
                  blurRadius: 28,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          Container(
            width: 106,
            height: 112,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.purple,
                width: 2.5,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(55),
                topRight: Radius.circular(55),
                bottomLeft: Radius.circular(55),
                bottomRight: Radius.circular(55),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.purple.withValues(alpha: 0.15),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.cyan,
                  shadows: [
                    Shadow(
                      color: AppTheme.purple,
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 35,
            child: Icon(
              Icons.circle,
              size: 6,
              color: AppTheme.cyan,
            ),
          ),
          const Positioned(
            top: 22,
            right: 28,
            child: Icon(
              Icons.circle,
              size: 5,
              color: AppTheme.cyan,
            ),
          ),
        ],
      ),
    );
  }
}
