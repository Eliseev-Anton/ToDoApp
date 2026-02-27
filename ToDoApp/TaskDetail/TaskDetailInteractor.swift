import Foundation

/// Interactor экрана задачи — содержит всю бизнес-логику сохранения.
///
/// Два сценария работы, которые определяются наличием поля todo:
/// 1. todo == nil  создаём новую запись в CoreData с новым id
/// 2. todo != nil  обновляем существующую запись по id
final class TaskDetailInteractor: TaskDetailInteractorInputProtocol {

    weak var presenter: TaskDetailInteractorOutputProtocol?
    /// Инжектируется Router'ом при создании модуля. nil = режим создания.
    var todo: TodoItem?

    private let coreDataManager = CoreDataManager.shared

    /// Определяет нужный сценарий и вызывает соответствующий метод CoreDataManager.
    func saveTodo(title: String, description: String) {
        if var existingTodo = todo {
            // Редактирование: меняем только title и description, остальное (id, дата) не трогаем
            existingTodo.title = title
            existingTodo.descriptionText = description
            coreDataManager.updateTodo(existingTodo) { [weak self] success in
                if success {
                    self?.presenter?.didSaveTodo()
                } else {
                    self?.presenter?.didFailWithError("Не удалось сохранить задачу")
                }
            }
        } else {
            // Создание: сначала получаем следующий свободный id, потом записываем
            coreDataManager.nextId { [weak self] nextId in
                let newTodo = TodoItem(
                    id: nextId,
                    title: title,
                    descriptionText: description,
                    createdDate: Date(),
                    isCompleted: false // новая задача всегда не выполнена
                )
                self?.coreDataManager.saveTodo(newTodo) { success in
                    if success {
                        self?.presenter?.didSaveTodo()
                    } else {
                        self?.presenter?.didFailWithError("Не удалось создать задачу")
                    }
                }
            }
        }
    }
}
