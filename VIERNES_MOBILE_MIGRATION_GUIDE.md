# Viernes Mobile - Feature Migration Guide

## Overview

This comprehensive migration guide documents the specific features that need to be migrated from the Viernes frontend (React/TypeScript) to Flutter mobile application. This analysis is based on the production frontend codebase located at `/Users/ianmoone/Development/Banana/viernes-front`.

---

## 1. Login System

### Current Implementation Analysis

**Location**: `/src/pages/Authentication/LoginBoxed.tsx`
**Authentication Context**: `/src/contexts/AuthContext.tsx`

### Key Components & Responsibilities

#### LoginBoxed Component
- **File**: `LoginBoxed.tsx`
- **Primary Purpose**: Email/password authentication with form validation
- **Dependencies**: Formik, Firebase Auth, SweetAlert2, i18n

#### Authentication Features
1. **Email/Password Login**: Firebase `signInWithEmailAndPassword`
2. **Google OAuth**: Firebase `signInWithPopup` with `GoogleAuthProvider`
3. **Form Validation**: Email format validation, required field checks
4. **Error Handling**: Comprehensive Firebase error code mapping
5. **Session Management**: Firebase Auth state persistence
6. **Multi-language Support**: i18n integration
7. **Return URL Handling**: Redirect preservation after login

### API Endpoints & Data Structures

#### Firebase Authentication
```typescript
// Firebase methods used
- signInWithEmailAndPassword(auth, email, password)
- signInWithPopup(auth, GoogleAuthProvider)
- onAuthStateChanged(auth, callback)
```

#### User Data Loading Flow
```typescript
interface AuthContextType {
  currentUser: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  loginWithGoogle: () => Promise<void>;
  logout: () => Promise<void>;
  resetPassword: (email: string) => Promise<void>;
}
```

#### User Data Structure
```typescript
interface UserData {
  uid: string;
  email: string;
  displayName: string;
  database_id: number;
  available: boolean;
  fullname: string;
  organizationalRole: {
    value_definition: string;
    description: string;
  };
  organizationalStatus: {
    value_definition: string;
    description: string;
  };
  organization_id: number;
}
```

### State Management Patterns

#### Redux Slices Used
- **userSlice**: Stores user profile data
- **organizationSlice**: Organization data and timezone
- **valueDefinitionsSlice**: Role/status definitions
- **themeConfigSlice**: Page title and theme

#### Authentication Flow
1. Firebase authentication
2. Load user data from Firestore (`UserService.getUserByUid`)
3. Fetch user availability status (`UserStatusService.getUserStatus`)
4. Auto-activate user on login (`UserStatusService.toggleUserAvailability`)
5. Load organizational data (`getCurrentUserOrganizationalInfo`)
6. Load organization info and timezone
7. Load value definitions

### User Flows & Interactions

#### Login Process
1. User enters email/password
2. Form validation (client-side)
3. Firebase authentication
4. Success toast notification
5. User data loading sequence
6. Navigation to dashboard or return URL

#### Error Handling
- `auth/user-not-found`: "No user found with this email"
- `auth/wrong-password`: "Incorrect password"
- `auth/invalid-email`: "Invalid email address"
- `auth/user-disabled`: "This account has been disabled"

### Mobile-Specific Considerations

#### Flutter Implementation Requirements
1. **Firebase Integration**: Flutter Firebase Auth plugin
2. **Google Sign-In**: `google_sign_in` package
3. **Form Validation**: Flutter form validators
4. **State Management**: Provider/Riverpod for auth state
5. **Secure Storage**: Store auth tokens securely
6. **Biometric Auth**: Consider fingerprint/face ID integration
7. **Deep Linking**: Handle return URLs properly

#### Dependencies & Third-Party Integrations
- Firebase Authentication
- Google Sign-In SDK
- Firestore for user data
- SweetAlert2 equivalent (Flutter snackbars/dialogs)
- i18n localization

### Auth Layout Component

**Location**: `/src/components/Layouts/AuthLayout.tsx`

#### Design Elements
- Background gradient image
- Decorative overlay images
- Responsive logo display (light/dark mode)
- Language selector component
- Backdrop blur effect
- Glassmorphism design

#### Mobile Adaptation
- Single-column layout
- Touch-friendly buttons
- Proper keyboard handling
- Responsive text sizing
- Safe area handling

---

## 2. Reset Password

### Current Implementation Analysis

