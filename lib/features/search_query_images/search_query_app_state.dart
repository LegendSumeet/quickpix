part of 'search_query_app_cubit.dart';

@immutable
sealed class SearchQueryAppState {}

final class SearchQueryAppInitial extends SearchQueryAppState {
  final String query;
  SearchQueryAppInitial(this.query);
}

final class SearchQueryAppLoading extends SearchQueryAppState {}

final class SearchQueryAppLoaded extends SearchQueryAppState {
  final List<ImageSrc> suggestions;
  SearchQueryAppLoaded(this.suggestions);
}

final class SearchQueryAppError extends SearchQueryAppState {
  final String error;
  SearchQueryAppError(this.error);
}