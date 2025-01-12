import 'package:equatable/equatable.dart';
import 'package:picpixels/model/image_src.dart';

abstract class CuratedPicsState extends Equatable {
  const CuratedPicsState();

  @override
  List<Object?> get props => [];
}

class CuratedPicsInitial extends CuratedPicsState {}

class CuratedPicsLoading extends CuratedPicsState {}

class CuratedPicsLoaded extends CuratedPicsState {
  final List<ImageSrc> pictures;

  const CuratedPicsLoaded(this.pictures);

  @override
  List<Object?> get props => [pictures];
}

class CuratedPicsError extends CuratedPicsState {
  final String message;

  const CuratedPicsError(this.message);

  @override
  List<Object?> get props => [message];
}
