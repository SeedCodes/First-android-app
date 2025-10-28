# Journal / Reflection Page - Implementation Notes

## Overview
The Journal page is the emotional and personal side of The Winter Arc app, allowing users to document their journey beyond just metrics and numbers. It adds depth and meaning to the challenge.

## Core Purpose
- Capture daily reflections and experiences
- Track emotional states (mood)
- Store visual proof (photos)
- Enable weekly deeper reflections
- Create a personal timeline of the arc journey

## Key Sections

### 1. Today's Entry Section
**Purpose**: Main daily journaling area

**Components:**
- Large multi-line text field (8 lines visible)
- Placeholder text with suggestions
- Dark input background for contrast
- Auto-save functionality

**Auto-Save Logic:**
- Triggers 1 second after user stops typing
- Uses Flutter's `onChanged` callback
- Debounces to avoid excessive saves
- Silent save (no user notification)

**Visual Design:**
- Card container with icon header
- Edit note icon to indicate writing space
- "Today's Entry" label
- Suggestion text in placeholder

### 2. Mood Picker
**Purpose**: Capture emotional state visually

**5 Mood Options:**
1. 😊 **Great** - Excellent day, everything going well
2. 🙂 **Good** - Positive day, steady progress
3. 😐 **Okay** - Neutral, just getting by
4. 😔 **Struggling** - Difficult day, challenges
5. 💪 **Motivated** - Energized, driven, pumped

**Interaction:**
- Tap emoji to select
- Selected mood shows highlighted border (blue)
- Selected mood has background tint
- Label turns blue when selected
- Saves immediately on selection

**Layout:**
- 5 equal-width boxes
- Emoji centered (28px size)
- Label below (11px font)
- Responsive spacing

### 3. Photo Attachment
**Purpose**: Visual proof and memory capture

**Features:**
- Single photo per day
- Upload button with dashed border
- Photo preview display
- Remove button (X) on preview
- Placeholder icons when no photo

**Current Implementation:**
- Placeholder for image picker
- Shows demo message when tapped
- Structure ready for `image_picker` package
- Stores path in model

**Future Integration:**
```dart
// Requires: image_picker: ^1.0.0
final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.gallery);
// OR ImageSource.camera for taking photo
```

**Use Cases:**
- Workout photo (gym selfie, equipment)
- Study notes (desk setup, books)
- Meal prep (healthy eating)
- Achievement screenshots
- Progress photos

### 4. Weekly Reflection Prompt
**Purpose**: Deeper reflection at weekly milestones

**Trigger Logic:**
- Appears every 7 days (day 7, 14, 21, etc.)
- Checks: `daysCompleted % 7 == 0`
- Only shows if not already completed for today
- Stored separately in entry model

**Components:**
- Purple gradient card (different from daily entry)
- Special icon (auto_awesome)
- Reflection prompt question
- Multi-line text field (4 lines)
- "Save Weekly Reflection" button
- Success notification on save

**Questions (could be rotated):**
- "How did your week go overall?"
- "What were your biggest wins this week?"
- "What challenges did you overcome?"
- "How have you grown in the past 7 days?"

**Visual Design:**
- Purple theme (`#9B59B6`) to differentiate
- Gradient background
- Prominent button
- Larger padding for importance

### 5. Journal History
**Purpose**: Review past entries and track journey

**Display Format:**
- Reverse chronological (newest first, excluding today)
- Card-based list
- Each card shows:
  - Date (formatted: "Jan 15, 2025")
  - Mood emoji (if logged)
  - Content preview (first 120 characters)
  - Photo indicator (green icon if photo exists)
  - Weekly reflection badge (purple badge if exists)

**Empty State:**
- Book icon
- "No past entries yet"
- Helpful subtext
- Shown when no history exists

**Entry Cards:**
- Dark background (`#1D1E33`)
- Light border
- Compact padding
- 3-line text truncation with ellipsis

## Data Model

### JournalEntry
```dart
{
  date: DateTime,              // When entry was created
  content: String,             // Daily reflection text
  mood: String?,               // Emoji character (optional)
  photoPath: String?,          // File path to photo (optional)
  weeklyReflection: String?    // Weekly reflection text (optional)
}
```

**Helper Methods:**
- `isToday()`: Check if entry is for current day
- `hasWeeklyReflection`: Boolean getter
- `isEmpty`: Check if entry has any content
- `getFormattedDate()`: Readable date string
- `getPreview()`: Truncated content for cards

## User Flow

### First Time User:
1. Taps "Journal" from bottom nav
2. Sees empty today's entry
3. Writes reflection
4. Selects mood
5. Optionally adds photo
6. Content auto-saves
7. Sees empty history section

