import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaycom_contacts/core/theme/app_colors.dart';
import 'package:jaycom_contacts/features/professions/presentation/cubit/professions_cubit.dart';
import 'package:jaycom_contacts/features/professions/presentation/cubit/professions_state.dart';

class AddProfessionDialog extends StatefulWidget {
  const AddProfessionDialog({super.key});

  @override
  State<AddProfessionDialog> createState() => _AddProfessionDialogState();
}

class _AddProfessionDialogState extends State<AddProfessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfessionsCubit>().addProfession(_nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfessionsCubit, ProfessionsState>(
      listenWhen: (previous, current) => current is ProfessionAddSuccess,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('تمت إضافة المهنة وتحديدها بنجاح.'),
            backgroundColor: AppColors.primaryDark,
          ),
        );
      },
      builder: (context, state) {
        final adding = state is ProfessionsAdding;
        final error = state is ProfessionAddFailure ? state.message : null;
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          title: const Row(
            children: [
              Icon(Icons.work_outline_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(child: Text('إضافة مهنة جديدة')),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    autofocus: true,
                    enabled: !adding,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => adding ? null : _submit(),
                    decoration: const InputDecoration(
                      labelText: 'اسم المهنة',
                      hintText: 'مثال: نجار',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'أدخل اسم المهنة.'
                        : null,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: adding ? null : () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: adding ? null : _submit,
              child: adding
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Text('إضافة المهنة'),
            ),
          ],
        );
      },
    );
  }
}
