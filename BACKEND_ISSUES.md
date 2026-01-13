# Backend Issues from Mobile Testing

This document lists backend-related issues discovered during mobile app smoke testing (02/01/2026) that require backend API or SSE server fixes.

---

## 🔴 HIGH PRIORITY

### Bug #2: SSE Event Contains Wrong Customer Name

**Severity:** HIGH
**Status:** Requires Backend Fix

**Issue:**
When starting a conversation with a customer (e.g., "Angie Valeria"), the notification displays a different customer's name (e.g., "Paola Zuluaga"). Additionally, the notification does not redirect to the conversation screen.

**Mobile Code Location:**
- `lib/core/services/notification_service.dart:288-290`
- `lib/core/models/sse_events.dart:144-157`

**Expected Behavior:**
- SSE `newConversation` event should contain the correct customer name in the `user_name` field
- The name should match the customer with whom the conversation is being started

**Actual Behavior:**
- SSE event contains a different customer's name
- Possibly the last active customer or a cached value

**Investigation Needed:**
- Check backend SSE event generation for `newConversation` events
- Verify the `user_name` field is populated with the correct customer data
- Check if there's a race condition or caching issue causing wrong customer data

**API Endpoint:** SSE Stream - `newConversation` event

**Event Structure Expected:**
```json
{
  "type": "newConversation",
  "userId": 123,
  "userName": "Angie Valeria",  // ← This field contains wrong name
  "userPhone": "+573001234567",
  "conversationId": 456
}
```

---

### Bug #3: Cannot Delete Customer

**Severity:** HIGH
**Status:** Requires Investigation

**Issue:**
Deleting customers fails with generic error message "Failed to delete customer". The mobile app correctly handles 200/204 responses, so the issue is likely on the backend.

**Mobile Code Location:**
- `lib/features/customers/data/datasources/customer_remote_datasource.dart:388-441`
- `lib/features/customers/presentation/pages/customer_detail_page.dart:241`

**Expected Behavior:**
- DELETE request should successfully remove customer or return proper error message
- Should return 200 or 204 on success

**Actual Behavior:**
- API returns an error (exact status code unknown)
- Possible causes:
  - Foreign key constraint preventing deletion
  - Soft-delete mechanism failing
  - Permission/authorization issue
  - Customer has related records (conversations, etc.)

**Investigation Needed:**
- Check backend API logs for actual error when deleting customers
- Verify foreign key constraints and cascading delete rules
- Check if soft-delete is implemented and working correctly
- Ensure proper error messages are returned to client

**API Endpoint:** `DELETE /organization_users/customers/{customerId}`

**Note:** Mobile error handling should also be improved to display actual backend error message instead of generic message.

---

### Bug #12: Cannot Send Images to Client

**Severity:** HIGH
**Status:** Requires Backend Investigation

**Issue:**
Advisors cannot send images to clients during conversations. The mobile app uploads images using multipart form data, but they don't appear in the conversation.

**Mobile Code Location:**
- `lib/features/conversations/data/datasources/conversation_remote_datasource.dart:422-497`

**Expected Behavior:**
- Advisor should be able to upload and send images
- API should accept multipart file upload
- Response should include message object with media URL

**Actual Behavior:**
- Image upload fails or doesn't create message
- Images don't appear in conversation

**Investigation Needed:**
- Check if backend accepts media uploads for this endpoint
- Verify API returns proper message structure with `media` URL
- Check backend logs for upload errors
- Verify file storage (S3, local, etc.) is working

**API Endpoint:** `POST /conversations/{conversationId}/messages/media/`

**Request Format:**
```
Content-Type: multipart/form-data

file: <binary data>
caption: "Optional caption"
```

**Expected Response:**
```json
{
  "id": 789,
  "conversationId": 456,
  "text": null,
  "media": "https://cdn.example.com/path/to/image.jpg",
  "media_type": "image/jpeg",
  "file_name": "image.jpg",
  "fromAgent": true,
  "createdAt": "2026-01-06T12:00:00Z"
}
```

---

### Bug #13: Client Images Not Received in Viernes

**Severity:** HIGH
**Status:** Requires Backend Investigation

**Issue:**
Images sent by clients don't appear in the Viernes mobile app. The mobile app expects `media`, `media_type`, and `file_name` fields in message responses.

**Mobile Code Location:**
- `lib/features/conversations/domain/entities/message_entity.dart:67-74`
- `lib/features/conversations/data/models/message_model.dart:27-51`
- `lib/features/conversations/presentation/widgets/message_bubble.dart:80`

**Expected Behavior:**
- Client images should be included in SSE events and API responses
- Message object should contain media URL and type
- Images should be accessible via the provided URL

**Actual Behavior:**
- Messages with images don't include `media` field
- or `media_type` field is missing/incorrect
- or Media URLs are not accessible (CORS, auth issues)

**Investigation Needed:**
- Check if backend SSE/API returns `media` field with proper URL for client images
- Verify `media_type` field is set correctly (should be 'image/jpeg', 'image/png', etc.)
- Check if media URLs are publicly accessible or require authentication
- Verify CORS headers if images are on different domain
- Check if WhatsApp/Instagram media webhook properly downloads and stores images

