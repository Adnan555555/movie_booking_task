import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/app_theme.dart';
import '../../model/movie.dart';

class SeatSelectionArgs {
  final Movie movie;
  final String dateLabel;
  final String timeLabel;
  final String hallLabel;
  SeatSelectionArgs({
    required this.movie,
    required this.dateLabel,
    required this.timeLabel,
    required this.hallLabel,
  });
}

class SeatSelectionPage extends StatefulWidget {
  final Movie movie;
  final String? dateLabel;
  final String? timeLabel;
  final String? hallLabel;
  const SeatSelectionPage({
    super.key,
    required this.movie,
    this.dateLabel,
    this.timeLabel,
    this.hallLabel,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final List<String> selectedSeats = [];
  final List<String> rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
  final int seatsPerRow = 12;
  final Set<String> unavailable = {
    'A4',
    'A5',
    'B6',
    'C8',
    'D3',
    'E10',
    'F1',
    'G7',
    'H9',
    'I4',
    'J11',
  };
  double scale = 1.0;

  bool isAvailable(String seat) => !unavailable.contains(seat);
  bool isSelected(String seat) => selectedSeats.contains(seat);

  bool isVip(String seat) {
    final row = seat[0];
    return row == 'H' || row == 'I' || row == 'J';
  }

  int seatPrice(String seat) => isVip(seat) ? 150 : 50;

  void toggleSeat(String seat) {
    if (!isAvailable(seat)) return;
    setState(() {
      isSelected(seat) ? selectedSeats.remove(seat) : selectedSeats.add(seat);
    });
  }

  Color seatColor(String seat) {
    if (isSelected(seat)) return const Color(0xFFCD9D0F);
    if (!isAvailable(seat)) return const Color(0xFFBDBDBD);
    return isVip(seat) ? const Color(0xFF564CA3) : AppTheme.lightBlueColor;
  }

  int get totalPrice => selectedSeats.fold(0, (sum, s) => sum + seatPrice(s));

  String _headerText() {
    final date = widget.dateLabel ?? 'March 5, 2021';
    final time = widget.timeLabel ?? '12:30';
    final hall = widget.hallLabel ?? 'Hall 1';
    return '$date | $time $hall';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.movie.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppTheme.textSecondary202C),
            ),
            Text(
              _headerText(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightBlueColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: BackButton(onPressed: () => Get.back()),
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 1, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 60,
                          child: Center(
                            child: CustomPaint(
                              size: const Size(260, 60),
                              painter: _ScreenArcPainter(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildSeatGrid(),
                        const SizedBox(height: 16),
                        Slider(
                          value: scale,
                          min: 0.8,
                          max: 1.6,
                          onChanged: (v) => setState(() => scale = v),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 30,
                  child: Column(
                    children: [
                      _circleButton(Icons.add, () {
                        setState(() {
                          scale = (scale + 0.1).clamp(0.8, 1.6);
                        });
                      }),
                      const SizedBox(height: 10),
                      _circleButton(Icons.remove, () {
                        setState(() {
                          scale = (scale - 0.1).clamp(0.8, 1.6);
                        });
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 20,
                alignment: WrapAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _legendItem(const Color(0xFFCD9D0F), 'Selected'),
                      const SizedBox(width: 18),
                      _legendItem(const Color(0xFFBDBDBD), 'Not available'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _legendItem(const Color(0xFF564CA3), 'VIP (150\$)'),
                      const SizedBox(width: 18),
                      _legendItem(AppTheme.lightBlueColor, 'Regular (50 \$)'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Selected seats chips
              if (selectedSeats.isNotEmpty) ...[
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: selectedSeats
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                        padding: EdgeInsets.only(
                          right:
                          entry.key == selectedSeats.length - 1 ? 0 : 8,
                        ),
                        child: _selectedChip(entry.value),
                      ),
                    )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Price',
                          style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 10,
                            color: AppTheme.textSecondary202C,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$ $totalPrice',
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary202C,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF61C3F2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        elevation: 2,
                      ),
                      onPressed: selectedSeats.isEmpty
                          ? null
                          : () {
                        Get.snackbar(
                          'Success',
                          'Proceeding to payment for ${selectedSeats.length} seat(s)',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: const Text(
                        'Proceed to pay',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeatGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        const labelWidth = 12.0;
        const seatMarginX = 4.0;
        final baseSize = 26 * scale;
        final maxSeatSize =
            ((maxWidth - labelWidth) / seatsPerRow) - seatMarginX;
        final itemSize = baseSize.clamp(16.0, maxSeatSize);
        return Center(
          child: Column(
            children: rows.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: labelWidth,
                      child: Text(
                        row,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    ...List.generate(seatsPerRow, (i) {
                      final seat = '$row${i + 1}';
                      final avail = isAvailable(seat);
                      final sel = isSelected(seat);
                      return GestureDetector(
                        onTap: avail ? () => toggleSeat(seat) : null,
                        child: Container(
                          width: itemSize,
                          height: itemSize,
                          margin: const EdgeInsets.symmetric(
                            horizontal: seatMarginX / 2,
                          ),
                          decoration: BoxDecoration(
                            color: seatColor(seat),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: sel
                                ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                                : !avail
                                ? const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 14,
                            )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500, color: AppTheme.textSecondary8F),
        ),
      ],
    );
  }

  Widget _selectedChip(String s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedSeats.remove(s);
              });
            },
            child: const Icon(Icons.close, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}

class _ScreenArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightBlueColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    canvas.drawPath(path, paint);
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SCREEN',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 8,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2, size.height - 22),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}