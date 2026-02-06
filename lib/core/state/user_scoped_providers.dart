import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/gallery/presentation/providers/gallery_provider.dart';
import '../../features/template_engine/presentation/providers/template_provider.dart';
import '../../features/template_engine/presentation/view_models/generation_view_model.dart';

/// Invalidates all providers scoped to the current user session.
/// Call on sign-out to prevent stale data on re-login.
void invalidateUserScopedProviders(Ref ref) {
  ref.invalidate(galleryStreamProvider);
  ref.invalidate(galleryActionsNotifierProvider);
  ref.invalidate(templatesProvider);
  ref.invalidate(generationViewModelProvider);
}
