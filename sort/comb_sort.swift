var a = [9, 4, 1, 7, 3, 8, 2, 6, 5]

var g = a.count
var s = true
while g > 1 || s {
    g = Int(Double(g) / 1.3)
    if g < 1 { g = 1 }
    s = false
    for i in 0..<(a.count - g) {
        if a[i] > a[i + g] {
            a.swapAt(i, i + g)
            s = true
        }
    }
}

print(a)
