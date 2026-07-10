import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../config/theme.dart';
import '../models/room_model.dart';
import '../models/report_model.dart';
import '../services/auth_provider.dart';
import '../services/firestore_provider.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  Room? _room;
  String _category = 'AC';
  String _priority = 'medium';
  bool _loading = false;

  final _categories = [
    'AC', 'Lampu', 'Listrik', 'Kebersihan', 'Meubelair',
    'Proyektor', 'Lainnya'
  ];
  final _priorities = [
    ('low', 'Rendah', Colors.grey),
    ('medium', 'Sedang', RumaColors.warningYellow),
    ('high', 'Tinggi', RumaColors.dangerRed),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _room ??= ModalRoute.of(context)?.settings.arguments as Room?;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = context.read<AuthProvider>();
    final firestore = context.read<FirestoreProvider>();
    final room = _room;
    final user = auth.user;

    final report = Report(
      id: const Uuid().v4(),
      userId: user?.uid ?? 'unknown',
      userName: user?.name ?? 'Unknown',
      roomId: room?.id ?? 'unknown',
      roomName: room?.name ?? 'Unknown',
      category: _category,
      description: _descCtrl.text.trim(),
      priority: _priority,
      status: ReportStatus.reported,
    );

    final ok = await firestore.addReport(report);
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim!'),
          backgroundColor: RumaColors.secondaryGreen,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim laporan. Coba lagi.'),
          backgroundColor: RumaColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;
    return Scaffold(
      appBar: AppBar(title: const Text('Laporkan Masalah')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (room != null) ...[
                Card(
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: RumaColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.meeting_room,
                          color: RumaColors.primaryBlue),
                    ),
                    title: Text(room.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${room.building} • Lt ${room.floor}'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text('Kategori Masalah',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(),
                items: _categories
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 20),
              Text('Prioritas',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: _priorities.map((p) {
                  final selected = _priority == p.$1;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? p.$3.withValues(alpha: 0.1)
                                : RumaColors.slate100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? p.$3 : RumaColors.slate200,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p.$2,
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: selected
                                    ? p.$3
                                    : RumaColors.slate500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Deskripsi Masalah',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      'Jelaskan masalah yang Anda temui secara detail...',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Deskripsi wajib diisi';
                  if (v.length < 10) return 'Minimal 10 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: RumaColors.white))
                      : const Text('Kirim Laporan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
