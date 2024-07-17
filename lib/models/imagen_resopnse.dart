class ImagePrediction {
  final String bytesBase64Encoded;
  final String mimeType;

  ImagePrediction({
    required this.bytesBase64Encoded,
    required this.mimeType,
  });

  factory ImagePrediction.fromJson(Map<String, dynamic> json) {
    return ImagePrediction(
      bytesBase64Encoded: json['bytesBase64Encoded'],
      mimeType: json['mimeType'],
    );
  }
}

class ImagenResponse {
  final List<ImagePrediction> predictions;

  ImagenResponse({
    required this.predictions,
  });

  factory ImagenResponse.fromJson(Map<String, dynamic> json) {
    return ImagenResponse(
      predictions: (json['predictions'] as List)
          .map((e) => ImagePrediction.fromJson(e))
          .toList(),
    );
  }
}
