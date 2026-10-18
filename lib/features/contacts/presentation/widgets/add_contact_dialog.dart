import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaycom_contacts/core/theme/app_colors.dart';
import 'package:jaycom_contacts/features/contacts/domain/utils/phone_validator.dart';
import 'package:jaycom_contacts/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:jaycom_contacts/features/contacts/presentation/cubit/contacts_state.dart';
import 'package:jaycom_contacts/features/professions/domain/entities/profession.dart';

class AddContactDialog extends StatefulWidget {
  const AddContactDialog({required this.profession, super.key});

  final Profession profession;

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _phoneController = TextEditingController();
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_updateValidity);
  }

  void _updateValidity() {
    final valid = PhoneValidator.isValidLocalNumber(_phoneController.text);
    setState(() => _valid = valid);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_updateValidity)
      ..dispose();
    super.dispose();
  }

  void _submit() {
    if (!_valid) return;
    context.read<ContactsCubit>().addContact(
      professionId: widget.profession.id,
      professionName: widget.profession.name,
      localNumber: _phoneController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactsCubit, ContactsState>(
      listenWhen: (previous, current) => current is ContactAddSuccess,
      listener: (context, state) {
        final success = state as ContactAddSuccess;
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              success.refreshWarning ?? 'تمت إضافة رقم الهاتف بنجاح.',
            ),
            backgroundColor: success.refreshWarning == null
                ? AppColors.primaryDark
                : const Color(0xFF9A6700),
          ),
        );
      },
      builder: (context, state) {
        final adding = state is ContactsAdding;
        final error = state is ContactAddFailure ? state.message : null;
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          title: Text('إضافة رقم جديد — ${widget.profession.name}'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text(
                      'سيتم إضافة رقم الهاتف إلى مهنة «${widget.profession.name}».',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'رقم الهاتف',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      controller: _phoneController,
                      autofocus: true,
                      enabled: !adding,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _valid && !adding ? _submit() : null,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        hintText: '0545365521',
                        counterText: '',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      maxLength: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل رقم الجوال المحلي من 10 أرقام، ويجب أن يبدأ بـ 05.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _valid
                        ? Container(
                            key: const ValueKey('phone-preview'),
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                'سيتم الإرسال: ${PhoneValidator.buildFullPhone(_phoneController.text)}',
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
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
              onPressed: !_valid || adding ? null : _submit,
              child: adding
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Text('حفظ الرقم'),
            ),
          ],
        );
      },
    );
  }
}
