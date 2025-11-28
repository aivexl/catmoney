import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations('en');
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Helper method that accepts language code directly
  static AppLocalizations fromCode(String languageCode) {
    return AppLocalizations(languageCode);
  }

  // Translation maps for all languages
  static const Map<String, Map<String, String>> _localizedValues = {
    // Navigation & Main Screens
    'home': {
      'en': 'Home',
      'id': 'Beranda',
      'es': 'Inicio',
      'fr': 'Accueil',
      'de': 'Startseite',
      'ja': 'ホーム',
      'zh': '主页',
      'ko': '홈',
      'pt': 'Início',
      'ar': 'الرئيسية',
    },
    'transactions': {
      'en': 'Transactions',
      'id': 'Transaksi',
      'es': 'Transacciones',
      'fr': 'Transactions',
      'de': 'Transaktionen',
      'ja': '取引',
      'zh': '交易',
      'ko': '거래',
      'pt': 'Transações',
      'ar': 'المعاملات',
    },
    'analytics': {
      'en': 'Analytics',
      'id': 'Analitik',
      'es': 'Análisis',
      'fr': 'Analytique',
      'de': 'Analytik',
      'ja': '分析',
      'zh': '分析',
      'ko': '분석',
      'pt': 'Análise',
      'ar': 'التحليلات',
    },
    'wallets': {
      'en': 'Wallets',
      'id': 'Dompet',
      'es': 'Carteras',
      'fr': 'Portefeuilles',
      'de': 'Geldbörsen',
      'ja': 'ウォレット',
      'zh': '钱包',
      'ko': '지갑',
      'pt': 'Carteiras',
      'ar': 'المحافظ',
    },
    'more': {
      'en': 'More',
      'id': 'Lainnya',
      'es': 'Más',
      'fr': 'Plus',
      'de': 'Mehr',
      'ja': 'その他',
      'zh': '更多',
      'ko': '더보기',
      'pt': 'Mais',
      'ar': 'المزيد',
    },
    'settings': {
      'en': 'Settings',
      'id': 'Pengaturan',
      'es': 'Configuración',
      'fr': 'Paramètres',
      'de': 'Einstellungen',
      'ja': '設定',
      'zh': '设置',
      'ko': '설정',
      'pt': 'Configurações',
      'ar': 'الإعدادات',
    },
    'update': {
      'en': 'Update',
      'id': 'Perbarui',
      'es': 'Actualizar',
      'fr': 'Mettre à jour',
      'de': 'Aktualisieren',
      'ja': '更新',
      'zh': '更新',
      'ko': '업데이트',
      'pt': 'Atualizar',
      'ar': 'تحديث',
    },
    'theme': {
      'en': 'Theme',
      'id': 'Tema',
      'es': 'Tema',
      'fr': 'Thème',
      'de': 'Design',
      'ja': 'テーマ',
      'zh': '主题',
      'ko': '테마',
      'pt': 'Tema',
      'ar': 'المظهر',
    },
    'autoDarkMode': {
      'en': 'Auto Dark Mode',
      'id': 'Mode Gelap Otomatis',
      'es': 'Modo Oscuro Automático',
      'fr': 'Mode Sombre Automatique',
      'de': 'Automatischer Dunkelmodus',
      'ja': '自動ダークモード',
      'zh': '自动深色模式',
      'ko': '자동 다크 모드',
      'pt': 'Modo Escuro Automático',
      'ar': 'الوضع الداكن التلقائي',
    },
    'lightMode': {
      'en': 'Light Mode',
      'id': 'Mode Terang',
      'es': 'Modo Claro',
      'fr': 'Mode Clair',
      'de': 'Heller Modus',
      'ja': 'ライトモード',
      'zh': '浅色模式',
      'ko': '라이트 모드',
      'pt': 'Modo Claro',
      'ar': 'الوضع الفاتح',
    },
    'darkMode': {
      'en': 'Dark Mode',
      'id': 'Mode Gelap',
      'es': 'Modo Oscuro',
      'fr': 'Mode Sombre',
      'de': 'Dunkler Modus',
      'ja': 'ダークモード',
      'zh': '深色模式',
      'ko': '다크 모드',
      'pt': 'Modo Escuro',
      'ar': 'الوضع الداكن',
    },
    'sunnyYellow': {
      'en': 'Sunny Yellow',
      'id': 'Kuning Cerah',
      'es': 'Amarillo Soleado',
      'fr': 'Jaune Ensoleillé',
      'de': 'Sonniges Gelb',
      'ja': 'サニーイエロー',
      'zh': '阳光黄',
      'ko': '써니 옐로우',
      'pt': 'Amarelo Ensolarado',
      'ar': 'أصفر مشمس',
    },
    'oceanBlue': {
      'en': 'Ocean Blue',
      'id': 'Biru Laut',
      'es': 'Azul Océano',
      'fr': 'Bleu Océan',
      'de': 'Ozeanblau',
      'ja': 'オーシャンブルー',
      'zh': '海洋蓝',
      'ko': '오션 블루',
      'pt': 'Azul Oceano',
      'ar': 'أزرق المحيط',
    },
    'mintFresh': {
      'en': 'Mint Fresh',
      'id': 'Mint Segar',
      'es': 'Menta Fresca',
      'fr': 'Menthe Fraîche',
      'de': 'Frische Minze',
      'ja': 'ミントフレッシュ',
      'zh': '薄荷清新',
      'ko': '민트 프레시',
      'pt': 'Menta Fresca',
      'ar': 'نعناع منعش',
    },
    'sunsetOrange': {
      'en': 'Sunset Orange',
      'id': 'Oranye Senja',
      'es': 'Naranja Atardecer',
      'fr': 'Orange Coucher de Soleil',
      'de': 'Sonnenuntergang Orange',
      'ja': 'サンセットオレンジ',
      'zh': '日落橙',
      'ko': '선셋 오렌지',
      'pt': 'Laranja Pôr do Sol',
      'ar': 'برتقالي الغروب',
    },
    'lavenderDream': {
      'en': 'Lavender Dream',
      'id': 'Lavender Impian',
      'es': 'Sueño Lavanda',
      'fr': 'Rêve Lavande',
      'de': 'Lavendeltraum',
      'ja': 'ラベンダードリーム',
      'zh': '薰衣草梦',
      'ko': '라벤더 드림',
      'pt': 'Sonho Lavanda',
      'ar': 'حلم اللافندر',
    },
    'selectTheme': {
      'en': 'Select Theme',
      'id': 'Pilih Tema',
      'es': 'Seleccionar Tema',
      'fr': 'Sélectionner le Thème',
      'de': 'Design Auswählen',
      'ja': 'テーマを選択',
      'zh': '选择主题',
      'ko': '테마 선택',
      'pt': 'Selecionar Tema',
      'ar': 'اختر المظهر',
    },

    // Transaction Types
    'income': {
      'en': 'Income',
      'id': 'Pemasukan',
      'es': 'Ingreso',
      'fr': 'Revenu',
      'de': 'Einkommen',
      'ja': '収入',
      'zh': '收入',
      'ko': '수입',
      'pt': 'Receita',
      'ar': 'الدخل',
    },
    'expense': {
      'en': 'Expense',
      'id': 'Pengeluaran',
      'es': 'Gasto',
      'fr': 'Dépense',
      'de': 'Ausgabe',
      'ja': '支出',
      'zh': '支出',
      'ko': '지출',
      'pt': 'Despesa',
      'ar': 'المصروفات',
    },
    'transfer': {
      'en': 'Transfer',
      'id': 'Transfer',
      'es': 'Transferencia',
      'fr': 'Transfert',
      'de': 'Überweisung',
      'ja': '振替',
      'zh': '转账',
      'ko': '이체',
      'pt': 'Transferência',
      'ar': 'تحويل',
    },

    // Settings Menu
    'currency': {
      'en': 'Currency',
      'id': 'Mata Uang',
      'es': 'Moneda',
      'fr': 'Devise',
      'de': 'Währung',
      'ja': '通貨',
      'zh': '货币',
      'ko': '통화',
      'pt': 'Moeda',
      'ar': 'العملة',
    },
    'language': {
      'en': 'Language',
      'id': 'Bahasa',
      'es': 'Idioma',
      'fr': 'Langue',
      'de': 'Sprache',
      'ja': '言語',
      'zh': '语言',
      'ko': '언어',
      'pt': 'Idioma',
      'ar': 'اللغة',
    },
    'categories': {
      'en': 'Categories',
      'id': 'Kategori',
      'es': 'Categorías',
      'fr': 'Catégories',
      'de': 'Kategorien',
      'ja': 'カテゴリー',
      'zh': '类别',
      'ko': '카테고리',
      'pt': 'Categorias',
      'ar': 'الفئات',
    },
    'reports': {
      'en': 'Reports',
      'id': 'Laporan',
      'es': 'Informes',
      'fr': 'Rapports',
      'de': 'Berichte',
      'ja': 'レポート',
      'zh': '报告',
      'ko': '보고서',
      'pt': 'Relatórios',
      'ar': 'التقارير',
    },
    'dataManagement': {
      'en': 'Data Management',
      'id': 'Manajemen Data',
      'es': 'Gestión de Datos',
      'fr': 'Gestion des Données',
      'de': 'Datenverwaltung',
      'ja': 'データ管理',
      'zh': '数据管理',
      'ko': '데이터 관리',
      'pt': 'Gerenciamento de Dados',
      'ar': 'إدارة البيانات',
    },
    'about': {
      'en': 'About',
      'id': 'Tentang',
      'es': 'Acerca de',
      'fr': 'À propos',
      'de': 'Über',
      'ja': 'について',
      'zh': '关于',
      'ko': '정보',
      'pt': 'Sobre',
      'ar': 'حول',
    },

    // Subtitles
    'manageCategories': {
      'en': 'Manage transaction categories',
      'id': 'Kelola kategori transaksi',
      'es': 'Gestionar categorías de transacciones',
      'fr': 'Gérer les catégories de transactions',
      'de': 'Transaktionskategorien verwalten',
      'ja': '取引カテゴリーを管理',
      'zh': '管理交易类别',
      'ko': '거래 카테고리 관리',
      'pt': 'Gerenciar categorias de transações',
      'ar': 'إدارة فئات المعاملات',
    },
    'viewReports': {
      'en': 'View financial reports',
      'id': 'Lihat laporan keuangan',
      'es': 'Ver informes financieros',
      'fr': 'Voir les rapports financiers',
      'de': 'Finanzberichte anzeigen',
      'ja': '財務レポートを表示',
      'zh': '查看财务报告',
      'ko': '재무 보고서 보기',
      'pt': 'Ver relatórios financeiros',
      'ar': 'عرض التقارير المالية',
    },
    'backupRestoreExport': {
      'en': 'Backup, restore, export/import',
      'id': 'Cadangkan, pulihkan, ekspor/impor',
      'es': 'Copia de seguridad, restaurar, exportar/importar',
      'fr': 'Sauvegarde, restauration, export/import',
      'de': 'Sichern, wiederherstellen, exportieren/importieren',
      'ja': 'バックアップ、復元、エクスポート/インポート',
      'zh': '备份、恢复、导出/导入',
      'ko': '백업, 복원, 내보내기/가져오기',
      'pt': 'Backup, restaurar, exportar/importar',
      'ar': 'النسخ الاحتياطي والاستعادة والتصدير/الاستيراد',
    },

    // Buttons & Actions
    'add': {
      'en': 'Add',
      'id': 'Tambah',
      'es': 'Agregar',
      'fr': 'Ajouter',
      'de': 'Hinzufügen',
      'ja': '追加',
      'zh': '添加',
      'ko': '추가',
      'pt': 'Adicionar',
      'ar': 'إضافة',
    },
    'save': {
      'en': 'Save',
      'id': 'Simpan',
      'es': 'Guardar',
      'fr': 'Enregistrer',
      'de': 'Speichern',
      'ja': '保存',
      'zh': '保存',
      'ko': '저장',
      'pt': 'Salvar',
      'ar': 'حفظ',
    },
    'cancel': {
      'en': 'Cancel',
      'id': 'Batal',
      'es': 'Cancelar',
      'fr': 'Annuler',
      'de': 'Abbrechen',
      'ja': 'キャンセル',
      'zh': '取消',
      'ko': '취소',
      'pt': 'Cancelar',
      'ar': 'إلغاء',
    },
    'delete': {
      'en': 'Delete',
      'id': 'Hapus',
      'es': 'Eliminar',
      'fr': 'Supprimer',
      'de': 'Löschen',
      'ja': '削除',
      'zh': '删除',
      'ko': '삭제',
      'pt': 'Excluir',
      'ar': 'حذف',
    },
    'edit': {
      'en': 'Edit',
      'id': 'Edit',
      'es': 'Editar',
      'fr': 'Modifier',
      'de': 'Bearbeiten',
      'ja': '編集',
      'zh': '编辑',
      'ko': '편집',
      'pt': 'Editar',
      'ar': 'تعديل',
    },
    'close': {
      'en': 'Close',
      'id': 'Tutup',
      'es': 'Cerrar',
      'fr': 'Fermer',
      'de': 'Schließen',
      'ja': '閉じる',
      'zh': '关闭',
      'ko': '닫기',
      'pt': 'Fechar',
      'ar': 'إغلاق',
    },

    // Transaction Form
    'amount': {
      'en': 'Amount',
      'id': 'Jumlah',
      'es': 'Cantidad',
      'fr': 'Montant',
      'de': 'Betrag',
      'ja': '金額',
      'zh': '金额',
      'ko': '금액',
      'pt': 'Quantia',
      'ar': 'المبلغ',
    },
    'category': {
      'en': 'Category',
      'id': 'Kategori',
      'es': 'Categoría',
      'fr': 'Catégorie',
      'de': 'Kategorie',
      'ja': 'カテゴリー',
      'zh': '类别',
      'ko': '카테고리',
      'pt': 'Categoria',
      'ar': 'الفئة',
    },
    'date': {
      'en': 'Date',
      'id': 'Tanggal',
      'es': 'Fecha',
      'fr': 'Date',
      'de': 'Datum',
      'ja': '日付',
      'zh': '日期',
      'ko': '날짜',
      'pt': 'Data',
      'ar': 'التاريخ',
    },
    'note': {
      'en': 'Note',
      'id': 'Catatan',
      'es': 'Nota',
      'fr': 'Note',
      'de': 'Notiz',
      'ja': 'メモ',
      'zh': '备注',
      'ko': '메모',
      'pt': 'Nota',
      'ar': 'ملاحظة',
    },
    'wallet': {
      'en': 'Wallet',
      'id': 'Dompet',
      'es': 'Cartera',
      'fr': 'Portefeuille',
      'de': 'Geldbörse',
      'ja': 'ウォレット',
      'zh': '钱包',
      'ko': '지갑',
      'pt': 'Carteira',
      'ar': 'المحفظة',
    },

    // Summary & Stats
    'totalIncome': {
      'en': 'Total Income',
      'id': 'Total Pemasukan',
      'es': 'Ingreso Total',
      'fr': 'Revenu Total',
      'de': 'Gesamteinkommen',
      'ja': '総収入',
      'zh': '总收入',
      'ko': '총 수입',
      'pt': 'Receita Total',
      'ar': 'إجمالي الدخل',
    },
    'totalExpense': {
      'en': 'Total Expense',
      'id': 'Total Pengeluaran',
      'es': 'Gasto Total',
      'fr': 'Dépense Totale',
      'de': 'Gesamtausgaben',
      'ja': '総支出',
      'zh': '总支出',
      'ko': '총 지출',
      'pt': 'Despesa Total',
      'ar': 'إجمالي المصروفات',
    },
    'balance': {
      'en': 'Balance',
      'id': 'Saldo',
      'es': 'Saldo',
      'fr': 'Solde',
      'de': 'Saldo',
      'ja': '残高',
      'zh': '余额',
      'ko': '잔액',
      'pt': 'Saldo',
      'ar': 'الرصيد',
    },

    // Time Periods
    'today': {
      'en': 'Today',
      'id': 'Hari Ini',
      'es': 'Hoy',
      'fr': "Aujourd'hui",
      'de': 'Heute',
      'ja': '今日',
      'zh': '今天',
      'ko': '오늘',
      'pt': 'Hoje',
      'ar': 'اليوم',
    },
    'thisWeek': {
      'en': 'This Week',
      'id': 'Minggu Ini',
      'es': 'Esta Semana',
      'fr': 'Cette Semaine',
      'de': 'Diese Woche',
      'ja': '今週',
      'zh': '本周',
      'ko': '이번 주',
      'pt': 'Esta Semana',
      'ar': 'هذا الأسبوع',
    },
    'thisMonth': {
      'en': 'This Month',
      'id': 'Bulan Ini',
      'es': 'Este Mes',
      'fr': 'Ce Mois',
      'de': 'Dieser Monat',
      'ja': '今月',
      'zh': '本月',
      'ko': '이번 달',
      'pt': 'Este Mês',
      'ar': 'هذا الشهر',
    },
    'thisYear': {
      'en': 'This Year',
      'id': 'Tahun Ini',
      'es': 'Este Año',
      'fr': 'Cette Année',
      'de': 'Dieses Jahr',
      'ja': '今年',
      'zh': '今年',
      'ko': '올해',
      'pt': 'Este Ano',
      'ar': 'هذا العام',
    },

    // Messages
    'noTransactions': {
      'en': 'No transactions yet',
      'id': 'Belum ada transaksi',
      'es': 'Aún no hay transacciones',
      'fr': 'Aucune transaction pour le moment',
      'de': 'Noch keine Transaktionen',
      'ja': 'まだ取引がありません',
      'zh': '暂无交易',
      'ko': '아직 거래가 없습니다',
      'pt': 'Ainda não há transações',
      'ar': 'لا توجد معاملات بعد',
    },
    'addFirstTransaction': {
      'en': 'Add your first transaction',
      'id': 'Tambahkan transaksi pertama Anda',
      'es': 'Agrega tu primera transacción',
      'fr': 'Ajoutez votre première transaction',
      'de': 'Fügen Sie Ihre erste Transaktion hinzu',
      'ja': '最初の取引を追加',
      'zh': '添加您的第一笔交易',
      'ko': '첫 거래 추가',
      'pt': 'Adicione sua primeira transação',
      'ar': 'أضف معاملتك الأولى',
    },

    // App Info
    'appName': {
      'en': 'Cat Money Manager',
      'id': 'Cat Money Manager',
      'es': 'Cat Money Manager',
      'fr': 'Cat Money Manager',
      'de': 'Cat Money Manager',
      'ja': 'Cat Money Manager',
      'zh': 'Cat Money Manager',
      'ko': 'Cat Money Manager',
      'pt': 'Cat Money Manager',
      'ar': 'Cat Money Manager',
    },
    'appDescription': {
      'en': 'Cute money management app with pastel theme and cats.',
      'id': 'Aplikasi manajemen keuangan lucu dengan tema pastel dan kucing.',
      'es': 'Linda aplicación de gestión de dinero con tema pastel y gatos.',
      'fr':
          'Application mignonne de gestion d\'argent avec thème pastel et chats.',
      'de': 'Süße Geldverwaltungs-App mit Pastellthema und Katzen.',
      'ja': 'パステルテーマと猫のかわいいお金管理アプリ。',
      'zh': '可爱的粉彩主题和猫咪的资金管理应用。',
      'ko': '파스텔 테마와 고양이가 있는 귀여운 자금 관리 앱.',
      'pt':
          'Aplicativo fofo de gerenciamento de dinheiro com tema pastel e gatos.',
      'ar': 'تطبيق إدارة أموال لطيف بموضوع الباستيل والقطط.',
    },

    // Feature Coming Soon
    'featureComingSoon': {
      'en': 'feature coming soon! 🐱',
      'id': 'fitur segera hadir! 🐱',
      'es': '¡función próximamente! 🐱',
      'fr': 'fonctionnalité bientôt disponible! 🐱',
      'de': 'Funktion kommt bald! 🐱',
      'ja': '機能は近日公開！🐱',
      'zh': '功能即将推出！🐱',
      'ko': '기능 출시 예정! 🐱',
      'pt': 'recurso em breve! 🐱',
      'ar': 'الميزة قريبًا! 🐱',
    },
    'categoryFeatureComingSoon': {
      'en': 'Category feature coming soon! 🐱',
      'id': 'Fitur kategori segera hadir! 🐱',
      'es': '¡Función de categoría próximamente! 🐱',
      'fr': 'Fonctionnalité de catégorie bientôt disponible! 🐱',
      'de': 'Kategoriefunktion kommt bald! 🐱',
      'ja': 'カテゴリー機能は近日公開！🐱',
      'zh': '类别功能即将推出！🐱',
      'ko': '카테고리 기능 출시 예정! 🐱',
      'pt': 'Recurso de categoria em breve! 🐱',
      'ar': 'ميزة الفئة قريبًا! 🐱',
    },
    'reportsFeatureComingSoon': {
      'en': 'Reports feature coming soon! 🐱',
      'id': 'Fitur laporan segera hadir! 🐱',
      'es': '¡Función de informes próximamente! 🐱',
      'fr': 'Fonctionnalité de rapports bientôt disponible! 🐱',
      'de': 'Berichtsfunktion kommt bald! 🐱',
      'ja': 'レポート機能は近日公開！🐱',
      'zh': '报告功能即将推出！🐱',
      'ko': '보고서 기능 출시 예정! 🐱',
      'pt': 'Recurso de relatórios em breve! 🐱',
      'ar': 'ميزة التقارير قريبًا! 🐱',
    },

    // Home Screen Specific
    'totalBalance': {
      'en': 'Total Balance',
      'id': 'Total Saldo',
      'es': 'Saldo Total',
      'fr': 'Solde Total',
      'de': 'Gesamtsaldo',
      'ja': '総残高',
      'zh': '总余额',
      'ko': '총 잔액',
      'pt': 'Saldo Total',
      'ar': 'الرصيد الإجمالي',
    },
    'totalExpenses': {
      'en': 'Total Expenses',
      'id': 'Total Pengeluaran',
      'es': 'Gastos Totales',
      'fr': 'Dépenses Totales',
      'de': 'Gesamtausgaben',
      'ja': '総支出',
      'zh': '总支出',
      'ko': '총 지출',
      'pt': 'Despesas Totais',
      'ar': 'إجمالي المصروفات',
    },
    'wishlist': {
      'en': 'Wishlist',
      'id': 'Wishlist',
      'es': 'Lista de Deseos',
      'fr': 'Liste de Souhaits',
      'de': 'Wunschliste',
      'ja': 'ウィッシュリスト',
      'zh': '愿望清单',
      'ko': '위시리스트',
      'pt': 'Lista de Desejos',
      'ar': 'قائمة الأمنيات',
    },
    'watchlist': {
      'en': 'Watchlist',
      'id': 'Watchlist',
      'es': 'Lista de Seguimiento',
      'fr': 'Liste de Surveillance',
      'de': 'Beobachtungsliste',
      'ja': 'ウォッチリスト',
      'zh': '关注列表',
      'ko': '관심목록',
      'pt': 'Lista de Observação',
      'ar': 'قائمة المراقبة',
    },
    'bills': {
      'en': 'Bills',
      'id': 'Tagihan',
      'es': 'Facturas',
      'fr': 'Factures',
      'de': 'Rechnungen',
      'ja': '請求書',
      'zh': '账单',
      'ko': '청구서',
      'pt': 'Contas',
      'ar': 'الفواتير',
    },
    'welcome': {
      'en': 'Welcome',
      'id': 'Selamat Datang',
      'es': 'Bienvenido',
      'fr': 'Bienvenue',
      'de': 'Willkommen',
      'ja': 'ようこそ',
      'zh': '欢迎',
      'ko': '환영합니다',
      'pt': 'Bem-vindo',
      'ar': 'مرحبا',
    },
    'startManaging': {
      'en': 'Start managing your finances by adding your first transaction',
      'id': 'Mulai kelola keuangan Anda dengan menambahkan transaksi pertama',
      'es':
          'Comienza a gestionar tus finanzas agregando tu primera transacción',
      'fr':
          'Commencez à gérer vos finances en ajoutant votre première transaction',
      'de':
          'Beginnen Sie mit der Verwaltung Ihrer Finanzen, indem Sie Ihre erste Transaktion hinzufügen',
      'ja': '最初の取引を追加して財務管理を始めましょう',
      'zh': '通过添加您的第一笔交易开始管理您的财务',
      'ko': '첫 거래를 추가하여 재무 관리를 시작하세요',
      'pt':
          'Comece a gerenciar suas finanças adicionando sua primeira transação',
      'ar': 'ابدأ في إدارة أموالك عن طريق إضافة معاملتك الأولى',
    },

    // Transactions Screen
    'calendar': {
      'en': 'Calendar',
      'id': 'Kalender',
      'es': 'Calendario',
      'fr': 'Calendrier',
      'de': 'Kalender',
      'ja': 'カレンダー',
      'zh': '日历',
      'ko': '달력',
      'pt': 'Calendário',
      'ar': 'التقويم',
    },

    'searchTransactions': {
      'en': 'Search transactions...',
      'id': 'Cari transaksi...',
      'es': 'Buscar transacciones...',
      'fr': 'Rechercher des transactions...',
      'de': 'Transaktionen suchen...',
      'ja': '取引を検索...',
      'zh': '搜索交易...',
      'ko': '거래 검색...',
      'pt': 'Pesquisar transações...',
      'ar': 'البحث في المعاملات...',
    },

    // Bills Screen
    'manageBills': {
      'en': 'Manage your bills & installments',
      'id': 'Kelola tagihan & cicilan Anda',
      'es': 'Administra tus facturas y cuotas',
      'fr': 'Gérez vos factures et versements',
      'de': 'Verwalten Sie Ihre Rechnungen und Raten',
      'ja': '請求書と分割払いを管理',
      'zh': '管理您的账单和分期付款',
      'ko': '청구서 및 할부 관리',
      'pt': 'Gerencie suas contas e parcelas',
      'ar': 'إدارة الفواتير والأقساط الخاصة بك',
    },
    'noBills': {
      'en': 'No bills yet',
      'id': 'Belum ada tagihan',
      'es': 'Aún no hay facturas',
      'fr': 'Aucune facture pour le moment',
      'de': 'Noch keine Rechnungen',
      'ja': 'まだ請求書はありません',
      'zh': '暂无账单',
      'ko': '아직 청구서가 없습니다',
      'pt': 'Ainda não há contas',
      'ar': 'لا توجد فواتير بعد',
    },
    'addBillsReminder': {
      'en': 'Add bills for automatic reminders!',
      'id': 'Tambahkan tagihan untuk pengingat otomatis!',
      'es': '¡Agrega facturas para recordatorios automáticos!',
      'fr': 'Ajoutez des factures pour des rappels automatiques!',
      'de': 'Fügen Sie Rechnungen für automatische Erinnerungen hinzu!',
      'ja': '自動リマインダーのために請求書を追加！',
      'zh': '添加账单以获取自动提醒！',
      'ko': '자동 알림을 위해 청구서를 추가하세요!',
      'pt': 'Adicione contas para lembretes automáticos!',
      'ar': 'أضف فواتير للتذكيرات التلقائية!',
    },
    'unpaid': {
      'en': 'Unpaid',
      'id': 'Belum Dibayar',
      'es': 'No Pagado',
      'fr': 'Impayé',
      'de': 'Unbezahlt',
      'ja': '未払い',
      'zh': '未付',
      'ko': '미납',
      'pt': 'Não Pago',
      'ar': 'غير مدفوع',
    },
    'paid': {
      'en': 'Paid',
      'id': 'Dibayar',
      'es': 'Pagado',
      'fr': 'Payé',
      'de': 'Bezahlt',
      'ja': '支払い済み',
      'zh': '已付',
      'ko': '납부됨',
      'pt': 'Pago',
      'ar': 'مدفوع',
    },
    'addBill': {
      'en': 'Add Bill',
      'id': 'Tambah Tagihan',
      'es': 'Agregar Factura',
      'fr': 'Ajouter une Facture',
      'de': 'Rechnung Hinzufügen',
      'ja': '請求書を追加',
      'zh': '添加账单',
      'ko': '청구서 추가',
      'pt': 'Adicionar Conta',
      'ar': 'إضافة فاتورة',
    },
    'billName': {
      'en': 'Bill Name',
      'id': 'Nama Tagihan',
      'es': 'Nombre de la Factura',
      'fr': 'Nom de la Facture',
      'de': 'Rechnungsname',
      'ja': '請求書名',
      'zh': '账单名称',
      'ko': '청구서 이름',
      'pt': 'Nome da Conta',
      'ar': 'اسم الفاتورة',
    },
    'dueDate': {
      'en': 'Due Date',
      'id': 'Jatuh Tempo',
      'es': 'Fecha de Vencimiento',
      'fr': 'Date d\'Échéance',
      'de': 'Fälligkeitsdatum',
      'ja': '期日',
      'zh': '截止日期',
      'ko': '마감일',
      'pt': 'Data de Vencimento',
      'ar': 'تاريخ الاستحقاق',
    },
    'recurring': {
      'en': 'Recurring',
      'id': 'Berulang',
      'es': 'Recurrente',
      'fr': 'Récurrent',
      'de': 'Wiederkehrend',
      'ja': '繰り返し',
      'zh': '循环',
      'ko': '반복',
      'pt': 'Recorrente',
      'ar': 'متكرر',
    },
    'repeatEveryMonths': {
      'en': 'Repeat every (months)',
      'id': 'Ulangi setiap (bulan)',
      'es': 'Repetir cada (meses)',
      'fr': 'Répéter tous les (mois)',
      'de': 'Wiederholen alle (Monate)',
      'ja': '（月）ごとに繰り返す',
      'zh': '每（月）重复',
      'ko': '반복 주기 (월)',
      'pt': 'Repetir a cada (meses)',
      'ar': 'تكرار كل (أشهر)',
    },
    'markAsPaid': {
      'en': 'Mark as Paid',
      'id': 'Tandai Sudah Dibayar',
      'es': 'Marcar como Pagado',
      'fr': 'Marquer comme Payé',
      'de': 'Als Bezahlt Markieren',
      'ja': '支払い済みとしてマーク',
      'zh': '标记为已付',
      'ko': '납부 완료로 표시',
      'pt': 'Marcar como Pago',
      'ar': 'تحديد كمدفوع',
    },
    'status': {
      'en': 'Status',
      'id': 'Status',
      'es': 'Estado',
      'fr': 'Statut',
      'de': 'Status',
      'ja': 'ステータス',
      'zh': '状态',
      'ko': '상태',
      'pt': 'Status',
      'ar': 'الحالة',
    },
    'billMarkedPaid': {
      'en': 'Bill marked as paid',
      'id': 'Tagihan ditandai sudah dibayar',
      'es': 'Factura marcada como pagada',
      'fr': 'Facture marquée comme payée',
      'de': 'Rechnung als bezahlt markiert',
      'ja': '請求書を支払い済みとしてマークしました',
      'zh': '账单已标记为已付',
      'ko': '청구서가 납부 완료로 표시되었습니다',
      'pt': 'Conta marcada como paga',
      'ar': 'تم تحديد الفاتورة كمدفوعة',
    },
    'billDeleted': {
      'en': 'Bill deleted',
      'id': 'Tagihan dihapus',
      'es': 'Factura eliminada',
      'fr': 'Facture supprimée',
      'de': 'Rechnung gelöscht',
      'ja': '請求書を削除しました',
      'zh': '账单已删除',
      'ko': '청구서가 삭제되었습니다',
      'pt': 'Conta excluída',
      'ar': 'تم حذف الفاتورة',
    },

    // Spend Tracker
    'spendTracker': {
      'en': 'Spend Tracker',
      'id': 'Pelacak Pengeluaran',
      'es': 'Rastreador de Gastos',
      'fr': 'Suivi des Dépenses',
      'de': 'Ausgaben-Tracker',
      'ja': '支出トラッカー',
      'zh': '支出追踪',
      'ko': '지출 추적',
      'pt': 'Rastreador de Gastos',
      'ar': 'متتبع الإنفاق',
    },
    'manageBudgets': {
      'en': 'Manage your spending budget',
      'id': 'Kelola anggaran pengeluaran Anda',
      'es': 'Administra tu presupuesto de gastos',
      'fr': 'Gérez votre budget de dépenses',
      'de': 'Verwalten Sie Ihr Ausgabenbudget',
      'ja': '支出予算を管理',
      'zh': '管理您的支出预算',
      'ko': '지출 예산 관리',
      'pt': 'Gerencie seu orçamento de gastos',
      'ar': 'إدارة ميزانية الإنفاق الخاصة بك',
    },
    'noBudgets': {
      'en': 'No budgets yet',
      'id': 'Belum ada anggaran',
      'es': 'Aún no hay presupuestos',
      'fr': 'Aucun budget pour le moment',
      'de': 'Noch keine Budgets',
      'ja': 'まだ予算はありません',
      'zh': '暂无预算',
      'ko': '아직 예산이 없습니다',
      'pt': 'Ainda não há orçamentos',
      'ar': 'لا توجد ميزانيات بعد',
    },
    'createBudget': {
      'en': 'Create a budget to control your spending!',
      'id': 'Buat anggaran untuk mengontrol pengeluaran Anda!',
      'es': '¡Crea un presupuesto para controlar tus gastos!',
      'fr': 'Créez un budget pour contrôler vos dépenses!',
      'de': 'Erstellen Sie ein Budget, um Ihre Ausgaben zu kontrollieren!',
      'ja': '支出を管理するために予算を作成しましょう！',
      'zh': '创建预算以控制您的支出！',
      'ko': '지출을 관리하기 위해 예산을 만드세요!',
      'pt': 'Crie um orçamento para controlar seus gastos!',
      'ar': 'أنشئ ميزانية للتحكم في إنفاقك!',
    },
    'active': {
      'en': 'Active',
      'id': 'Aktif',
      'es': 'Activo',
      'fr': 'Actif',
      'de': 'Aktiv',
      'ja': 'アクティブ',
      'zh': '活跃',
      'ko': '활성',
      'pt': 'Ativo',
      'ar': 'نشط',
    },
    'inactive': {
      'en': 'Inactive',
      'id': 'Tidak Aktif',
      'es': 'Inactivo',
      'fr': 'Inactif',
      'de': 'Inaktiv',
      'ja': '非アクティブ',
      'zh': '非活跃',
      'ko': '비활성',
      'pt': 'Inativo',
      'ar': 'غير نشط',
    },
    'overBudget': {
      'en': 'Over budget',
      'id': 'Melebihi anggaran',
      'es': 'Sobre el presupuesto',
      'fr': 'Budget dépassé',
      'de': 'Über dem Budget',
      'ja': '予算超過',
      'zh': '超出预算',
      'ko': '예산 초과',
      'pt': 'Acima do orçamento',
      'ar': 'تجاوز الميزانية',
    },
    'limit': {
      'en': 'Limit',
      'id': 'Batas',
      'es': 'Límite',
      'fr': 'Limite',
      'de': 'Limit',
      'ja': '制限',
      'zh': '限额',
      'ko': '한도',
      'pt': 'Limite',
      'ar': 'الحد',
    },
    'spent': {
      'en': 'Spent',
      'id': 'Terpakai',
      'es': 'Gastado',
      'fr': 'Dépensé',
      'de': 'Ausgegeben',
      'ja': '使用済み',
      'zh': '已用',
      'ko': '지출됨',
      'pt': 'Gasto',
      'ar': 'أنفق',
    },
    'remaining': {
      'en': 'Remaining',
      'id': 'Sisa',
      'es': 'Restante',
      'fr': 'Restant',
      'de': 'Verbleibend',
      'ja': '残り',
      'zh': '剩余',
      'ko': '남음',
      'pt': 'Restante',
      'ar': 'المتبقي',
    },
    'percentage': {
      'en': 'Percentage',
      'id': 'Persentase',
      'es': 'Porcentaje',
      'fr': 'Pourcentage',
      'de': 'Prozentsatz',
      'ja': 'パーセンテージ',
      'zh': '百分比',
      'ko': '백분율',
      'pt': 'Porcentagem',
      'ar': 'نسبة مئوية',
    },
    'customColor': {
      'en': 'Custom Color',
      'id': 'Warna Kustom',
      'es': 'Color Personalizado',
      'fr': 'Couleur Personnalisée',
      'de': 'Benutzerdefinierte Farbe',
      'ja': 'カスタムカラー',
      'zh': '自定义颜色',
      'ko': '사용자 지정 색상',
      'pt': 'Cor Personalizada',
      'ar': 'لون مخصص',
    },
    'hexCode': {
      'en': 'Hex Code (e.g. #FF0000)',
      'id': 'Kode Hex (mis. #FF0000)',
      'es': 'Código Hex (ej. #FF0000)',
      'fr': 'Code Hex (ex. #FF0000)',
      'de': 'Hex-Code (z.B. #FF0000)',
      'ja': '16進コード (例: #FF0000)',
      'zh': '十六进制代码 (例如 #FF0000)',
      'ko': '16진수 코드 (예: #FF0000)',
      'pt': 'Código Hex (ex. #FF0000)',
      'ar': 'رمز سداسي عشري (مثال #FF0000)',
    },
    'addBudget': {
      'en': 'Add Budget',
      'id': 'Tambah Anggaran',
      'es': 'Agregar Presupuesto',
      'fr': 'Ajouter un Budget',
      'de': 'Budget Hinzufügen',
      'ja': '予算を追加',
      'zh': '添加预算',
      'ko': '예산 추가',
      'pt': 'Adicionar Orçamento',
      'ar': 'إضافة ميزانية',
    },
    'editBudget': {
      'en': 'Edit Budget',
      'id': 'Edit Anggaran',
      'es': 'Editar Presupuesto',
      'fr': 'Modifier le Budget',
      'de': 'Budget Bearbeiten',
      'ja': '予算を編集',
      'zh': '编辑预算',
      'ko': '예산 편집',
      'pt': 'Editar Orçamento',
      'ar': 'تعديل الميزانية',
    },
    'limitAmount': {
      'en': 'Limit Amount',
      'id': 'Jumlah Batas',
      'es': 'Monto Límite',
      'fr': 'Montant Limite',
      'de': 'Limitbetrag',
      'ja': '制限額',
      'zh': '限额金额',
      'ko': '한도 금액',
      'pt': 'Valor Limite',
      'ar': 'مبلغ الحد',
    },
    'period': {
      'en': 'Period',
      'id': 'Periode',
      'es': 'Período',
      'fr': 'Période',
      'de': 'Zeitraum',
      'ja': '期間',
      'zh': '周期',
      'ko': '기간',
      'pt': 'Período',
      'ar': 'فترة',
    },
    'daily': {
      'en': 'Daily',
      'id': 'Harian',
      'es': 'Diario',
      'fr': 'Quotidien',
      'de': 'Täglich',
      'ja': '毎日',
      'zh': '每日',
      'ko': '매일',
      'pt': 'Diário',
      'ar': 'يومي',
    },
    'weekly': {
      'en': 'Weekly',
      'id': 'Mingguan',
      'es': 'Semanal',
      'fr': 'Hebdomadaire',
      'de': 'Wöchentlich',
      'ja': '毎週',
      'zh': '每周',
      'ko': '매주',
      'pt': 'Semanal',
      'ar': 'أسبوعي',
    },
    'monthly': {
      'en': 'Monthly',
      'id': 'Bulanan',
      'es': 'Mensual',
      'fr': 'Mensuel',
      'de': 'Monatlich',
      'ja': '毎月',
      'zh': '每月',
      'ko': '매월',
      'pt': 'Mensal',
      'ar': 'شهري',
    },
    'categoryRequired': {
      'en': 'Category is required',
      'id': 'Kategori wajib diisi',
      'es': 'La categoría es obligatoria',
      'fr': 'La catégorie est requise',
      'de': 'Kategorie ist erforderlich',
      'ja': 'カテゴリは必須です',
      'zh': '类别为必填项',
      'ko': '카테고리는 필수입니다',
      'pt': 'A categoria é obrigatória',
      'ar': 'الفئة مطلوبة',
    },
    'limitRequired': {
      'en': 'Limit amount is required',
      'id': 'Jumlah batas wajib diisi',
      'es': 'El monto límite es obligatorio',
      'fr': 'Le montant limite est requis',
      'de': 'Limitbetrag ist erforderlich',
      'ja': '制限額は必須です',
      'zh': '限额金额为必填项',
      'ko': '한도 금액은 필수입니다',
      'pt': 'O valor limite é obrigatório',
      'ar': 'مبلغ الحد مطلوب',
    },
    'invalidAmount': {
      'en': 'Invalid amount',
      'id': 'Jumlah tidak valid',
      'es': 'Monto inválido',
      'fr': 'Montant invalide',
      'de': 'Ungültiger Betrag',
      'ja': '無効な金額',
      'zh': '无效金额',
      'ko': '유효하지 않은 금액',
      'pt': 'Valor inválido',
      'ar': 'مبلغ غير صالح',
    },

    // Add Transaction Form
    'addTransaction': {
      'en': 'Add Transaction',
      'id': 'Tambah Transaksi',
      'es': 'Agregar Transacción',
      'fr': 'Ajouter une Transaction',
      'de': 'Transaktion Hinzufügen',
      'ja': '取引を追加',
      'zh': '添加交易',
      'ko': '거래 추가',
      'pt': 'Adicionar Transação',
      'ar': 'إضافة معاملة',
    },
    'editTransaction': {
      'en': 'Edit Transaction',
      'id': 'Edit Transaksi',
      'es': 'Editar Transacción',
      'fr': 'Modifier la Transaction',
      'de': 'Transaktion Bearbeiten',
      'ja': '取引を編集',
      'zh': '编辑交易',
      'ko': '거래 편집',
      'pt': 'Editar Transação',
      'ar': 'تعديل المعاملة',
    },
    'selectCategory': {
      'en': 'Select Category',
      'id': 'Pilih Kategori',
      'es': 'Seleccionar Categoría',
      'fr': 'Sélectionner une Catégorie',
      'de': 'Kategorie Auswählen',
      'ja': 'カテゴリーを選択',
      'zh': '选择类别',
      'ko': '카테고리 선택',
      'pt': 'Selecionar Categoria',
      'ar': 'اختر الفئة',
    },
    'selectAccount': {
      'en': 'Select Account',
      'id': 'Pilih Akun',
      'es': 'Seleccionar Cuenta',
      'fr': 'Sélectionner un Compte',
      'de': 'Konto Auswählen',
      'ja': 'アカウントを選択',
      'zh': '选择账户',
      'ko': '계정 선택',
      'pt': 'Selecionar Conta',
      'ar': 'اختر الحساب',
    },
    'selectIcon': {
      'en': 'Select Icon',
      'id': 'Pilih Ikon',
      'es': 'Seleccionar Icono',
      'fr': 'Sélectionner une Icône',
      'de': 'Symbol Auswählen',
      'ja': 'アイコンを選択',
      'zh': '选择图标',
      'ko': '아이콘 선택',
      'pt': 'Selecionar Ícone',
      'ar': 'اختر الرمز',
    },
    'selectColor': {
      'en': 'Select Color',
      'id': 'Pilih Warna',
      'es': 'Seleccionar Color',
      'fr': 'Sélectionner une Couleur',
      'de': 'Farbe Auswählen',
      'ja': '色を選択',
      'zh': '选择颜色',
      'ko': '색상 선택',
      'pt': 'Selecionar Cor',
      'ar': 'اختر اللون',
    },
    'optional': {
      'en': 'Optional',
      'id': 'Opsional',
      'es': 'Opcional',
      'fr': 'Optionnel',
      'de': 'Optional',
      'ja': 'オプション',
      'zh': '可选',
      'ko': '선택사항',
      'pt': 'Opcional',
      'ar': 'اختياري',
    },

    // Accounts Screen
    'accounts': {
      'en': 'Accounts',
      'id': 'Akun',
      'es': 'Cuentas',
      'fr': 'Comptes',
      'de': 'Konten',
      'ja': 'アカウント',
      'zh': '账户',
      'ko': '계정',
      'pt': 'Contas',
      'ar': 'الحسابات',
    },
    'addAccount': {
      'en': 'Add Account',
      'id': 'Tambah Akun',
      'es': 'Agregar Cuenta',
      'fr': 'Ajouter un Compte',
      'de': 'Konto Hinzufügen',
      'ja': 'アカウントを追加',
      'zh': '添加账户',
      'ko': '계정 추가',
      'pt': 'Adicionar Conta',
      'ar': 'إضافة حساب',
    },
    'accountName': {
      'en': 'Account Name',
      'id': 'Nama Akun',
      'es': 'Nombre de Cuenta',
      'fr': 'Nom du Compte',
      'de': 'Kontoname',
      'ja': 'アカウント名',
      'zh': '账户名称',
      'ko': '계정 이름',
      'pt': 'Nome da Conta',
      'ar': 'اسم الحساب',
    },
    'initialBalance': {
      'en': 'Initial Balance',
      'id': 'Saldo Awal',
      'es': 'Saldo Inicial',
      'fr': 'Solde Initial',
      'de': 'Anfangssaldo',
      'ja': '初期残高',
      'zh': '初始余额',
      'ko': '초기 잔액',
      'pt': 'Saldo Inicial',
      'ar': 'الرصيد الأولي',
    },

    // Common Actions
    'search': {
      'en': 'Search',
      'id': 'Cari',
      'es': 'Buscar',
      'fr': 'Rechercher',
      'de': 'Suchen',
      'ja': '検索',
      'zh': '搜索',
      'ko': '검색',
      'pt': 'Pesquisar',
      'ar': 'بحث',
    },
    'filter': {
      'en': 'Filter',
      'id': 'Filter',
      'es': 'Filtrar',
      'fr': 'Filtrer',
      'de': 'Filtern',
      'ja': 'フィルター',
      'zh': '筛选',
      'ko': '필터',
      'pt': 'Filtrar',
      'ar': 'تصفية',
    },
    'all': {
      'en': 'All',
      'id': 'Semua',
      'es': 'Todos',
      'fr': 'Tous',
      'de': 'Alle',
      'ja': 'すべて',
      'zh': '全部',
      'ko': '전체',
      'pt': 'Todos',
      'ar': 'الكل',
    },
    'welcome': {
      'en': 'Welcome',
      'id': 'Selamat Datang',
      'es': 'Bienvenido',
      'fr': 'Bienvenue',
      'de': 'Willkommen',
      'ja': 'ようこそ',
      'zh': '欢迎',
      'ko': '환영합니다',
      'pt': 'Bem-vindo',
      'ar': 'أهلاً بك',
    },
    'startManaging': {
      'en': 'Start managing your finances by adding your first transaction',
      'id': 'Mulai kelola keuangan Anda dengan menambahkan transaksi pertama',
      'es':
          'Comienza a administrar tus finanzas agregando tu primera transacción',
      'fr':
          'Commencez à gérer vos finances en ajoutant votre première transaction',
      'de':
          'Beginnen Sie mit der Verwaltung Ihrer Finanzen, indem Sie Ihre erste Transaktion hinzufügen',
      'ja': '最初の取引を追加して、財務管理を始めましょう',
      'zh': '添加您的第一笔交易，开始管理您的财务',
      'ko': '첫 거래를 추가하여 자금 관리를 시작하세요',
      'pt':
          'Comece a gerenciar suas finanças adicionando sua primeira transação',
      'ar': 'ابدأ في إدارة أموالك بإضافة معاملتك الأولى',
    },
  };

  String translate(String key) {
    final translations = _localizedValues[key];
    if (translations == null) return key;
    return translations[languageCode] ?? translations['en'] ?? key;
  }

  // Convenience getters for common translations
  String get home => translate('home');
  String get transactions => translate('transactions');
  String get analytics => translate('analytics');
  String get wallets => translate('wallets');
  String get more => translate('more');
  String get settings => translate('settings');

  String get income => translate('income');
  String get expense => translate('expense');
  String get transfer => translate('transfer');

  String get currency => translate('currency');
  String get language => translate('language');
  String get categories => translate('categories');
  String get reports => translate('reports');
  String get dataManagement => translate('dataManagement');
  String get about => translate('about');

  String get manageCategories => translate('manageCategories');
  String get viewReports => translate('viewReports');
  String get backupRestoreExport => translate('backupRestoreExport');

  String get add => translate('add');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get close => translate('close');

  String get amount => translate('amount');
  String get category => translate('category');
  String get date => translate('date');
  String get note => translate('note');
  String get wallet => translate('wallet');

  String get totalIncome => translate('totalIncome');
  String get totalExpense => translate('totalExpense');
  String get balance => translate('balance');

  String get today => translate('today');
  String get thisWeek => translate('thisWeek');
  String get thisMonth => translate('thisMonth');
  String get thisYear => translate('thisYear');

  String get noTransactions => translate('noTransactions');
  String get addFirstTransaction => translate('addFirstTransaction');

  String get appName => translate('appName');
  String get appDescription => translate('appDescription');

  String get featureComingSoon => translate('featureComingSoon');
  String get categoryFeatureComingSoon =>
      translate('categoryFeatureComingSoon');
  String get reportsFeatureComingSoon => translate('reportsFeatureComingSoon');

  String get totalBalance => translate('totalBalance');
  String get totalExpenses => translate('totalExpenses');
  String get wishlist => translate('wishlist');
  String get watchlist => translate('watchlist');
  String get bills => translate('bills');

  String get addTransaction => translate('addTransaction');
  String get editTransaction => translate('editTransaction');
  String get selectCategory => translate('selectCategory');
  String get selectAccount => translate('selectAccount');
  String get selectIcon => translate('selectIcon');
  String get selectColor => translate('selectColor');
  String get optional => translate('optional');

  String get accounts => translate('accounts');
  String get addAccount => translate('addAccount');
  String get accountName => translate('accountName');
  String get initialBalance => translate('initialBalance');

  String get search => translate('search');
  String get filter => translate('filter');
  String get all => translate('all');

  String get calendar => translate('calendar');
  String get searchTransactions => translate('searchTransactions');

  String get manageBills => translate('manageBills');
  String get noBills => translate('noBills');
  String get addBillsReminder => translate('addBillsReminder');
  String get unpaid => translate('unpaid');
  String get paid => translate('paid');
  String get addBill => translate('addBill');
  String get billName => translate('billName');
  String get dueDate => translate('dueDate');
  String get recurring => translate('recurring');
  String get repeatEveryMonths => translate('repeatEveryMonths');
  String get markAsPaid => translate('markAsPaid');
  String get status => translate('status');
  String get billMarkedPaid => translate('billMarkedPaid');
  String get billDeleted => translate('billDeleted');

  String get spendTracker => translate('spendTracker');
  String get manageBudgets => translate('manageBudgets');
  String get noBudgets => translate('noBudgets');
  String get createBudget => translate('createBudget');
  String get active => translate('active');
  String get inactive => translate('inactive');
  String get overBudget => translate('overBudget');
  String get limit => translate('limit');
  String get spent => translate('spent');
  String get remaining => translate('remaining');
  String get percentage => translate('percentage');
  String get budgetDeleted => translate('budgetDeleted');
  String get customColor => translate('customColor');
  String get hexCode => translate('hexCode');
  String get addBudget => translate('addBudget');
  String get editBudget => translate('editBudget');
  String get limitAmount => translate('limitAmount');
  String get period => translate('period');
  String get daily => translate('daily');
  String get weekly => translate('weekly');
  String get monthly => translate('monthly');
  String get categoryRequired => translate('categoryRequired');
  String get limitRequired => translate('limitRequired');
  String get invalidAmount => translate('invalidAmount');
  String get update => translate('update');

  // Theme
  String get theme => translate('theme');
  String get autoDarkMode => translate('autoDarkMode');
  String get lightMode => translate('lightMode');
  String get darkMode => translate('darkMode');
  String get sunnyYellow => translate('sunnyYellow');
  String get oceanBlue => translate('oceanBlue');
  String get mintFresh => translate('mintFresh');
  String get sunsetOrange => translate('sunsetOrange');
  String get lavenderDream => translate('lavenderDream');
  String get selectTheme => translate('selectTheme');

  String get welcome => translate('welcome');
  String get startManaging => translate('startManaging');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id', 'es', 'fr', 'de', 'ja', 'zh', 'ko', 'pt', 'ar']
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
