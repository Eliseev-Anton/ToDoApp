import UIKit

/// Экран создания и редактирования задачи.
///
/// Открывается как fullScreen overlay поверх списка.
/// Кастомная кнопка «Назад» (стрелка из Assets + текст) закрывает overlay.
/// Сохранение происходит автоматически при закрытии экрана.
final class TaskDetailViewController: UIViewController, TaskDetailViewProtocol {
    
    var presenter: TaskDetailPresenterProtocol?
    
    private var isEditingExisting = false
    private var descriptionBottomConstraint: NSLayoutConstraint?
    // MARK: - UI Elements
    
    /// Кастомная кнопка «Назад» — стрелка из Assets (back) + текст жёлтым.
    /// UIStackView с UIImageView + UILabel — никакой подложки.
    private lazy var backButton: UIStackView = {
        let yellow = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        
        let arrow = UIImageView(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate))
        arrow.tintColor = yellow
        arrow.contentMode = .scaleAspectFit
        arrow.translatesAutoresizingMaskIntoConstraints = false
        arrow.widthAnchor.constraint(equalToConstant: 12).isActive = true
        arrow.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let label = UILabel()
        label.text = "Назад"
        label.font = .systemFont(ofSize: 17)
        label.textColor = yellow
        
        let stack = UIStackView(arrangedSubviews: [arrow, label])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backTapped))
        stack.addGestureRecognizer(tap)
        stack.isUserInteractionEnabled = true
        
        return stack
    }()
    
    private lazy var titleTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 34, weight: .bold)
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: "Название",
            attributes: [.foregroundColor: UIColor.darkGray]
        )
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16, weight: .regular)
        tv.textColor = .white
        tv.backgroundColor = .clear
        tv.isScrollEnabled = true
        // Небольшой отрицательный отступ слева выравнивает текст с titleTextField
        tv.textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    /// UITextView не имеет встроенного плейсхолдера — добавляем поверх как subview
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Введите описание..."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardDismissOnTap()
        presenter?.viewDidLoad()
        descriptionTextView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        overrideUserInterfaceStyle = .dark
        
        view.addSubview(backButton)
        view.addSubview(titleTextField)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
        descriptionTextView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleTextField.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            {
                let c = descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
                descriptionBottomConstraint = c
                return c
            }(),
            
            placeholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 0),
            placeholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor, constant: 0),
        ])
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        dateLabel.text = formatter.string(from: Date())
    }
    
    // MARK: - Keyboard
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.descriptionBottomConstraint?.constant = -keyboardHeight - 16
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.descriptionBottomConstraint?.constant = -16
            self.view.layoutIfNeeded()
        }
    }
    
    
    // MARK: - Actions
    
    /// Нажатие «Назад» — сохраняем и закрываем overlay
    @objc private func backTapped() {
        saveIfNeeded()
        dismiss(animated: true)
    }
    
    /// Сохраняем только если есть непустой заголовок — не создаём «пустые» задачи
    private func saveIfNeeded() {
        let title = titleTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            presenter?.saveTodo(title: title, description: description)
        }
      
    }
    
    // MARK: - TaskDetailViewProtocol
    
    func showTodo(_ todo: TodoItem) {
        isEditingExisting = true
        titleTextField.text = todo.title
        descriptionTextView.text = todo.descriptionText
        placeholderLabel.isHidden = !todo.descriptionText.isEmpty
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        dateLabel.text = formatter.string(from: todo.createdDate)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func taskSaved() {
        // Задача сохранена — список обновится через делегат, здесь дополнительных действий нет
    }
}

// MARK: - UITextViewDelegate

extension TaskDetailViewController: UITextViewDelegate {
    /// Скрываем плейсхолдер как только пользователь начал печатать
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
