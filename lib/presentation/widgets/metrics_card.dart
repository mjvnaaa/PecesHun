// lib/presentation/widgets/metrics_card.dart
import 'package:apkpribadi/core/utils/formatters.dart';
import 'package:flutter/material.dart';

class MetricsCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const MetricsCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // DIPERBAIKI: mainAxisSize.min agar Column tidak mengambil ruang lebih
          mainAxisSize: MainAxisSize.min, 
          children: [
            // Baris atas: judul + ikon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // DIPERBAIKI: Flexible agar judul bisa menyesuaikan
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1, // Pastikan hanya satu baris
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12), // Jarak antara judul dan jumlah

            // Nilai utama (jumlah uang)
            // DIPERBAIKI: Bungkus dengan Flexible untuk kontrol ukuran
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown, // Skala ke bawah jika terlalu besar
                alignment: Alignment.centerLeft,
                child: Text(
                  Formatters.formatCurrency(amount),
                  maxLines: 1, // Pastikan hanya satu baris
                  overflow: TextOverflow.ellipsis, // Jika tetap overflow, potong
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}