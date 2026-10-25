import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const String baseUrl = 'https://leave-request-backend-production.up.railway.app/api';

void main() {
  runApp(const MiniHrisApp());
}

class MiniHrisApp extends StatelessWidget {
  const MiniHrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Mandiri Karyawan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  int? _activeEmployeeId;
  List<dynamic> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/employees'),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          _employees = data;
          if (_employees.isNotEmpty) {
            _activeEmployeeId = _employees.first['id'];
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Portal Mandiri Karyawan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (_employees.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: DropdownButton<int>(
                value: _activeEmployeeId,
                underline: const SizedBox(),
                items: _employees.map((e) {
                  return DropdownMenuItem<int>(
                    value: e['id'],
                    child: Text(
                      e['name'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _activeEmployeeId = val),
              ),
            ),
        ],
      ),
      body: _currentIndex == 0
          ? LeaveFormView(
              employeeId: _activeEmployeeId,
              onSuccess: () => setState(() => _currentIndex = 1),
            )
          : LeaveHistoryView(employeeId: _activeEmployeeId),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_calendar_outlined),
            selectedIcon: Icon(Icons.edit_calendar),
            label: 'Ajukan Cuti',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat Cuti',
          ),
        ],
      ),
    );
  }
}

// ---------------- TAB 1: FORM PENGAJUAN CUTI ----------------
class LeaveFormView extends StatefulWidget {
  final int? employeeId;
  final VoidCallback onSuccess;

  const LeaveFormView({
    super.key,
    required this.employeeId,
    required this.onSuccess,
  });

  @override
  State<LeaveFormView> createState() => _LeaveFormViewState();
}

class _LeaveFormViewState extends State<LeaveFormView> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? (_startDate ?? DateTime.now())),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    final fmt = DateFormat('yyyy-MM-dd');

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/leaves'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'employee_id': widget.employeeId,
          'reason': _reasonController.text.trim(),
          'start_date': fmt.format(_startDate!),
          'end_date': fmt.format(_endDate!),
        }),
      );

      setState(() => _isSubmitting = false);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF059669), // Emerald
              size: 54,
            ),
            title: const Text('Permohonan Terkirim'),
            content: const Text(
              'Permohonan cuti Anda berhasil diajukan dan sedang menunggu persetujuan HR.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _reasonController.clear();
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                  widget.onSuccess();
                },
                child: const Text('Lihat Riwayat'),
              ),
            ],
          ),
        );
      } else {
        final error = jsonDecode(res.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFE11D48), // Rose
              content: Text('Gagal: ${error['message'] ?? 'Terjadi kesalahan sistem'}'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFE11D48),
            content: Text('Koneksi terputus: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy');
    final isFormReady = _startDate != null && _endDate != null && !_isSubmitting;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Periode Cuti',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: true),
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(
                      _startDate == null ? 'Tanggal Mulai' : fmt.format(_startDate!),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('s/d'),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: false),
                    icon: const Icon(Icons.event, size: 18),
                    label: Text(
                      _endDate == null ? 'Tanggal Selesai' : fmt.format(_endDate!),
                    ),
                  ),
                ),
              ],
            ),
            if (_totalDays > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Chip(
                  avatar: const Icon(
                    Icons.schedule,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                  label: Text(
                    'Total Pengajuan: $_totalDays Hari Kerja',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  backgroundColor: const Color(0xFFEFF6FF),
                  side: BorderSide.none,
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Alasan Cuti',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Misal: Menghadiri keperluan keluarga mendesak...',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Mohon isi alasan cuti secara singkat'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isFormReady ? _submit : null,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_isSubmitting ? 'Mengirim...' : 'Ajukan Permohonan Cuti'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- TAB 2: RIWAYAT CUTI ----------------
class LeaveHistoryView extends StatelessWidget {
  final int? employeeId;

  const LeaveHistoryView({super.key, required this.employeeId});

  Future<List<dynamic>> _fetchMyLeaves() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/leaves'),
        headers: {'Accept': 'application/json'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> allLeaves = jsonDecode(res.body);
        return allLeaves.where((l) => l['employee_id'] == employeeId).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchMyLeaves(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final leaves = snapshot.data ?? [];
        if (leaves.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 54, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Belum ada riwayat permohonan cuti.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: leaves.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final item = leaves[i];
            final status = item['status'] as String;

            Color bg;
            Color text;
            String label;

            // Palet Semantik Status
            if (status == 'approved') {
              bg = const Color(0xFFD1FAE5);
              text = const Color(0xFF065F46);
              label = 'Disetujui';
            } else if (status == 'rejected') {
              bg = const Color(0xFFFFE4E6);
              text = const Color(0xFF9F1239);
              label = 'Ditolak';
            } else {
              bg = const Color(0xFFFEF3C7);
              text = const Color(0xFF92400E);
              label = 'Menunggu Persetujuan';
            }

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item['start_date']} s/d ${item['end_date']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: text,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keperluan: ${item['reason'] ?? ''}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    if (status == 'rejected' &&
                        item['rejection_reason'] != null &&
                        item['rejection_reason'].toString().trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Color(0xFFE11D48),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Catatan HR: ${item['rejection_reason']}',
                                style: const TextStyle(
                                  color: Color(0xFF9F1239),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}