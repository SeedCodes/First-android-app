class QuotesHelper {
  static final List<String> _quotes = [
    "Stay locked in. Small wins build arcs.",
    "Discipline is choosing what you want most over what you want now.",
    "Every day is a new chapter in your arc.",
    "Progress, not perfection. Keep moving forward.",
    "The Winter Arc is where legends are forged.",
    "Consistency beats intensity. Show up daily.",
    "Your future self is watching. Make them proud.",
    "Cold days build strong character.",
    "Champions are made in the off-season.",
    "One percent better every day compounds.",
    "The grind doesn't stop. Neither do you.",
    "Embrace the struggle. That's where growth lives.",
    "Your arc, your rules, your transformation.",
    "Winter is coming. Are you ready?",
    "No zero days. Every day counts.",
    "The best project you'll ever work on is yourself.",
    "Comfort is the enemy of progress.",
    "Build today. Celebrate tomorrow.",
    "Your only limit is you.",
    "Make this arc unforgettable.",
    "Sweat now, shine later.",
    "The pain of discipline is temporary. The pain of regret is forever.",
    "You didn't come this far to only come this far.",
    "Trust the process. Respect the journey.",
    "Excellence is a habit, not an act.",
    "Wake up with determination. Sleep with satisfaction.",
    "Your goals don't care how you feel.",
    "Be stronger than your excuses.",
    "The harder you work, the luckier you get.",
    "Success is the sum of small efforts repeated daily.",
  ];

  // Get a quote based on the current day (pseudo-random but consistent per day)
  static String getDailyQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % _quotes.length;
    return _quotes[index];
  }

  // Get a random quote
  static String getRandomQuote() {
    final index = DateTime.now().millisecond % _quotes.length;
    return _quotes[index];
  }

  // Get all quotes
  static List<String> getAllQuotes() {
    return List.unmodifiable(_quotes);
  }
}
