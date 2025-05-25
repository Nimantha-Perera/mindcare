import 'package:flutter/material.dart';

class MeditationStep {
  final int stepNumber;
  final String title;
  final String subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Widget? customContent;
  final bool showOnlyNext;
  final bool isLast;

  MeditationStep({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.customContent,
    this.showOnlyNext = false,
    this.isLast = false,
  });
}