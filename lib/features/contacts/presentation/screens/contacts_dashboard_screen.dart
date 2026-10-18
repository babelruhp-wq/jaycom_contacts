import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaycom_contacts/core/constants/app_constants.dart';
import 'package:jaycom_contacts/core/theme/app_colors.dart';
import 'package:jaycom_contacts/core/widgets/brand_logo.dart';
import 'package:jaycom_contacts/core/widgets/feedback_view.dart';
import 'package:jaycom_contacts/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jaycom_contacts/features/contacts/domain/entities/contact.dart';
import 'package:jaycom_contacts/features/contacts/domain/utils/contact_matcher.dart';
import 'package:jaycom_contacts/features/contacts/presentation/cubit/contacts_cubit.dart';
import 'package:jaycom_contacts/features/contacts/presentation/cubit/contacts_state.dart';
import 'package:jaycom_contacts/features/contacts/presentation/widgets/add_contact_dialog.dart';
import 'package:jaycom_contacts/features/professions/domain/entities/profession.dart';
import 'package:jaycom_contacts/features/professions/presentation/cubit/professions_cubit.dart';
import 'package:jaycom_contacts/features/professions/presentation/cubit/professions_state.dart';
import 'package:jaycom_contacts/features/professions/presentation/widgets/add_profession_dialog.dart';

class ContactsDashboardScreen extends StatefulWidget {
  const ContactsDashboardScreen({super.key});

  @override
  State<ContactsDashboardScreen> createState() =>
      _ContactsDashboardScreenState();
}

class _ContactsDashboardScreenState extends State<ContactsDashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<ProfessionsCubit>().fetchProfessions();
    context.read<ContactsCubit>().fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 960;
        return Scaffold(
          key: _scaffoldKey,
          appBar: desktop
              ? null
              : AppBar(
                  title: const Text(AppConstants.arabicAppName),
                  actions: [
                    IconButton(
                      tooltip: 'فتح قائمة المهن',
                      onPressed: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                      icon: const Icon(Icons.menu_rounded),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
          endDrawer: desktop
              ? null
              : const Drawer(
                  width: 310,
                  child: SafeArea(
                    child: _DashboardSidebar(closeDrawerOnSelect: true),
                  ),
                ),
          body: SafeArea(
            child: desktop
                ? const Row(
                    children: [
                      SizedBox(width: 310, child: _DashboardSidebar()),
                      Expanded(child: _ContactsWorkspace()),
                    ],
                  )
                : const _ContactsWorkspace(),
          ),
        );
      },
    );
  }
}

class _DashboardSidebar extends StatelessWidget {
  const _DashboardSidebar({this.closeDrawerOnSelect = false});

