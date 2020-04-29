class Language {
  String code;
  String englishName;
  String localName;
  String flag;
  bool selected;

  Language(this.code, this.englishName, this.localName, this.flag, {this.selected = false});
}

class LanguagesList {
  List<Language> _languages;

  LanguagesList(String SelectedLanguageCode) {
    this._languages = [
      new Language("he", "Hebrew", "עברית", "assets/img/hebrew.png", selected: SelectedLanguageCode =="he" ? true : false),
      //new Language("ar", "Arabic", "العربية", "assets/img/united-arab-emirates.png", selected: SelectedLanguageCode =="ar" ? true : false),
      //new Language("en", "English", "English", "assets/img/united-states-of-america.png", selected: SelectedLanguageCode =="en" ? true : false),
    ];
  }

  List<Language> get languages => _languages;
}
