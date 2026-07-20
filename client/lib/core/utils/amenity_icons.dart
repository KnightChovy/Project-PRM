import 'package:flutter/material.dart';

/// Đổi tên tiện ích (chuỗi) -> icon tương ứng. Dùng chung cho cả
/// khách sạn và phòng, để không phải lặp lại map icon ở nhiều nơi.
IconData amenityIcon(String name) {
  switch (name.toLowerCase()) {
    // Tiện ích khách sạn
    case 'wifi':
      return Icons.wifi;
    case 'pool':
      return Icons.pool;
    case 'spa':
      return Icons.spa_outlined;
    case 'gym':
      return Icons.fitness_center;
    case 'restaurant':
      return Icons.restaurant;
    case 'private beach':
      return Icons.beach_access_outlined;
    // Tiện ích phòng
    case 'king bed':
      return Icons.king_bed_outlined;
    case 'sea view':
      return Icons.waves;
    case 'bathtub':
      return Icons.bathtub_outlined;
    case 'smart tv':
      return Icons.tv;
    case 'minibar':
      return Icons.kitchen_outlined;
    case 'balcony':
      return Icons.balcony_outlined;
    default:
      return Icons.check_circle_outline;
  }
}
