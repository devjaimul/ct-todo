import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/widgets/toast_helper.dart';
import '../models/todo_model.dart';

/// GetX controller for CRUD operations on todos with Firestore,
/// offline caching, pagination, and status-based stats.
class TodoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //  Observable State 
  final todos = <TodoModel>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final isSaving = false.obs;

  // Pagination
  DocumentSnapshot? _lastDoc;
  static const int _pageSize = AppConstants.pageSize;

  // Stats (computed)
  int get totalCount => todos.length;
  int get pendingCount =>
      todos.where((t) => t.status == AppConstants.statusPending).length;
  int get inProgressCount =>
      todos.where((t) => t.status == AppConstants.statusInProgress).length;
  int get cancelledCount =>
      todos.where((t) => t.status == AppConstants.statusCancelled).length;

  // Helpers 
  String? get _uid => _auth.currentUser?.uid;
  ConnectivityService get _connectivity => Get.find<ConnectivityService>();
  CacheService get _cache => Get.find<CacheService>();

  CollectionReference get _todosRef =>
      _firestore.collection('users').doc(_uid).collection('todos');

  //  Lifecycle 
  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  // Fetch Todos (initial or refresh) 
  Future<void> fetchTodos({bool refresh = false}) async {
    if (refresh) {
      _lastDoc = null;
      hasMore.value = true;
    }

    isLoading.value = true;

    try {
      if (_connectivity.isOnline.value && _uid != null) {
        // Sync any pending offline operations first
        await _syncPendingOps();

        final query = _todosRef
            .orderBy('updatedAt', descending: true)
            .limit(_pageSize);

        final snapshot = await query.get();
        final fetched = snapshot.docs
            .map((doc) => TodoModel.fromFirestore(doc))
            .toList();

        _lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        hasMore.value = snapshot.docs.length == _pageSize;

        todos.assignAll(fetched);

        // Cache locally
        _cacheTodos();
      } else {
        // Load from cache
        _loadFromCache();
      }
    } catch (e) {
      _loadFromCache();
      ToastHelper.showError('Failed to load todos');
    } finally {
      isLoading.value = false;
    }
  }

  //  Load More (pagination) 
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || _lastDoc == null) return;

    isLoadingMore.value = true;

    try {
      final query = _todosRef
          .orderBy('updatedAt', descending: true)
          .startAfterDocument(_lastDoc!)
          .limit(_pageSize);

      final snapshot = await query.get();
      final fetched = snapshot.docs
          .map((doc) => TodoModel.fromFirestore(doc))
          .toList();

      _lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      hasMore.value = snapshot.docs.length == _pageSize;

      todos.addAll(fetched);
      _cacheTodos();
    } catch (e) {
      ToastHelper.showError('Failed to load more todos');
    } finally {
      isLoadingMore.value = false;
    }
  }

  //  Add Todo 
  Future<bool> addTodo(String title, String description, String status) async {
    isSaving.value = true;
    try {
      final now = DateTime.now();
      final todoData = {
        'title': title.trim(),
        'description': description.trim(),
        'status': status,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      if (_connectivity.isOnline.value && _uid != null) {
        final docRef = await _todosRef.add(todoData);
        final newTodo = TodoModel(
          id: docRef.id,
          title: title.trim(),
          description: description.trim(),
          status: status,
          createdAt: now,
          updatedAt: now,
        );
        todos.insert(0, newTodo);
        _cacheTodos();
      } else {
        // Offline: add locally + queue for sync
        final tempId = 'temp_${now.millisecondsSinceEpoch}';
        final newTodo = TodoModel(
          id: tempId,
          title: title.trim(),
          description: description.trim(),
          status: status,
          createdAt: now,
          updatedAt: now,
        );
        todos.insert(0, newTodo);
        _cacheTodos();
        await _cache.addPendingOp(AppConstants.keyPendingOps, {
          'type': 'add',
          'data': newTodo.toJson(),
        });
        ToastHelper.showInfo('Saved offline. Will sync when online.');
      }

      ToastHelper.showSuccess('Todo added successfully!');
      return true;
    } catch (e) {
      ToastHelper.showError('Failed to add todo');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  //  Update Todo 
  Future<bool> updateTodo(
    String todoId,
    String title,
    String description,
    String status,
  ) async {
    isSaving.value = true;
    try {
      final now = DateTime.now();

      if (_connectivity.isOnline.value && _uid != null) {
        await _todosRef.doc(todoId).update({
          'title': title.trim(),
          'description': description.trim(),
          'status': status,
          'updatedAt': Timestamp.fromDate(now),
        });
      } else {
        await _cache.addPendingOp(AppConstants.keyPendingOps, {
          'type': 'update',
          'id': todoId,
          'data': {
            'title': title.trim(),
            'description': description.trim(),
            'status': status,
            'updatedAt': now.toIso8601String(),
          },
        });
        ToastHelper.showInfo('Updated offline. Will sync when online.');
      }

      // Update local list
      final idx = todos.indexWhere((t) => t.id == todoId);
      if (idx != -1) {
        todos[idx] = todos[idx].copyWith(
          title: title.trim(),
          description: description.trim(),
          status: status,
          updatedAt: now,
        );
      }
      _cacheTodos();

      ToastHelper.showSuccess('Todo updated successfully!');
      return true;
    } catch (e) {
      ToastHelper.showError('Failed to update todo');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Delete Todo 
  Future<void> deleteTodo(String todoId) async {
    try {
      if (_connectivity.isOnline.value && _uid != null) {
        await _todosRef.doc(todoId).delete();
      } else {
        await _cache.addPendingOp(AppConstants.keyPendingOps, {
          'type': 'delete',
          'id': todoId,
        });
        ToastHelper.showInfo('Deleted offline. Will sync when online.');
      }

      todos.removeWhere((t) => t.id == todoId);
      _cacheTodos();
      ToastHelper.showSuccess('Todo deleted');
    } catch (e) {
      ToastHelper.showError('Failed to delete todo');
    }
  }

  // Get Single Todo 
  TodoModel? getTodoById(String id) {
    try {
      return todos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // Cache Operations
  void _cacheTodos() {
    final jsonList = todos.map((t) => t.toJson()).toList();
    _cache.setJsonList(AppConstants.keyCachedTodos, jsonList);
  }

  void _loadFromCache() {
    final cached = _cache.getJsonList(AppConstants.keyCachedTodos);
    if (cached.isNotEmpty) {
      todos.assignAll(cached.map((j) => TodoModel.fromJson(j)).toList());
    }
  }

  // Sync Pending Offline Operations
  Future<void> _syncPendingOps() async {
    if (_uid == null) return;
    final ops = _cache.getPendingOps(AppConstants.keyPendingOps);
    if (ops.isEmpty) return;

    for (final op in ops) {
      try {
        switch (op['type']) {
          case 'add':
            final data = Map<String, dynamic>.from(op['data']);
            data.remove('id');
            data['createdAt'] = Timestamp.fromDate(
                DateTime.parse(data['createdAt']));
            data['updatedAt'] = Timestamp.fromDate(
                DateTime.parse(data['updatedAt']));
            await _todosRef.add(data);
            break;
          case 'update':
            final id = op['id'] as String;
            final data = Map<String, dynamic>.from(op['data']);
            if (data.containsKey('updatedAt')) {
              data['updatedAt'] = Timestamp.fromDate(
                  DateTime.parse(data['updatedAt']));
            }
            if (!id.startsWith('temp_')) {
              await _todosRef.doc(id).update(data);
            }
            break;
          case 'delete':
            final id = op['id'] as String;
            if (!id.startsWith('temp_')) {
              await _todosRef.doc(id).delete();
            }
            break;
        }
      } catch (_) {
        // Skip failed ops silently
      }
    }

    await _cache.clearPendingOps(AppConstants.keyPendingOps);
  }
}
