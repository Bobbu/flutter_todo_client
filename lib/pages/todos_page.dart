import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../pages/todo_edit_page.dart';
import '../main_globals.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  late TextEditingController textController;
  late FocusNode focusNode;
  bool _showCompleted = false;
  List<Todo> _todos = [];
  late Future<List<Todo>> _todosFuture;
  final _todoService = TodoService();

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
    // No waiting. Will use a future builder below in the build method
    _todosFuture = _todoService.getAll();
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _todosFuture = _todoService.getAll();
    });
  }

  void _toggledAndSaveTodoAtIndex(int index) async {
    try {
      _todos[index].completed = !_todos[index].completed;
      await _todoService.saveTodo(_todos[index]);
      setState(() {});
    } on TodoServiceException catch (ex) {
      final ScaffoldMessengerState? scaffold = appScaffoldKey.currentState;
      final snackBar = SnackBar(content: Text(ex.message));
      if (scaffold != null) {
        scaffold.showSnackBar(snackBar);
      } else {
        debugPrint(ex.message);
      }
    }
  }

  Future<void> _onTextSubmitted(String value) async {
    try {
      Todo newTodo = Todo(item: value, completed: false);
      newTodo = await _todoService.saveTodo(newTodo);
      setState(() {
        _todos.add(newTodo);
        textController.clear();
        //focusNode.requestFocus();
      });
    } on TodoServiceException catch (ex) {
      final ScaffoldMessengerState? scaffold = appScaffoldKey.currentState;
      final snackBar = SnackBar(content: Text(ex.message));
      if (scaffold != null) {
        scaffold.showSnackBar(snackBar);
      } else {
        debugPrint(ex.message);
      }
    }
  }

  void _toggleVisibility() {
    setState(() {
      _showCompleted = !_showCompleted;
    });
  }

  void _deleteTodoAtIndex(int index) async {
    try {
      await _todoService.deleteTodo(_todos[index]);
      setState(() {
        _todos.removeAt(index);
      });
    } on TodoServiceException catch (ex) {
      final ScaffoldMessengerState? scaffold = appScaffoldKey.currentState;
      final snackBar = SnackBar(content: Text(ex.message));
      if (scaffold != null) {
        scaffold.showSnackBar(snackBar);
      } else {
        debugPrint(ex.message);
      }
    }
  }

  void _editTodoAtIndex(int index, BuildContext context) async {
    final resultingTodo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoEditPage(),
        // Pass the arguments as part of the RouteSettings. The
        // DetailScreen reads the arguments from these settings.
        settings: RouteSettings(
          arguments: _todos[index],
        ),
      ),
    ) as Todo;

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.

    // TODO This check ALWAYS resolved as "not mounted" and I could not find a
    // way around it. That being said, at least the way it was being used --
    // just to pass data back from the "modal" edit page -- all seems to work on
    // the surface without the check or short circuit. Should get to the bottom
    // of this.

    // if (!context.mounted) {
    //   debugPrint(
    //       'Context no longer mounted. shorting out through early return.');
    //   return;
    // }

    setState(() {
      _todos.replaceRange(index, index + 1, [resultingTodo]);
    });
  }

  int _incompleteTodos() {
    int result = 0;
    for (Todo todo in _todos) {
      if (!todo.completed) {
        result++;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Force a refresh of todos',
          ),
          IconButton(
            icon: _showCompleted
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onPressed: _toggleVisibility,
            tooltip: _showCompleted
                ? 'Hide completed todos'
                : 'Show completed todos',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Do blah blah blah',
                  labelText: "Add a new todo",
                ),
                focusNode: focusNode,
                onSubmitted: (value) => _onTextSubmitted(value),
                // onEditingComplete: () {
                //   debugPrint('onEditing Complete');
                //   focusNode.unfocus();
                // },
                onTapOutside: (event) {
                  debugPrint('onTapOutside');
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              )),
          FutureBuilder(
            future: _todosFuture,
            builder:
                (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
              if (snapshot.hasData) {
                _todos = (snapshot.data)!;
                if (_todos.isEmpty) {
                  return const Center(
                      child: Text('No todos just yet. Why not add one?',
                          maxLines: 2));
                } else {
                  return Expanded(
                    child: Column(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                                '${_incompleteTodos()} of ${_todos.length} to be completed')),
                        Expanded(
                          child: ListView(
                            children: List<Widget>.generate(
                              _todos.length,
                              (index) {
                                if (!_todos[index].completed) {
                                  return _listTileForTodoAt(context, index);
                                } else {
                                  if (_showCompleted) {
                                    return _listTileForTodoAt(context, index);
                                  }
                                  return Container();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                return const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0, color: Colors.blue));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _listTileForTodoAt(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Slidable(
          // Specify a key if the Slidable is dismissible, which ours is.
          key: UniqueKey(),

          // The end action pane is the one at the right or the bottom side.
          endActionPane: ActionPane(
            // A motion is a widget used to control how the pane animates. Other
            // options include ScrollMotion(), BehindMotion(), and
            // StretchMotion(),
            motion: const DrawerMotion(),
            dismissible: DismissiblePane(onDismissed: () {}),

            children: [
              SlidableAction(
                onPressed: ((context) {
                  _deleteTodoAtIndex(index);
                }),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
              ),
              SlidableAction(
                onPressed: ((context) {
                  _editTodoAtIndex(index, context);
                }),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Edit',
              ),
            ],
          ),

          child: ListTile(
              title: Text(
                _todos[index].item,
                style: TextStyle(
                    decorationColor: Colors.red,
                    decoration: _todos[index].completed
                        ? TextDecoration.lineThrough
                        : null),
              ),
              onTap: () => _toggledAndSaveTodoAtIndex(index)),
        ),
      ),
    );
  }
}
