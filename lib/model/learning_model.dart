class LearningData {
  final String title;
  final String description;
  final String imageUrl;

  LearningData({required this.title, required this.description, required this.imageUrl});

  factory LearningData.fromJson(Map<String, dynamic> json) {
    return LearningData(
      title: json['title'] ?? '',
      description: json['des'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class LearningResponse {
  final List<LearningData> data;

  LearningResponse({required this.data});

  factory LearningResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<LearningData> learningDataList = dataList.map((i) => LearningData.fromJson(i)).toList();

    return LearningResponse(data: learningDataList);
  }
}
