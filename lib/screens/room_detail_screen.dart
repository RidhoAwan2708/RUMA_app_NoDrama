import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_issue_screen.dart';
import '../models/room_model.dart';

class RoomDetailScreen extends StatelessWidget {
  final String? roomId;

  const RoomDetailScreen({super.key, this.roomId});

  @override
  Widget build(BuildContext context) {
    final effectiveRoomId = roomId ??
        (ModalRoute.of(context)?.settings.arguments as String?) ??
        'room1';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/splash',
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff8f9fe), 
        appBar: AppBar(
          title: const Text(
            'Room Detail',
            style: TextStyle(color: Color(0xff004ec4), fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xff004ec4)),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/splash',
                (route) => false,
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {},
            ),
          ],
        ),
        // 🛠️ Ditambahkan Center & ConstrainedBox agar tampilan di Web/PC terpusat rapi dan tidak molor lebar
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('rooms').doc(effectiveRoomId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
                    child: Text('Ruangan "$effectiveRoomId" tidak ditemukan.'),
                  );
                }

                final roomData = snapshot.data!.data() as Map<String, dynamic>;
                final room = Room.fromMap(roomData);

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Image Banner Utama
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=600&auto=format&fit=crop',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // 2. Main Info Card
                          Transform.translate(
                            offset: const Offset(0, -30),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(12),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            room.name,
                                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xff1e1e24)),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('CAPACITY', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                            Text(
                                              '${roomData['capacity'] ?? 50}', 
                                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff004ec4)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.business, size: 16, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text('${room.building}, Lantai ${room.floor}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 3. Health Score & Maintenance Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'HEALTH SCORE',
                                    value: '${room.healthScore.toInt()}%',
                                    extraWidget: Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: LinearProgressIndicator(
                                              value: room.healthScore / 100,
                                              backgroundColor: Colors.grey.withAlpha(30),
                                              valueColor: AlwaysStoppedAnimation<Color>(room.healthColor),
                                              minHeight: 6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.flash_on, color: room.healthColor, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildMetricCard(
                                    title: 'MAINTENANCE',
                                    value: '12 June 2026', 
                                    subtext: 'Last checked',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 4. Facilities Section Grid
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('FACILITIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              childAspectRatio: 1.4,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              children: [
                                _buildFacilityItem(Icons.ac_unit, 'AC'),
                                _buildFacilityItem(Icons.videocam, 'Projector'),
                                _buildFacilityItem(Icons.wifi, 'WiFi'),
                                _buildFacilityItem(Icons.lightbulb_outline, 'Lights'),
                                _buildFacilityItem(Icons.chair_alt, 'Chairs'),
                                _buildFacilityItem(Icons.table_restaurant, 'Tables'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 5. Upcoming Schedule Section
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('UPCOMING SCHEDULE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                _buildScheduleItem(Icons.school, 'Computer Science 101', '09:00 AM - 11:00 AM', Colors.blue, true),
                                const SizedBox(height: 12),
                                _buildScheduleItem(Icons.meeting_room, 'Faculty Meeting', '01:30 PM - 02:30 PM', Colors.grey, false),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 6. Sticky Floating Report Issue Button
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff004ec4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                          ),
                          // 🛠️ SEKARANG LANGSUNG PINDAH DAN MELEMPAR OBJEK ROOM
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportIssueScreen(),
                                settings: RouteSettings(arguments: room), // Dibaca didChangeDependencies di halaman lapor
                              ),
                            );
                          },
                          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
                          label: const Text(
                            'Report Issue',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Widget Helper: Kartu Skor / Informasi Metrik
  static Widget _buildMetricCard({required String title, required String value, String? subtext, Widget? extraWidget}) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff1e1e24))),
          if (extraWidget != null) extraWidget,
          if (subtext != null) Text(subtext, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  // Widget Helper: Item Grid Fasilitas
  static Widget _buildFacilityItem(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff0f3fc),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xff004ec4), size: 24),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff4a5568))),
        ],
      ),
    );
  }

  // Widget Helper: Item List Jadwal
  static Widget _buildScheduleItem(IconData icon, String title, String time, Color iconBgColor, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconBgColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xff1e1e24))),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Icon(
            isActive ? Icons.arrow_forward_ios : Icons.lock_outline,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}