  final bool closeDrawerOnSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            child: Row(
              children: [
                const BrandLogo(size: 54, borderRadius: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'جايكم',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                      ),
                      Text(
                        'جهات الاتصال',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
            child: Row(
              children: [
                Text(
                  'المهن',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: 'إضافة مهنة',
                  onPressed: () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProfessionsCubit>(),
                      child: const AddProfessionDialog(),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ProfessionsCubit, ProfessionsState>(
              builder: (context, professionState) {
                if (professionState is ProfessionsLoading &&
                    professionState.professions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (professionState is ProfessionsError &&
                    professionState.professions.isEmpty) {
                  return _SidebarError(
                    message: professionState.message,
                    onRetry: context.read<ProfessionsCubit>().fetchProfessions,
                  );
                }
                if (professionState.professions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(22),
                    child: Center(
                      child: Text(
                        'لا توجد مهن بعد.\nاستخدم زر الإضافة لإنشاء أول مهنة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          height: 1.7,
                        ),
                      ),
                    ),
                  );
                }

                return BlocBuilder<ContactsCubit, ContactsState>(
                  buildWhen: (previous, current) =>
                      previous.contacts != current.contacts,
                  builder: (context, contactState) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      itemCount: professionState.professions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        final profession = professionState.professions[index];
                        final count = contactsForProfession(
                          contactState.contacts,
                          profession.name,
                        ).length;
                        final selected =
                            professionState.selectedProfession?.id ==
                            profession.id;
                        return _ProfessionTile(
                          profession: profession,
                          count: count,
                          selected: selected,
                          onTap: () {
                            context.read<ProfessionsCubit>().selectProfession(
                              profession,
                            );
                            context.read<ContactsCubit>().clearSearch();
                            if (closeDrawerOnSelect) {
                              Navigator.of(context).pop();
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: context.read<AuthCubit>().logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionTile extends StatelessWidget {
  const _ProfessionTile({
    required this.profession,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final Profession profession;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 21,
                color: selected ? AppColors.primaryDark : AppColors.textMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  profession.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primaryDark : AppColors.text,
                  ),
                ),
              ),
              Container(
                key: ValueKey('profession-count-${profession.id}'),
                constraints: const BoxConstraints(minWidth: 30),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : AppColors.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactsWorkspace extends StatelessWidget {
  const _ContactsWorkspace();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfessionsCubit, ProfessionsState>(
      builder: (context, professionState) {
        if (professionState is ProfessionsLoading &&
            professionState.professions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (professionState is ProfessionsError &&
            professionState.professions.isEmpty) {
          return FeedbackView(
            icon: Icons.cloud_off_rounded,
            title: 'تعذر تحميل المهن',
            message: professionState.message,
            actionLabel: 'إعادة المحاولة',
            onAction: context.read<ProfessionsCubit>().fetchProfessions,
          );
        }
        if (professionState.professions.isEmpty) {
          return FeedbackView(
            icon: Icons.work_outline_rounded,
            title: 'ابدأ بإضافة مهنة',
            message: 'أضف أول مهنة لتتمكن من تنظيم أرقام التواصل تحتها.',
            actionLabel: 'إضافة مهنة',
            onAction: () => showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (_) => BlocProvider.value(
                value: context.read<ProfessionsCubit>(),
                child: const AddProfessionDialog(),
              ),
            ),
          );
        }
        final selected = professionState.selectedProfession;
        if (selected == null) return const SizedBox.shrink();

        return BlocBuilder<ContactsCubit, ContactsState>(
          builder: (context, contactState) {
            final allForProfession = contactsForProfession(
              contactState.contacts,
              selected.name,
            );
            final visibleContacts = contactsForProfession(
              contactState.contacts,
              selected.name,
              query: contactState.searchQuery,
            );
            final initialLoading =
                contactState is ContactsLoading &&
                contactState.contacts.isEmpty;
            final fatalError =
                contactState is ContactsError && contactState.contacts.isEmpty;

            return Padding(
              padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width < 600 ? 16 : 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WorkspaceHeader(
                    profession: selected,
                    count: allForProfession.length,
                    refreshing: contactState is ContactsLoading,
                  ),
                  const SizedBox(height: 22),
                  _SearchBar(query: contactState.searchQuery),
                  const SizedBox(height: 18),
                  if (initialLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (fatalError)
                    Expanded(
                      child: FeedbackView(
                        icon: Icons.cloud_off_rounded,
                        title: 'تعذر تحميل جهات الاتصال',
                        message: contactState.message,
                        actionLabel: 'إعادة المحاولة',
                        onAction: context.read<ContactsCubit>().fetchContacts,
                      ),
                    )
                  else if (allForProfession.isEmpty)
                    Expanded(
                      child: FeedbackView(
                        icon: Icons.contact_phone_outlined,
                        title: 'لا توجد أرقام في هذه المهنة',
                        message: 'أضف أول رقم هاتف لمهنة «${selected.name}».',
                        actionLabel: 'إضافة رقم',
                        onAction: () => _showAddContact(context, selected),
                      ),
                    )
                  else if (visibleContacts.isEmpty)
                    const Expanded(
                      child: FeedbackView(
                        icon: Icons.search_off_rounded,
                        title: 'لا توجد نتائج',
                        message: 'جرّب البحث باستخدام أرقام أخرى.',
                      ),
                    )
                  else
                    Expanded(child: _ContactsList(contacts: visibleContacts)),
                  if (contactState is ContactsError &&
                      contactState.contacts.isNotEmpty)
                    _InlineError(message: contactState.message),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.profession,
    required this.count,
    required this.refreshing,
  });

  final Profession profession;
  final int count;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profession.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count ${count == 1 ? 'جهة اتصال' : 'جهات اتصال'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: refreshing
                      ? null
                      : context.read<ContactsCubit>().fetchContacts,
                  icon: refreshing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: const Text('تحديث'),
                ),
                FilledButton.icon(
                  onPressed: () => _showAddContact(context, profession),
                  icon: const Icon(Icons.add_call),
                  label: const Text('إضافة رقم'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.query});

  final String query;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 580),
      child: TextField(
        controller: _controller,
        onChanged: context.read<ContactsCubit>().updateSearch,
        textDirection: TextDirection.ltr,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: 'ابحث برقم الهاتف داخل هذه المهنة',
          hintTextDirection: TextDirection.rtl,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: widget.query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'مسح البحث',
                  onPressed: () {
                    _controller.clear();
                    context.read<ContactsCubit>().clearSearch();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }
}

class _ContactsList extends StatelessWidget {
  const _ContactsList({required this.contacts});

  final List<Contact> contacts;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(10),
        itemCount: contacts.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 58),
        itemBuilder: (context, index) =>
            _ContactRow(contact: contacts[index], index: index),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.contact, required this.index});

  final Contact contact;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'رقم الهاتف ${contact.phone}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableText(
                  contact.phone,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'نسخ الرقم',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: contact.phone));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ رقم الهاتف.')),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarError extends StatelessWidget {
  const _SidebarError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.textMuted,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

void _showAddContact(BuildContext context, Profession profession) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: context.read<ContactsCubit>(),
      child: AddContactDialog(profession: profession),
    ),
  );
}
