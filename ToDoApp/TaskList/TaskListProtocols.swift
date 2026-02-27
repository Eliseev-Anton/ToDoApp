import UIKit

/// Контракты VIPER-модуля списка задач.
///
/// Каждый протокол описывает зону ответственности одного компонента.
/// Все зависимости между компонентами — только через эти протоколы,

// MARK: - View

/// View знает только о том, что нужно отобразить — никакой бизнес-логики
protocol TaskListViewProtocol: AnyObject {
    var presenter: TaskListPresenterProtocol? { get set }

    /// Обновляет список задач на экране
    func showTodos(_ todos: [TodoItem])
    /// Показывает алерт с текстом ошибки пользователю
    func showError(_ message: String)
}

// MARK: - Presenter

/// Посредник между View и Interactor.
/// Получает пользовательские события от View, отдаёт команды Interactor,
/// форматирует данные для отображения.
protocol TaskListPresenterProtocol: AnyObject {
    var view: TaskListViewProtocol? { get set }
    var interactor: TaskListInteractorInputProtocol? { get set }
    var router: TaskListRouterProtocol? { get set }

    /// Вызывается при загрузке экрана — запускает загрузку задач
    func viewDidLoad()
    /// Пользователь нажал на задачу — открыть экран редактирования
    func didSelectTodo(_ todo: TodoItem)
    /// Нажата кнопка создания новой задачи
    func addNewTodo()
    /// Удалить задачу (вызывается из контекстного меню)
    func deleteTodo(_ todo: TodoItem)
    /// Переключить статус выполнения задачи
    func toggleTodoCompletion(_ todo: TodoItem)
    /// Поиск по строке запроса
    func searchTodos(query: String)
    /// Поделиться текстом задачи через системный шаринг
    func shareTodo(_ todo: TodoItem, from view: UIViewController)
}

// MARK: - Interactor Input

/// Интерфейс Interactor, доступный Presenter-у.
/// Interactor работает с данными: CoreData, сеть, бизнес-правила.
protocol TaskListInteractorInputProtocol: AnyObject {
    var presenter: TaskListInteractorOutputProtocol? { get set }

    /// Загружает задачи — из CoreData если есть, иначе из API
    func fetchTodos()
    func deleteTodo(id: Int64)
    func toggleTodoCompletion(id: Int64)
    func searchTodos(query: String)
}

// MARK: - Interactor Output

/// Обратная связь от Interactor к Presenter после завершения асинхронных операций
protocol TaskListInteractorOutputProtocol: AnyObject {
    /// Возвращает актуальный список задач после любой операции
    func didFetchTodos(_ todos: [TodoItem])
    /// Что-то пошло не так — Presenter решит, как уведомить пользователя
    func didFailWithError(_ message: String)
    /// Данные изменились (удаление, toggle) — нужно перечитать список
    func didUpdateData()
}

// MARK: - Router

/// Отвечает исключительно за навигацию: создание модулей и переходы между экранами
protocol TaskListRouterProtocol: AnyObject {
    /// Собирает весь VIPER-модуль и возвращает готовый NavigationController
    static func createModule() -> UINavigationController
    /// Переходит на экран детального просмотра/редактирования задачи.
    /// todo == nil означает создание новой задачи.
    func navigateToDetail(from view: TaskListViewProtocol, with todo: TodoItem?)
}

