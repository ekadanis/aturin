import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'dart:io' show Platform;

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({
    Key? key,
    required this.alarmSettings,
  }) : super(key: key);

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> with SingleTickerProviderStateMixin {
  late final String _title;
  int _snoozeMinutes = 5;
  
  // State untuk gesture slider
  bool _isDragging = false;
  Offset _position = Offset.zero;
  double _dragThreshold = 70.0; // Jarak geser yang diperlukan untuk aksi
  
  // State untuk menentukan aksi yang akan dilakukan
  String _actionType = ''; // 'stop' atau 'snooze'
  
  // State untuk animasi
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _title = widget.alarmSettings.notificationSettings?.body ?? 'Waktunya Meditasi';
    
    // Inisialisasi animasi untuk efek pulsing pada lingkaran
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Untuk menghitung jarak geseran
  double _calculateDragDistance() {
    return _position.distance;
  }
  
  // Untuk mengukur persentase penyelesaian geseran
  double _calculateDragPercentage() {
    double distance = _calculateDragDistance();
    return (distance / _dragThreshold).clamp(0.0, 1.0);
  }
  
  // Menentukan apakah posisi berada di bagian kanan (x positif) atau kiri (x negatif)
  bool _isRightSide() {
    return _position.dx > 0;
  }
  
  // Mendapatkan warna berdasarkan posisi
  Color _getPositionColor() {
    final bool isRight = _isRightSide();
    final baseColor = isRight ? Colors.red : Colors.blue;
    
    // Campurkan dengan warna putih berdasarkan persentase geseran
    return Color.lerp(
      Colors.white,
      baseColor,
      _calculateDragPercentage()
    )!;
  }
  
  // Mendapatkan ikon berdasarkan posisi
  IconData _getPositionIcon() {
    final bool isRight = _isRightSide();
    return isRight ? Icons.alarm_off : Icons.snooze;
  }
  
  // Mendapatkan teks instruksi berdasarkan posisi
  String _getInstructionText() {
    if (!_isDragging || _calculateDragPercentage() < 0.2) {
      return 'Geser ke arah manapun';
    }
    
    final bool isRight = _isRightSide();
    if (isRight) {
      return 'Lepas untuk mematikan alarm';
    } else {
      return 'Lepas untuk menunda $_snoozeMinutes menit';
    }
  }
  
  // Eksekusi aksi berdasarkan posisi
  void _executeAction() {
    if (_isRightSide()) {
      _dismissAlarm();
    } else {
      _snoozeAlarm();
    }
  }

  void _dismissAlarm() {
    Alarm.stop(widget.alarmSettings.id);
    Navigator.pop(context);
  }

  void _snoozeAlarm() {
    final now = DateTime.now();
    final snoozeTime = now.add(Duration(minutes: _snoozeMinutes));

    Alarm.stop(widget.alarmSettings.id);

    final snoozeSettings = AlarmSettings(
      id: widget.alarmSettings.id,
      dateTime: snoozeTime,
      assetAudioPath: widget.alarmSettings.assetAudioPath,
      loopAudio: widget.alarmSettings.loopAudio,
      vibrate: widget.alarmSettings.vibrate,
      warningNotificationOnKill: Platform.isAndroid,
      androidFullScreenIntent: widget.alarmSettings.androidFullScreenIntent,
      volumeSettings: widget.alarmSettings.volumeSettings,
      notificationSettings: widget.alarmSettings.notificationSettings,
    );

    Alarm.set(alarmSettings: snoozeSettings);
    Navigator.pop(context);
  }

  void _decreaseSnooze() {
    setState(() {
      if (_snoozeMinutes > 1) {
        _snoozeMinutes -= 1;
      }
    });
  }

  void _increaseSnooze() {
    setState(() {
      if (_snoozeMinutes < 30) {
        _snoozeMinutes += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final day = now.day;
    final month = _getMonthName(now.month);
    
    // Warna yang berubah berdasarkan posisi
    final positionColor = _getPositionColor();

    return Scaffold(
      backgroundColor: Color(0xFFEEF3FF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              Text(
                '$hour : $minute',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Fri, $day $month',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Waktunya Meditasi\n$_title',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Panduan visual untuk geser
              Text(
                _getInstructionText(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              // Container untuk membatasi area interaksi
              Stack(
                alignment: Alignment.center,
                children: [
                  // Petunjuk teks minimalis kiri-kanan
                  Positioned(
                    left: 0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.blue.withOpacity(0.6),
                          size: 18,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Kiri untuk",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "TUNDA",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Positioned(
                    right: 0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.red.withOpacity(0.6),
                          size: 18,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Kanan untuk",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "STOP",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Container lingkaran utama
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          Color(0xFFEEF3FF),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(
                        color: positionColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: GestureDetector(
                      onPanStart: (details) {
                        setState(() {
                          _isDragging = true;
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _position += details.delta;
                          // Membatasi posisi dalam lingkaran
                          if (_calculateDragDistance() > 80) {
                            _position = (_position / _calculateDragDistance()) * 80;
                          }
                        });
                      },
                      onPanEnd: (details) {
                        if (_calculateDragDistance() > _dragThreshold * 0.7) {
                          _executeAction();
                        } else {
                          // Animasi kembali ke posisi awal jika tidak mencapai threshold
                          setState(() {
                            _isDragging = false;
                            _position = Offset.zero;
                          });
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Lingkaran pulsating outer
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 120 + _pulseController.value * 10,
                                height: 120 + _pulseController.value * 10,
                                decoration: BoxDecoration(
                                  color: positionColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              );
                            },
                          ),
                          // Indikator kemajuan geseran
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: positionColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Lingkaran yang dapat digeser
                          Transform.translate(
                            offset: _position,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: positionColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  // Drop shadow dengan blur 50 sesuai arah geseran (kiri/kanan)
                                  BoxShadow(
                                    color: _isRightSide() 
                                      ? Colors.red.withOpacity(_calculateDragPercentage() * 0.7) 
                                      : Colors.blue.withOpacity(_calculateDragPercentage() * 0.7),
                                    blurRadius: 50,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 0), // Posisi bayangan tepat di tengah
                                  )
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  _getPositionIcon(),
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Tunda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove, size: 16),
                    ),
                    onPressed: _decreaseSnooze,
                  ),
                  Text(
                    '$_snoozeMinutes menit',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                    onPressed: _increaseSnooze,
                  ),
                ],
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}