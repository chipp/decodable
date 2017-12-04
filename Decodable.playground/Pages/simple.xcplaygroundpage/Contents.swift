import Foundation

// Самый простой пример: распарсить массив моделей.
// Ключи модели совпадают с ключами JSON.

let url = Bundle.main.url(forResource: "content", withExtension: "json")!
let data = try! Data(contentsOf: url)

struct Team: Decodable {
  let name: String
}

struct Player: Decodable {
  let firstName: String, lastName: String, displayName: String?, team: Team
}

let decoder = JSONDecoder()
let players = try! decoder.decode([Player].self, from: data)
dump(players)
