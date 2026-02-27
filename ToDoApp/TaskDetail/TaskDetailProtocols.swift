import UIKit

/// Контракты VIPER-модуля экрана создания и редактирования задачи

/// Делегат для обратного уведомления модуля-родителя о том, что задача была сохранена.
/// Используем делегат вместо NotificationCenter, чтобы связь была явной и типобезопасной.
protocol TaskDetailModuleDelegate: AnyObject {
    func didSaveTask()
}

// MARK: - View

protocol TaskDetailViewProtocol: AnyObject {
    var presenter: TaskDetailPresenterProtocol? { get set }

    /// Заполняет поля экрана данными существующей задачи (режим редактирования)
    func showTodo(_ todo: TodoItem)
    func showError(_ message: String)
    /// Вызывается после успешного сохранения — View может закрыться или показать индикатор
    func taskSaved()
}

// MARK: - Presenter

protocol TaskDetailPresenterProtocol: AnyObject {
    var view: TaskDetailViewProtocol? { get set }
    var interactor: TaskDetailInteractorInputProtocol? { get set }
    var router: TaskDetailRouterProtocol? { get set }

    /// Если в Interactor передана существующая задача — отображает её данные на View
    func viewDidLoad()
    /// Сохраняет задачу — создаёт новую или обновляет существующую (Interactor решает)
    func saveTodo(title: String, description: String)
    /// Навигация назад через Router
    func goBack()
}

// MARK: - Interactor Input

protocol TaskDetailInteractorInputProtocol: AnyObject {
    var presenter: TaskDetailInteractorOutputProtocol? { get set }
    /// nil — создание новой задачи, non-nil — редактирование существующей
    var todo: TodoItem? { get set }

    func saveTodo(title: String, description: String)
}

// MARK: - Interactor Output

protocol TaskDetailInteractorOutputProtocol: AnyObject {
    /// Задача успешно записана в CoreData
    func didSaveTodo()
    func didFailWithError(_ message: String)
    /// Не используется напрямую — задача приходит через interactor.todo при старте
    func didLoadTodo(_ todo: TodoItem)
}

// MARK: - Router

protocol TaskDetailRouterProtocol: AnyObject {
    /// Собирает VIPER-модуль.
    /// - Parameters:
    ///   - todo: задача для редактирования, nil — режим создания
    ///   - delegate: уведомляет список задач об изменениях после сохранения
    static func createModule(with todo: TodoItem?, delegate: TaskDetailModuleDelegate?) -> UIViewController
    func goBack(from view: TaskDetailViewProtocol)
}