**Location**: `/src/pages/Authentication/RecoverIdBox.tsx`, `/src/pages/Authentication/ResetPassword.tsx`

### Key Components & Responsibilities

#### Password Recovery Flow
1. **Email Input** (`RecoverIdBox.tsx`): Collect user email
2. **Email Sending**: Firebase `sendPasswordResetEmail`
3. **Link Handling** (`ResetPassword.tsx`): Process reset link from email
4. **Password Reset**: Firebase `confirmPasswordReset`

### API Endpoints & Data Structures

#### Firebase Methods
```typescript
// Password reset flow
- sendPasswordResetEmail(auth, email)
- confirmPasswordReset(auth, oobCode, newPassword)
```

#### URL Parameters
- `oobCode`: Out-of-band code from email link
- `mode`: Should be 'resetPassword'

### Form Validation Patterns

#### Email Validation
```typescript
if (!values.email) {
  errors.email = t('validation.required');
} else if (!/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i.test(values.email)) {
  errors.email = t('validation.invalid_email');
}
```

#### Password Validation
```typescript
if (!values.password) {
  errors.password = t('validation.required');
} else if (values.password.length < 8) {
  errors.password = t('validation.password_min_8');
} else if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(values.password)) {
  errors.password = t('validation.password_requirements');
}

// Password confirmation
if (values.password !== values.confirmPassword) {
  errors.confirmPassword = t('validation.passwords_not_match');
}
```

### User Flows & Interactions

#### Recovery Process
1. User clicks "Forgot Password" link
2. Enters email address
3. System sends recovery email
4. User clicks link in email
5. System validates oobCode and mode
6. User enters new password (with confirmation)
7. System updates password
8. Success message and redirect to login

#### Error Handling
- `auth/expired-action-code`: "Reset link has expired"
- `auth/invalid-action-code`: "Invalid reset code"
- `auth/weak-password`: "Password is too weak"

### Mobile-Specific Considerations

#### Flutter Implementation
1. **Email Deep Links**: Handle password reset URLs
2. **URL Scheme**: Configure custom URL scheme
3. **Password Visibility**: Toggle password visibility
4. **Security**: Secure password input fields
5. **Validation**: Real-time form validation
6. **Navigation**: Proper back navigation handling

#### UI/UX Patterns
- Email input with validation feedback
- Password strength indicator
- Show/hide password toggles
- Clear error messaging
- Loading states during operations
- Success confirmation screens

---

## 3. Dashboard

### Current Implementation Analysis

**Main Dashboard**: `/src/pages/Index.tsx` (Sales Admin Dashboard)
**Conversations Dashboard**: `/src/pages/ConversationsDashboard.tsx`

### Key Components & Responsibilities

#### Sales Dashboard (`Index.tsx`)
1. **Revenue Charts**: ApexCharts area chart with income/expenses
2. **Sales by Category**: Donut chart for category breakdown
3. **Daily Sales**: Stacked bar chart for weekly data
4. **Total Orders**: Area chart with sparkline design
5. **Summary Cards**: Income, profit, expenses with progress bars
6. **Recent Activities**: Scrollable activity timeline
7. **Transactions**: Financial transaction history
8. **Recent Orders**: Tabular order data with status badges
9. **Top Selling Products**: Product performance table

#### Conversations Dashboard (`ConversationsDashboard.tsx`)
1. **Monthly Statistics**: Interactions, attendees, calls, minutes
2. **Sentiment Analysis**: Donut chart for conversation sentiments
3. **Top Categories**: Horizontal bar chart
4. **Conversation Tags**: Pie chart distribution
5. **Usage Metrics**: Radial progress charts for messages/minutes consumed
6. **Customer Summary**: Paginated data table with search
7. **Export Functionality**: CSV export of conversation stats
8. **Subscription Status**: No-subscription state handling

### Data Visualization Components

#### Chart Configurations (ApexCharts)
```typescript
// Revenue Chart - Area Chart
const revenueChart = {
  series: [
    { name: 'Income', data: [...] },
    { name: 'Expenses', data: [...] }
  ],
  options: {
    chart: { type: 'area', height: 325 },
    colors: isDark ? ['#2196F3', '#E7515A'] : ['#1B55E2', '#E7515A'],
    // ... responsive configuration
  }
};

// Sentiment Chart - Donut Chart
const sentimentChart = {
  series: Object.values(sentimentData),
  options: {
    chart: { type: 'donut', height: 300 },
    colors: ['#06C698', '#FFB020', '#E7515A'],
    labels: ['Positive', 'Neutral', 'Negative']
  }
};
```

