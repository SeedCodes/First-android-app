# Profile / Settings Page - Implementation Notes

## Overview
The Profile/Settings page is the control center of The Winter Arc app, giving users flexibility to customize their experience and manage their arc without losing progress.

## Core Purpose
- Display current arc information
- Allow editing of arc details (name, goals)
- Provide customization options (theme, notifications)
- Enable arc restart with safety measures
- Show app information and credits

## Key Sections

### 1. Arc Information Section
**Purpose**: Display and manage current arc details

**Display Elements:**
- Arc name in large green text
- Day counter (e.g., "Day 18/75")
- Days remaining chip
- Complete list of current goals with checkmarks
- Gradient blue-green background card

**Action Buttons:**
1. **Edit Name** - Opens dialog to rename arc
2. **Edit Goals** - Navigates to dedicated goals editing page
3. **Restart Arc** - Clears all data with confirmation

**Visual Design:**
- Blue/green gradient background
- Star icon header
- Info chips with icons
- Three action buttons (2 on row 1, 1 on row 2)
- Goals list with green checkmarks

### 2. Edit Arc Name Feature
**Implementation**: Dialog-based editing

**Flow:**
1. User taps "Edit Name"
2. Dialog opens with current name pre-filled
3. User edits in text field
4. Taps "Save" or "Cancel"
5. If saved, arc updates immediately
6. Dialog closes

**Validation:**
- Name cannot be empty
- Updates ArcData and saves to storage
- UI refreshes with new name

### 3. Edit Goals Page
**Separate full-page interface**

**Components:**
- Back button with title header
- Goal counter (e.g., "3/5")
- List of current goals
- Each goal has drag indicator and delete button
- Add new goal input field + button
- "Save Changes" button at bottom

**Features:**
- Add goals (up to 5 max)
- Remove goals (minimum 3 required)
- Drag indicators suggest reordering (not implemented yet)
- Text input for new goals
- Validation messages via snackbar

**Flow:**
1. User taps "Edit Goals" from profile
2. New page opens with current goals
3. User adds/removes goals
4. Taps "Save Changes"
5. Updates arc data
6. Returns to profile
7. Profile reloads with new goals

### 4. Restart Arc Feature
**Destructive action with safety**

**Confirmation Dialog:**
- Warning title: "Restart Arc?"
- Description: "This will clear all your progress and start fresh. This action cannot be undone."
- Two buttons: "Cancel" (safe) and "Restart" (red/danger)

**Action:**
```dart
// Clears ALL app data:
- Arc data
- Daily progress
- Progress stats (streaks, completions)
- Journal entries
// Settings are preserved
```

**After Restart:**
- Navigates to Arc Setup page
- Removes all previous routes
- User starts completely fresh
- Can create new arc

### 5. Theme Selection
**Three theme options**

**Themes:**
1. **Default Dark** - Blue & emerald winter theme (current)
2. **Minimal** - Clean monochrome design
3. **Warrior** - Bold red & black theme

**Implementation:**
- Radio-button style selection
- Selected theme has purple border and checkmark
- Tapping theme saves selection
- Shows "coming soon" message (theme switching not yet implemented)

**Visual:**
- Purple section header
- Card for each theme
- Theme title and description
- Selected state highlighting

**Future Implementation:**
Would require:
- Theme provider/manager
- Color scheme definitions for each theme
- App-wide theme switching
- Rebuild UI with new colors

### 6. Notifications Settings
**Customizable reminders**

**Toggle Switch:**
- Daily Reminders ON/OFF
- When enabled, shows additional options
- When disabled, hides time and style options

**Notification Time:**
- Displays current time (e.g., "09:00")
- Taps opens Flutter time picker
- User selects hour and minute
- Saves immediately

**Motivational Style:**
Three radio options:
1. **Short Tips** - "Stay locked in."
2. **Quotes** - Inspirational quotes
3. **Custom** - Your own reminders

**Implementation Status:**
- UI fully functional
- Settings saved and loaded
- Actual notifications not implemented
- Shows "coming soon" note

**Future Implementation:**
Would require:
- `flutter_local_notifications` package
- Notification scheduling
- Permission requests
- Background task handling

### 7. About Section
**App information display**

**Displays:**
- App name: "The Winter Arc"
- Version: "1.0.0"
- Platform: "Android"
- Tagline: "Made with ❄️ for winter warriors"
- Copyright: "© 2025 The Winter Arc"

**Visual Design:**
- Blue section header
- Info icon
- Row format (icon, label, value)
- Centered footer text
- Clean, simple layout

## Data Models

### AppSettings
```dart
{
  themeIndex: int,              // 0: Default, 1: Minimal, 2: Warrior
  notificationsEnabled: bool,   // Toggle state
  notificationHour: int,        // 0-23
  notificationMinute: int,      // 0-59
  motivationStyle: int          // 0: Tips, 1: Quotes, 2: Custom
}
```

**Helper Methods:**
- `getThemeName()`: String name of theme
- `getMotivationStyleName()`: String name of style
- `getFormattedNotificationTime()`: "HH:MM" format

## User Flows

