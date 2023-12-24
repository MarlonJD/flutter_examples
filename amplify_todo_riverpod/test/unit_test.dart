void main() {
  // group('TodoManager', () {
  //   late TodoManager todoManager;

  //   setUp(() {
  //     todoManager = TodoManager();
  //   });

  //   test('Todo ekleme', () {
  //     const input = 'yeni yapılacak';

  //     // test fonksiyon: addTodo
  //     todoManager.addTodo(input);

  //     //  sonuçlar
  //     expect(todoManager.todos.length, 1);
  //     expect(todoManager.todos[0].name, input);
  //     expect(todoManager.todos[0].completed, false);
  //   });

  //   test('Todo silme', () {
  //     final todo = Todo(
  //       id: '1',
  //       name: 'Test Todo',
  //       completed: false,
  //     );
  //     todoManager.todos = [todo];

  //     //test fonksiyon: deleteTodo
  //     todoManager.deleteTodo(todo.id);

  //     //  sonuctodoManager.todos listesinin boş olması
  //     expect(todoManager.todos.length, 0);
  //   });

  //   test('Todo durumunu değiştirme', () {
  //     final todo = Todo(
  //       id: '1',
  //       name: 'Test Todo',
  //       completed: false,
  //     );
  //     todoManager.todos = [todo];

  //     // test: toggleTodoStatus
  //     todoManager.toggleTodoStatus(todo.id);

  //     // sonuc todo.completed değerinin true olması
  //     expect(todoManager.todos[0].completed, true);
  //   });

  //   test('Tüm todoları alma', () {
  //     final todo1 = Todo(
  //       id: '1',
  //       name: 'Todo 1',
  //       completed: false,
  //     );
  //     final todo2 = Todo(
  //       id: '2',
  //       name: 'Todo 2',
  //       completed: true,
  //     );
  //     todoManager.todos = [todo1, todo2];

  //     // Test edilecek fonksiyon: getAllTodos
  //     final allTodos = todoManager.getAllTodos();

  //     // Beklenen sonuçlar
  //     expect(allTodos.length, 2);
  //     expect(allTodos[0], todo1);
  //     expect(allTodos[1], todo2);
  //   });
  // });
}
