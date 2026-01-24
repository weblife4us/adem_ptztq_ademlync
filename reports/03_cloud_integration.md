# 03 - Облачная интеграция

## AWS API Gateway

### Endpoint

```
Host: y1w5f43rx8.execute-api.us-east-1.amazonaws.com
Base Path: /production
```

## API Endpoints

### Аутентификация

| Endpoint | Метод | Описание |
|----------|-------|----------|
| `/sign-in` | POST | Вход в систему |
| `/user/forgot-password` | POST | Восстановление пароля |
| `/user/confirm-forgot-password` | POST | Подтверждение сброса пароля |

### MFA (Multi-Factor Authentication)

| Endpoint | Метод | Описание |
|----------|-------|----------|
| `/get-mfa-status` | GET | Статус MFA |
| `/enable-mfa` | POST | Включение MFA |
| `/verify-mfa` | POST | Верификация MFA |
| `/mfa-challenge` | POST | MFA челлендж |
| `/discover-idp` | GET | Обнаружение IdP |

### Управление пользователями

| Endpoint | Метод | Описание |
|----------|-------|----------|
| `/user/create` | POST | Создание пользователя |
| `/user/delete` | DELETE | Удаление пользователя |
| `/user/modify` | PUT | Изменение пользователя |
| `/user/list` | GET | Список пользователей |
| `/user/groups` | GET | Группы пользователей |

### Работа с данными

| Endpoint | Метод | Описание |
|----------|-------|----------|
| `/data/upload` | POST | Загрузка файла |
| `/data/list-files` | GET | Список файлов |
| `/data/list-folders` | GET | Список папок |
| `/download-file` | GET | Скачивание файла |
| `/data/bulk-download` | POST | Массовое скачивание |

## Аутентификация запросов

Все запросы требуют Bearer токен в заголовке:

```
Authorization: Bearer <access_token>
```

## Типы файлов (CloudFileType)

Приложение работает с различными типами логов:
- Daily logs
- Interval logs
- Event logs
- Alarm logs
- Q logs
- Flow DP logs

## Форматы экспорта (ExportFormat)

Поддерживаемые форматы для выгрузки данных:
- CSV
- Excel
- PDF

## Менеджеры облака

### CloudManager

Singleton класс, объединяющий:
- `UserManager` - управление пользователями
- `FileManager` - работа с файлами

### Основные методы CloudManager

```dart
// Аутентификация
Future<String?> login(email, password)
Future<void> loginAsNewUser(email, password, newPassword)
void logout()

// MFA
Future<bool?> getMfaStatus(email)
Future<String?> enableMfa(email)
Future<void> verifyMfa(email, otp)

// Пользователи
Future<List<User>> fetchUsers()
Future<List<Group>> fetchGroups()
Future<void> createUser(email, group)
Future<void> updateUser(email, group)
Future<void> deleteUser(email)

// Файлы
Future<List<String>> fetchFiles(type, sn)
Future<List<String>> fetchFolders(type)
Future<void> uploadFile(sn, folderPath, filePath, filename, fmt)
Future<void> requestDownloadFileEmail(filePath)
```
