import 'package:equatable/equatable.dart';

abstract class CuratedPicsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCuratedPics extends CuratedPicsEvent {
  final int page;
  final int perPage;

  FetchCuratedPics({this.page = 1, this.perPage = 15});

  @override
  List<Object?> get props => [page, perPage];
}
