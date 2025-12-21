import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/admin_api_service.dart';
import '../services/mock_data_service.dart';
import '../models/dashboard_stats.dart';
import '../models/activity.dart';
import '../models/chart_data.dart';
import '../theme/app_theme.dart';
import '../widgets/safe_opacity.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  final AdminApiService _apiService = AdminApiService();
  DashboardStats? _stats;
  List<Activity> _activities = [];
  ChartDataResponse? _chartData;
  bool _isRefreshing = false;
  bool _isRealData = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    
    // Önce API'ye istek at, başarısız olursa mock data göster
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    final mockStats = MockDataService.getMockStats();
    final mockActivities = MockDataService.getMockActivities(limit: 10);
    final mockChart = MockDataService.getMockChartData(days: 7);

    setState(() {
      _stats = mockStats.stats;
      _activities = mockActivities.activities;
      _chartData = mockChart;
      _isRealData = false;
    });
    _animationController.forward(from: 0);
    _fadeController.value = 1.0.clamp(0.0, 1.0);
  }

  Future<void> _loadData() async {
    // Eğer zaten yükleniyorsa, yeni istek başlatma
    if (_isLoading) return;
    
    if (!mounted) return;
    
    setState(() {
      _isRefreshing = true;
      _isLoading = true;
    });

    try {
      // Paralel API çağrıları
      final results = await Future.wait([
        _apiService.getStats(),
        _apiService.getActivities(limit: 10),
        _apiService.getChartData(days: 7),
      ]);

      // Sayfa hala açık mı kontrol et
      if (!mounted) return;

      final statsResponse = results[0] as StatsResponse;
      final activitiesResponse = results[1] as ActivitiesResponse;
      final chartResponse = results[2] as ChartDataResponse;

      final newStats = statsResponse.stats;
      final newActivities = activitiesResponse.activities;
      final newChartData = chartResponse;

      // Eğer gerçek veri geldiyse (mock değilse)
      final isRealData = statsResponse.message != 'Mock veriler gösteriliyor';
      
      if (mounted) {
        setState(() {
          _stats = newStats;
          _activities = newActivities;
          _chartData = newChartData;
          _isRealData = isRealData;
        });
        
        if (isRealData) {
          // Gerçek veri geldi, animasyon göster
          try {
            _fadeController.value = 0.0.clamp(0.0, 1.0);
            await _fadeController.forward();
            _animationController.forward(from: 0);
          } catch (e) {
            // Hata durumunda sessizce devam et
            _fadeController.value = 1.0.clamp(0.0, 1.0);
            _animationController.forward(from: 0);
          }
        } else {
          // Mock data geldi, direkt göster
          _fadeController.value = 1.0.clamp(0.0, 1.0);
          _animationController.forward(from: 0);
        }
      }
    } catch (e) {
      // Hata durumunda mock data göster
      if (mounted) {
        _loadMockData();
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
    if (_stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor.withAlpha(204),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Veriler yükleniyor...',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 16,
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
          child: child!,
        );
      },
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
            final padding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
            
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Dashboard',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!isMobile) const Spacer(),
                      if (!_isRealData && !isMobile)
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              const SizedBox(width: 6),
                              Text(
                                'Bağlanıyor...',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppTheme.warningColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (!isMobile) _buildRefreshButton(),
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
                        _buildRefreshButton(),
                      ],
                    ),
                  ],
                  SizedBox(height: isMobile ? 8 : 8),
                  Text(
                    'Genel bakış ve istatistikler',
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 14 : 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: isMobile ? 20 : 32),

            // Stat Kartları
            _buildStatCards(),
            const SizedBox(height: 32),

                  // Grafik ve Aktiviteler
                  LayoutBuilder(
                    builder: (context, innerConstraints) {
                      if (innerConstraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildChart()),
                            SizedBox(width: isMobile ? 16 : 24),
                            Expanded(child: _buildActivityList()),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildChart(),
                          SizedBox(height: isMobile ? 16 : 24),
                          _buildActivityList(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardColor),
      ),
      child: IconButton(
        onPressed: _isRefreshing ? null : _loadData,
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
    );
  }

  Widget _buildStatCards() {
    if (_stats == null) return const SizedBox.shrink();

    final statItems = [
      _StatItem(
        title: 'Toplam Kullanıcı',
        value: '${_stats!.totalUsers}',
        subtitle: 'Bugün +${_stats!.todayNewUsers}',
        icon: Icons.people_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
      ),
      _StatItem(
        title: 'Toplam Kayıt',
        value: '${_stats!.totalRecords}',
        subtitle: 'Bugün +${_stats!.todayNewRecords}',
        icon: Icons.article_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
        ),
      ),
      _StatItem(
        title: 'Aktif Paylaşım',
        value: '${_stats!.activeShares}',
        subtitle: 'Toplam ${_stats!.totalShares}',
        icon: Icons.share_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        ),
      ),
      _StatItem(
        title: 'Toplam Çeviri',
        value: '${_stats!.totalTranslations}',
        subtitle: 'Ort. ${_stats!.averageRecordsPerUser.toStringAsFixed(1)} kayıt/kişi',
        icon: Icons.translate_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
        
        int crossAxisCount;
        if (isMobile) {
          crossAxisCount = 1;
        } else if (isTablet) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = constraints.maxWidth > 1200 ? 4 : 2;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isMobile ? 12 : 20,
            mainAxisSpacing: isMobile ? 12 : 20,
            childAspectRatio: crossAxisCount == 1 
                ? (isMobile ? 2.2 : 2.5) 
                : (isMobile ? 1.6 : 1.8),
          ),
          itemCount: statItems.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final delay = index * 0.15;
                final animValue = Curves.easeOutBack.transform(
                  ((_animationController.value - delay) / (1 - delay))
                      .clamp(0.0, 1.0),
                );
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - animValue)),
                  child: Opacity(
                    opacity: animValue,
                    child: child,
                  ),
                );
              },
              child: _buildStatCard(statItems[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final padding = isMobile ? 16.0 : 24.0;
        
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
            boxShadow: [
              BoxShadow(
                color: item.gradient.colors.first.withAlpha(26),
                blurRadius: isMobile ? 12 : 20,
                offset: Offset(0, isMobile ? 6 : 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        gradient: item.gradient,
                        borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
                        boxShadow: [
                          BoxShadow(
                            color: item.gradient.colors.first.withAlpha(102),
                            blurRadius: isMobile ? 8 : 12,
                            offset: Offset(0, isMobile ? 3 : 4),
                          ),
                        ],
                      ),
                      child: Icon(item.icon, color: Colors.white, size: isMobile ? 20 : 24),
                    ),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 10,
                          vertical: isMobile ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: AppTheme.successColor,
                              size: isMobile ? 12 : 14,
                            ),
                            SizedBox(width: isMobile ? 3 : 4),
                            Flexible(
                              child: Text(
                                item.subtitle,
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 9 : 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.successColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  item.value,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 12 : 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final padding = isMobile ? 16.0 : 24.0;
        
        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Flexible(
                child: Text(
                  'Son 7 Gün İstatistikleri',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 20 : 32),
          SizedBox(
            height: isMobile ? 200 : 280,
            child: _chartData != null && _chartData!.recordCreations.isNotEmpty
                ? LineChart(_buildLineChartData())
                : Center(
                    child: Text(
                      'Grafik verisi bulunamadı',
                      style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                    ),
                  ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChartLegend(
                color: AppTheme.primaryColor,
                label: 'Yeni Kullanıcılar',
                isMobile: isMobile,
              ),
              SizedBox(width: isMobile ? 16 : 32),
              _ChartLegend(
                color: AppTheme.successColor,
                label: 'Yeni Kayıtlar',
                isMobile: isMobile,
              ),
            ],
          ),
        ],
      ),
        );
      },
    );
  }

  LineChartData _buildLineChartData() {
    final userSpots = _chartData!.userRegistrations.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.count.toDouble());
    }).toList();

    final recordSpots = _chartData!.recordCreations.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.count.toDouble());
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppTheme.cardColor.withAlpha(77),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < _chartData!.recordCreations.length) {
                final date = _chartData!.recordCreations[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    date.substring(5),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        // Kullanıcı kayıtları
        LineChartBarData(
          spots: userSpots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppTheme.primaryColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              return FlDotCirclePainter(
                radius: 5,
                color: AppTheme.primaryColor,
                strokeWidth: 2,
                strokeColor: AppTheme.surfaceColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withAlpha(77),
                AppTheme.primaryColor.withAlpha(0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Kayıt oluşturma
        LineChartBarData(
          spots: recordSpots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: AppTheme.successColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              return FlDotCirclePainter(
                radius: 5,
                color: AppTheme.successColor,
                strokeWidth: 2,
                strokeColor: AppTheme.surfaceColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.successColor.withAlpha(77),
                AppTheme.successColor.withAlpha(0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => AppTheme.cardColor,
          tooltipRoundedRadius: 12,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final color = spot.bar.color ?? Colors.white;
              final label =
                  spot.barIndex == 0 ? 'Kullanıcı' : 'Kayıt';
              return LineTooltipItem(
                '$label: ${spot.y.toInt()}',
                GoogleFonts.poppins(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final padding = isMobile ? 16.0 : 24.0;
        
        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 8 : 10),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: AppTheme.warningColor,
                      size: isMobile ? 18 : 20,
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Flexible(
                    child: Text(
                      'Son Aktiviteler',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 20),
              if (_activities.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 30 : 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: isMobile ? 40 : 48,
                          color: AppTheme.textMuted.withAlpha(128),
                        ),
                        SizedBox(height: isMobile ? 8 : 12),
                        Text(
                          'Henüz aktivite yok',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textMuted,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activities.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
                    child: Divider(color: AppTheme.cardColor.withAlpha(128)),
                  ),
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    return _buildActivityItem(activity, isMobile);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(Activity activity, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 8 : 10),
          decoration: BoxDecoration(
            color: activity.color.withAlpha(26),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          ),
          child: Icon(activity.icon, color: activity.color, size: isMobile ? 16 : 18),
        ),
        SizedBox(width: isMobile ? 10 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.description,
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 12 : 13,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 1 : 2),
              Text(
                _formatDate(activity.timestamp),
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 10 : 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Az önce';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} dakika önce';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} saat önce';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;

  _StatItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  final bool isMobile;

  const _ChartLegend({
    required this.color,
    required this.label,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMobile ? 10 : 12,
          height: isMobile ? 10 : 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        SizedBox(width: isMobile ? 6 : 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 10 : 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

