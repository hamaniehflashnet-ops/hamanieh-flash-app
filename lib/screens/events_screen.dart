import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<String> _filters = ['Tous', 'À venir', 'Couverts'];
  String _selected = 'Tous';
  late Future<List<EventItem>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = ApiService.instance.getEvents(filter: _selected.toLowerCase());
  }

  void _selectFilter(String f) {
    setState(() {
      _selected = f;
      _eventsFuture = ApiService.instance.getEvents(filter: f.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFAppBar(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Événements à couvrir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filters.map((f) {
                final isSelected = f == _selected;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    selectedColor: AppColors.secondaryBlue,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark),
                    onSelected: (_) => _selectFilter(f),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<EventItem>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final events = snapshot.data ?? [];
                if (events.isEmpty) {
                  return const Center(child: Text('Aucun événement pour ce filtre.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  itemBuilder: (context, i) => _EventCard(event: events[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventItem event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('dd').format(event.date);
    final month = DateFormat('MMM', 'fr').format(event.date);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(day, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  Text(month, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(event.location, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Voir détails')),
          ],
        ),
      ),
    );
  }
}
