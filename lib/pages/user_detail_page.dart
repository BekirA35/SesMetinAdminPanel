import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/admin_api_service.dart';
import '../services/mock_data_service.dart';
import '../models/admin_user.dart';
import '../models/admin_record.dart';
import '../theme/app_theme.dart';
import '../widgets/safe_opacity.dart';

class UserDetailPage extends StatefulWidget {
  final String userId;

  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage>
    with SingleTickerProviderStateMixin {
  final AdminApiService _apiService = AdminApiService();
  
  AdminUser? _user;
  List<AdminRecord> _records = [];
  bool _isRefreshing = false;
  bool _isRealData = false;
  bool _isLoading = false;
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
    
    final userId = int.tryParse(widget.userId);
    if (userId != null) {
      // Önce API'ye istek at, başarısız olursa mock data göster
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _loadMockUserData(int userId) {
    final mockResponse = MockDataService.getMockUserRecords(userId);
    setState(() {
      _user = mockResponse.user;
      _records = mockResponse.records;
      _isRealData = false;
    });
    _fadeController.value = 1.0.clamp(0.0, 1.0);
  }

  Future<void> _loadUserData() async {
    final userId = int.tryParse(widget.userId);
    if (userId == null) {
      return;
    }

    // Eğer zaten yükleniyorsa, yeni istek başlatma
    if (_isLoading) return;
    
    if (!mounted) return;

    setState(() {
      _isRefreshing = true;
      _isLoading = true;
    });

    try {
      final response = await _apiService.getUserRecords(userId);
      
      // Sayfa hala açık mı kontrol et
      if (!mounted) return;
      
      final isRealData = response.message != 'Mock veriler gösteriliyor';
      
      if (mounted) {
        setState(() {
          _user = response.user;
          _records = response.records;
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
        _loadMockUserData(userId);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final padding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Geri Butonu ve Başlık
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                    border: Border.all(color: AppTheme.cardColor),
                  ),
                  child: IconButton(
                    onPressed: () => context.go('/users'),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      size: isMobile ? 20 : 24,
                    ),
                    color: AppTheme.textSecondary,
                    tooltip: 'Geri',
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Flexible(
                  child: Text(
                    'Kullanıcı Detayı',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 20 : 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (!isMobile && !_isRealData) ...[
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
                if (!isMobile) ...[
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                      border: Border.all(color: AppTheme.cardColor),
                    ),
                    child: IconButton(
                      onPressed: _isRefreshing ? null : _loadUserData,
                      icon: _isRefreshing
                          ? SizedBox(
                              width: isMobile ? 18 : 20,
                              height: isMobile ? 18 : 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              size: isMobile ? 20 : 24,
                            ),
                      color: AppTheme.textSecondary,
                      tooltip: 'Yenile',
                      padding: EdgeInsets.all(isMobile ? 8 : 12),
                    ),
                  ),
                ],
              ],
            ),
            if (isMobile) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardColor),
                    ),
                    child: IconButton(
                      onPressed: _isRefreshing ? null : _loadUserData,
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
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: isMobile ? 16 : 24),

            // İçerik
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_user == null) {
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
              'Kullanıcı bilgileri yükleniyor...',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
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
          child: child!,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final innerIsMobile = constraints.maxWidth < 768;
          
          if (constraints.maxWidth > 900 && !innerIsMobile) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildProfileCard(innerIsMobile)),
                SizedBox(width: innerIsMobile ? 16 : 24),
                Expanded(flex: 2, child: _buildRecordsGrid(innerIsMobile)),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı Profil Kartı
                _buildProfileCard(innerIsMobile),
                SizedBox(height: innerIsMobile ? 16 : 24),

                // Kayıtlar Başlığı
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(innerIsMobile ? 8 : 10),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(innerIsMobile ? 10 : 12),
                      ),
                      child: Icon(
                        Icons.article_rounded,
                        color: AppTheme.successColor,
                        size: innerIsMobile ? 18 : 20,
                      ),
                    ),
                    SizedBox(width: innerIsMobile ? 8 : 12),
                    Text(
                      'Kayıtlar',
                      style: GoogleFonts.poppins(
                        fontSize: innerIsMobile ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(width: innerIsMobile ? 8 : 12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: innerIsMobile ? 10 : 12,
                        vertical: innerIsMobile ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_records.length} kayıt',
                        style: GoogleFonts.poppins(
                          fontSize: innerIsMobile ? 11 : 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: innerIsMobile ? 12 : 16),

                // Kayıtlar Grid
                _buildRecordsGrid(innerIsMobile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(bool isMobile) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR');
    final padding = isMobile ? 20.0 : 28.0;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceColor,
            AppTheme.surfaceColor.withAlpha(204),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(26),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(102),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _user!.username.isNotEmpty ? _user!.username[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 28),

          // Kullanıcı Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user!.username,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _user!.email,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Kayıt: ${dateFormat.format(_user!.createdAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // İstatistik Kartları
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildMiniStat(
                      icon: Icons.article_rounded,
                      label: 'Kayıt',
                      value: '${_user!.recordCount}',
                      color: AppTheme.successColor,
                    ),
                    _buildMiniStat(
                      icon: Icons.share_rounded,
                      label: 'Paylaşım',
                      value: '${_user!.shareCount}',
                      color: AppTheme.warningColor,
                    ),
                    if (_user!.lastActivityAt != null)
                      _buildMiniStat(
                        icon: Icons.access_time_rounded,
                        label: 'Son Aktivite',
                        value: _formatTimeAgo(_user!.lastActivityAt!),
                        color: AppTheme.accentColor,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsGrid(bool isMobile) {
    if (_records.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 32 : 48),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_rounded,
                size: isMobile ? 40 : 48,
                color: AppTheme.textMuted.withAlpha(128),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'Bu kullanıcının henüz kaydı yok',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 14 : 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (isMobile) {
          crossAxisCount = 1;
        } else {
          crossAxisCount = constraints.maxWidth > 1200
              ? 3
              : constraints.maxWidth > 700
                  ? 2
                  : 1;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isMobile ? 12 : 16,
            mainAxisSpacing: isMobile ? 12 : 16,
            childAspectRatio: isMobile ? 1.2 : 1.4,
          ),
          itemCount: _records.length,
          itemBuilder: (context, index) {
            return _buildRecordCard(_records[index], isMobile);
          },
        );
      },
    );
  }

  Widget _buildRecordCard(AdminRecord record, bool isMobile) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final padding = isMobile ? 16.0 : 20.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Durum
          Row(
            children: [
              Expanded(
                child: Text(
                  record.title ?? 'Başlıksız Kayıt',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (record.hasActiveShare)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 12,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Paylaşılıyor',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // İçerik Önizleme
          Expanded(
            child: Text(
              record.textContent ?? 'İçerik yok',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),

          // Alt Bilgiler
          Divider(color: AppTheme.cardColor.withAlpha(128)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                dateFormat.format(record.createdAt),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
              const Spacer(),
              _buildSmallBadge(
                icon: Icons.translate_rounded,
                value: '${record.translationCount}',
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              _buildSmallBadge(
                icon: Icons.visibility_rounded,
                value: '${record.shareAccessCount}',
                color: AppTheme.warningColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Az önce';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}dk';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}sa';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}g';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