### API Endpoints & Data Structures

#### Analytics API (`/src/api/analytics.ts`)
```typescript
interface MonthlyStatsResponse {
  interactions: number;
  attendees: number;
  sentiments: { [key: string]: number };
  top_categories: { [key: string]: number };
  tags: { [key: string]: number };
}

interface VapiAnalyticsResponse {
  name: string;
  result: Array<{
    countId?: string;
    sumDuration?: number;
  }>;
}

interface CustomerSummaryData {
  fullname: string;
  phone_number: string;
  segment: string;
  main_interest: string;
  tags: string[];
  purchase_intention: string;
}
```

#### Key Endpoints
- `GET /analytics/monthly-stats`: Monthly conversation statistics
- `GET /analytics/vapi`: Voice analytics data
- `GET /analytics/customer-summary`: Customer data with pagination
- `GET /analytics/export-conversation-stats`: CSV export

### State Management Patterns

#### Dashboard State
```typescript
const [monthlyStats, setMonthlyStats] = useState<MonthlyStatsResponse | null>(null);
const [vapiAnalytics, setVapiAnalytics] = useState<VapiAnalyticsResponse[] | null>(null);
const [loading, setLoading] = useState(true);
const [activeTab, setActiveTab] = useState('general');

// Customer summary state
const [customerData, setCustomerData] = useState<CustomerSummaryData[]>([]);
const [customerPage, setCustomerPage] = useState(1);
const [customerPageSize, setCustomerPageSize] = useState(10);
```

#### Organization Data Integration
- Usage from Redux: `organizationData` for limits and consumption
- Billing date calculation and display
- Subscription status checking

### Layout Structure & Navigation

#### Grid System
```typescript
// Stats cards grid
<div className='grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-6'>
  {/* Metric cards */}
</div>

// Charts grid
<div className='grid grid-cols-1 xl:grid-cols-2 gap-6'>
  {/* Chart components */}
</div>
```

#### Responsive Breakpoints
- Mobile: `grid-cols-1`
- Small: `sm:grid-cols-2`
- Large: `xl:grid-cols-4`

### Mobile-Specific Considerations

#### Flutter Implementation
1. **Chart Library**: `fl_chart` or `syncfusion_flutter_charts`
2. **Grid Layout**: `GridView.builder` with responsive columns
3. **Data Tables**: `DataTable` or `PaginatedDataTable`
4. **Pull-to-Refresh**: `RefreshIndicator` for data refresh
5. **Responsive Cards**: `Card` widgets with proper spacing
6. **Export**: Share functionality for CSV files
7. **Loading States**: `CircularProgressIndicator`
8. **Error Handling**: Snackbars for error states

#### Real-time Data Updates
- **SSE Integration**: Server-sent events for live updates
- **Periodic Refresh**: Timer-based data refresh
- **Cache Management**: Efficient data caching strategy

#### Usage Visualization
- **Progress Indicators**: Radial progress for consumption metrics
- **Status Badges**: Subscription status indicators
- **Interactive Charts**: Touch-responsive chart interactions

---

## 4. Conversations with Chatbots

### Current Implementation Analysis

**Main Chat**: `/src/pages/Conversations/ConversationChat.tsx`
**API Layer**: `/src/api/conversations.ts`
**Components**: `/src/components/Conversations/`

### Key Components & Responsibilities

#### ConversationChat Component
1. **Message Display**: Chat bubble interface with sender/receiver styling
2. **Real-time Updates**: Server-Sent Events (SSE) for live messaging
3. **Media Support**: Image, audio, document upload/display
4. **File Processing**: Drag-and-drop file upload with validation
5. **Message Input**: Multi-line text input with emoji picker
6. **Conversation Management**: Status updates, agent assignment, tagging
7. **Tool Calls**: Display of AI tool executions and responses
8. **Typing Indicators**: Real-time typing status

#### Message Types & Features
```typescript
interface ConversationMessage {
  id: number;
  message: string;
  type: 'incoming' | 'outgoing' | 'system';
  created_at: string;
  sender_name?: string;
  media_url?: string;
  media_type?: 'image' | 'audio' | 'document';
  tool_calls?: ToolCallMessage[];
}
```

