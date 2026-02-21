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
/// ⚠️ SYNC: isPremium flags and creditCost values must match
/// supabase/functions/_shared/model_config.ts (PREMIUM_MODELS + MODEL_CREDIT_COSTS)
/// Pricing rule: Artio credit = KIE credit × 2 (Gemini/Seedream excluded)
class AiModels {
  AiModels._();

  // Universal aspect ratios shown in UI for ALL models.
  // These 5 ratios are supported by most KIE models natively.
  // GPT Image (only supports 1:1, 2:3, 3:2) is auto-mapped server-side:
  //   3:4 → 2:3, 4:3 → 3:2, 9:16 → 2:3, 16:9 → 3:2
  static const List<String> supportedAspectRatios = [
    '1:1',
    '3:4',
    '4:3',
    '9:16',
    '16:9',
  ];

  // Default model
  static const String defaultModelId = 'google/imagen4';

  // All models
  static const List<AiModelConfig> all = [
    // ── KIE: Google / Imagen Models ──
    AiModelConfig(
      id: 'google/imagen4',
      displayName: 'Imagen 4',
      isPremium: false,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 16,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'google/imagen4-fast',
      displayName: 'Imagen 4 Fast',
      isPremium: false,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 8,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'google/imagen4-ultra',
      displayName: 'Imagen 4 Ultra',
      isPremium: true,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 24,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'google/nano-banana-edit',
      displayName: 'Nano Banana Edit',
      isPremium: false,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 8,
      type: 'image-editing',
      isNew: true,
    ),
    AiModelConfig(
      id: 'nano-banana-pro', // NOTE: no google/ prefix per KIE API spec
      displayName: 'Nano Banana Pro',
      isPremium: false,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 36,
      type: 'text-to-image',
    ),

    // ── KIE: Flux-2 Models ──
    AiModelConfig(
      id: 'flux-2/flex-text-to-image',
      displayName: 'Flux-2 Flex',
      isPremium: false,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 28,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'flux-2/flex-image-to-image',
      displayName: 'Flux-2 Flex Edit',
      isPremium: false,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 28,
      type: 'image-to-image',
    ),
    AiModelConfig(
      id: 'flux-2/pro-text-to-image',
      displayName: 'Flux-2 Pro',
      isPremium: true,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 10,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'flux-2/pro-image-to-image',
      displayName: 'Flux-2 Pro Edit',
      isPremium: true,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 10,
      type: 'image-to-image',
    ),

    // ── KIE: GPT Image Models ──
    AiModelConfig(
      id: 'gpt-image/1.5-text-to-image',
      displayName: 'GPT Image 1.5',
      isPremium: true,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 8,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'gpt-image/1.5-image-to-image',
      displayName: 'GPT Image 1.5 Edit',
      isPremium: true,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 8,
      type: 'image-to-image',
    ),

    // ── KIE: Seedream Models ──
    AiModelConfig(
      id: 'seedream/4.5-text-to-image',
      displayName: 'Seedream 4.5',
      isPremium: false,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 8,
      type: 'text-to-image',
    ),
    AiModelConfig(
      id: 'seedream/4.5-edit',
      displayName: 'Seedream 4.5 Edit',
      isPremium: false,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 10,
      type: 'image-editing',
    ),

    // ── Gemini: Google Native Models (fallback) ──
    AiModelConfig(
      id: 'gemini-3-pro-image-preview',
      displayName: 'Gemini 3 Pro Image',
      isPremium: true,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 15,
      type: 'text-to-image',
      isNew: true,
    ),
    AiModelConfig(
      id: 'gemini-2.5-flash-image',
      displayName: 'Gemini 2.5 Flash Image',
      isPremium: false,
      supportedAspectRatios: supportedAspectRatios,
      creditCost: 8,
      type: 'text-to-image',
      isNew: true,
    ),
  ];

  /// Get model by ID
  static AiModelConfig? getById(String id) {
    final matches = all.where((m) => m.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  /// Get default model
  static AiModelConfig get defaultModel => getById(defaultModelId) ?? all.first;

  /// Filter models by type
  static List<AiModelConfig> byType(String type) =>
      all.where((m) => m.type == type).toList();

  /// Get text-to-image models only
  static List<AiModelConfig> get textToImageModels => byType('text-to-image');

  /// Get free models only
  static List<AiModelConfig> get freeModels =>
      all.where((m) => !m.isPremium).toList();
}
