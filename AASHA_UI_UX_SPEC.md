# AASHA UI/UX Spec (PPTX-Matched)

## Source Alignment
- Reference deck: `AASHA_ AI-Assisted Safety & Health Assistant - SDG Enhanced.pptx`
- Primary visual language: human-centric healthcare imagery + teal overlay
- Core narrative anchors: SDG 3 (Health), SDG 5 (Gender Equality), SDG 10 (Reduced Inequalities)

## Visual System

### Color Tokens
- `aasha-teal-900`: `#1A5F7A`
- `aasha-teal-700`: `#159895`
- `aasha-teal-500`: `#57C5B6`
- `aasha-navy-950`: `#1A1A2E`
- `aasha-surface-50`: `#F9FAFB`
- `aasha-surface-100`: `#F3F4F6`
- `aasha-neutral-700`: `#4A5565`
- `aasha-neutral-800`: `#364153`
- `aasha-sdg3-green`: `#4C9F38`
- `aasha-sdg5-orange`: `#FF3A21`
- `aasha-sdg10-magenta`: `#DD1367`
- `aasha-white`: `#FFFFFF`
- `aasha-black`: `#000000`

### Typography
- Display / hero: `Oranienbaum` (serif, elegant, trust-building)
- UI / body / labels: `Quattrocento Sans` (clean, legible, human tone)
- Heading rhythm:
  - H1 desktop: 64–92 px
  - H2 desktop: 40–56 px
  - Body large: 24–30 px
  - Body regular: 16–20 px

### Shape & Depth
- Card radius: `24–32`
- Pill radius: `999`
- Glass surface: white at `8–16%` opacity + subtle stroke
- Shadows: soft, low spread, long blur
- Atmosphere: blurred teal orbs over dark/teal gradient backgrounds

## Product IA & Flow
1. Brand Landing
2. Role Selection (Senior / Caregiver / Volunteer / Family)
3. Care Home Dashboard
4. AR Medication Scanner
5. Pharmacy Relay Network
6. Safety Guardian + SOS
7. Performance & Impact (SDG KPI dashboard)
8. Settings + Accessibility

## Screen Specs

### 1) Brand Landing
- Full-width teal gradient hero with human photo treatment
- Left content cluster:
  - `AASHA` hero wordmark
  - Product subtitle
  - One-paragraph value statement
  - SDG chips (3, 5, 10)
- Right glass panel:
  - Quick Assist preview cards
  - Medication status, safety pulse, AI companion action
- CTA row:
  - `Start as Senior`
  - `Continue as Caregiver`
  - `See Community Network`

### 2) Role Selection
- 2x2 role cards with icon + short copy
- Each role maps to tailored defaults:
  - Senior: bigger text + voice-first
  - Caregiver: monitoring + reminders
  - Volunteer: local assistance tasks
  - Family: alerts + progress snapshots

### 3) Care Home Dashboard
- Left rail navigation (high contrast, large tap targets)
- Top summary cards:
  - Medications due
  - Health trend
  - Safety status
- Main timeline:
  - Morning/Noon/Night medication flow
  - Check-off interactions with color confidence states
- Right action panel:
  - `Ask AASHA` voice/text
  - `Call trusted contact`
  - `Start SOS workflow`

### 4) AR Medication Scanner
- Camera-first layout
- Scanner focus frame centered with instruction text
- Result sheet (bottom):
  - Drug name
  - Dose + timing
  - Food interaction
  - Contraindications warning chip
- Actions:
  - `Read aloud`
  - `Save to schedule`
  - `Share with caregiver`

### 5) Pharmacy Relay Network
- Map/list split view
- Active relay requests as cards:
  - pickup location
  - delivery priority
  - volunteer ETA
- Trust indicators:
  - verified volunteer badge
  - handoff completion timeline
- CTA:
  - `Request Relay`
  - `Become a Volunteer`

### 6) Safety Guardian + SOS
- Persistent safety pulse widget
- Trigger options:
  - fall detection
  - panic button
  - location anomaly
- Emergency flow:
  1. confirm alert
  2. notify guardians
  3. trigger local community response
  4. optional ambulance escalation

### 7) Performance & Impact
- KPI tiles:
  - adherence improvement
  - response time
  - incident reduction
  - community participation
- SDG progress visualization:
  - SDG3 health outcomes
  - SDG5 caregiver burden reduction
  - SDG10 access equity metrics

### 8) Settings & Accessibility
- Text scale slider
- Language toggle
- Voice guidance speed
- High-contrast mode
- Simplified navigation mode

## Component Library (Recommended)
- `Button/Primary`, `Button/Secondary`, `Button/Ghost`
- `Chip/SDG`
- `Card/Glass`, `Card/Metric`, `Card/Alert`
- `Status/Pill`
- `Nav/SidebarItem`
- `Modal/SOSConfirm`
- `Panel/Assistant`

## Interaction Patterns
- Voice-first prompts on high-friction tasks
- Progressive disclosure for medical detail
- Confirm-before-critical actions (SOS, medication overrides)
- Large, thumb-safe controls on mobile
- Always-visible “Back to Safety Home”

## Accessibility Baselines
- Contrast: minimum WCAG AA
- Body text never below 16 px equivalent
- Touch target minimum: 44x44
- Every critical action has:
  - icon + text label
  - optional voice shortcut

## Motion Guidelines
- Gentle 180–260ms transitions
- Soft elevation on hover/focus (desktop)
- Minimal motion mode for sensitive users
- SOS sequence uses urgency color changes, not aggressive animation

## Engineering Hand-off Notes
- Build tokenized theme from color set above
- Keep SDG chips as reusable semantic components
- Treat `Safety Status` as global app state component
- Ensure offline-capable medication checklist path
