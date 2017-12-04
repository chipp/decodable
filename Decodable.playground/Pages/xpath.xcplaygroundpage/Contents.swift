import Foundation

// В этом playground стоит задача распарсить массив игроков, пройдя по нескольким
// ключам внутрь рутового словаря document → result → players

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

// Для этого понадобится вспомогательный тип Path, который будет содержать в себе
// путь из ключей, который нам нужно пройти до массива Players

struct Path: CodingKey {
  init?(stringValue: String) {
    self.components = [stringValue]
  }

  var stringValue: String {
    return components[0]
  }

  var intValue: Int?
  init?(intValue: Int) { return nil }

  let components: [String]

  init(components: [String]) {
    self.components = components
  }

  var next: Path {
    var components = self.components
    _ = components.removeFirst()
    return Path(components: components)
  }
}

extension Decoder {

  // Нужен вспомогательный метод для Decoder, чтобы извлечь нужный контейнер
  // по пути заданному в Path.

  func decoder(for path: Path) throws -> Decoder {
    var container = try self.container(keyedBy: Path.self)
    var path = path
    while path.components.count > 1 {
      container = try container.nestedContainer(keyedBy: Path.self, forKey: path)
      path = path.next
    }
    return try container.superDecoder(forKey: path)
  }

}

struct Container: Decodable {
  let models: [Player]

  init(from decoder: Decoder) throws {
    let path = Path(components: ["document", "result", "players"])
    let decoder = try decoder.decoder(for: path)
    let container = try decoder.singleValueContainer()
    models = try container.decode([Player].self)
  }
}

let decoder = JSONDecoder()
let container = try! decoder.decode(Container.self, from: data)
dump(container.models)
