import 'package:wikipedia/wikipedia.dart';

class WikipediaService {
  static final WikipediaService instance = WikipediaService();
  Wikipedia service = Wikipedia();

  Future<String?> useWikipedia({required String query}) async {
    try {    
      var result = await service.searchQuery(searchQuery: query, limit: 1);
      for (int i = 0; i < result!.query!.search!.length; i++) {
        if (!(result.query!.search![i].pageid == null)) {
          var resultDescription = await service.searchSummaryWithPageId(
              pageId: result.query!.search![i].pageid!);
          return resultDescription?.extract ?? '';
        }
      }
    } catch (e) {
      print(e);
      return null;
    }
  return null;
  }
}
