enum AppLanguage {
  english('en', 'English'),
  tagalog('tl', 'Tagalog');

  const AppLanguage(this.code, this.displayName);

  final String code;
  final String displayName;

  static AppLanguage fromCode(String? code) {
    if (code == 'tl') return AppLanguage.tagalog;
    return AppLanguage.english;
  }
}
