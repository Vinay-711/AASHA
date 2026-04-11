import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../di/injection.dart';
import '../../bloc/medication/medication_bloc.dart';
import '../../bloc/medication/medication_event.dart';
import '../../bloc/medication/medication_state.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});
  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _genericCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();

  String _frequency = 'twice daily';
  final List<Map<String, dynamic>> _timings = [
    {'time': '08:00', 'with_food': false}
  ];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _colorCode = '#7B1FA2';
  String _shape = 'round';

  late MedicationBloc _bloc;

  static const _frequencies = [
    'once daily',
    'twice daily',
    'three times daily',
    'as needed',
  ];

  static const _shapes = ['round', 'oval', 'capsule', 'tablet'];

  static const _colors = [
    '#4CAF50',
    '#2196F3',
    '#F44336',
    '#FF9800',
    '#7B1FA2',
    '#009688',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = getIt<MedicationBloc>();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _genericCtrl.dispose();
    _dosageCtrl.dispose();
    _instructionsCtrl.dispose();
    _bloc.close();
    super.dispose();
  }

  void _addTiming() {
    setState(() {
      _timings.add({'time': '12:00', 'with_food': false});
    });
  }

  void _removeTiming(int index) {
    if (_timings.length > 1) {
      setState(() => _timings.removeAt(index));
    }
  }

  Future<void> _pickTime(int index) async {
    final parts = (_timings[index]['time'] as String).split(':');
    final initial =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        _timings[index]['time'] =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameCtrl.text.trim(),
      'generic_name':
          _genericCtrl.text.trim().isEmpty ? null : _genericCtrl.text.trim(),
      'dosage': _dosageCtrl.text.trim(),
      'frequency': _frequency,
      'timing': _timings,
      'start_date':
          '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
      'end_date': _endDate != null
          ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
          : null,
      'instructions': _instructionsCtrl.text.trim().isEmpty
          ? null
          : _instructionsCtrl.text.trim(),
      'color_code': _colorCode,
      'shape': _shape,
    };
    _bloc.add(AddMedication(data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Add Medication',
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
        ),
        body: BlocListener<MedicationBloc, MedicationState>(
          listener: (context, state) {
            if (state is MedicationAdded) {
              context.pop();
            }
            if (state is MedicationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red[700]),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Medicine Name *',
                          prefixIcon: const Icon(Icons.medication_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      // Generic Name
                      TextFormField(
                        controller: _genericCtrl,
                        decoration: InputDecoration(
                          labelText: 'Generic Name',
                          prefixIcon: const Icon(Icons.science_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Dosage
                      TextFormField(
                        controller: _dosageCtrl,
                        decoration: InputDecoration(
                          labelText: 'Dosage (e.g. 25mg) *',
                          prefixIcon: const Icon(Icons.scale_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      // Frequency
                      DropdownButtonFormField<String>(
                        value: _frequency,
                        decoration: InputDecoration(
                          labelText: 'Frequency',
                          prefixIcon: const Icon(Icons.repeat_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _frequencies
                            .map((f) =>
                                DropdownMenuItem(value: f, child: Text(f)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _frequency = v);
                        },
                      ),
                      const SizedBox(height: 18),

                      // Timing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Schedule',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          TextButton.icon(
                            onPressed: _addTiming,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Time'),
                          ),
                        ],
                      ),
                      ...List.generate(_timings.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickTime(i),
                                  icon: const Icon(Icons.access_time_rounded),
                                  label: Text(_timings[i]['time']),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  const Text('Food', style: TextStyle(fontSize: 12)),
                                  Checkbox(
                                    value: _timings[i]['with_food'] ?? false,
                                    onChanged: (v) => setState(
                                        () => _timings[i]['with_food'] = v),
                                  ),
                                ],
                              ),
                              if (_timings.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.red, size: 20),
                                  onPressed: () => _removeTiming(i),
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 14),

                      // Start / End dates
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickStartDate,
                              icon: const Icon(Icons.calendar_today_rounded,
                                  size: 18),
                              label: Text(
                                  'Start: ${_startDate.month}/${_startDate.day}/${_startDate.year}'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickEndDate,
                              icon: const Icon(Icons.event_rounded, size: 18),
                              label: Text(_endDate != null
                                  ? 'End: ${_endDate!.month}/${_endDate!.day}/${_endDate!.year}'
                                  : 'No end date'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Instructions
                      TextFormField(
                        controller: _instructionsCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Instructions',
                          prefixIcon: const Icon(Icons.notes_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Color picker
                      const Text('Color',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _colors.map((c) {
                          final color = Color(
                              int.parse(c.replaceFirst('#', '0xFF')));
                          final selected = c == _colorCode;
                          return GestureDetector(
                            onTap: () => setState(() => _colorCode = c),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(
                                        color: Colors.black87, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Shape
                      DropdownButtonFormField<String>(
                        value: _shape,
                        decoration: InputDecoration(
                          labelText: 'Shape',
                          prefixIcon: const Icon(Icons.circle_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _shapes
                            .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                    s[0].toUpperCase() + s.substring(1))))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _shape = v);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B1FA2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Add Medication',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
