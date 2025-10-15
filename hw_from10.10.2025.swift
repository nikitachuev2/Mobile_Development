import Foundation

enum Gender: CaseIterable { case male, female }

class Animal {
    let species: String
    var name: String
    var age: Int
    var gender: Gender
    var hunger: Int
    var thirst: Int
    var health: Int
    var alive: Bool
    let metabolism: Int
    let sickChance: Int
    let reproChance: Int
    let walkCost: Int

    init(species: String, name: String, age: Int, gender: Gender, metabolism: Int, sickChance: Int, reproChance: Int, walkCost: Int) {
        self.species = species
        self.name = name
        self.age = age
        self.gender = gender
        self.hunger = Int.random(in: 10...40)
        self.thirst = Int.random(in: 10...40)
        self.health = Int.random(in: 70...100)
        self.alive = true
        self.metabolism = metabolism
        self.sickChance = sickChance
        self.reproChance = reproChance
        self.walkCost = walkCost
    }

    func eat() -> String {
        if !alive { return "" }
        let gain = Int.random(in: 25...40)
        hunger = max(0, hunger - gain)
        health = min(100, health + Int.random(in: 1...3))
        return "\(name) (\(species)) поел"
    }

    func drink() -> String {
        if !alive { return "" }
        let gain = Int.random(in: 25...40)
        thirst = max(0, thirst - gain)
        health = min(100, health + Int.random(in: 1...3))
        return "\(name) (\(species)) попил"
    }

    func walk() -> String {
        if !alive { return "" }
        hunger = min(100, hunger + walkCost)
        thirst = min(100, thirst + walkCost)
        health = min(100, health + Int.random(in: 0...2))
        return "\(name) (\(species)) погулял"
    }

    func tickBody() {
        hunger = min(100, hunger + metabolism)
        thirst = min(100, thirst + metabolism)
        if Int.random(in: 1...100) <= sickChance { health = max(0, health - Int.random(in: 5...15)) }
        if hunger > 80 { health = max(0, health - Int.random(in: 5...12)) }
        if thirst > 80 { health = max(0, health - Int.random(in: 7...16)) }
        if health == 0 || hunger == 100 || thirst == 100 { alive = false }
        age += Int.random(in: 0...1)
        if age > 25 && Int.random(in: 0...10) == 0 { health = max(0, health - 10) }
    }

    func canMate(with other: Animal) -> Bool {
        alive && other.alive && species == other.species && gender != other.gender && age >= 2 && other.age >= 2
    }

    func tryMate(with other: Animal) -> Animal? {
        if !canMate(with: other) { return nil }
        let chance = max(reproChance, other.reproChance)
        if Int.random(in: 1...100) <= chance {
            let g = Gender.allCases.randomElement()!
            let babyName = "\(species)-детёныш-\(Int.random(in: 100...999))"
            return Animal(species: species, name: babyName, age: 0, gender: g, metabolism: metabolism, sickChance: sickChance, reproChance: reproChance, walkCost: walkCost)
        }
        return nil
    }
}

final class Lion: Animal {
    init(idx: Int, gender: Gender) { super.init(species: "Лев", name: "Лев-\(idx)", age: Int.random(in: 1...12), gender: gender, metabolism: 9, sickChance: 7, reproChance: 18, walkCost: 10) }
}
final class Elephant: Animal {
    init(idx: Int, gender: Gender) { super.init(species: "Слон", name: "Слон-\(idx)", age: Int.random(in: 1...20), gender: gender, metabolism: 6, sickChance: 5, reproChance: 12, walkCost: 7) }
}
final class Monkey: Animal {
    init(idx: Int, gender: Gender) { super.init(species: "Обезьяна", name: "Обезьяна-\(idx)", age: Int.random(in: 1...18), gender: gender, metabolism: 8, sickChance: 10, reproChance: 20, walkCost: 9) }
}
final class Giraffe: Animal {
    init(idx: Int, gender: Gender) { super.init(species: "Жираф", name: "Жираф-\(idx)", age: Int.random(in: 1...20), gender: gender, metabolism: 7, sickChance: 6, reproChance: 14, walkCost: 8) }
}
final class Zebra: Animal {
    init(idx: Int, gender: Gender) { super.init(species: "Зебра", name: "Зебра-\(idx)", age: Int.random(in: 1...15), gender: gender, metabolism: 8, sickChance: 8, reproChance: 16, walkCost: 9) }
}
final class Penguin: Animal {
    init(idx: Int, gender: Gender) { super.init(species: "Пингвин", name: "Пингвин-\(idx)", age: Int.random(in: 1...12), gender: gender, metabolism: 7, sickChance: 9, reproChance: 15, walkCost: 8) }
}

