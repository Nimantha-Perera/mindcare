import 'package:flutter/material.dart';

class FilterSection extends StatelessWidget {
  final List<String> specialties;
  final String selectedSpecialty;
  final bool isOnlineOnly;
  final ValueChanged<String> onSpecialtyChanged;
  final ValueChanged<bool> onOnlineFilterChanged;

  const FilterSection({
    Key? key,
    required this.specialties,
    required this.selectedSpecialty,
    required this.isOnlineOnly,
    required this.onSpecialtyChanged,
    required this.onOnlineFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Mental Health Specialty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildSpecialtyFilters(),
          const SizedBox(height: 12),
          _buildOnlineFilter(),
        ],
      ),
    );
  }

  Widget _buildSpecialtyFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          final specialty = specialties[index];
          final isSelected = selectedSpecialty == specialty;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                onSpecialtyChanged(selected ? specialty : 'All');
              },
              backgroundColor: Colors.grey[200],
              selectedColor: const Color(0xFF6A4C93),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnlineFilter() {
    return Row(
      children: [
        Switch(
          value: isOnlineOnly,
          onChanged: onOnlineFilterChanged,
          activeColor: const Color(0xFF6A4C93),
        ),
        const SizedBox(width: 8),
        const Text(
          'Show online doctors only',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}