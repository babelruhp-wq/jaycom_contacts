import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaycom_contacts/core/constants/app_constants.dart';
import 'package:jaycom_contacts/core/theme/app_colors.dart';
import 'package:jaycom_contacts/core/widgets/brand_logo.dart';
import 'package:jaycom_contacts/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jaycom_contacts/features/auth/presentation/cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _LoginBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final desktop = constraints.maxWidth >= 800;
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x190B563F),
                              blurRadius: 48,
                              offset: Offset(0, 20),
                            ),
                          ],
                        ),
                        child: desktop
                            ? Row(
                                children: [
                                  const Expanded(child: _BrandPanel()),
                                  Expanded(
                                    child: _LoginForm(
                                      formKey: _formKey,
                                      usernameController: _usernameController,
                                      passwordController: _passwordController,
                                      obscurePassword: _obscurePassword,
                                      onTogglePassword: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                      onSubmit: _submit,
                                    ),
                                  ),
                                ],
                              )
                            : _LoginForm(
                                formKey: _formKey,
                                usernameController: _usernameController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                onTogglePassword: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                onSubmit: _submit,
                                showLogo: true,
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    this.showLogo = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final loading = state is AuthLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 42),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showLogo) ...[
              const Center(child: BrandLogo(size: 76, borderRadius: 22)),
              const SizedBox(height: 22),
            ],
            Text(
              'مرحبًا بعودتك',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سجّل الدخول لإدارة جهات اتصال جايكم.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: usernameController,
              enabled: !loading,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'أدخل اسم المستخدم.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              enabled: !loading,
              obscureText: obscurePassword,
              onFieldSubmitted: (_) => onSubmit(),
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: obscurePassword
                      ? 'إظهار كلمة المرور'
                      : 'إخفاء كلمة المرور',
                  onPressed: loading ? null : onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'أدخل كلمة المرور.' : null,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              child: state is AuthError
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.message,
                                style: const TextStyle(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: loading ? null : onSubmit,
              child: loading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.3),
                    )
                  : const Text('تسجيل الدخول'),
            ),
            const SizedBox(height: 18),
            Text(
              'هذه بوابة محلية مؤقتة وليست بديلًا عن مصادقة الخادم.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 600),
      padding: const EdgeInsets.all(48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandLogo(size: 94, borderRadius: 28),
          const SizedBox(height: 32),
          Text(
            AppConstants.arabicAppName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'مساحة موحدة وسريعة لتنظيم المهن وأرقام التواصل.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: CustomPaint(painter: _DotsPainter()),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withValues(alpha: 0.08);
    for (double x = 24; x < size.width; x += 34) {
      for (double y = 24; y < size.height; y += 34) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
