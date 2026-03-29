class AdminJobModel {
  const AdminJobModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.modelId,
    this.prompt,
    this.imageUrl,
    this.errorMessage,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String status;
  final String modelId;
  final String? prompt;
  final String? imageUrl;
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AdminJobModel.fromJson(Map<String, dynamic> json) {
    return AdminJobModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String? ?? 'pending',
      modelId: json['model_id'] as String? ?? '',
      prompt: json['prompt'] as String?,
      imageUrl: json['image_url'] as String?,
      errorMessage: json['error_message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  bool get isDone => status == 'done';
  bool get isFailed => status == 'failed';
  bool get isGenerating => status == 'generating';
  bool get isPending => status == 'pending';
}
