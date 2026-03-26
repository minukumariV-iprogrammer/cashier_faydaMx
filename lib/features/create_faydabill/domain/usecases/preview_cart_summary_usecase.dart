import '../../data/datasources/fayda_cart_remote_datasource.dart';
import '../../data/models/preview_summary_models.dart';

class PreviewCartSummaryUseCase {
  PreviewCartSummaryUseCase(this._remote);

  final FaydaCartRemoteDataSource _remote;

  Future<PreviewSummaryDataModel> call(Map<String, dynamic> body) {
    return _remote.previewCartSummary(body);
  }
}
