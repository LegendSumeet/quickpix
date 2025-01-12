import 'package:bloc/bloc.dart';
import 'package:picpixels/dio/dio_client.dart';
import 'package:picpixels/model/curated_model.dart';
import 'curated_pics_event.dart';
import 'curated_pics_state.dart';

class CuratedPicsBloc extends Bloc<CuratedPicsEvent, CuratedPicsState> {
  final DioClient dioClient;

  CuratedPicsBloc({required this.dioClient}) : super(CuratedPicsInitial()) {
    on<FetchCuratedPics>(_onFetchCuratedPics);
  }

  Future<void> _onFetchCuratedPics(
      FetchCuratedPics event, Emitter<CuratedPicsState> emit) async {
    emit(CuratedPicsLoading());
    try {
      await dioClient.initialize();
      final response = await dioClient.get('/curated', queryParams: {
        'page': event.page,
        'per_page': event.perPage,
      });
      final PexelsResponse pexelsResponse =
          PexelsResponse.fromJson(response.data);

      emit(CuratedPicsLoaded(pexelsResponse.photos));
    } catch (e) {
      print(e);
      emit(CuratedPicsError(e.toString()));
    }
  }
}
