import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/admin_api_service.dart';
import '../services/mock_data_service.dart';
import '../models/activity.dart';
import '../theme/app_theme.dart';
import '../widgets/safe_opacity.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage>
    with SingleTickerProviderStateMixin {
  final AdminApiService _apiService = AdminApiService();
  
  List<Activity> _activities = [];
  List<Activity> _filteredActivities = [];
  bool _isRefreshing = false;
  bool _isRealData = false;
  bool _isLoading = false;
  String _selectedFilter = 'all';
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    
    // Önce API'ye istek at, başarısız olursa mock data göster
    _loadActivities();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _loadMockActivities() {
    final mockResponse = MockDataService.getMockActivities(limit: 100);
    setState(() {
      _activities = mockResponse.activities;
      _applyFilter();
      _isRealData = false;
    });
    _fadeController.value = 1.0.clamp(0.0, 1.0);
  }

  Future<void> _loadActivities() async {
    // Eğer zaten yükleniyorsa, yeni istek başlatma
    if (_isLoading) return;
    
    if (!mounted) return;
    
    setState(() {
      _isRefreshing = true;
      _isLoading = true;
    });

    try {
      final response = await _apiService.getActivities(limit: 100);
      
      // Sayfa hala açık mı kontrol et
      if (!mounted) return;
      
      final isRealData = response.message != 'Mock veriler gösteriliyor';
      
      if (mounted) {
        setState(() {
          _activities = response.activities;
          _applyFilter();
          _isRealData = isRealData;
        });
        
        if (isRealData) {
          // Gerçek veri geldi, animasyon göster
          try {
            _fadeController.value = 0.0.clamp(0.0, 1.0);
            await _fadeController.forward();
          } catch (e) {
            // Hata durumunda sessizce devam et
            _fadeController.value = 1.0.clamp(0.0, 1.0);
          }
        } else {
          // Mock data geldi, direkt göster
          try {
            _fadeController.value = 1.0.clamp(0.0, 1.0);
          } catch (e) {
            // Hata durumunda sessizce devam et
          }
        }
      }
    } catch (e) {
      // API hatası durumunda mock data göster
      if (mounted) {
        _loadMockActivities();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'all') {
      _filteredActivities = _activities;
    } else {
      _filteredActivities = _activities
          .where((a) => a.type == _selectedFilter)
          .toList();
    }
  }

  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final padding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Flexible(
                child: Text(
                  'Aktiviteler',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (!isMobile) ...[
                SizedBox(width: isTablet ? 12 : 16),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 10 : 12,
                    vertical: isTablet ? 5 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_filteredActivities.length} aktivite',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 12 : 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ),
                if (!_isRealData) ...[
                  SizedBox(width: isTablet ? 10 : 12),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 12,
                      vertical: isTablet ? 5 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.warningColor.withAlpha(77)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.warningColor,
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 4 : 6),
                        Text(
                          'Bağlanıyor...',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 10 : 11,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_filteredActivities.length} aktivite',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ),
                if (!_isRealData)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.warningColor.withAlpha(77)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 6,
                          height: 6,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.warningColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Bağlanıyor...',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          SizedBox(height: isMobile ? 8 : 8),
          Text(
            'Son kullanıcı aktivitelerini takip et',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : 16,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // Filtreler
          _buildFilters(isMobile),
          SizedBox(height: isMobile ? 16 : 24),

          // İçerik
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
      ),
      child: isMobile
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildFilterChip('all', 'Tümü', Icons.list_rounded, isMobile)),
                    SizedBox(width: isMobile ? 6 : 8),
                    Expanded(child: _buildFilterChip('user_registered', 'Kayıtlar', Icons.person_add_rounded, isMobile)),
                  ],
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Row(
                  children: [
                    Expanded(child: _buildFilterChip('record_created', 'Notlar', Icons.note_add_rounded, isMobile)),
                    SizedBox(width: isMobile ? 6 : 8),
                    Expanded(child: _buildFilterChip('share_created', 'Paylaşımlar', Icons.share_rounded, isMobile)),
                  ],
                ),
                SizedBox(height: isMobile ? 6 : 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withAlpha(128),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: _isRefreshing ? null : _loadActivities,
                    icon: _isRefreshing
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh_rounded, size: 20),
                    color: AppTheme.textSecondary,
                    tooltip: 'Yenile',
                  ),
                ),
              ],
            )
          : Row(
              children: [
                _buildFilterChip('all', 'Tümü', Icons.list_rounded, isMobile),
                SizedBox(width: isMobile ? 6 : 8),
                _buildFilterChip('user_registered', 'Kayıtlar', Icons.person_add_rounded, isMobile),
                SizedBox(width: isMobile ? 6 : 8),
                _buildFilterChip('record_created', 'Notlar', Icons.note_add_rounded, isMobile),
                SizedBox(width: isMobile ? 6 : 8),
                _buildFilterChip('share_created', 'Paylaşımlar', Icons.share_rounded, isMobile),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withAlpha(128),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _isRefreshing ? null : _loadActivities,
                    icon: _isRefreshing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh_rounded),
                    color: AppTheme.textSecondary,
                    tooltip: 'Yenile',
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon, bool isMobile) {
    final isSelected = _selectedFilter == value;
    
    Color chipColor;
    switch (value) {
      case 'user_registered':
        chipColor = AppTheme.successColor;
        break;
      case 'record_created':
        chipColor = AppTheme.primaryColor;
        break;
      case 'share_created':
        chipColor = AppTheme.warningColor;
        break;
      default:
        chipColor = AppTheme.accentColor;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _setFilter(value),
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? chipColor.withAlpha(51) : Colors.transparent,
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(
                color: isSelected ? chipColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: isMobile ? 16 : 18,
                  color: isSelected ? chipColor : AppTheme.textMuted,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? chipColor : AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor.withAlpha(204),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aktiviteler yükleniyor...',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: AppTheme.textMuted.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'Aktivite bulunamadı',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        // SafeOpacity kullanarak opacity değerini güvenli hale getir
        return SafeOpacity(
          opacity: _fadeController.value,
          child: _buildTimeline(),
        );
      },
    );
  }

  Widget _buildTimeline() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final padding = isMobile ? 16.0 : 24.0;
        
        // Aktiviteleri tarihe göre grupla
        final groupedActivities = <String, List<Activity>>{};
        final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
        
        for (final activity in _filteredActivities) {
          final dateKey = dateFormat.format(activity.timestamp);
          groupedActivities.putIfAbsent(dateKey, () => []);
          groupedActivities[dateKey]!.add(activity);
        }

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
          ),
          child: ListView.builder(
            padding: EdgeInsets.all(padding),
        itemCount: groupedActivities.length,
        itemBuilder: (context, index) {
          final dateKey = groupedActivities.keys.elementAt(index);
          final dayActivities = groupedActivities[dateKey]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: 24),
              // Tarih Başlığı
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor.withAlpha(128),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateKey,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Divider(color: AppTheme.cardColor.withAlpha(128)),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              // Aktiviteler
              ...dayActivities.map((activity) => _buildTimelineItem(activity, isMobile)),
            ],
          );
        },
      ),
        );
      },
    );
  }

  Widget _buildTimelineItem(Activity activity, bool isMobile) {
    final timeFormat = DateFormat('HH:mm');
    
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Çizgisi ve İkon
          Column(
            children: [
              Container(
                width: isMobile ? 36 : 44,
                height: isMobile ? 36 : 44,
                decoration: BoxDecoration(
                  color: activity.color.withAlpha(38),
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
                  border: Border.all(
                    color: activity.color.withAlpha(77),
                    width: 2,
                  ),
                ),
                child: Icon(
                  activity.icon,
                  size: isMobile ? 18 : 20,
                  color: activity.color,
                ),
              ),
            ],
          ),
          SizedBox(width: isMobile ? 12 : 16),
          
          // İçerik
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withAlpha(77),
                borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
                border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.description,
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 12 : 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          timeFormat.format(activity.timestamp),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildActivityTag(activity),
                      if (activity.username != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 12,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activity.username!,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTag(Activity activity) {
    String label;
    switch (activity.type) {
      case 'user_registered':
        label = 'Yeni Kullanıcı';
        break;
      case 'record_created':
        label = 'Yeni Kayıt';
        break;
      case 'share_created':
        label = 'Paylaşım';
        break;
      default:
        label = 'Aktivite';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: activity.color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: activity.color,
        ),
      ),
    );
  }
}

