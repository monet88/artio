import 'package:artio/features/create/presentation/providers/create_form_provider.dart';
import 'package:artio/features/create/presentation/view_models/create_view_model.dart';
import 'package:artio/features/gallery/presentation/providers/gallery_provider.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/features/template_engine/presentation/view_models/generation_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Invalidates all providers scoped to the current user session.
/// Call on sign-out to prevent stale data on re-login.
void invalidateUserScopedProviders(Ref ref) {
  ref
    ..invalidate(galleryStreamProvider)
    ..invalidate(galleryActionsNotifierProvider)
    ..invalidate(templatesProvider)
    ..invalidate(generationViewModelProvider)
    ..invalidate(createViewModelProvider)
    ..invalidate(createFormNotifierProvider);
}
