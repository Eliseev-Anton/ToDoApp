import Foundation

/// Presenter экрана создания/редактирования задачи.
///
/// При инициализации модуля Interactor уже содержит задачу (или nil).
final class TaskDetailPresenter: TaskDetailPresenterProtocol {

    weak var view: TaskDetailViewProtocol?
    var interactor: TaskDetailInteractorInputProtocol?
    var router: TaskDetailRouterProtocol?
    /// weak — TaskListViewController не должен удерживаться этим модулем после закрытия экрана
    weak var delegate: TaskDetailModuleDelegate?

    func viewDidLoad() {
        // Если открыт экран редактирования — заполняем поля данными задачи
        if let todo = interactor?.todo {
            view?.showTodo(todo)
        }
        // Если todo == nil — View уже показала пустые поля, ничего делать не нужно
    }

    func saveTodo(title: String, description: String) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            view?.showError("Название не может быть пустым")
            return
        }
        interactor?.saveTodo(title: title, description: description)
    }

    func goBack() {
        router?.goBack(from: view!)
    }
}

// MARK: - Interactor Output

extension TaskDetailPresenter: TaskDetailInteractorOutputProtocol {

    func didSaveTodo() {
        // Уведомляем список задач, чтобы он перезагрузил данные
        delegate?.didSaveTask()
        view?.taskSaved()
    }

    func didFailWithError(_ message: String) {
        view?.showError(message)
    }

    func didLoadTodo(_ todo: TodoItem) {
        view?.showTodo(todo)
    }
}
