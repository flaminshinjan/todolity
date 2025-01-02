import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateStrip extends StatelessWidget {
  DateStrip({Key? key}) : super(key: key);

  final DateTime now = DateTime.now();

  List<DateTime> _getDates() {
    return List.generate(7, (index) {
      return now.subtract(Duration(days: now.weekday - index - 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final dates = _getDates();
    
    return Container(
      margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFf9be03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage\nyour tasks',
            
            style: TextStyle(
              fontSize: 50,
              
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dates.map((date) {
              final isToday = date.day == now.day;
              return Column(
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 3),
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday ? Colors.black : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                    decoration: isToday ? BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ) : null,
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isToday ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}