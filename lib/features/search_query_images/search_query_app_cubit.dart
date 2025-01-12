import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:picpixels/dio/dio_client.dart';
import 'package:picpixels/model/curated_model.dart';
import 'package:picpixels/model/image_src.dart';

part 'search_query_app_state.dart';

class SearchQueryAppCubit extends Cubit<SearchQueryAppState> {
  SearchQueryAppCubit({required String query})
      : super(SearchQueryAppInitial(query)) {
    search(query);
  }

  void search(String query) async {
    if (query.isEmpty) return;
    emit(SearchQueryAppLoading());
    try {
      DioClient dio = DioClient();
      Response response = await dio
          .get('/search', queryParams: {'query': query.toLowerCase()});
      final PexelsResponse pexelsResponse =
          PexelsResponse.fromJson(response.data);

      emit(SearchQueryAppLoaded(pexelsResponse.photos));
    } catch (e) {
      emit(SearchQueryAppError(e.toString()));
    }
  }
}
