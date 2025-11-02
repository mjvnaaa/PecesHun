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

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        // TODO: Tambahkan legenda (indicator) jika diinginkan
      ),
    );
  }
}