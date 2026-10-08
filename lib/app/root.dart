import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/resume/presentation/cubit/resumes_cubit.dart';
import '../features/resume/presentation/pages/resumes_page.dart';
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
      label: 'Resumes',
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
    ),
    RootNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  static const List<Widget> _pages = [_ResumesTab(), _ProfileTab()];

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
      // ✨ extendBody عشان المحتوى يمتد تحت الـ Nav العائم
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

class _ResumesTab extends StatelessWidget {
  const _ResumesTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ResumesCubit>()..loadResumes(),
      child: const ResumesPage(),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: const ProfilePage(),
    );
  }
}