#### Media Handling
- **Supported Formats**: Images (jpg, png, gif), Audio (mp3, wav), Documents (pdf, doc, docx, xls, xlsx, ppt, pptx, txt)
- **Upload Validation**: File size limits, type validation
- **Preview System**: File preview before sending
- **Processing Overlay**: Loading states during upload

### API Endpoints & Data Structures

#### Core Conversations API
```typescript
// Main endpoints
GET /conversations/                     // List conversations with filters
GET /conversations/{id}                // Get conversation details
GET /conversations/{id}/messages       // Get conversation messages
POST /conversations/{id}/messages      // Send new message
PUT /conversations/{id}/assign         // Assign conversation to agent
PUT /conversations/{id}/status         // Update conversation status
POST /conversations/{id}/tags          // Add tags to conversation
DELETE /conversation-tags/{tagId}      // Remove tag from conversation

// Pagination & Filtering
interface ConversationsParams {
  page?: number;
  page_size?: number;
  order_by?: string;
  order_direction?: 'asc' | 'desc';
  search_term?: string;
  filters?: string;  // JSON filter string
  conversation_type?: 'CHAT' | 'VOICE';
}
```

#### Conversation Data Structure
```typescript
interface Conversation {
  id: number;
  user_id: number;
  user: ConversationUser;        // Customer data
  agent: ConversationAgent | null;      // Assigned agent
  status: ConversationStatus;           // Current status
  tags: ConversationTag[];             // Applied tags
  assigns: ConversationAssign | null;   // Assignment info
  priority: string;                     // Priority level
  category: string;                     // Auto-categorization
  sentiment: string;                    // Sentiment analysis
  type: 'CHAT' | 'VOICE';              // Conversation type
  locked: boolean;                      // Lock status
  unreaded: number;                     // Unread message count
  created_at: string;
  updated_at: string;
}
```

### Real-time Messaging (SSE)

#### Server-Sent Events Integration
```typescript
const { typingIndicator } = useConversationSSE({
  conversationId: parseInt(id),
  enabled: !!id,
  onNewMessage: (message) => {
    // Add message to chat
    // Auto-scroll to bottom
    // Handle placeholder message reload
  },
  onReplaceMessage: (oldMessage, newMessage) => {
    // Replace temporary with final message
  },
  onAgentAssigned: (agentId, agentName) => {
    // Update conversation agent info
    // Show notification
  },
  onStatusChange: (conversationId, newStatus) => {
    // Update conversation status
    // Show status change notification
  },
  onTypingChange: () => {
    // Handle typing indicator updates
  }
});
```

#### Message Flow
1. **Outgoing**: User types → validation → send to API → optimistic update
2. **Incoming**: SSE message → deduplicate → add to list → scroll to bottom
3. **Replace**: Temporary message → final AI response → replace in list

### Chat Interface Features

#### Message Input System
- **Multi-line Support**: Auto-expanding textarea
- **Character Limit**: 4096 characters (WhatsApp parity)
- **Emoji Picker**: Common emoji selection grid
- **File Attachment**: Drag-and-drop + button upload
- **Send Button**: Disabled when empty/processing

#### File Processing Workflow
```typescript
// File validation
const validateFile = (file: File, type: 'image' | 'document') => {
  const config = MEDIA_CONFIGS[type];

  // Size validation
  if (file.size > config.maxSize) {
    throw new MediaError(`File too large. Max size: ${config.maxSizeMB}MB`);
  }

  // Type validation
  const extension = getFileExtension(file.name);
  if (!config.allowedExtensions.includes(extension)) {
    throw new MediaError(`Invalid file type. Allowed: ${config.allowedExtensions.join(', ')}`);
  }
};
```

### State Management & Data Flow

#### Component State
```typescript
// Conversation data
const [conversation, setConversation] = useState<Conversation | null>(null);
const [messages, setMessages] = useState<ConversationMessage[]>([]);
const [allMessages, setAllMessages] = useState<ConversationMessage[]>([]);

// UI state
const [loading, setLoading] = useState(true);
const [sending, setSending] = useState(false);
const [newMessage, setNewMessage] = useState('');
const [selectedFiles, setSelectedFiles] = useState<FilePreview[]>([]);
const [showToolCalls, setShowToolCalls] = useState(true);

// Agent assignment
const [availableAgents, setAvailableAgents] = useState<Agent[]>([]);
const [assigningConversation, setAssigningConversation] = useState(false);
```

