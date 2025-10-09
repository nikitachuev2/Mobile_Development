var a = [5, 3, 8, 1, 2]

for i in 0..<a.count - 1 {
    for j in 0..<a.count - 1 - i {
        if a[j] > a[j + 1] {
            let t = a[j]
            a[j] = a[j + 1]
            a[j + 1] = t
        }
    }
}

print(a)