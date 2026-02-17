/// AI Model configurations for image generation
class AiModelConfig {

  const AiModelConfig({
    required this.id,
    required this.displayName,
    required this.isPremium,
    required this.supportedAspectRatios,
    required this.creditCost,
    required this.type,
    this.isNew = false,
  });
  final String id;
  final String displayName;
  final bool isPremium;
  final List<String> supportedAspectRatios;
  final int creditCost;
  final String type; // text-to-image, image-to-image, image-editing
  final bool isNew;
}

/// All available AI models from KIE API
class AiModels {
  AiModels._();

  // Default aspect ratios for most models
  static const List<String> standardAspectRatios = [
    '1:1',
    '2:3',
    '3:2',
    '4:5',
    '5:4',
    '9:16',
    '16:9',
    '3:4',
    '4:3',
  ];

  // GPT Image limited aspect ratios
  static const List<String> gptAspectRatios = ['1:1', '2:3', '3:2'];

  // Default model
  static const String defaultModelId = 'google/imagen4';

  // All models
  static const List<AiModelConfig> all = [
    // Google / Imagen Models
    AiModelConfig(
      id: 'google/imagen4',
      displayName: 'Imagen 4',
      isPremium: false,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 6,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'google/imagen4-fast',
      displayName: 'Imagen 4 Fast',
      isPremium: false,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 4,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'google/imagen4-ultra',
      displayName: 'Imagen 4 Ultra',
      isPremium: true,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 12,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'google/nano-banana-edit',
      displayName: 'Nano Banana Edit',
      isPremium: false,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 10,
      type: 'image-editing',
      isNew: true,
    ),
    AiModelConfig(
      id: 'google/pro-image-to-image',
      displayName: 'Pro Image-to-Image',
      isPremium: true,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 15,
      type: 'image-to-image',
    ),

    // Flux-2 Models
    AiModelConfig(
      id: 'flux-2/flex-text-to-image',
      displayName: 'Flux-2 Flex',
      isPremium: false,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 8,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'flux-2/flex-image-to-image',
      displayName: 'Flux-2 Flex Edit',
      isPremium: false,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 10,
      type: 'image-to-image',
    ),
    AiModelConfig(
      id: 'flux-2/pro-text-to-image',
      displayName: 'Flux-2 Pro',
      isPremium: true,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 16,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'flux-2/pro-image-to-image',
      displayName: 'Flux-2 Pro Edit',
      isPremium: true,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 20,
      type: 'image-to-image',
    ),

    // GPT Image Models
    AiModelConfig(
      id: 'gpt-image/1.5-text-to-image',
      displayName: 'GPT Image 1.5',
      isPremium: false,
      supportedAspectRatios: gptAspectRatios,
      creditCost: 15,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'gpt-image/1.5-image-to-image',
      displayName: 'GPT Image 1.5 Edit',
      isPremium: false,
      supportedAspectRatios: gptAspectRatios,
      creditCost: 18,
      type: 'image-to-image',
    ),

    // Seedream Models
    AiModelConfig(
      id: 'seedream/4.5-text-to-image',
      displayName: 'Seedream 4.5',
      isPremium: false,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 8,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'seedream/4.5-edit',
      displayName: 'Seedream 4.5 Edit',
      isPremium: false,
      supportedAspectRatios: standardAspectRatios,
      creditCost: 10,
      type: 'image-editing',
    ),
  ];

  /// Get model by ID
  static AiModelConfig? getById(String id) {
    try {
      return all.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get default model
  static AiModelConfig get defaultModel =>
      getById(defaultModelId) ?? all.first;

  /// Filter models by type
  static List<AiModelConfig> byType(String type) =>
      all.where((m) => m.type == type).toList();

  /// Get text-to-image models only
  static List<AiModelConfig> get textToImageModels =>
      byType('text-to-image');

  /// Get free models only
  static List<AiModelConfig> get freeModels =>
      all.where((m) => !m.isPremium).toList();
}
