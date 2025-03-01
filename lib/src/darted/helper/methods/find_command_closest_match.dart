String? getClosestMatch(String? input, List<String> searchList,
    {int maxDistance = 2}) {
  String? closest;
  int minDistance = maxDistance + 1;

  int calculateDistance(String s1, String s2) {
    List<List<int>> dp = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 +
              [
                dp[i - 1][j], // Deletion
                dp[i][j - 1], // Insertion
                dp[i - 1][j - 1] // Substitution
              ].reduce((a, b) => a < b ? a : b);
        }
      }
    }

    return dp[s1.length][s2.length];
  }

  if (input != null) {
    for (String command in searchList) {
      int distance = calculateDistance(input, command);
      if (distance < minDistance) {
        minDistance = distance;
        closest = command;
      }
    }
  }

  return closest;
}
