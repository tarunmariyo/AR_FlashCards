import Foundation

extension String {
    func levenshteinDistance(to string: String) -> Int {
        let str1 = Array(self)
        let str2 = Array(string)
        var matrix = Array(repeating: Array(repeating: 0, count: str2.count + 1), count: str1.count + 1)
        
        for i in 0...str1.count {
            matrix[i][0] = i
        }
        for j in 0...str2.count {
            matrix[0][j] = j
        }
        
        for i in 1...str1.count {
            for j in 1...str2.count {
                if str1[i - 1] == str2[j - 1] {
                    matrix[i][j] = matrix[i - 1][j - 1]
                } else {
                    matrix[i][j] = Swift.min(
                        matrix[i - 1][j] + 1,     // deletion
                        matrix[i][j - 1] + 1,     // insertion
                        matrix[i - 1][j - 1] + 1  // substitution
                    )
                }
            }
        }
        
        return matrix[str1.count][str2.count]
    }
}