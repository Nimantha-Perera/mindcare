import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeCardButton extends StatelessWidget {
  final IconData? leftIcon;
  final String? leftText;
  final String label;
  final IconData? rightIcon;
  final String? leftImageAsset;
  final String? rightImageAsset;
  final Color leftBackgroundColor;
  final Color rightBackgroundColor;
  final VoidCallback onTap;

  const HomeCardButton({
    Key? key,
    this.leftIcon,
    this.leftText,
    required this.label,
    this.rightIcon,
    this.leftImageAsset,
    this.rightImageAsset,
    this.leftBackgroundColor = Colors.grey,
    this.rightBackgroundColor = Colors.grey,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _buildLeftWidget(),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildRightWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftWidget() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: leftIcon != null || leftText != null ? leftBackgroundColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: leftIcon != null
            ? Icon(leftIcon, color: Colors.white, size: 24)
            : leftText != null
                ? Text(
                    leftText!,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : leftImageAsset != null
                    ? Image.asset(leftImageAsset!, height: 52)
                    : null,
      ),
    );
  }

  Widget _buildRightWidget() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: rightIcon != null ? rightBackgroundColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: rightIcon != null
            ? Icon(rightIcon, color: Colors.white, size: 24)
            : rightImageAsset != null
                ? Image.asset(rightImageAsset!, height: 52)
                : null,
      ),
    );
  }
}
