import Foundation

func fill(_ n: Int) -> [Int] {
    var a: [Int] = []
    for _ in 0..<n {
        a.append(Int.random(in: 0...2))
    }
    return a
}

func limit(_ a: [Int]) -> [Int] {
    var r: [Int] = []
    var c0 = 0, c1 = 0, c2 = 0
    for x in a {
        if x == 0 && c0 < 3 { r.append(x); c0 += 1 }
        else if x == 1 && c1 < 5 { r.append(x); c1 += 1 }
        else if x == 2 && c2 < 6 { r.append(x); c2 += 1 }
    }
    return r
}

func bubbleSort(_ a: inout [Int]) {
    if a.count < 2 { return }
    for i in 0..<(a.count - 1) {
        for j in 0..<(a.count - 1 - i) {
            if a[j] > a[j + 1] {
                a.swapAt(j, j + 1)
            }
        }
    }
}

var a = fill(30)
var b = limit(a)
bubbleSort(&b)
print("src:", a)
print("res:", b)