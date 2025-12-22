# WheelBoard API - Quick Reference

## 📚 Documentation Index

This repository contains complete API documentation for the WheelBoard platform:

1. **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** - Complete API reference (60+ endpoints)
2. **[USER_TYPES_FLOW.md](./USER_TYPES_FLOW.md)** - User workflows and interactions
3. **[ISSUES_AND_MIGRATION.md](./ISSUES_AND_MIGRATION.md)** - Issues report and migration roadmap

---

## 🎯 Quick Overview

### Base URL
```
https://wheelboardapi.addonshareware.com/
```

### User Types
1. **Transport Company** - Fleet management, trip scheduling, hiring
2. **Service Provider** - Service listings and bookings
3. **Professional** - Job applications, trip bidding

### Total Endpoints: **60+**

---

## 🔑 Authentication

### Register
```http
POST /api/User/company_signup
POST /api/User/professional_signup
```

### Login
```http
POST /api/User/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response**:
```json
{
  "userId": "string",
  "token": "string",
  "userType": "Company|Professional|ServiceProvider"
}
```

### Use Token
```http
Authorization: Bearer {token}
```

---

## 🚛 Transport Company - Top Endpoints

### Fleet Management
```http
# Drivers
POST   /api/Transport/add-driver
PUT    /api/Transport/update-driver
GET    /api/Transport/drivers?userId={userId}

# Vehicles
POST   /api/Transport/add-vehicle
PUT    /api/Transport/update-vehicle
GET    /api/Transport/vehicle?userId={userId}
```

### Trip Management
```http
# Create & List
POST   /api/Trip/add-trip
GET    /api/Trip/trip-list/{userId}

# Bidding
GET    /api/Trip/get-trip-bids/{tripId}
POST   /api/Trip/assign-trip/{bidId}
```

### Job Postings
```http
POST   /api/Job/add-job
GET    /api/Job/job-list/{userId}
GET    /api/Job/get-applications/{jobId}
PUT    /api/Job/update-job-status
```

---

## 🛠️ Service Provider - Top Endpoints

### Service Management
```http
POST   /api/Service/add-service
PUT    /api/Service/update-service
DELETE /api/Service/{serviceId}/user/{userId}/delete
GET    /api/Service/service-list/{userId}
GET    /api/Service/details/{serviceId}
```

### Service Assignments
```http
GET    /api/Service/service-assign-list?serviceId={serviceId}
POST   /api/Service/assign-service
PUT    /api/Service/update-service-status?assignmentId={id}&status={status}
POST   /api/Service/complete-service?assignmentId={id}
```

---

## 👨‍🔧 Professional - Top Endpoints

### Job Search
```http
GET    /api/Job/open-job-list
POST   /api/Job/apply-job
GET    /api/Job/applied-jobs/{userId}
POST   /api/Job/job-like-toggle
```

### Trip Bidding
```http
GET    /api/Trip/unassign-trip-list
GET    /api/Trip/unassigned-trip-details/{tripId}
POST   /api/Trip/submit-bid
GET    /api/Trip/assign-trip-list/{driverId}
```

---

## 🌐 Common Endpoints

### Profile
```http
GET    /api/User/user-profile?userId={userId}
PUT    /api/User/update-professional-profile
PUT    /api/User/update-transport-profile
```

### Posts/Feed
```http
GET    /api/Post/get-all-post
POST   /api/Post/add
```

### Notifications
```http
GET    /api/NotificationsApi/notifications?userId={userId}
POST   /api/NotificationsApi/notification/read
```

### Dashboard
```http
GET    /api/Dashboard/GetDashboard?userId={userId}
```

---

## 📊 Data Models Quick Reference

### Trip
```json
{
  "tripId": "string",
  "userId": "string",
  "vehicleId": "string",
  "driverId": "string",
  "pickupLocation": "string",
  "deliveryLocation": "string",
  "pickupDate": "ISO8601",
  "pickupTime": "string",
  "payRange": "string",
  "tripStatus": "Posted|Scheduled|Completed",
  "totalBidCount": 0
}
```

### Job
```json
{
  "jobId": "string",
  "role": "string",
  "jobDuration": "string",
  "openings": 0,
  "salary": 0,
  "city": "string",
  "jobType": "string",
  "description": "string",
  "imagePaths": []
}
```

### Service
```json
{
  "serviceId": "string",
  "serviceTitle": "string",
  "city": "string",
  "fullAddress": "string",
  "isAvailable": true,
  "businessName": "string",
  "businessType": "string",
  "contactNumber": "string",
  "price": 0
}
```

---

## ⚠️ Known Issues (Top 5)

### 1. Endpoint Naming Conflicts
```
❌ Same path for different operations:
   POST /api/Trip/assign-trip/{bidId}
   GET  /api/Trip/assign-trip/{userId}
```

### 2. Required Fields for Optional Data
```
❌ VehicleNumber required even when driver not assigned
   Workaround: Send "Not Assigned"

❌ DriverId required even for Posted trips
   Workaround: Send empty string
```

### 3. Inconsistent Field Naming
```
❌ Request: PascalCase (UserId, VehicleId)
   Response: camelCase (userId, vehicleId)
```

### 4. No Pagination
```
❌ All list endpoints return ALL records
   Can cause performance issues
```

### 5. No Error Standard
```
❌ Different error formats
   Difficult to handle errors consistently
```

**See [ISSUES_AND_MIGRATION.md](./ISSUES_AND_MIGRATION.md) for complete list and solutions**

---

## 🔄 Typical Workflows

### Transport: Post Trip for Bidding
```
1. POST /api/Trip/add-trip
   - TripStatus: "Posted"
   - DriverId: "" (empty)
   