class Zoo {
    var animals: [Animal] = []
    var day: Int = 0
    private var announcedDead: Set<String> = []

    init() {
        seed()
    }

    func seed() {
        animals += makeGroup(count: Int.random(in: 2...5)) { i, g in Lion(idx: i, gender: g) }
        animals += makeGroup(count: Int.random(in: 2...6)) { i, g in Elephant(idx: i, gender: g) }
        animals += makeGroup(count: Int.random(in: 3...8)) { i, g in Monkey(idx: i, gender: g) }
        animals += makeGroup(count: Int.random(in: 2...6)) { i, g in Giraffe(idx: i, gender: g) }
        animals += makeGroup(count: Int.random(in: 3...8)) { i, g in Zebra(idx: i, gender: g) }
        animals += makeGroup(count: Int.random(in: 4...10)) { i, g in Penguin(idx: i, gender: g) }
    }

    func makeGroup<T: Animal>(count: Int, _ build: (Int, Gender) -> T) -> [Animal] {
        var arr: [Animal] = []
        for i in 1...count { arr.append(build(i, Gender.allCases.randomElement()!)) }
        return arr
    }

    func stats() -> String {
        let alive = animals.filter { $0.alive }
        let by = Dictionary(grouping: alive, by: { $0.species }).mapValues { $0.count }
        let dead = animals.count - alive.count
        let parts = by.keys.sorted().map { "\($0): \(by[$0] ?? 0)" }
        return "[живые: \(alive.count)] \(parts.joined(separator: ", ")) | погибло: \(dead)"
    }

    func randomAction(for a: Animal) -> String {
        let r = Int.random(in: 1...100)
        if r <= 35 { return a.eat() }
        else if r <= 65 { return a.drink() }
        else { return a.walk() }
    }

    func tryReproLogs() -> [String] {
        var logs: [String] = []
        let aliveBySpecies = Dictionary(grouping: animals.filter { $0.alive }, by: { $0.species })
        for (_, group) in aliveBySpecies {
            if group.count < 2 { continue }
            var males = group.filter { $0.gender == .male }
            var females = group.filter { $0.gender == .female }
            males.shuffle()
            females.shuffle()
            let pairs = min(males.count, females.count)
            for i in 0..<pairs {
                if Int.random(in: 1...100) <= 30 {
                    if let baby = males[i].tryMate(with: females[i]) {
                        animals.append(baby)
                        logs.append("Родился \(baby.species) \(baby.name)")
                    }
                }
            }
        }
        return logs
    }

    func removeDeadLogs() -> [String] {
        let newlyDead = animals.filter { !$0.alive && !announcedDead.contains($0.name) }
        newlyDead.forEach { announcedDead.insert($0.name) }
        return newlyDead.map { "\($0.name) (\($0.species)) умер" }
    }

    func tick() -> [String] {
        day += 1
        var logs: [String] = ["— День \(day) —"]
        let deathsBeforeCount = animals.filter { !$0.alive }.count
        for a in animals.shuffled() where a.alive {
            logs.append(randomAction(for: a))
            a.tickBody()
        }
        logs.append(contentsOf: tryReproLogs())
        let deathLogs = removeDeadLogs()
        if !deathLogs.isEmpty { logs.append(contentsOf: deathLogs) }
        let newDeaths = animals.filter { !$0.alive }.count - deathsBeforeCount
        if newDeaths > 0 && Int.random(in: 0...1) == 0 { logs.append("Печальный день для зоопарка") }
        logs.append(stats())
        return logs.filter { !$0.isEmpty }
    }
}

let zoo = Zoo()
print("Старт зоопарка. \(zoo.stats())")
for _ in 1...10 {
    let out = zoo.tick()
    for line in out { print(line) }
    Thread.sleep(forTimeInterval: 0.1)
}
print("Итоги: \(zoo.stats())")
