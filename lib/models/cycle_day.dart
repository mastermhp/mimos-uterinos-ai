import 'package:flutter/material.dart';

enum CycleDayType {
  normal,
  period,
  ovulation,
  pms,
  predicted,
  selected,
}

class CycleDay {
  final DateTime date;
  final CycleDayType type;
  final bool isToday;
  final bool isPredicted;

  CycleDay({
    required this.date,
    this.type = CycleDayType.normal,
    this.isToday = false,
    this.isPredicted = false,
  });

  Color get backgroundColor {
    if (isToday) {
      return Colors.blue.shade100;
    }
    
    switch (type) {
      case CycleDayType.period:
        return isPredicted 
            ? Colors.red.shade100 
            : Colors.red.shade200;
      case CycleDayType.ovulation:
        return isPredicted 
            ? Colors.green.shade100 
            : Colors.green.shade200;
      case CycleDayType.pms:
        return isPredicted 
            ? Colors.amber.shade100 
            : Colors.amber.shade200;
      case CycleDayType.selected:
        return Colors.purple.shade100;
      default:
        return Colors.transparent;
    }
  }

  Color get textColor {
    if (isToday) {
      return Colors.blue.shade800;
    }
    
    switch (type) {
      case CycleDayType.period:
        return Colors.red.shade800;
      case CycleDayType.ovulation:
        return Colors.green.shade800;
      case CycleDayType.pms:
        return Colors.amber.shade800;
      case CycleDayType.selected:
        return Colors.purple.shade800;
      default:
        return Colors.black87;
    }
  }

  IconData? get icon {
    switch (type) {
      case CycleDayType.period:
        return Icons.water_drop;
      case CycleDayType.ovulation:
        return Icons.egg_alt;
      case CycleDayType.pms:
        return Icons.mood;
      default:
        return null;
    }
  }
}
