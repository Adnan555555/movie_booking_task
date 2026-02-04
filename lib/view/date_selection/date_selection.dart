import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_route.dart';
import '../../core/app_theme.dart';
import '../../model/movie.dart';
import '../seat_selection/seat_selection.dart';

class DateSelectionPage extends StatefulWidget {
  final Movie movie;
  const DateSelectionPage({super.key, required this.movie});

  @override
  State<DateSelectionPage> createState() => _DateSelectionPageState();
}

class _DateSelectionPageState extends State<DateSelectionPage> {
  final List<String> dates = [
    '5 Mar',
    '6 Mar',
    '7 Mar',
    '8 Mar',
    '9 Mar',
    '10 Mar',
  ];
  int selectedDateIndex = 0;
  int selectedShowIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Get.back()),
        title: Column(
          children: [
            Text(
              widget.movie.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppTheme.textSecondary202C),
            ),
            const SizedBox(height: 4),
            Text(
              'In Theaters ${_formatReleaseDate(widget.movie.releaseDate)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightBlueColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Text(
                  'Date',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppTheme.textSecondary202C),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(dates.length, (i) {
                      final selected = i == selectedDateIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedDateIndex = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.lightBlueColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.lightBlueColor
                                    : Colors.black12,
                              ),
                            ),
                            child: Text(
                              dates[i],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: selected
                                    ? AppTheme.white
                                    : AppTheme.textSecondary202C,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 50),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _showCard(
                        0,
                        '12:30',
                        'Cinetech + Hall 1',
                        'From 50\$ or 2500 bonus',
                      ),
                      const SizedBox(width: 12),
                      _showCard(
                        1,
                        '13:30',
                        'Cinetech + Hall 1',
                        'From 75\$ or 3000 bonus',
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightBlueColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final args = SeatSelectionArgs(
                      movie: widget.movie,
                      dateLabel: dates[selectedDateIndex],
                      timeLabel: selectedShowIndex == 0 ? '12:30' : '13:30',
                      hallLabel: 'Hall 1',
                    );
                    Get.toNamed(AppRouter.seatSelection, arguments: args);
                  },
                  child: Text(
                    'Select Seats',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600, color: AppTheme.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showCard(int index, String time, String hall, String priceText) {
    final selected = selectedShowIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedShowIndex = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                time,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary202C),
              ),
              const SizedBox(width: 6),
              Text(
                hall,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textSecondary8F),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: 270,
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppTheme.lightBlueColor : Colors.black12,
                  width: selected ? 1 : 1,
                ),
              ),
              child: SizedBox(child: const _MiniSeatPreview()),
            ),
          ),
          Row(
            children: [
              Text(
                priceText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary202C,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatReleaseDate(String date) {
    if (date.isEmpty) return date;
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final year = parts[0];
        return '${months[month - 1]} $day, $year';
      }
    } catch (_) {}
    return date;
  }
}

class _MiniSeatPreview extends StatelessWidget {
  const _MiniSeatPreview();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: CustomPaint(
        painter: _MiniSeatPainter(),
        size: const Size(double.infinity, double.infinity),
      ),
    );
  }
}

class _MiniSeatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final arcPaint = Paint()
      ..color = AppTheme.lightBlueColor
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;
    final arcPath = Path();
    arcPath.moveTo(size.width * 0.08, size.height * 0.15);
    arcPath.quadraticBezierTo(
      size.width * 0.5,
      0,
      size.width * 0.92,
      size.height * 0.15,
    );
    canvas.drawPath(arcPath, arcPaint);

    final cols = 18;
    final rows = 8;
    final gapX = size.width * 0.84 / cols;
    final gapY = size.height * 0.6 / rows;
    final startX = size.width * 0.08;
    final startY = size.height * 0.25;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final dx = startX + c * gapX;
        final dy = startY + r * gapY;
        Color color;
        if (r >= rows - 2) {
          color = const Color(0xFF564CA3);
        } else {
          color = AppTheme.lightBlueColor;
        }
        if ((r + c) % 11 == 0) {
          color = const Color(0xFFCD9D0F);
        }
        final p = Paint()..color = color;
        canvas.drawCircle(Offset(dx, dy), gapX * 0.18, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}