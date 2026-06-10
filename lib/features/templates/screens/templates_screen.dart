import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smartops/core/models/project_template_model.dart';
import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/services/template_service.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/features/templates/widgets/template_card.dart';

class TemplatesScreen extends StatefulWidget {
  final bool isClient;

  const TemplatesScreen({
    super.key,
    this.isClient = false,
  });

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<ProjectTemplateModel> templates = [];
  bool isLoading = true;
  String errorMessage = '';

  String selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> loadTemplates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await TemplateService.getTemplates();

      setState(() {
        templates = data
            .map(
              (item) => ProjectTemplateModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      });
    } catch (error) {
      setState(() {
        errorMessage = _cleanErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<String> get categories {
    final values = templates
        .map((template) => template.category)
        .where((item) => item.trim().isNotEmpty)
        .toSet()
        .toList();

    values.sort();

    return ['all', ...values];
  }

  List<ProjectTemplateModel> get filteredTemplates {
    final query = _searchController.text.trim().toLowerCase();

    return templates.where((template) {
      final matchesSearch = query.isEmpty ||
          [
            template.name,
            template.description,
            template.category,
            template.estimatedDuration.toString(),
          ].join(' ').toLowerCase().contains(query);

      final matchesCategory =
          selectedCategory == 'all' || template.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _openCreateTemplateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const _CreateTemplateDialog(),
    );

    if (result == true) {
      await loadTemplates();
    }
  }

  Future<void> _openEditTemplateDialog(ProjectTemplateModel template) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _CreateTemplateDialog(template: template),
    );

    if (result == true) {
      await loadTemplates();
    }
  }

  Future<void> _deleteTemplate(ProjectTemplateModel template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete template?',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
            style: const TextStyle(
              color: Color(0xFF667085),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await TemplateService.deleteTemplate(template.templateId);

      setState(() {
        templates.removeWhere(
              (item) => item.templateId == template.templateId,
        );
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Template deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanErrorMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openRequestTemplateDialog(ProjectTemplateModel template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Request this template?',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          content: Text(
            'Are you sure you want to request "${template.name}"? The request will be sent to the admin for review.',
            style: const TextStyle(
              color: Color(0xFF667085),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text(
                'Confirm Request',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B2E59),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await TemplateService.requestFromTemplate(
        templateId: template.templateId,
        name: template.name,
        description: template.description,
        category: template.category,
        estimatedDuration: template.estimatedDuration,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project request submitted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanErrorMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openCustomRequestDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const _RequestTemplateDialog(),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom project request submitted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatRole(String role) {
    if (role.isEmpty) return 'Member';

    return role
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    })
        .join(' ');
  }

  Widget _buildOverview(AuthProvider authProvider) {
    final bool isAdmin = authProvider.isAdmin;

    return Column(
      children: [
        Row(
          children: [
           // Expanded(
             // child: _OverviewCard(
              //  title: 'Active Templates',
              //  value: isLoading ? '...' : '${templates.length}',
               // subtitle: 'From database',
               // icon: Icons.view_module_outlined,
               // color: const Color(0xFF0B2E59),
             // ),
           // ),
           // const SizedBox(width: 10),
           // Expanded(
           //   child: _OverviewCard(
            //    title: 'Managed By',
             //   value: 'Mahmoud',
               // subtitle: 'Current admin',
              //  icon: Icons.person_outline,
              //  color: Colors.green.shade700,
             // ),
            //),
          ],
        ),
        const SizedBox(height: 10),
        _OverviewCard(
          title: 'Access Level',
          value: isAdmin ? 'Admin' : _formatRole(authProvider.role),
          subtitle: isAdmin ? 'Full control' : 'Can request',
          icon: isAdmin
              ? Icons.admin_panel_settings_outlined
              : Icons.verified_user_outlined,
          color: Colors.purple.shade700,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search templates by name, category, or description...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.close),
            )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF0B2E59)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isActive = selectedCategory == category;

              return ChoiceChip(
                selected: isActive,
                label: Text(
                  category == 'all' ? 'All Categories' : category,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF0B2E59),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                selectedColor: const Color(0xFF0B2E59),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE9EEF5)),
                onSelected: (_) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody({
    required bool isClient,
    required bool isAdmin,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF0B2E59)),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 38),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            AppButton(
              text: 'Try Again',
              icon: Icons.refresh,
              onPressed: loadTemplates,
              backgroundColor: Colors.red.shade700,
            ),
          ],
        ),
      );
    }

    if (filteredTemplates.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EEF5)),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.view_module_outlined,
              color: Color(0xFF98A2B3),
              size: 44,
            ),
            SizedBox(height: 12),
            Text(
              'No matching templates found',
              style: TextStyle(
                color: Color(0xFF0B2E59),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try changing your search text or category filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredTemplates.map((template) {
        return TemplateCard(
          template: template,
          isClient: isClient,
          isAdmin: isAdmin,
          onUseTemplate:
          isClient ? () => _openRequestTemplateDialog(template) : null,
          onEdit: isAdmin ? () => _openEditTemplateDialog(template) : null,
          onDelete: isAdmin ? () => _deleteTemplate(template) : null,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final bool isAdmin = authProvider.isAdmin;
    final bool isClient = authProvider.isClient || widget.isClient;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'templates'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return RefreshIndicator(
              onRefresh: loadTemplates,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTopBar(
                      title: 'Templates',
                      onMenuTap: () => _openDrawer(context),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Project Templates',
                      style: TextStyle(
                        color: Color(0xFF0B2E59),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isClient
                          ? 'Browse reusable templates or submit a custom project request for admin review.'
                          : 'Manage reusable project blueprints and operational project structures.',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (isAdmin)
                      AppButton(
                        text: 'Create Template',
                        icon: Icons.add,
                        onPressed: _openCreateTemplateDialog,
                      ),
                    if (isClient)
                      AppButton(
                        text: 'Request Custom Project',
                        icon: Icons.add_comment_outlined,
                        onPressed: _openCustomRequestDialog,
                      ),
                    if (isAdmin || isClient) const SizedBox(height: 18),
                    _buildOverview(authProvider),
                    const SizedBox(height: 18),
                    _buildSearchAndFilters(),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Text(
                          'Template Registry',
                          style: TextStyle(
                            color: Color(0xFF0B2E59),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${filteredTemplates.length} shown',
                          style: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBody(
                      isClient: isClient,
                      isAdmin: isAdmin,
                    ),
                    const SizedBox(height: 28),
                    AppFooter(
                      text: 'Need help?',
                      actionText: 'Contact Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CreateTemplateDialog extends StatefulWidget {
  final ProjectTemplateModel? template;

  const _CreateTemplateDialog({
    this.template,
  });

  bool get isEditMode => template != null;

  @override
  State<_CreateTemplateDialog> createState() => _CreateTemplateDialogState();
}

class _CreateTemplateDialogState extends State<_CreateTemplateDialog> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final durationController = TextEditingController();

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    if (widget.template != null) {
      nameController.text = widget.template!.name;
      descriptionController.text = widget.template!.description;
      categoryController.text = widget.template!.category;
      durationController.text = widget.template!.estimatedDuration.toString();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    durationController.dispose();
    super.dispose();
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      if (widget.isEditMode) {
        await TemplateService.updateTemplate(
          templateId: widget.template!.templateId,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          category: categoryController.text.trim(),
          estimatedDuration: int.parse(durationController.text.trim()),
        );
      } else {
        await TemplateService.createTemplate(
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          category: categoryController.text.trim(),
          estimatedDuration: int.parse(durationController.text.trim()),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Template updated successfully.'
                : 'Template created successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return _TemplateFormDialogShell(
      title: widget.isEditMode ? 'Edit Template' : 'Create Template',
      subtitle: widget.isEditMode
          ? 'Update this reusable project template.'
          : 'Add a reusable project structure for future client requests.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _DialogTextField(
              label: 'Template Name',
              hint: 'Mobile Application',
              controller: nameController,
              validator: (value) => _required(value, 'Template name'),
            ),
            const SizedBox(height: 14),
            _DialogTextField(
              label: 'Description',
              hint: 'Describe this reusable project template...',
              controller: descriptionController,
              maxLines: 4,
              validator: (value) => _required(value, 'Description'),
            ),
            const SizedBox(height: 14),
            _DialogTextField(
              label: 'Category',
              hint: 'Mobile Development',
              controller: categoryController,
              validator: (value) => _required(value, 'Category'),
            ),
            const SizedBox(height: 14),
            _DialogTextField(
              label: 'Estimated Duration',
              hint: '30',
              controller: durationController,
              keyboardType: TextInputType.number,
              validator: (value) {
                final message = _required(value, 'Estimated duration');

                if (message != null) return message;

                final parsed = int.tryParse(value!.trim());

                if (parsed == null || parsed <= 0) {
                  return 'Estimated duration must be a positive number';
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
            AppButton(
              text: widget.isEditMode ? 'Save Changes' : 'Create Template',
              icon: widget.isEditMode ? Icons.save_outlined : Icons.add,
              isLoading: isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestTemplateDialog extends StatefulWidget {
  final ProjectTemplateModel? template;

  const _RequestTemplateDialog({
    this.template,
  });

  bool get isTemplateRequest => template != null;

  @override
  State<_RequestTemplateDialog> createState() => _RequestTemplateDialogState();
}

class _RequestTemplateDialogState extends State<_RequestTemplateDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController categoryController;
  late final TextEditingController durationController;
  late final TextEditingController deadlineController;

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.template?.name ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.template?.description ?? '',
    );

    categoryController = TextEditingController(
      text: widget.template?.category ?? '',
    );

    durationController = TextEditingController(
      text: widget.template?.estimatedDuration.toString() ?? '',
    );

    deadlineController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    durationController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }

    return null;
  }

  String? _deadlineValidator(String? value) {
    final message = _required(value, 'Deadline');

    if (message != null) return message;

    final date = DateTime.tryParse(value!.trim());

    if (date == null) {
      return 'Deadline must be in YYYY-MM-DD format';
    }

    return null;
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0B2E59),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0B2E59),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final formattedDate =
        '${pickedDate.year.toString().padLeft(4, '0')}-'
        '${pickedDate.month.toString().padLeft(2, '0')}-'
        '${pickedDate.day.toString().padLeft(2, '0')}';

    setState(() {
      deadlineController.text = formattedDate;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      if (widget.isTemplateRequest) {
        await TemplateService.requestFromTemplate(
          templateId: widget.template!.templateId,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          category: categoryController.text.trim(),
          estimatedDuration: int.parse(durationController.text.trim()),
        );
      } else {
        await TemplateService.createCustomProjectRequest(
          projectName: nameController.text.trim(),
          description: descriptionController.text.trim(),
          category: categoryController.text.trim(),
          deadline: deadlineController.text.trim(),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _TemplateFormDialogShell(
      title:
      widget.isTemplateRequest ? 'Request Project' : 'Custom Project Request',
      subtitle: widget.isTemplateRequest
          ? 'Review the template details before submitting your request.'
          : 'Describe your custom project request for admin review.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _DialogTextField(
              label: 'Project Name',
              hint: 'Enter project name',
              controller: nameController,
              validator: (value) => _required(value, 'Project name'),
            ),
            const SizedBox(height: 14),
            _DialogTextField(
              label: 'Description',
              hint: 'Describe your project request...',
              controller: descriptionController,
              maxLines: 4,
              validator: (value) => _required(value, 'Description'),
            ),
            const SizedBox(height: 14),
            _DialogTextField(
              label: 'Category',
              hint: 'Software System',
              controller: categoryController,
              validator: (value) => _required(value, 'Category'),
            ),
            const SizedBox(height: 14),
            if (widget.isTemplateRequest)
              _DialogTextField(
                label: 'Estimated Duration',
                hint: '30',
                controller: durationController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final message = _required(value, 'Estimated duration');

                  if (message != null) return message;

                  final parsed = int.tryParse(value!.trim());

                  if (parsed == null || parsed <= 0) {
                    return 'Estimated duration must be a positive number';
                  }

                  return null;
                },
              )
            else
              TextFormField(
                controller: deadlineController,
                readOnly: true,
                onTap: _pickDeadline,
                validator: _deadlineValidator,
                decoration: InputDecoration(
                  labelText: 'Deadline',
                  hintText: 'YYYY-MM-DD',
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF0B2E59)),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            AppButton(
              text: widget.isTemplateRequest
                  ? 'Submit Request'
                  : 'Submit Custom Request',
              icon: Icons.send_outlined,
              isLoading: isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateFormDialogShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _TemplateFormDialogShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EEF8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.view_module_outlined,
                    color: Color(0xFF0B2E59),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _DialogTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0B2E59)),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      constraints: const BoxConstraints(
        minHeight: 128,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFE9EEF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.04),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: fullWidth
          ? Row(
        children: [
          _OverviewIcon(icon: icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: _OverviewText(
              title: title,
              value: value,
              subtitle: subtitle,
              color: color,
              large: true,
            ),
          ),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OverviewIcon(icon: icon, color: color),
          const SizedBox(height: 12),
          _OverviewText(
            title: title,
            value: value,
            subtitle: subtitle,
            color: color,
            large: false,
          ),
        ],
      ),
    );
  }
}

class _OverviewIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _OverviewIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _OverviewText extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final bool large;

  const _OverviewText({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.large,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: large ? 24 : 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}