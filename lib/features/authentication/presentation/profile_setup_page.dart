import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_snackbar.dart';
import 'auth_provider.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _medicalConditionsController = TextEditingController();

  String? _selectedCountry;
  bool _initialized = false;

  static const List<String> _countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Argentina',
    'Australia',
    'Austria',
    'Bahrain',
    'Bangladesh',
    'Belgium',
    'Brazil',
    'Canada',
    'China',
    'Denmark',
    'Egypt',
    'Finland',
    'France',
    'Germany',
    'Greece',
    'India',
    'Indonesia',
    'Iraq',
    'Ireland',
    'Italy',
    'Japan',
    'Jordan',
    'Kuwait',
    'Lebanon',
    'Libya',
    'Malaysia',
    'Mexico',
    'Morocco',
    'Netherlands',
    'New Zealand',
    'Nigeria',
    'Norway',
    'Oman',
    'Pakistan',
    'Palestine',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Saudi Arabia',
    'Singapore',
    'South Africa',
    'South Korea',
    'Spain',
    'Sudan',
    'Sweden',
    'Switzerland',
    'Syria',
    'Thailand',
    'Tunisia',
    'Turkey',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Vietnam',
    'Yemen',
    'Other',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    _initialized = true;
    final user = context.read<AuthProvider>().user;
    final displayName = user?.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      _nameController.text = displayName.trim();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final authProvider = context.read<AuthProvider>();

    if (!_formKey.currentState!.validate()) {
      showAppSnackBar(
        'Please complete all required fields.',
        isError: true,
      );
      return;
    }

    final success = await authProvider.saveProfile(
      displayName: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      country: _selectedCountry!,
      medicalConditions: _medicalConditionsController.text.trim().isEmpty
          ? null
          : _medicalConditionsController.text.trim(),
    );

    if (!success) {
      showAppSnackBar(
        authProvider.errorMessage ??
            'Could not save your profile. Please try again.',
        isError: true,
      );
      return;
    }

    showAppSnackBar(
      'Profile saved successfully. Welcome to your dashboard!',
      isSuccess: true,
    );

    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final errorMessage = authProvider.errorMessage;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBrandHeader(theme),
                    const SizedBox(height: AppSpacing.xxxl),
                    _buildStepBadge(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Complete your profile',
                      style: AppTypography.heading1(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tell us a little about yourself so we can personalize '
                      'your monitoring experience.',
                      style: AppTypography.body(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: theme.colorScheme.outline),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (errorMessage != null) ...[
                            _buildErrorBanner(errorMessage),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name.';
                              }
                              if (value.trim().length < 2) {
                                return 'Please enter a valid name.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              hintText: 'Enter your age in years',
                              prefixIcon: Icon(Icons.cake_outlined),
                              suffixText: 'years',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your age.';
                              }
                              final age = int.tryParse(value.trim());
                              if (age == null || age < 1 || age > 120) {
                                return 'Please enter an age between 1 and 120.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCountry,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Country',
                              prefixIcon: Icon(Icons.public),
                            ),
                            hint: const Text('Select your country'),
                            menuMaxHeight: 320,
                            items: _countries
                                .map(
                                  (country) => DropdownMenuItem(
                                    value: country,
                                    child: Text(country),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCountry = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your country.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _medicalConditionsController,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.done,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText:
                                  'Do you have any medical conditions or diseases?',
                              hintText: 'Optional, e.g. dry eye or astigmatism',
                              prefixIcon: Icon(Icons.health_and_safety_outlined),
                              alignLabelWithHint: true,
                            ),
                            onFieldSubmitted: (_) => _handleSave(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Your information is private and only used '
                                  'to personalize your experience.',
                                  style: AppTypography.caption(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: authProvider.isLoading ? null : _handleSave,
                        icon: authProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.arrow_forward, size: 20),
                        label: Text(
                          authProvider.isLoading ? 'Saving...' : 'Next & Save',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primary0,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.remove_red_eye,
            color: AppColors.primary300,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'Eye Monitoring',
          style: AppTypography.heading3(color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildStepBadge() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary0,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          'STEP 1 OF 1',
          style: AppTypography.caption(color: AppColors.primary300)
              .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.errorText.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.errorText,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body(color: AppColors.errorText),
            ),
          ),
        ],
      ),
    );
  }
}
