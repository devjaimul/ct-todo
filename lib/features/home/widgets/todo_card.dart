import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../models/todo_model.dart';

/// Individual todo card with title, description preview, status chip,

class TodoCard extends StatefulWidget {
  final TodoModel todo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int index;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onEdit,
    required this.onDelete,
    this.index = 0,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (widget.index * 80)),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title Row ──────────────────────────────────────────
              Row(
                children: [
                  // Status dot
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.todo.title,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // ── Description ────────────────────────────────────────
              AnimatedCrossFade(
                firstChild: Text(
                  widget.todo.description,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Text(
                  widget.todo.description,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              SizedBox(height: 12.h),

              // ── Status Chip + Actions ──────────────────────────────
              Row(
                children: [
                  // Status chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBgColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      AppConstants.statusLabel(widget.todo.status),
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Edit button
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    color: AppColors.primary,
                    onTap: widget.onEdit,
                  ),
                  SizedBox(width: 8.w),
                  // Delete button
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    onTap: widget.onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (widget.todo.status) {
      case AppConstants.statusPending:
        return AppColors.pending;
      case AppConstants.statusInProgress:
        return AppColors.inProgress;
      case AppConstants.statusCancelled:
        return AppColors.cancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get _statusBgColor {
    switch (widget.todo.status) {
      case AppConstants.statusPending:
        return AppColors.pendingBg;
      case AppConstants.statusInProgress:
        return AppColors.inProgressBg;
      case AppConstants.statusCancelled:
        return AppColors.cancelledBg;
      default:
        return AppColors.textFieldFill;
    }
  }
}

/// Circular action button (edit / delete) for the todo card.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(7.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18.sp),
      ),
    );
  }
}
