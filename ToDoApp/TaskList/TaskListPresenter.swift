import UIKit

/// Presenter списка задач — посредник между View и Interactor.
///
/// Всё, что связано с отображением — делегируется View.
/// Всё, что связано с данными — делегируется Interactor.
final class TaskListPresenter: TaskListPresenterProtocol {

    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorInputProtocol?
    var router: TaskListRouterProtocol?

    func viewDidLoad() {
        // Каждый раз при появлении экрана запрашиваем актуальные данные
        interactor?.fetchTodos()
    }

    func didSelectTodo(_ todo: TodoItem) {
        router?.navigateToDetail(from: view!, with: todo)
    }

    func addNewTodo() {
        // nil сигнализирует Router'у, что открываем экран создания, а не редактирования
        router?.navigateToDetail(from: view!, with: nil)
    }

    func deleteTodo(_ todo: TodoItem) {
        interactor?.deleteTodo(id: todo.id)
    }

    func toggleTodoCompletion(_ todo: TodoItem) {
        interactor?.toggleTodoCompletion(id: todo.id)
    }

    func searchTodos(query: String) {
        interactor?.searchTodos(query: query)
    }

    /// Здесь Presenter работает с UIViewController напрямую,
    func shareTodo(_ todo: TodoItem, from viewController: UIViewController) {
        let text = "\(todo.title)\n\(todo.descriptionText)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
}

// MARK: - Interactor Output

extension TaskListPresenter: TaskListInteractorOutputProtocol {

    func didFetchTodos(_ todos: [TodoItem]) {
        view?.showTodos(todos)
    }

    func didFailWithError(_ message: String) {
        view?.showError(message)
    }

    /// После любого изменения данных (удаление, toggle) перечитываем весь список.
    /// Это проще и надёжнее, чем точечно обновлять строки таблицы.
    func didUpdateData() {
        interactor?.fetchTodos()
    }
}
