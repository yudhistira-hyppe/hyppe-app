import '../models/collection/search/search_content.dart';

class HashtagArgument{
  bool isTitle;
  bool fromRoute;
  Tags hashtag;
  HashtagArgument({required this.isTitle, required this.hashtag, this.fromRoute = false});
}