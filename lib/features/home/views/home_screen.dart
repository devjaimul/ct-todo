import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/routes/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_dialog.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../controller/todo_controller.dart';
import '../widgets/stats_card.dart';
import '../widgets/todo_card.dart';

/// Home screen with stats dashboard, paginated todo list,

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TodoController _todoController = Get.find<TodoController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _todoController.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _todoController.fetchTodos(refresh: true);
  }

  void _confirmDelete(String todoId) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Delete Todo',
        subtitle: 'Are you sure you want to delete this todo? This action cannot be undone.',
        confirmText: 'Delete',
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);
          _todoController.deleteTodo(todoId);
        },
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Logout',
        subtitle: 'Are you sure you want to logout?',
        confirmText: 'Logout',
        confirmColor: AppColors.primary,
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          Navigator.pop(context);
          Get.find<TodoController>().todos.clear();
          await FirebaseAuth.instance.signOut();
          if (mounted) context.goNamed(AppRouter.signIn);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: Obx(() {
          if (_todoController.isLoading.value) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(top: 16.h),
              child: Column(
                children: [
                  const StatsShimmerLoading(),
                  SizedBox(height: 20.h),
                  const TodoShimmerLoading(),
                ],
              ),
            );
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: _buildStatsGrid(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                  child: Row(
                    children: [
                      Text(
                        'My Todos',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_todoController.totalCount} items',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_todoController.todos.isEmpty)
                SliverFillRemaining(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == _todoController.todos.length) {
                          // Loading more indicator
                          return Obx(() => _todoController.isLoadingMore.value
                              ? Padding(
                                  padding: EdgeInsets.all(20.r),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink());
                        }

                        final todo = _todoController.todos[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: TodoCard(
                            todo: todo,
                            index: index,
                            onEdit: () => context.pushNamed(
                              AppRouter.editTodo,
                              queryParameters: {'id': todo.id},
                            ),
                            onDelete: () => _confirmDelete(todo.id),
                          ),
                        );
                      },
                      childCount: _todoController.todos.length +
                          (_todoController.hasMore.value ? 1 : 0),
                    ),
                  ),
                ),

              // Bottom padding
              SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRouter.addTodo),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Todo',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';

    return AppBar(
      backgroundColor: AppColors.surface,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $displayName 👋',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Manage your tasks efficiently',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: _confirmLogout,
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(width: 8.w),
      ],
      toolbarHeight: 68.h,
    );
  }

  Widget _buildStatsGrid() {
    return Obx(() => GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.15,
          children: [
            StatsCard(
              title: 'Total Todos',
              count: _todoController.totalCount,
              icon: Icons.checklist_rounded,
              gradient: AppColors.totalGradient,
            ),
            StatsCard(
              title: 'Pending',
              count: _todoController.pendingCount,
              icon: Icons.pending_actions_rounded,
              gradient: AppColors.pendingGradient,
            ),
            StatsCard(
              title: 'In Progress',
              count: _todoController.inProgressCount,
              icon: Icons.timelapse_rounded,
              gradient: AppColors.inProgressGradient,
            ),
            StatsCard(
              title: 'Cancelled',
              count: _todoController.cancelledCount,
              icon: Icons.cancel_outlined,
              gradient: AppColors.cancelledGradient,
            ),
          ],
        ));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_add_outlined,
              size: 48.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No todos yet',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the + button to create your first todo',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
