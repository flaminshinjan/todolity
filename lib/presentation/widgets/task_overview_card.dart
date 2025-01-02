import 'package:flutter/material.dart';

class TaskOverviewCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;

  const TaskOverviewCard({
    Key? key,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularCard(
            'Total Tasks',
            totalTasks.toString(),
            Colors.white,
            Colors.black87,
          ),
          _buildCircularCard(
            'Completed',
            completedTasks.toString(),
            Colors.white,
            Colors.black87,
          ),
          _buildCircularCard(
            'Pending',
            pendingTasks.toString(),
            const Color(0xFF036ac9),
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCircularCard(
    String label,
    String count,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}