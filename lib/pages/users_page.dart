import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../services/admin_api_service.dart';
import '../services/mock_data_service.dart';
import '../models/admin_user.dart';
import '../theme/app_theme.dart';
import '../widgets/safe_opacity.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with SingleTickerProviderStateMixin {
  final AdminApiService _apiService = AdminApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<AdminUser> _users = [];
  List<AdminUser> _filteredUsers = [];
  bool _isRefreshing = false;
  bool _isRealData = false;
  bool _isLoading = false;
  int _sortColumnIndex = 0;
  bool _sortAscending = false;
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
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadMockUsers() {
    final mockResponse = MockDataService.getMockUsers();
    setState(() {
      _users = mockResponse.users;
      _filteredUsers = mockResponse.users;
      _isRealData = false;
    });
    _fadeController.value = 1.0.clamp(0.0, 1.0);
  }

  Future<void> _loadUsers() async {
    // Eğer zaten yükleniyorsa, yeni istek başlatma
    if (_isLoading) return;
    
    if (!mounted) return;
    
    setState(() {
      _isRefreshing = true;
      _isLoading = true;
    });

    try {
      final response = await _apiService.getUsers();
      
      // Sayfa hala açık mı kontrol et
      if (!mounted) return;
      
      final isRealData = response.message != 'Mock veriler gösteriliyor';
      
      if (mounted) {
        setState(() {
          _users = response.users;
          _filteredUsers = response.users;
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
        _loadMockUsers();
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

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          return user.username.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _sort<T>(Comparable<T> Function(AdminUser user) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _filteredUsers.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
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
                  'Kullanıcılar',
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
                    color: AppTheme.primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_filteredUsers.length} kullanıcı',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 12 : 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
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
                    color: AppTheme.primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_filteredUsers.length} kullanıcı',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
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
            'Tüm kayıtlı kullanıcıları görüntüle',
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 14 : 16,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),

          // Arama ve Filtreler
          _buildSearchBar(isMobile),
          SizedBox(height: isMobile ? 16 : 24),

          // Tablo
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontSize: isMobile ? 14 : 16,
              ),
              decoration: InputDecoration(
                hintText: isMobile ? 'Ara...' : 'Kullanıcı adı veya email ile ara...',
                hintStyle: GoogleFonts.poppins(
                  color: AppTheme.textMuted,
                  fontSize: isMobile ? 14 : 16,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textMuted,
                  size: isMobile ? 20 : 24,
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 8 : 12,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withAlpha(128),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            ),
            child: IconButton(
              onPressed: _isRefreshing ? null : _loadUsers,
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
      ),
    );
  }

  Widget _buildContent() {
    if (_users.isEmpty) {
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
              'Kullanıcılar yükleniyor...',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 64,
              color: AppTheme.textMuted.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'Kullanıcı bulunamadı',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        // SafeOpacity kullanarak opacity değerini güvenli hale getir
        return SafeOpacity(
          opacity: _fadeController.value,
          child: isMobile ? _buildMobileUserList() : _buildDataTable(),
        );
      },
    );
  }

  Widget _buildMobileUserList() {
    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildMobileUserCard(user);
      },
    );
  }

  Widget _buildMobileUserCard(AdminUser user) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.go('/users/${user.id}'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor.withAlpha(128),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${user.id}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.article_rounded, size: 12, color: AppTheme.successColor),
                    const SizedBox(width: 4),
                    Text(
                      '${user.recordCount}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share_rounded, size: 12, color: AppTheme.warningColor),
                    const SizedBox(width: 4),
                    Text(
                      '${user.shareCount}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Kayıt: ${dateFormat.format(user.createdAt)}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardColor.withAlpha(128)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable2(
          columnSpacing: 16,
          horizontalMargin: 20,
          minWidth: 800,
          headingRowColor: WidgetStateProperty.all(AppTheme.cardColor.withAlpha(77)),
          headingTextStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
          dataTextStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columns: [
            DataColumn2(
              label: const Text('ID'),
              size: ColumnSize.S,
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort<num>((user) => user.id, columnIndex, ascending),
            ),
            DataColumn2(
              label: const Text('Kullanıcı Adı'),
              size: ColumnSize.L,
              onSort: (columnIndex, ascending) =>
                  _sort<String>((user) => user.username, columnIndex, ascending),
            ),
            DataColumn2(
              label: const Text('Email'),
              size: ColumnSize.L,
              onSort: (columnIndex, ascending) =>
                  _sort<String>((user) => user.email, columnIndex, ascending),
            ),
            DataColumn2(
              label: const Text('Kayıt'),
              size: ColumnSize.S,
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort<num>((user) => user.recordCount, columnIndex, ascending),
            ),
            DataColumn2(
              label: const Text('Paylaşım'),
              size: ColumnSize.S,
              numeric: true,
              onSort: (columnIndex, ascending) =>
                  _sort<num>((user) => user.shareCount, columnIndex, ascending),
            ),
            DataColumn2(
              label: const Text('Kayıt Tarihi'),
              size: ColumnSize.M,
              onSort: (columnIndex, ascending) =>
                  _sort<DateTime>((user) => user.createdAt, columnIndex, ascending),
            ),
            const DataColumn2(
              label: Text('İşlem'),
              size: ColumnSize.S,
            ),
          ],
          rows: _filteredUsers.map((user) => _buildUserRow(user)).toList(),
        ),
      ),
    );
  }

  DataRow _buildUserRow(AdminUser user) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return DataRow(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withAlpha(128),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${user.id}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user.username,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            user.email,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(color: AppTheme.textSecondary),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${user.recordCount}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: AppTheme.successColor,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${user.shareCount}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: AppTheme.warningColor,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            dateFormat.format(user.createdAt),
            style: GoogleFonts.poppins(color: AppTheme.textSecondary),
          ),
        ),
        DataCell(
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () => context.go('/users/${user.id}'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              color: AppTheme.primaryColor,
              tooltip: 'Detayları Gör',
            ),
          ),
        ),
      ],
    );
  }
}

