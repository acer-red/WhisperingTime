import 'package:flutter/material.dart';
import 'package:whispering_time/util/time.dart';

class TimeDisplay extends StatefulWidget {
  final DateTime time;
  const TimeDisplay({Key? key, required this.time});

  @override
  TimeDisplayState createState() => TimeDisplayState();
}

class TimeDisplayState extends State<TimeDisplay> {
  bool _showAbsolute = false;

  String _getRelativeTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return '刚刚';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    }
    if (diff.inDays < 30) {
      int weeks = (diff.inDays / 7).floor();
      return '$weeks周前';
    }
    if (diff.inDays < 365) {
      int months = (diff.inDays / 30).floor();
      return '$months月前';
    }
    int years = (diff.inDays / 365).floor();
    return '$years年前';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAbsolute = !_showAbsolute;
        });
      },
      child: Text(
        _showAbsolute
            ? Time.string(widget.time)
            : _getRelativeTime(widget.time),
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
    );
  }
}
