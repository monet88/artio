import 'package:artio/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:artio/features/gallery/domain/repositories/i_gallery_repository.dart';
import 'package:artio/features/template_engine/domain/repositories/i_generation_repository.dart';
import 'package:artio/features/template_engine/domain/repositories/i_template_repository.dart';
import 'package:mocktail/mocktail.dart';

/// Mock for IAuthRepository
class MockAuthRepository extends Mock implements IAuthRepository {}

/// Mock for ITemplateRepository
class MockTemplateRepository extends Mock implements ITemplateRepository {}

/// Mock for IGenerationRepository
class MockGenerationRepository extends Mock implements IGenerationRepository {}

/// Mock for IGalleryRepository
class MockGalleryRepository extends Mock implements IGalleryRepository {}
