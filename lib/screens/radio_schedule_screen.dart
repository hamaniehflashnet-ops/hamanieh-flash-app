import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';
import '../widgets/error_retry.dart';

class RadioScheduleScreen extends StatefulWidget {
  const RadioScheduleScreen({super.key});

  @override
  State<RadioScheduleScreen> createState() => _RadioScheduleScreenState();
}

class _RadioScheduleScreenState extends State<RadioScheduleScreen> {
  late Future<List<RadioProgram>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = ApiService.instance.getRadioSchedule();
  }

  void _reload() {
    setState(() => _scheduleFuture = ApiService.instance.getRadioSchedule());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFAppBar(),
      body: FutureBuilder<List<RadioProgram>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorRetry(onRetry: _reload);
          }
          final programs = snapshot.data ?? [];
          if (programs.isEmpty) {
            return const Center(child: Text('Aucun programme disponible pour le moment.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: programs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final p = programs[i];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.radio, color: Colors.white),
                  ),
                  title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${p.startTime} - ${p.endTime}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
