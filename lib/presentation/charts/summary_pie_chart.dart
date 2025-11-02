// lib/presentation/charts/summary_pie_chart.dart
import 'package:apkpribadi/core/constants.dart';
import 'package:apkpribadi/providers/transaction_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummaryPieChart extends ConsumerWidget {
  const SummaryPieChart({super.key});

  // Daftar warna untuk chart
  final List<Color> _chartColors = const [
    AppColors.primary,
    AppColors.secondary,
    AppColors.expense,
    AppColors.income,
    Color(0xFF3498DB),
    Color(0xFF9B59B6),
    Color(0xFFE67E22),
    Color(0xFF1ABC9C),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(pieChartDataProvider);
    final totalExpense =
        data.values.fold(0.0, (sum, amount) => sum + amount);

    int colorIndex = 0;

    // Jika data dummy ("Belum ada data")
    if (data.containsKey('Belum ada data')) {
      return const Center(
        child: Text('Data pengeluaran masih kosong.'),
      );
    }

    // --- Pembuatan Data Chart (Sections) ---
    final sections = data.entries.map((entry) {
      final percentage = (entry.value / totalExpense) * 100;
      final color = _chartColors[colorIndex % _chartColors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();

    // --- Perubahan Utama: Gunakan Column ---
    return Column(
      children: [
        // 1. Chart
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 2. Legenda
        _buildLegend(context, data),
      ],
    );
  }

  // --- Widget Baru: Legenda ---
  Widget _buildLegend(BuildContext context, Map<String, double> data) {
    int colorIndex = 0;

    return Wrap(
      spacing: 12.0, // Jarak horizontal antar item
      runSpacing: 8.0, // Jarak vertikal antar baris
      alignment: WrapAlignment.center,
      children: data.entries.map((entry) {
        final color = _chartColors[colorIndex % _chartColors.length];
        colorIndex++;

        return _Indicator(
          color: color,
          text: entry.key,
          isSquare: false,
          size: 14,
        );
      }).toList(),
    );
  }
}

// --- Widget Helper Baru: Indicator ---
class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;

  const _Indicator({
    required this.color,
    required this.text,
    this.isSquare = false,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        )
      ],
    );
  }
}