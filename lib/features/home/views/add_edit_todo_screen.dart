import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controller/todo_controller.dart';

/// Screen for adding a new todo or editing an existing one.
/// If [todoId] is provided, the screen enters edit mode.


class AddEditTodoScreen extends StatefulWidget {
  final String? todoId;
  const AddEditTodoScreen({super.key, this.todoId});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _todoController = Get.find<TodoController>();

  String _selectedStatus = AppConstants.statusPending;
  bool get _isEdit => widget.todoId != null && widget.todoId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final todo = _todoController.getTodoById(widget.todoId!);
      if (todo != null) {
        _titleController.text = todo.title;
        _descriptionController.text = todo.description;
        _selectedStatus = todo.status;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    bool success;
    if (_isEdit) {
      success = await _todoController.updateTodo(
        widget.todoId!,
        _titleController.text,
        _descriptionController.text,
        _selectedStatus,
      );
    } else {
      success = await _todoController.addTodo(
        _titleController.text,
        _descriptionController.text,
        _selectedStatus,
      );
    }

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(_isEdit ? 'Edit Todo' : 'Add Todo'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.totalGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isEdit ? Icons.edit_note_rounded : Icons.note_add_rounded,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _isEdit
                          ? 'Update your todo details'
                          : 'Create a new task to stay organized',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),

              _buildLabel('Title'),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: _titleController,
                hintText: 'Enter todo title',
                prefixIcon: Icon(
                  Icons.title_rounded,
                  color: AppColors.iconColor,
                  size: 20.sp,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              _buildLabel('Description'),
              SizedBox(height: 8.h),
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Enter description',
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 76.h),
                  child: Icon(
                    Icons.description_outlined,
                    color: AppColors.iconColor,
                    size: 20.sp,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              _buildLabel('Status'),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.textFieldFill,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.textFieldBorder),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.iconColor,
                    size: 24.sp,
                  ),
                  dropdownColor: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  items: AppConstants.todoStatuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: _statusColor(status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            AppConstants.statusLabel(status),
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
              ),
              SizedBox(height: 36.h),

              Obx(
                () => CustomButton(
                  text: _isEdit ? 'Update Todo' : 'Create Todo',
                  isLoading: _todoController.isSaving.value,
                  onTap: _handleSave,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
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
}
