import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:kalorimu/core/constants/app_colors.dart';
import 'package:kalorimu/data/models/food_journal.dart';
import 'package:kalorimu/core/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kalorimu/core/utils/date_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _targetCalories = 0;
  List<FoodJournal> _journals = [];
  bool _isLoading = true;
  
  final _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadTargetAndJournals();
  }

  Future<void> _loadTargetAndJournals() async {
    await _loadTargetCalories();
    await _fetchJournals();
    if (_targetCalories == 0 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTargetCaloriesDialog();
      });
    }
  }

  Future<void> _loadTargetCalories() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'unknown';
    final customDayKey = AppDateUtils.getCustomDayKey(DateTime.now());
    final key = 'daily_target_${userId}_$customDayKey';
    
    int? target = prefs.getInt(key);
    
    if (target == null || target == 0) {
      target = prefs.getInt('default_target_calories_$userId') ?? 2000;
    }
    
    if (mounted) {
      setState(() {
        _targetCalories = target!;
      });
    }
  }

  Future<void> _saveTargetCalories(int newTarget) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'unknown';
    final customDayKey = AppDateUtils.getCustomDayKey(DateTime.now());
    final key = 'daily_target_${userId}_$customDayKey';
    
    await prefs.setInt(key, newTarget);
    
    if (mounted) {
      setState(() {
        _targetCalories = newTarget;
      });
    }
  }

  void _showTargetCaloriesDialog() {
    final controller = TextEditingController(text: _targetCalories > 0 ? _targetCalories.toString() : '2000');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Target Kalori Hari Ini', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Berapa target kalori yang ingin kamu capai hari ini?', style: GoogleFonts.inter()),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: 'kcal',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (_targetCalories > 0)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
          ElevatedButton(
            onPressed: () {
              final newTarget = int.tryParse(controller.text);
              if (newTarget != null && newTarget > 0) {
                _saveTargetCalories(newTarget);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Simpan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchJournals() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final start = AppDateUtils.getStartOfCustomDay(now);
      final end = AppDateUtils.getEndOfCustomDay(now);
      
      final data = await _databaseService.getJournals(start: start, end: end);
      if (mounted) {
        setState(() {
          _journals = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteJournal(FoodJournal journal) async {
    if (journal.id == null) return;
    
    // Optimistic UI update
    setState(() {
      _journals.removeWhere((j) => j.id == journal.id);
    });
    
    // Delete from DB
    final success = await _databaseService.deleteJournal(journal.id!);
    
    if (!success) {
      // Revert if failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus data')),
        );
        _fetchJournals(); // Refresh to restore
      }
    }
  }
  
  int get _totalCalories => _journals.fold(0, (sum, item) => sum + item.calories);
  int get _totalProtein => _journals.fold(0, (sum, item) => sum + (item.proteinG?.toInt() ?? 0));
  int get _totalCarbs => _journals.fold(0, (sum, item) => sum + (item.carbsG?.toInt() ?? 0));
  int get _totalFat => _journals.fold(0, (sum, item) => sum + (item.fatG?.toInt() ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.primaryContainer.withValues(alpha: 0.5), height: 1),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Center(
            child: Image.asset('assets/images/logo.png', width: 36, height: 36, fit: BoxFit.contain),
          ),
        ),
        leadingWidth: 60,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 28),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchJournals,
        color: AppColors.primaryContainer,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DAILY SUMMARY',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      IconButton(
                        onPressed: _showTargetCaloriesDialog,
                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryContainer),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Builder(
                    builder: (context) {
                      double progress = 0.0;
                      if (_targetCalories > 0) {
                        progress = (_totalCalories / _targetCalories);
                        if (progress > 1.0) progress = 1.0;
                        if (progress < 0.0) progress = 0.0;
                      }
                      
                      return GestureDetector(
                        onTap: _showTargetCaloriesDialog,
                        child: CircularPercentIndicator(
                          radius: 80.0,
                          lineWidth: 12.0,
                          percent: progress,
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: AppColors.surfaceVariant,
                          progressColor: AppColors.primaryContainer,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                NumberFormat('#,###').format(_totalCalories),
                                style: GoogleFonts.montserrat(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '/ ${NumberFormat('#,###').format(_targetCalories)} kcal',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMacroItem(Icons.restaurant, 'Protein', '${_totalProtein}g'),
                      _buildMacroItem(Icons.grain, 'Carbs', '${_totalCarbs}g'),
                      _buildMacroItem(Icons.water_drop, 'Fat', '${_totalFat}g'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Today's Journal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Journal",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryContainer, // Gold
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Journal
            if (_journals.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No meals logged today.\nTap the camera button to start!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ..._journals.map((journal) => _buildJournalCard(journal)),

            const SizedBox(height: 16),

            // Wellness Tip
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F0), // Very light gold/beige
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: AppColors.primaryContainer, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wellness Tip',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Adding a touch of lemon water before your meals can help improve digestion and keep you refreshed throughout the day.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // AI Disclaimer
            Center(
              child: Text(
                'Disclaimer: Hasil analisis AI tidak 100% akurat.\nTingkat kebenaran estimasi kalori berkisar ~90%.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/camera'),
        backgroundColor: AppColors.primaryContainer,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 20,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.dashboard_outlined, 'Dashboard', true, () {}),
            const SizedBox(width: 48), // Space for FAB
            _buildBottomNavItem(Icons.person_outline, 'Profile', false, () => context.go('/profile')),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryContainer, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 3,
          color: AppColors.primaryContainer,
        ),
      ],
    );
  }

  Widget _buildJournalCard(FoodJournal journal) {
    if (journal.id == null) return _buildCardContent(journal);

    return Dismissible(
      key: Key(journal.id!),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Hapus Jurnal", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
              content: Text("Yakin ingin menghapus makanan ini?", style: GoogleFonts.inter()),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Batal", style: GoogleFonts.inter(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Hapus", style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteJournal(journal);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: _buildCardContent(journal),
    );
  }

  Widget _buildCardContent(FoodJournal journal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primaryContainer, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Food Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(journal.imageUrl ?? 'https://via.placeholder.com/60'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        journal.mealType.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(journal.loggedAt),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          journal.foodName,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${journal.calories} kcal',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7B5800), // AppColors.secondary
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryContainer : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primaryContainer : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
