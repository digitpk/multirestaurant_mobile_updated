class BannerMedia {
  String url;
  BannerMedia();

  BannerMedia.fromJSON(Map<String, dynamic> jsonMap)
      : url = jsonMap['url'];
}
