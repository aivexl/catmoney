class LanguageInfo {
  final String code;
  final String nameEnglish;
  final String nameNative;
  final String flag;

  const LanguageInfo({
    required this.code,
    required this.nameEnglish,
    required this.nameNative,
    required this.flag,
  });
}

class LanguageData {
  static const List<LanguageInfo> languages = [
    LanguageInfo(
      code: 'en',
      nameEnglish: 'English',
      nameNative: 'English',
      flag: '🇺🇸',
    ),
    LanguageInfo(
      code: 'id',
      nameEnglish: 'Indonesian',
      nameNative: 'Bahasa Indonesia',
      flag: '🇮🇩',
    ),
    LanguageInfo(
      code: 'es',
      nameEnglish: 'Spanish',
      nameNative: 'Español',
      flag: '🇪🇸',
    ),
    LanguageInfo(
      code: 'fr',
      nameEnglish: 'French',
      nameNative: 'Français',
      flag: '🇫🇷',
    ),
    LanguageInfo(
      code: 'de',
      nameEnglish: 'German',
      nameNative: 'Deutsch',
      flag: '🇩🇪',
    ),
    LanguageInfo(
      code: 'ja',
      nameEnglish: 'Japanese',
      nameNative: '日本語',
      flag: '🇯🇵',
    ),
    LanguageInfo(
      code: 'zh',
      nameEnglish: 'Chinese (Simplified)',
      nameNative: '简体中文',
      flag: '🇨🇳',
    ),
    LanguageInfo(
      code: 'ko',
      nameEnglish: 'Korean',
      nameNative: '한국어',
      flag: '🇰🇷',
    ),
    LanguageInfo(
      code: 'pt',
      nameEnglish: 'Portuguese',
      nameNative: 'Português',
      flag: '🇧🇷',
    ),
    LanguageInfo(
      code: 'ar',
      nameEnglish: 'Arabic',
      nameNative: 'العربية',
      flag: '🇸🇦',
    ),
  ];

  static LanguageInfo getLanguageByCode(String code) {
    return languages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => languages[0], // Default to English
    );
  }
}