### Returning User:
1. Opens journal
2. Sees today's entry (if already started) or blank
3. Can continue writing
4. Can change mood
5. Scrolls to see past entries
6. Reads previous reflections

### Week Completion (Day 7, 14, etc.):
1. Opens journal
2. Sees weekly reflection prompt (purple card)
3. Writes deeper weekly reflection
4. Taps "Save Weekly Reflection"
5. Gets confirmation
6. Prompt disappears
7. Weekly badge appears in history

## Storage Strategy

### Data Structure:
- List of `JournalEntry` objects
- Stored as JSON array in SharedPreferences
- Key: `journal_entries`

### Save Operations:
1. **Auto-save daily entry**: After 1-second delay
2. **Mood selection**: Immediate save
3. **Photo add/remove**: Immediate save
4. **Weekly reflection**: Manual save button

### Load Operations:
- On page init, load all entries
- Find today's entry if exists
- Calculate if weekly prompt should show
- Separate today from history

## Visual Design

### Color Palette:
- **Primary Blue**: `#4A90E2` (daily entry theme)
- **Purple**: `#9B59B6` (weekly reflection theme)
- **Green**: `#50C878` (success indicators)
- **Background**: `#0A0E21`
- **Cards**: `#1D1E33`

### Typography:
- Header: 32px bold white
- Subtext: 16px white70
- Entry text: 15px white (1.5 line height)
- Date labels: 14px blue
- Mood labels: 11px

### Spacing:
- Page padding: 24px
- Section gaps: 16-24px
- Card padding: 20px
- Element spacing: 8-12px

## Emotional Design Elements

### Why This Matters:
- Numbers alone don't tell the full story
- Mood tracking reveals patterns
- Reflections capture context
- Photos preserve memories
- Weekly reviews provide perspective

### Psychological Benefits:
1. **Self-awareness**: Recognize patterns in mood/behavior
2. **Accountability**: Written commitment increases follow-through
3. **Gratitude**: Reflecting on wins builds positivity
4. **Problem-solving**: Writing about struggles helps process them
5. **Memory**: Photos and text preserve the journey

### User Engagement:
- Low friction (auto-save)
- Visual feedback (emoji selection)
- Variety (daily + weekly prompts)
- Progress visibility (history)
- Optional depth (can write lots or little)

## Future Enhancements (Ideas)

### Potential Features:
- Search journal entries
- Filter by mood
- Export journal as PDF
- Mood graph over time (on Progress page)
- Multiple photos per day
- Voice recording option
- Tags/categories
- Favorite/star important entries
- Reminder notifications
- Writing prompts (random questions)
- Streak for consecutive journaling
- Word count tracker

### Advanced Analytics:
- Most common mood
- Mood correlation with goal completion
- Word cloud from entries
- Sentiment analysis
- Writing consistency graph

## Technical Notes

### Image Picker Integration:
To enable real photo uploads, add to `pubspec.yaml`:
```yaml
dependencies:
  image_picker: ^1.0.0
```

Then implement:
```dart
import 'package:image_picker/image_picker.dart';

Future<void> _addPhoto() async {
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: ImageSource.gallery, // or ImageSource.camera
    maxWidth: 1920,
    maxHeight: 1080,
    imageQuality: 85,
  );
  
  if (image != null) {
    setState(() {
      _photoPath = image.path;
    });
    _saveEntry();
  }
}
```

### Performance Considerations:
1. **Lazy loading**: Only load visible history entries for very long journals
2. **Image caching**: Use Flutter's image cache for photos
3. **Debounced saves**: Prevent excessive writes
4. **Efficient JSON**: Serialize only changed entries

## Testing Scenarios

### Basic Functionality:
1. Write entry → auto-saves
2. Select mood → saves immediately
3. Add photo → preview shows
4. Remove photo → preview disappears
5. Navigate away → data persists

### Weekly Reflection:
1. On day 7 → prompt appears
2. Save reflection → prompt disappears
3. Badge shows in history
4. On day 8 → no prompt
5. On day 14 → prompt appears again

### History:
1. No entries → empty state
2. One entry → shows in history
3. Multiple entries → chronological order
4. Entry with photo → icon indicator
5. Entry with weekly → badge shows

## Accessibility Notes

- Large touch targets (56x56px for mood)
- High contrast text
- Clear labels
- Keyboard support for text input
- Screen reader friendly (add semantics)

## Privacy & Security

**Current:**
- Data stored locally on device
- Not uploaded anywhere
- Persists only in app storage

**Future Considerations:**
- Optional cloud backup
- Export/import functionality
- Encryption for sensitive entries
- Secure photo storage
