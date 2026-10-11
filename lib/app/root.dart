import 'package:business_os/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection_container.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/resume/presentation/cubit/resumes_cubit.dart';
import '../features/resume/presentation/pages/dashboard_page.dart';
import '../shared/widgets/root_bottom_navigation.dart';

class Root extends StatefulWidget {
  const Root({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  late int _currentIndex;

  static const List<RootNavItem> _items = [
    RootNavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_customize_outlined,
      activeIcon: Icons.dashboard_customize,
    ),
    RootNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
    RootNavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  static const List<Widget> _pages = [_DashboardTab(), _ProfileTab() , _SettingsTab()];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _items.length - 1);
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: RootBottomNavigation(
        items: _items,
        currentIndex: _currentIndex,
        onChanged: _onTabSelected,
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ResumesCubit>()..loadResumes(),
      child: const DashboardPage(),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ProfileCubit>()..load()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),
      ],
      child: ProfilePage(),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return const SettingsPage();
  }
}
