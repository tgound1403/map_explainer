/// Search events
sealed class SearchEvent {
  const SearchEvent();
}

class SearchQuery extends SearchEvent {
  final String query;
  const SearchQuery(this.query);
}

class LoadHistory extends SearchEvent {
  const LoadHistory();
}

class ClearHistory extends SearchEvent {
  const ClearHistory();
}

class RemoveHistoryItem extends SearchEvent {
  final String query;
  const RemoveHistoryItem(this.query);
}

class ClearQuery extends SearchEvent {
  const ClearQuery();
}
