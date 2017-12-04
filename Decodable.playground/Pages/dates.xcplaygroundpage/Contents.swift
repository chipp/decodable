import Foundation

let url = Bundle.main.url(forResource: "content", withExtension: "json")!
let data = try! Data(contentsOf: url)

struct Team: Decodable {
  let name: String
}

struct Player: Decodable {
  let firstName: String, lastName: String, displayName: String?, team: Team
  let birthday: Date
}

let decoder = JSONDecoder()

// Для парсинга дат в JSONDecoder есть свойство dateDecodingStrategy:
// мы можем сконфигурировать каким образом мы хотим парсить дату.
// В нашем случае мы будем использовать DateFormatter

let formatter = DateFormatter()
formatter.locale = Locale(identifier: "en_US_POSIX")
formatter.dateFormat = "dd/MM/yyyy"
decoder.dateDecodingStrategy = .formatted(formatter)

let players = try! decoder.decode([Player].self, from: data)
dump(players.map { $0.birthday })