2. Professionals see trip and submit bids

3. GET /api/Trip/get-trip-bids/{tripId}
   - Review all bids
   
4. POST /api/Trip/assign-trip/{bidId}
   - Assign to best bid
   
5. Trip assigned ✅
```

### Professional: Apply for Job
```
1. GET /api/Job/open-job-list
   - Browse available jobs
   
2. POST /api/Job/apply-job
   - Submit application
   
3. GET /api/Job/applied-jobs/{userId}
   - Check application status
   
4. Wait for company to accept ✅
```

### Service Provider: Handle Booking
```
1. POST /api/Service/add-service
   - List service
   
2. Customer books service

3. GET /api/Service/service-assign-list
   - See bookings
   
4. PUT /api/Service/update-service-status
   - Status: "In Progress"
   
5. POST /api/Service/complete-service
   - Mark as completed ✅
```

---

## 🚀 Getting Started

### 1. Choose User Type
- Transport Company → Fleet management
- Service Provider → Service listings
- Professional → Find work

### 2. Register & Login
```http
POST /api/User/company_signup
# or
POST /api/User/professional_signup

# Then login
POST /api/User/login
```

### 3. Complete Profile
```http
# Transport
POST /api/User/complete-transport

# Service Provider
POST /api/User/complete-service-provider
```

### 4. Start Using Features
- Transport: Add drivers/vehicles, create trips
- Service Provider: Add services
- Professional: Browse jobs/trips, apply/bid

---

## 📱 Mobile App Integration

### Flutter/Dart
```dart
// API Constants
class ApiConstants {
  static const String baseUrl = 'https://wheelboardapi.addonshareware.com/';
}

// Headers
final headers = {
  'Authorization': 'Bearer $token',
  'Accept': '*/*',
  'Content-Type': 'application/json',
};

// Example: Get Trips
final response = await http.get(
  Uri.parse('${ApiConstants.baseUrl}api/Trip/trip-list/$userId'),
  headers: headers,
);
```

### Multipart Upload (Images)
```dart
var request = http.MultipartRequest(
  'POST',
  Uri.parse('${ApiConstants.baseUrl}api/Transport/add-driver'),
);

request.headers['Authorization'] = 'Bearer $token';
request.fields['UserId'] = userId;
request.fields['FullName'] = fullName;
// ... other fields

if (imageFile != null) {
  request.files.add(
    await http.MultipartFile.fromPath('image', imageFile.path),
  );
}

final response = await request.send();
```

---

## 🔍 Search & Filter (Limited Support)

### Current Limitations
```
❌ No pagination
❌ No search by keyword
❌ No date range filters
❌ No advanced filters
```

### Workaround
```
1. Fetch all records
2. Filter on client side
3. Implement local pagination
```

**Note**: New backend will have proper search/filter support

---

## 💡 Best Practices

### 1. Error Handling
```dart
try {
  final response = await apiCall();
  if (response.statusCode == 200) {
    // Success
  } else {
    // Handle error
    print('Error: ${response.statusCode}');
  }
} catch (e) {
  // Network error
  print('Network error: $e');
}
```

### 2. Token Management
```dart
// Store token securely
await storage.write(key: 'auth_token', value: token);

// Use in all requests
final token = await storage.read(key: 'auth_token');
headers['Authorization'] = 'Bearer $token';

// Handle token expiration
if (response.statusCode == 401) {
  // Token expired, re-login
  await login();
}
```

### 3. Image Handling
```dart
// Format image URL
String formatImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return '${ApiConstants.baseUrl}$path';
}
```

### 4. Date Formatting
```dart
// Send to API (ISO8601)
final dateString = DateTime.now().toIso8601String();

// Parse from API
final date = DateTime.parse(json['pickupDate']);
```

---

## 📞 Support & Resources

### Documentation
- **Complete API Docs**: [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
- **User Flows**: [USER_TYPES_FLOW.md](./USER_TYPES_FLOW.md)
- **Issues & Migration**: [ISSUES_AND_MIGRATION.md](./ISSUES_AND_MIGRATION.md)

### Common Questions

**Q: How to handle "Not Assigned" vehicle number?**  
A: When adding driver without vehicle, send `VehicleNumber: "Not Assigned"`

**Q: How to create posted trip?**  
A: Set `TripStatus: "Posted"` and `DriverId: ""` (empty)

**Q: Why different field names in request/response?**  
A: Known issue. Request uses PascalCase, response uses camelCase

**Q: How to get paginated results?**  
A: Not supported yet. Fetch all and paginate on client side

**Q: Token expired, what to do?**  
A: Re-login to get new token (refresh token not implemented)

---

## 🎯 Next Steps

### For New Backend Development
1. Read [ISSUES_AND_MIGRATION.md](./ISSUES_AND_MIGRATION.md)
2. Follow migration roadmap (12 weeks)
3. Implement proper REST API design
4. Add missing features (pagination, search, etc.)
5. Fix all known issues

### For Current App Development
1. Use workarounds for known issues
2. Implement client-side pagination
3. Handle inconsistent field naming
4. Add proper error handling
5. Plan for API migration

---

## 📊 Statistics

- **Total Endpoints**: 60+
- **User Types**: 3
- **Data Models**: 30+
- **Known Issues**: 15+
- **Missing Features**: 10+

---

**Quick Reference Version**: 1.0  
**Last Updated**: December 20, 2024  
**Status**: Production

---

## 🔗 Quick Links

- [Full API Documentation →](./API_DOCUMENTATION.md)
- [User Types & Flows →](./USER_TYPES_FLOW.md)
- [Issues & Migration Guide →](./ISSUES_AND_MIGRATION.md)
