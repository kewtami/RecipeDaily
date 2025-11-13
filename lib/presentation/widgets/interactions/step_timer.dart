import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StepTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onTimerComplete;
  final bool autoStart;

  const StepTimer({
    Key? key,
    required this.duration,
    this.onTimerComplete,
    this.autoStart = false,
  }) : super(key: key);

  @override
  State<StepTimer> createState() => _StepTimerState();
}

class _StepTimerState extends State<StepTimer> {
  late Duration _remainingTime;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    if (widget.autoStart) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isCompleted) {
      setState(() {
        _remainingTime = widget.duration;
        _isCompleted = false;
      });
    }

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      } else {
        _stopTimer();
        setState(() {
          _isCompleted = true;
        });
        widget.onTimerComplete?.call();
        
        // Show a SnackBar notification
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Timer completed!'),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = widget.duration;
      _isRunning = false;
      _isCompleted = false;
    });
  }

  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Color _getTimerColor() {
    if (_isCompleted) return AppColors.success;
    if (!_isRunning) return AppColors.primary;
    
    final progress = _remainingTime.inSeconds / widget.duration.inSeconds;
    if (progress > 0.5) return AppColors.primary;
    if (progress > 0.2) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getTimerColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getTimerColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer Display Row
          Row(
            children: [
              // Timer icon
              Icon(
                _isCompleted 
                    ? Icons.check_circle 
                    : (_isRunning ? Icons.timer : Icons.timer_outlined),
                size: 24,
                color: _getTimerColor(),
              ),
              const SizedBox(width: 8),
              
              // Step Timer text
              const Text(
                'Step Timer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              
              // Time display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTimerColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatTime(_remainingTime),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Play/Pause button
              if (!_isCompleted)
                IconButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(
                    _isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 32,
                  ),
                  color: _getTimerColor(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: _isRunning ? 'Pause' : 'Start',
                ),
              
              const SizedBox(width: 8),
              
              // Reset button
              IconButton(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh_rounded, size: 28),
                color: _getTimerColor(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Reset',
              ),
            ],
          ),
          
          // Progress Bar
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _isCompleted 
                  ? 1.0 
                  : 1.0 - (_remainingTime.inSeconds / widget.duration.inSeconds),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}