**Message Model Expected Fields:**
```json
{
  "id": 123,
  "conversationId": 456,
  "text": "Check out this image",
  "media": "https://cdn.example.com/client-images/image.jpg",  // ← Must be present
  "media_type": "image/jpeg",  // ← Must be present and correct
  "file_name": "photo.jpg",    // ← Must be present
  "fromUser": true,
  "createdAt": "2026-01-06T12:00:00Z"
}
```

---

## 🟡 MEDIUM PRIORITY

### Bug #9: Cannot Create Internal Notes

**Severity:** MEDIUM
**Status:** Requires Backend Investigation

**Issue:**
Creating internal notes in conversations fails with error "Error al crear la nota".

**Mobile Code Location:**
- `lib/features/internal_notes/data/datasources/internal_notes_remote_datasource.dart:116-185`

**Expected Behavior:**
- POST request with note content should create internal note
- API should return 200 or 201 with created note object

**Actual Behavior:**
- API returns validation error or other error
- Note is not created

**Investigation Needed:**
- Check backend logs for actual validation error
- Verify API expects `content` field (not different field name)
- Check if additional required fields are missing from mobile request
- Verify conversation exists and is accessible
- Check if response structure matches `InternalNoteModel.fromJson()` expectations

**API Endpoint:** `POST /conversations/{conversationId}/internal_notes`

**Request Format:**
```json
{
  "content": "This is an internal note"
}
```

**Expected Response:**
```json
{
  "id": 123,
  "conversationId": 456,
  "content": "This is an internal note",
  "createdBy": {
    "id": 789,
    "fullname": "Agent Name"
  },
  "createdAt": "2026-01-06T12:00:00Z"
}
```

---

### Bug #10: Conversation List Not Auto-Updating

**Severity:** MEDIUM
**Status:** Requires SSE Investigation

**Issue:**
Conversation list doesn't automatically update when new messages arrive, requiring manual refresh.

**Mobile Code Location:**
- `lib/features/conversations/presentation/providers/conversation_provider.dart:825-862`

**Root Cause Analysis:**
- Mobile app subscribes to SSE `userMessage` and `agentMessage` events
- Events should trigger conversation list to move updated conversation to top
- SSE connection must be established and maintained

**Investigation Needed:**
1. Verify backend SSE events are sent for all conversation updates
2. Check if SSE connection stays alive or disconnects prematurely
3. Verify events include all required fields (`conversationId`, `userId`, `text`, etc.)
4. Check SSE server logs for connection issues
5. May be authentication token expiry causing SSE disconnection

**SSE Events Expected:**
- `userMessage` - When customer sends message
- `agentMessage` - When agent sends message
- `newConversation` - When new conversation starts

**Mobile SSE Initialization:**
- Connection established in `AuthenticationWrapper` after login
- Requires valid Firebase auth token
- Should reconnect automatically on disconnect

---

### Bug #14: Conversation Reassignment Not Available

**Severity:** MEDIUM
**Status:** Feature Not Implemented

**Issue:**
No option available to reassign conversations to other advisors/agents.

**Investigation Needed:**
- Feature may not be implemented in either mobile or backend
- No API endpoint found for reassignment in current mobile code

**Implementation Needed:**
- Backend API endpoint: `POST /conversations/{id}/reassign` or `PATCH /conversations/{id}`
- Request body should include target agent ID
- Mobile UI needs reassignment dialog/button in conversation detail screen

**Suggested API Endpoint:**
```
POST /conversations/{conversationId}/reassign

Request:
{
  "agentId": 123
}

Response:
{
  "conversationId": 456,
  "agentId": 123,
  "agent": {
    "id": 123,
    "fullname": "New Agent Name"
  },
  "reassignedAt": "2026-01-06T12:00:00Z"
}
```

---

## 📝 TESTING RECOMMENDATIONS

1. **Enable Backend Logging:** Increase log verbosity for API endpoints and SSE events mentioned above
2. **Test SSE Events:** Use SSE client tools to monitor event stream and verify event payloads
3. **API Testing:** Use Postman/Insomnia to test endpoints independently of mobile app
4. **Database Inspection:** Check database records after failed operations to understand state
5. **Error Response Format:** Ensure all API errors return consistent format with meaningful messages

---

## ✅ MOBILE IMPROVEMENTS MADE

While investigating these backend issues, the following mobile improvements were implemented:

1. **Bug #3 - Better Error Messages:** Mobile should display actual backend error message instead of generic "Failed to delete customer"
2. **Bug #10 - SSE Debugging:** Add logging to track SSE connection status and event reception

---

## 📞 CONTACT

For questions about these issues, refer to:
- Mobile code: `/Users/ianmoone/Development/Banana/viernes_mobile/`
- Backend team: [Contact information]
- Testing report: `Reporte Testing - Viernes.pdf`

---

**Document Created:** 2026-01-06
**Mobile App Version:** Current development build
**Backend Environment:** Development/Production (specify)
