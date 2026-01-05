import 'package:flutter/material.dart';

class Badge {
  final String id;
  final String translationKeyName;
  final String translationKeyDesc;
  final IconData icon;
  final bool isLocked;

  const Badge({
    required this.id,
    required this.translationKeyName,
    required this.translationKeyDesc,
    required this.icon,
    this.isLocked = true,
  });

  Badge copyWith({bool? isLocked}) {
    return Badge(
      id: id,
      translationKeyName: translationKeyName,
      translationKeyDesc: translationKeyDesc,
      icon: icon,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
