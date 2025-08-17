import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterDialog extends StatefulWidget {
  final String selectedStatusFilter;
  final String selectedDoctorFilter;
  final DateTime? selectedDateFilter;
  final bool emergencyOnlyFilter;
  final Function(String, String, DateTime?, bool) onFiltersChanged;

  const FilterDialog({
    Key? key,
    required this.selectedStatusFilter,
    required this.selectedDoctorFilter,
    required this.selectedDateFilter,
    required this.emergencyOnlyFilter,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String _statusFilter;
  late String _doctorFilter;
  late DateTime? _dateFilter;
  late bool _emergencyFilter;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.selectedStatusFilter;
    _doctorFilter = widget.selectedDoctorFilter;
    _dateFilter = widget.selectedDateFilter;
    _emergencyFilter = widget.emergencyOnlyFilter;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Appointments'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter
            const Text(
              'Status:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _statusFilter,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                setState(() {
                  _statusFilter = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            
            // Date Filter
            const Text(
              'Date:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dateFilter != null
                            ? DateFormat('MMM dd, yyyy').format(_dateFilter!)
                            : 'Select Date',
                        style: TextStyle(
                          color: _dateFilter != null 
                              ? Colors.black87 
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (_dateFilter != null)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _dateFilter = null;
                          });
                        },
                        icon: const Icon(Icons.clear, size: 20),
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Emergency Filter
            CheckboxListTile(
              value: _emergencyFilter,
              onChanged: (value) {
                setState(() {
                  _emergencyFilter = value ?? false;
                });
              },
              title: const Text('Emergency Appointments Only'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            
            const SizedBox(height: 12),
            
            // Quick Filter Chips
            const Text(
              'Quick Filters:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Today'),
                  selected: _isToday(),
                  onSelected: (selected) {
                    setState(() {
                      _dateFilter = selected ? DateTime.now() : null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('This Week'),
                  selected: _isThisWeek(),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        final now = DateTime.now();
                        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                        _dateFilter = startOfWeek;
                      } else {
                        _dateFilter = null;
                      }
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Pending Only'),
                  selected: _statusFilter == 'pending',
                  onSelected: (selected) {
                    setState(() {
                      _statusFilter = selected ? 'pending' : 'all';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Reset all filters
            setState(() {
              _statusFilter = 'all';
              _doctorFilter = 'all';
              _dateFilter = null;
              _emergencyFilter = false;
            });
          },
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onFiltersChanged(
              _statusFilter,
              _doctorFilter,
              _dateFilter,
              _emergencyFilter,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A4C93),
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateFilter ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _dateFilter = date;
      });
    }
  }

  bool _isToday() {
    if (_dateFilter == null) return false;
    final now = DateTime.now();
    return _dateFilter!.year == now.year &&
           _dateFilter!.month == now.month &&
           _dateFilter!.day == now.day;
  }

  bool _isThisWeek() {
    if (_dateFilter == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _dateFilter!.year == startOfWeek.year &&
           _dateFilter!.month == startOfWeek.month &&
           _dateFilter!.day == startOfWeek.day;
  }
}