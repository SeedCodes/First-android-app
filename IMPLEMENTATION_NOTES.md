# Implementation Notes - Home Dashboard

## Page Overview
The Home Dashboard is the core daily tracking interface where users interact with their Winter Arc challenge every day.

## Key Components

### 1. Dual Progress Rings
- **Outer Ring (Blue)**: Shows overall arc progress (days completed / total days)
- **Inner Ring (Green)**: Shows today's goal completion percentage
- **Center Display**: Current day number and daily completion percentage
- **Custom Painter**: Uses Flutter's `CustomPainter` class for smooth circular progress visualization

### 2. Daily Goals System
The app uses a smart daily reset system:
- Goals are stored with a timestamp
- On app load, the system checks if saved progress is from today
- If not today, it creates fresh progress for the current day
- All goals start unchecked each day
- User can check/uncheck goals in real-time
- Progress is saved immediately to SharedPreferences

### 3. Motivational Quotes
- 30+ curated quotes focused on discipline and growth
- Quote changes daily based on day of year
- Consistent quote per day (same quote all day)
- Displayed in a gradient card below goals

### 4. Bottom Navigation Bar
- **Home**: Current page (highlighted)
- **Progress**: Stats & streaks page (placeholder)
- **Journal**: Reflections page (placeholder)
- **Profile**: Settings & user info (placeholder)

## Data Flow

```
App Start
    ↓
Check if Arc exists (main.dart)
    ↓
Yes → Load Home Dashboard
No → Show Arc Setup
    ↓
Home Dashboard loads:
  1. Arc data (name, duration, start date)
  2. Daily progress (today's goal status)
  3. Calculate days completed
  4. Generate daily quote
    ↓
User checks goal
    ↓
Update state + Save to storage
    ↓
Progress ring updates visually
```

## Models

### ArcData
- `arcName`: String (user's arc title)
- `duration`: int (70-90 days)
- `goals`: List<String> (3-5 goals)
- `startDate`: DateTime
- Methods: getDaysCompleted(), getDaysRemaining(), getProgressPercentage()

### DailyProgress
- `goals`: Map<String, bool> (goal name → completion status)
- `date`: DateTime (when progress was created)
- Methods: toggleGoal(), getCompletedCount(), getCompletionPercentage(), isToday()

## Storage Strategy

### SharedPreferences Keys
- `arc_data`: Stores the arc configuration (created once during setup)
- `daily_progress`: Stores today's goal completion (resets daily)

### Auto-Reset Logic
When loading daily progress:
1. Retrieve stored progress from SharedPreferences
2. Check if `progress.date` matches today's date
3. If yes → return existing progress
4. If no → return null (triggers creation of fresh progress)

## Visual Design

### Color Palette
- Background: `#0A0E21` (Dark Navy)
- Card Surface: `#1D1E33` (Lighter Navy)
- Primary (Blue): `#4A90E2`
- Success (Green): `#50C878`
- Text: White with varying opacity

### Spacing & Layout
- Consistent 24px padding around screen edges
- 40px spacing between major sections
- 16px padding inside cards
- 12px spacing between interactive elements

### Interactive States
**Unchecked Goal:**
- Dark background `#0A0E21`
- Light border (white12)
- Empty checkbox with border
- Normal font weight

**Checked Goal:**
- Green-tinted background
- Green border `#50C878`
- Filled checkbox with checkmark
- Strikethrough text
- Celebration icon

## User Experience Features

1. **Instant Feedback**: Goals update immediately on tap
2. **Visual Rewards**: Checked goals show celebration icon
3. **Progress Visibility**: Dual rings show both daily and overall progress
4. **Motivation**: Daily quote keeps users inspired
5. **Navigation**: Easy access to other features via bottom nav

## Future Integration Points

The bottom navigation is ready for:
- Progress page (stats, streaks, charts)
- Journal page (daily reflections)
- Profile page (user settings, arc management)

All navigation items show "Coming soon" snackbars when tapped.

## Testing Scenarios

1. **First Time User**: Setup arc → redirected to dashboard
2. **Returning User**: Opens app → see dashboard with saved arc
3. **Goal Completion**: Tap goals → see progress ring fill up
4. **Daily Reset**: Open app next day → goals reset to unchecked
5. **Multiple Days**: Progress outer ring advances over time

## Performance Notes

- Minimal rebuilds: Only goal list and progress rings rebuild on state change
- Efficient storage: Only save when data changes
- Lazy loading: Data loaded once on init
- Smooth animations: CustomPainter for efficient ring rendering
