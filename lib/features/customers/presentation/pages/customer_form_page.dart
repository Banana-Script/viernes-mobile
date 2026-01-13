import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:phone_form_field/phone_form_field.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../../shared/widgets/viernes_button.dart';
import '../../../../shared/widgets/unsaved_changes_dialog.dart';
import '../../domain/entities/customer_entity.dart';
import '../providers/customer_provider.dart';

enum CustomerFormMode { add, edit }

/// Customer Form Page
///
/// Unified form component for both Add and Edit customer operations.
/// Features:
/// - Mode-specific behavior (add vs edit)
/// - Real-time validation
/// - Phone input with country selector
/// - Change detection (edit mode)
/// - Unsaved changes warning
/// - Loading states
/// - Error handling
class CustomerFormPage extends ConsumerStatefulWidget {
  final CustomerFormMode mode;
  final CustomerEntity? customer; // Required for edit mode

  const CustomerFormPage({
    super.key,
    required this.mode,
    this.customer,
  }) : assert(
          mode == CustomerFormMode.add || customer != null,
          'Customer is required for edit mode',
        );

  @override
  ConsumerState<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends ConsumerState<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = PhoneController(initialValue: PhoneNumber.parse('+57'));
  final _identificationController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();

  bool _isSubmitting = false;
  bool _hasChanges = false;