#### Message Management
- **Filtering**: Tool calls can be shown/hidden
- **Sorting**: Messages sorted by timestamp
- **Deduplication**: Prevent duplicate SSE messages
- **Pagination**: Load previous messages on scroll

### Mobile-Specific Considerations

#### Flutter Implementation
1. **Chat UI**: Custom chat bubble widgets with sender/receiver styling
2. **WebSocket/SSE**: `web_socket_channel` or HTTP streaming
3. **File Upload**: `image_picker`, `file_picker` packages
4. **Media Display**: Image viewers, audio players, document viewers
5. **Real-time Updates**: Stream builders for live message updates
6. **Push Notifications**: Firebase messaging for new messages
7. **Offline Support**: Local message caching and sync

#### Mobile Chat Features
- **Voice Messages**: Audio recording and playback
- **Camera Integration**: In-app photo capture
- **File Sharing**: Integration with device file system
- **Copy/Forward**: Message interaction options
- **Search**: Message search within conversations
- **Media Gallery**: Shared media viewing
- **Typing Indicators**: Visual typing status
- **Message Status**: Sent, delivered, read indicators

#### Performance Optimizations
- **Virtual Scrolling**: Efficient rendering of long message lists
- **Image Caching**: Cached network images
- **Lazy Loading**: Load messages on demand
- **Memory Management**: Dispose of unused resources

---

## 5. Profile Section

### Current Implementation Analysis

**Location**: `/src/pages/Users/Profile.tsx`
**User Status API**: `/src/api/userStatus.ts`
**User Service**: `/src/services/userService.ts`

### Key Components & Responsibilities

#### Profile Display
1. **User Information**: Name, occupation, contact details, location
2. **Profile Image**: Avatar display with edit capability
3. **Professional Info**: Job title, work-related details
4. **Contact Methods**: Email, phone, social links
5. **Activity Overview**: Task progress, project status
6. **Financial Summary**: Income, profit, expenses tracking
7. **Subscription Info**: Plan details, renewal status, usage limits
8. **Payment History**: Transaction history with invoice access
9. **Payment Methods**: Stored credit cards and payment options

#### User Status Management
```typescript
interface UserStatusResponse {
  available: boolean;
}

class UserStatusService {
  // Get current availability status
  static async getUserStatus(databaseId: number): Promise<UserStatusResponse>;

  // Toggle availability (online/offline for conversations)
  static async toggleUserAvailability(databaseId: number, available: boolean): Promise<void>;
}
```

### Profile Data Structure

#### User Profile Information
```typescript
interface UserProfile {
  // Basic info
  id: number;
  fullname: string;
  email: string;
  phone?: string;
  avatar_url?: string;

  // Professional details
  occupation?: string;
  location?: string;
  birthdate?: string;

  // Organizational info
  database_id: number;
  organization_id: number;
  available: boolean;

  // Role & permissions
  organizationalRole: {
    value_definition: string;
    description: string;
  };
  organizationalStatus: {
    value_definition: string;
    description: string;
  };
}
```

### Profile Sections & Features

#### 1. Personal Information Section
- **Profile Photo**: Circular avatar with edit button
- **Basic Details**: Name, title, birth date, location
- **Contact Information**: Email (clickable), phone number
- **Social Links**: Twitter, Dribbble, GitHub profile links
- **Edit Profile**: Link to account settings page

#### 2. Activity Dashboard Section
- **Task Overview**: Progress tracking for various projects
- **Project Status**: Percentage completion with color-coded progress bars
- **Recent Activity**: Timestamped activity list with status indicators
- **Work Statistics**: Task completion metrics

#### 3. Financial Overview Section
- **Summary Cards**: Income, profit, expenses with percentage indicators
- **Visual Indicators**: Progress bars and color-coded status
- **Trend Analysis**: Performance comparison data

#### 4. Subscription Management Section
- **Plan Information**: Current subscription tier (Pro Plan example)
- **Plan Features**: Feature list (monthly visitors, reports, storage)
- **Billing Status**: Days left, renewal date, monthly cost
- **Usage Progress**: Visual progress bar for plan utilization
- **Renewal Actions**: "Renew Now" button for plan management

#### 5. Payment History Section
- **Transaction List**: Monthly payment records
- **Payment Details**: Plan type, completion percentage
- **Invoice Actions**: View/download invoice options via dropdown menu
- **Payment Status**: Visual indicators for payment success