### Edit Arc Name:
1. Profile page → Tap "Edit Name"
2. Dialog opens
3. Edit text → "Save"
4. Arc name updates
5. Profile refreshes

### Edit Goals:
1. Profile page → Tap "Edit Goals"
2. Edit Goals page opens
3. Add/remove goals
4. "Save Changes"
5. Return to profile
6. Home dashboard reloads with new goals

### Restart Arc:
1. Profile page → Tap "Restart Arc"
2. Confirmation dialog
3. "Restart" (red button)
4. All data cleared
5. Navigate to Arc Setup
6. Create new arc

### Change Theme:
1. Profile page → Themes section
2. Tap theme option
3. Selection saved
4. Checkmark appears
5. Snackbar confirms

### Set Notification Time:
1. Profile page → Notifications
2. Ensure toggle is ON
3. Tap "Notification Time"
4. Time picker opens
5. Select time → OK
6. Time updates and saves

## Storage Strategy

**Settings Persistence:**
- Saved to SharedPreferences
- Key: `app_settings`
- JSON serialized
- Loaded on page init
- Saved immediately on change

**Arc Data Updates:**
- Edit name → updates and saves ArcData
- Edit goals → updates and saves ArcData
- Changes reflect immediately
- Home dashboard reloads when returning

**Data Clearing:**
- Restart Arc → clears 4 keys:
  - `arc_data`
  - `daily_progress`
  - `progress_stats`
  - `journal_entries`
- Settings preserved across restarts

## Visual Design

### Color Coding:
- **Arc Info**: Blue/green gradient
- **Themes**: Purple (`#9B59B6`)
- **Notifications**: Green (`#50C878`)
- **About**: Blue (`#4A90E2`)
- **Restart**: Red (`#E74C3C`) for danger

### Layout:
- 24px page padding
- 24px between sections
- 20px card padding
- 16px internal spacing

### Typography:
- Header: 32px bold
- Section titles: 18px bold
- Body text: 14-15px
- Labels: 12-14px
- Arc name: 24px bold green

## Safety Features

### Destructive Actions:
1. **Restart Arc** - Confirmation dialog required
2. **Remove Goal** - Validates minimum 3 goals
3. **Name Edit** - Empty name rejected

### Validation:
- Goal count: 3-5 enforced
- Arc name: Non-empty required
- Settings: Reasonable defaults
- Time: Valid 24-hour format

### User Feedback:
- Snackbar messages for all actions
- Success: Green background
- Error: Red background
- Info: Blue background

## Integration Points

### With Home Dashboard:
- Profile changes → Home reloads data
- Edit goals → Daily goals update
- Restart arc → Returns to setup

### With Other Pages:
- Settings affect all pages (future themes)
- Notifications would trigger from background
- Arc info displayed in Progress page

## Future Enhancements

### Theme System:
- Implement actual theme switching
- Create color schemes for each theme
- Use Provider or Riverpod for state
- Persist theme choice
- Animate color transitions

### Notifications:
- Implement local notifications
- Schedule daily reminders
- Use selected motivational style
- Handle permissions
- Background scheduling

### Additional Settings:
- App language selection
- Data export/import
- Cloud backup option
- Account creation
- Profile photo upload

### Arc Management:
- Archive completed arcs
- View arc history
- Compare arc performances
- Statistics across all arcs

### Goals Enhancement:
- Drag-to-reorder goals
- Goal categories/tags
- Goal templates library
- Goal suggestions based on category

## Technical Notes

### Time Picker Integration:
```dart
showTimePicker(
  context: context,
  initialTime: TimeOfDay(hour: 9, minute: 0),
  builder: (context, child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF4A90E2),
        ),
      ),
      child: child!,
    );
  },
);
```

### Dialog Pattern:
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: Color(0xFF1D1E33),
    title: Text('Title', style: TextStyle(color: Colors.white)),
    content: // ... content
    actions: [
      TextButton(/* Cancel */),
      ElevatedButton(/* Confirm */),
    ],
  ),
);
```

### Navigation After Data Change:
```dart
Navigator.push(/* Edit page */)
  .then((_) {
    _loadData(); // Reload on return
  });
```

## Testing Scenarios

### Arc Editing:
1. Edit name → verify update
2. Add goal → verify saved
3. Remove goal → verify minimum enforced
4. Save goals → verify home updates

### Settings:
1. Toggle notifications → verify saved
2. Change time → verify display update
3. Select theme → verify checkmark
4. Change style → verify selection

### Restart:
1. Tap restart → verify dialog
2. Cancel → verify no changes
3. Confirm → verify all data cleared
4. Verify navigation to setup

### Validation:
1. Empty arc name → rejected
2. < 3 goals → prevented
3. > 5 goals → prevented
4. Empty goal name → rejected

## Accessibility

- Large touch targets (buttons 44x44+)
- Clear labels and descriptions
- Confirmation dialogs for destructive actions
- Visual feedback for all interactions
- High contrast text

## Performance

- Lazy loading of data
- Immediate UI updates
- Async storage operations
- No unnecessary rebuilds
- Efficient navigation

## Security & Privacy

- All data local (no cloud by default)
- No account required
- No data collection
- Settings user-controlled
- Restart clears sensitive data