  // Track initial values for change detection (edit mode)
  late final Map<String, String?> _initialValues;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _setupChangeListeners();
  }

  void _initializeForm() {
    if (widget.mode == CustomerFormMode.edit && widget.customer != null) {
      final customer = widget.customer!;
      _fullNameController.text = customer.name;
      _emailController.text = customer.email;
      _phoneController.value = PhoneNumber.parse(customer.phoneNumber);

      // Load optional fields from entity
      _identificationController.text = customer.identification ?? '';
      _ageController.text = customer.age?.toString() ?? '';
      _occupationController.text = customer.occupation ?? '';

      // Store initial values for change detection
      _initialValues = {
        'fullName': customer.name,
        'email': customer.email,
        'phone': customer.phoneNumber,
        'identification': customer.identification ?? '',
        'age': customer.age?.toString() ?? '',
        'occupation': customer.occupation ?? '',
      };
    } else {
      _initialValues = {
        'fullName': '',
        'email': '',
        'phone': '',
        'identification': '',
        'age': '',
        'occupation': '',
      };
    }
  }

  void _setupChangeListeners() {
    _fullNameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
    _identificationController.addListener(_checkForChanges);
    _ageController.addListener(_checkForChanges);
    _occupationController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    if (widget.mode == CustomerFormMode.edit) {
      final hasChanges = _fullNameController.text != _initialValues['fullName'] ||
          _emailController.text != _initialValues['email'] ||
          _phoneController.value.international != _initialValues['phone'] ||
          _identificationController.text != _initialValues['identification'] ||
          _ageController.text != _initialValues['age'] ||
          _occupationController.text != _initialValues['occupation'];

      if (hasChanges != _hasChanges) {
        setState(() => _hasChanges = hasChanges);
      }
    } else {
      // In add mode, any content means changes
      final hasContent = _fullNameController.text.isNotEmpty ||
          _emailController.text.isNotEmpty ||
          _phoneController.value.international.length > 3 ||
          _identificationController.text.isNotEmpty ||
          _ageController.text.isNotEmpty ||
          _occupationController.text.isNotEmpty;

      if (hasContent != _hasChanges) {
        setState(() => _hasChanges = hasContent);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _identificationController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges && !_isSubmitting) {
      final isDark = ref.read(isDarkModeProvider);
      return await UnsavedChangesDialog.show(context, isDark);
    }
    return true;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = provider_pkg.Provider.of<CustomerProvider>(context, listen: false);

      if (widget.mode == CustomerFormMode.add) {
        await _createCustomer(provider);
      } else {
        await _updateCustomer(provider);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _createCustomer(CustomerProvider provider) async {
    // Get role and status IDs from value definitions service
    final valueDefsService = DependencyInjection.valueDefinitionsService;
    final roleId = valueDefsService.getCustomerRoleId();
    final statusId = valueDefsService.getActiveStatusId();

    final userData = {
      'fullname': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'session_id': _phoneController.value.international,
      'verified': 1,
      if (_identificationController.text.isNotEmpty)
        'identification': _identificationController.text.trim(),
      if (_ageController.text.isNotEmpty) 'age': int.parse(_ageController.text),
      if (_occupationController.text.isNotEmpty) 'occupation': _occupationController.text.trim(),
    };

    final success = await provider.createCustomer(
      roleId: roleId,
      statusId: statusId,
      userData: userData,
    );

    if (success && mounted) {
      final l10n = AppLocalizations.of(context);
      _showSuccessSnackbar(l10n?.customerCreatedSuccess ?? 'Customer created successfully');
      Navigator.pop(context, true); // Return true to indicate success
    } else if (mounted) {
      _showErrorSnackbar(_mapErrorMessage(provider.errorMessage));
    }
  }

  /// Maps backend error messages to localized strings
  String _mapErrorMessage(String? errorMessage) {
    final l10n = AppLocalizations.of(context);
    if (errorMessage == null) {
      return l10n?.errorCreatingCustomer ?? 'Error creating customer';
    }

    // Map known backend error messages to localized strings
    if (errorMessage.contains('already has access to the organization')) {
      return l10n?.errorUserAlreadyExists ?? errorMessage;
    }
    if (errorMessage.contains('Invalid') || errorMessage.contains('invalid')) {
      return l10n?.errorInvalidCustomerData ?? errorMessage;
    }

    // Return original message if no mapping found
    return errorMessage;
  }

  Future<void> _updateCustomer(CustomerProvider provider) async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    // Build update data with only changed fields (PATCH semantics)
    final updateData = <String, dynamic>{};

    if (_fullNameController.text != _initialValues['fullName']) {
      updateData['fullname'] = _fullNameController.text.trim();
    }
    if (_emailController.text != _initialValues['email']) {
      updateData['email'] = _emailController.text.trim();
    }
    // Note: Phone is read-only in edit mode, so we don't include it
    if (_identificationController.text != _initialValues['identification']) {
      updateData['identification'] = _identificationController.text.trim();
    }
    if (_ageController.text != _initialValues['age']) {
      updateData['age'] = _ageController.text.isNotEmpty ? int.parse(_ageController.text) : null;
    }
    if (_occupationController.text != _initialValues['occupation']) {
      updateData['occupation'] = _occupationController.text.trim();
    }

    if (updateData.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final success = await provider.updateCustomer(
      userId: widget.customer!.userId,
      data: updateData,
    );

    if (success && mounted) {
      final l10n = AppLocalizations.of(context);
      _showSuccessSnackbar(l10n?.customerUpdatedSuccess ?? 'Customer updated successfully');
      Navigator.pop(context, true); // Return true to indicate success
    } else if (mounted) {
      _showErrorSnackbar(_mapErrorMessage(provider.errorMessage));
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ViernesColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
        ),
        margin: const EdgeInsets.all(ViernesSpacing.md),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ViernesColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
        ),
        margin: const EdgeInsets.all(ViernesSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: !_hasChanges || _isSubmitting,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) {
                  navigator.pop();
                }
              } else {
                navigator.pop();
              }
            },
          ),
          title: Text(
            widget.mode == CustomerFormMode.add
                ? (l10n?.addCustomer ?? 'Add Customer')
                : (l10n?.editCustomer ?? 'Edit Customer'),
            style: ViernesTextStyles.h6.copyWith(
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
            ),
          ),
        ),
        body: ViernesBackground(
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(ViernesSpacing.md),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFullNameField(isDark, l10n),
                          const SizedBox(height: ViernesSpacing.md),
                          _buildEmailField(isDark, l10n),
                          const SizedBox(height: ViernesSpacing.md),
                          _buildPhoneField(isDark, l10n),
                          const SizedBox(height: ViernesSpacing.md),
                          _buildIdentificationField(isDark, l10n),
                          const SizedBox(height: ViernesSpacing.md),
                          _buildAgeField(isDark, l10n),
                          const SizedBox(height: ViernesSpacing.md),
                          _buildOccupationField(isDark, l10n),
                          const SizedBox(height: ViernesSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildActionButtons(isDark, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullNameField(bool isDark, AppLocalizations? l10n) {
    return _buildTextField(
      controller: _fullNameController,
      label: l10n?.fullName ?? 'Full Name',
      hint: l10n?.enterFullName ?? 'Enter customer full name',
      icon: Icons.person_rounded,
      isDark: isDark,
      isRequired: true,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n?.fullNameRequired ?? 'Full name is required';
        }
        if (value.trim().length < 2) {
          return l10n?.nameMinLength ?? 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(bool isDark, AppLocalizations? l10n) {
    final isRequired = widget.mode == CustomerFormMode.add;
    return _buildTextField(
      controller: _emailController,
      label: l10n?.email ?? 'Email',
      hint: l10n?.enterEmail ?? 'Enter email address',
      icon: Icons.email_rounded,
      isDark: isDark,
      isRequired: isRequired,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return l10n?.emailRequired ?? 'Email is required';
        }
        if (value != null && value.trim().isNotEmpty) {
          final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(value.trim())) {
            return l10n?.pleaseEnterValidEmail ?? 'Please enter a valid email';
          }
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(bool isDark, AppLocalizations? l10n) {
    final isEditMode = widget.mode == CustomerFormMode.edit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n?.phoneNumber ?? 'Phone Number',
              style: ViernesTextStyles.label.copyWith(
                color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: ViernesTextStyles.label.copyWith(
                color: ViernesColors.danger,
              ),
            ),
            if (isEditMode) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.lock_rounded,
                size: 14,
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
        const SizedBox(height: ViernesSpacing.xs),
        PhoneFormField(
          controller: _phoneController,
          enabled: !isEditMode, // Read-only in edit mode
          decoration: InputDecoration(
            hintText: l10n?.enterPhoneNumber ?? 'Enter phone number',
            prefixIcon: Icon(
              Icons.phone_rounded,
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: isDark
                ? ViernesColors.panelDark.withValues(alpha: 0.5)
                : ViernesColors.panelLight.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
              borderSide: BorderSide(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
              borderSide: BorderSide(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
              borderSide: BorderSide(
                color: isDark ? ViernesColors.accent : ViernesColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
              borderSide: const BorderSide(
                color: ViernesColors.danger,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
              borderSide: const BorderSide(
                color: ViernesColors.danger,
                width: 2,
              ),
            ),
          ),
          countrySelectorNavigator: const CountrySelectorNavigator.page(),
          validator: (phoneNumber) {
            if (phoneNumber == null || !phoneNumber.isValid()) {
              return l10n?.phoneRequired ?? 'Phone number is required';
            }
            return null;
          },
          // Initial country set via controller // Default to Colombia
        ),
        if (isEditMode)
          Padding(
            padding: const EdgeInsets.only(top: ViernesSpacing.xs, left: ViernesSpacing.sm),
            child: Text(
              l10n?.phoneCannotBeChanged ?? 'Phone number cannot be changed',
              style: ViernesTextStyles.helper.copyWith(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIdentificationField(bool isDark, AppLocalizations? l10n) {
    return _buildTextField(
      controller: _identificationController,
      label: l10n?.identification ?? 'Identification',
      hint: l10n?.enterIdentification ?? 'Enter ID number (optional)',
      icon: Icons.badge_rounded,
      isDark: isDark,
    );
  }

  Widget _buildAgeField(bool isDark, AppLocalizations? l10n) {
    return _buildTextField(
      controller: _ageController,
      label: l10n?.age ?? 'Age',
      hint: l10n?.enterAge ?? 'Enter age (optional)',
      icon: Icons.cake_rounded,
      isDark: isDark,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value != null && value.trim().isNotEmpty) {
          final age = int.tryParse(value);
          if (age == null) {
            return l10n?.invalidAge ?? 'Please enter a valid age';
          }
          if (widget.mode == CustomerFormMode.add) {
            if (age < 1 || age > 120) {
              return l10n?.ageMustBeBetween ?? 'Age must be between 1 and 120';
            }
          } else {
            if (age < 0 || age > 120) {
              return l10n?.ageMustBeBetweenEdit ?? 'Age must be between 0 and 120';
            }
          }
        }
        return null;
      },
    );
  }

  Widget _buildOccupationField(bool isDark, AppLocalizations? l10n) {
    return _buildTextField(
      controller: _occupationController,
      label: l10n?.occupation ?? 'Occupation',
      hint: l10n?.enterOccupation ?? 'Enter occupation (optional)',
      icon: Icons.work_rounded,
      isDark: isDark,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isRequired = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: ViernesTextStyles.label.copyWith(
                color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: ViernesTextStyles.label.copyWith(
                  color: ViernesColors.danger,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: ViernesSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: ViernesTextStyles.bodyText.copyWith(
            color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ViernesTextStyles.bodyText.copyWith(
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              icon,
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: isDark
                ? ViernesColors.panelDark.withValues(alpha: 0.5)
                : ViernesColors.panelLight.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
              borderSide: BorderSide(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
              borderSide: BorderSide(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
              borderSide: BorderSide(
                color: isDark ? ViernesColors.accent : ViernesColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
              borderSide: const BorderSide(
                color: ViernesColors.danger,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
              borderSide: const BorderSide(
                color: ViernesColors.danger,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? ViernesColors.panelDark.withValues(alpha: 0.95)
            : ViernesColors.panelLight.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                .withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ViernesButton.outline(
              text: l10n?.cancel ?? 'Cancel',
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      if (_hasChanges) {
                        final shouldPop = await _onWillPop();
                        if (shouldPop && mounted) {
                          navigator.pop();
                        }
                      } else {
                        navigator.pop();
                      }
                    },
            ),
          ),
          const SizedBox(width: ViernesSpacing.sm),
          Expanded(
            flex: 2,
            child: ViernesButton.primary(
              text: widget.mode == CustomerFormMode.add
                  ? (l10n?.createCustomer ?? 'Create Customer')
                  : (l10n?.saveChanges ?? 'Save Changes'),
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