#### 6. Payment Methods Section
- **Stored Cards**: Credit card information display
- **Card Types**: Support for American Express, Mastercard, Visa
- **Expiration Dates**: Card validity information
- **Primary Card**: Primary payment method indication
- **Card Management**: Implicit card addition/removal functionality

### API Endpoints & Data Structures

#### Profile Management Endpoints
```typescript
// User data (from Firebase/Firestore)
GET /users/{uid}                        // Get user profile
PUT /users/{uid}                        // Update user profile

// Availability status
GET /organization_users/read/{databaseId}    // Get availability status
POST /organization_users/change_agent_availability/{databaseId}/{available}  // Toggle availability

// Organizational data
GET /auth/current-user-organizational-info  // Get role/status info
```

#### Settings & Preferences
- Account settings link: `/users/user-account-settings`
- Profile editing capabilities
- Privacy settings management
- Notification preferences

### User Flows & Interactions

#### Profile View Flow
1. Load user data from Redux store
2. Display profile information in organized sections
3. Show real-time availability status
4. Provide edit/manage action buttons
5. Navigate to detailed settings when needed

#### Status Management Flow
1. Display current availability status
2. Allow toggling between available/unavailable
3. Update status via API call
4. Refresh UI to reflect new status
5. Handle error states gracefully

### Mobile-Specific Considerations

#### Flutter Implementation Requirements
1. **Profile Screen**: Scrollable profile layout with sections
2. **Image Handling**: Avatar display and editing with `image_picker`
3. **Contact Actions**: Clickable email/phone with platform integration
4. **Social Links**: Web view or external app launch
5. **Status Toggle**: Switch widget for availability status
6. **Progress Indicators**: Custom progress bar widgets
7. **Card Display**: Credit card UI components
8. **Invoice Viewer**: PDF viewer for invoice documents

#### Mobile Adaptations
- **Responsive Layout**: Single-column mobile-first design
- **Touch Interactions**: Tap-friendly buttons and links
- **Swipe Actions**: Swipe gestures for card management
- **Modal Dialogs**: Profile editing in modal/bottom sheets
- **Native Integration**: Email/SMS app integration
- **Biometric Auth**: Secure access to payment information
- **Offline Support**: Cache profile data for offline viewing

#### Profile Settings Integration
- **Account Settings**: Deep link to settings screens
- **Photo Management**: Camera/gallery integration for avatar updates
- **Form Validation**: Real-time validation for profile edits
- **Security Features**: Password change, 2FA management
- **Privacy Controls**: Data visibility and sharing settings

---

## Migration Implementation Strategy

### Phase 1: Authentication Foundation
1. Set up Firebase Authentication in Flutter
2. Implement login/logout flows
3. Create password reset functionality
4. Set up secure token storage
5. Implement Google Sign-In integration

### Phase 2: Dashboard & Analytics
1. Set up chart/visualization libraries
2. Create responsive dashboard layouts
3. Implement API integration for analytics
4. Add real-time data refresh capabilities
5. Create export functionality

### Phase 3: Conversation System
1. Implement chat UI components
2. Set up real-time messaging (WebSocket/SSE)
3. Add media upload/display capabilities
4. Implement conversation management features
5. Add push notification support

### Phase 4: Profile & Settings
1. Create profile display screens
2. Implement profile editing capabilities
3. Add status management features
4. Create settings and preferences
5. Implement payment/subscription views

### Phase 5: Integration & Polish
1. Connect all features end-to-end
2. Implement offline support
3. Add comprehensive error handling
4. Optimize performance and UX
5. Conduct thorough testing

### Technical Architecture Recommendations

#### State Management
- **Provider/Riverpod**: For application state management
- **BLoC Pattern**: For complex business logic
- **Shared Preferences**: For local settings storage
- **Secure Storage**: For sensitive data (tokens, credentials)

#### Networking
- **Dio**: HTTP client with interceptors
- **Web Socket**: Real-time communication
- **Retrofit/JSON Annotation**: API code generation
- **Connectivity Plus**: Network status monitoring

#### UI/UX Components
- **Material Design 3**: Consistent UI components
- **Custom Widgets**: Reusable business components
- **Animations**: Smooth transitions and micro-interactions
- **Responsive Layout**: Adaptive UI for different screen sizes

This migration guide provides the comprehensive foundation needed to successfully port all five key features from the Viernes React frontend to a feature-complete Flutter mobile application while maintaining full functional parity and enhancing the mobile user experience.