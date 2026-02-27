import UIKit

/// Сборка и навигация модуля детального просмотра / создания задачи.
///
/// Модуль работает в двух режимах:
/// - todo == nil - создание новой задачи
/// - todo != nil - редактирование существующей
/// Режим определяет Interactor на основании наличия объекта todo.
final class TaskDetailRouter: TaskDetailRouterProtocol {

    weak var viewController: UIViewController?

    /// Создаёт и связывает все VIPER-компоненты модуля.
    ///
    /// - Parameters:
    ///   - todo: задача для редактирования; nil означает режим создания
    ///   - delegate: список задач, который нужно уведомить после сохранения
    static func createModule(with todo: TodoItem?, delegate: TaskDetailModuleDelegate?) -> UIViewController {
        let view = TaskDetailViewController()
        let presenter = TaskDetailPresenter()
        let interactor = TaskDetailInteractor()
        let router = TaskDetailRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        // Делегат — weak-ссылка на TaskListViewController
        presenter.delegate = delegate
        interactor.presenter = presenter
        // Передаём задачу в Interactor - именно он знает, создавать или обновлять
        interactor.todo = todo
        router.viewController = view

        return view
    }

    /// Закрывает overlay — dismiss вместо pop
    func goBack(from view: TaskDetailViewProtocol) {
        viewController?.dismiss(animated: true)
    }
}
