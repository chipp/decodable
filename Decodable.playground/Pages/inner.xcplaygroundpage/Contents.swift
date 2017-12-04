import Foundation

// Массив моделей находится внутри словаря: {"players": []}.

let url = Bundle.main.url(forResource: "content", withExtension: "json")!
let data = try! Data(contentsOf: url)

struct Team: Decodable {
  let name: String
}

struct Player: Decodable {
  let firstName: String, lastName: String, displayName: String?, team: Team

  private enum CodingKeys: String, CodingKey {
    case firstName = "first_name", lastName = "last_name", displayName = "display_name"
    case team
  }
}

// Можно распарсить его как словарь.

let decoder = JSONDecoder()
do {
  let dictionary = try decoder.decode([String: [Player]].self, from: data)
  dump(dictionary["players", default: []])
  // Однако, в этом случае парсер не вернёт ошибку, если нет ожидаемого ключа players.
  // Об его отсутствии мы узнаем только когда попытаемся разобрать результат
  print()
} catch {
  dump(error)
}

// Можно ввести новую модель Container

struct PlayersContainer: Decodable {
  let players: [Player]
}

do {
  let container = try decoder.decode(PlayersContainer.self, from: data)
  dump(container.players)
  // Таким образом, парсер вернёт ошибку, если не будет нужного нам ключа players.
  // Но очень не хочется описывать такие контейнеры для каждого возможного ответа.
  print()
} catch {
  dump(error)
}

// Поэтому мы можем создать контейнер с generic-параметром.
// Для этого нам нужен протокол, который будут реализовывать модели (Player, Team).
// В реализации нужно будет объявить ключ, по которому из словаря можно достать
// массив моделей.

protocol ContainableModel: Decodable {
  static var key: String { get }
}

extension Player: ContainableModel {
  static let key = "players"
}

extension Team: ContainableModel {
  static let key = "teams"
}

struct GenericContainer<M: ContainableModel>: Decodable {
  let models: [M]

  private enum CodingKeys: CodingKey {
    /*  Т.к. в качестве значения для enum Enum: String могут быть только строковые литералы,
        то мы не может использовать динамический ключ для свойства models.
        Необходимо самостоятельно реализовать поддержку протокола CodingKey */
    case models

    /*  Для этого необходимо вернуть строковое значение для каждого элемента enum
        (в нашем случае один case, поэтому всегда будем возвращать M.key).*/
    var stringValue: String {
      return M.key
    }

    /*  И реализовать инициализацию по строковому значению.
        Если оно совпадает с M.key – значит это наш ключ models */
    init?(stringValue: String) {
      switch stringValue {
      case M.key: self = .models
      default: return nil
      }
    }

    var intValue: Int? { return nil }
    init?(intValue: Int) { return nil }
  }
}

do {
  let container = try decoder.decode(GenericContainer<Player>.self, from: data)
  dump(container.models)
} catch {
  dump(error)
}
