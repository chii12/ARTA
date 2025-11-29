# API Endpoint Specification for ARTA Survey Backend

## Base URL
```
Production: https://api.arta.gov.ph/v1
Development: http://localhost:3000/v1
```

## Authentication
Use Bearer token authentication (if required):
```
Authorization: Bearer {token}
```

---

## 1. Submit Survey Response

**Endpoint:** `POST /surveys`

**Description:** Create a new survey response

**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer {token} (optional)
```

**Request Body:**
```json
{
  "timestamp": "2025-11-16T10:30:00.000Z",
  "personalInfo": {
    "name": "string",
    "clientType": "Citizen|Business|Government",
    "sex": "Male|Female",
    "date": "YYYY-MM-DD",
    "age": "string",
    "region": "string",
    "serviceAvailed": "string"
  },
  "ccQuestions": {
    "cc1": "string",
    "cc2": "string",
    "cc3": "string"
  },
  "sqdQuestions": {
    "sqd0": "string",
    "sqd1": "string",
    "sqd2": "string",
    "sqd3": "string",
    "sqd4": "string",
    "sqd5": "string",
    "sqd6": "string",
    "sqd7": "string",
    "sqd8": "string"
  },
  "feedback": {
    "suggestions": "string",
    "email": "string"
  }
}
```

**Success Response:**
```
Status: 201 Created

{
  "success": true,
  "message": "Survey response submitted successfully",
  "data": {
    "id": "survey_123456",
    "timestamp": "2025-11-16T10:30:00.000Z"
  }
}
```

**Error Response:**
```
Status: 400 Bad Request

{
  "success": false,
  "message": "Validation error",
  "errors": [
    "personalInfo.name is required",
    "ccQuestions.cc1 is required"
  ]
}
```

---

## 2. Get All Surveys (Admin)

**Endpoint:** `GET /surveys`

**Description:** Retrieve all survey responses with pagination

**Request Headers:**
```
Authorization: Bearer {admin_token}
```

**Query Parameters:**
```
page: number (default: 1)
limit: number (default: 20, max: 100)
from_date: YYYY-MM-DD (optional)
to_date: YYYY-MM-DD (optional)
client_type: Citizen|Business|Government (optional)
```

**Success Response:**
```
Status: 200 OK

{
  "success": true,
  "data": {
    "surveys": [
      {
        "id": "survey_123456",
        "timestamp": "2025-11-16T10:30:00.000Z",
        "personalInfo": { ... },
        "ccQuestions": { ... },
        "sqdQuestions": { ... },
        "feedback": { ... }
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "totalPages": 8
    }
  }
}
```

---

## 3. Get Survey by ID (Admin)

**Endpoint:** `GET /surveys/:id`

**Description:** Retrieve a specific survey response

**Request Headers:**
```
Authorization: Bearer {admin_token}
```

**Success Response:**
```
Status: 200 OK

{
  "success": true,
  "data": {
    "id": "survey_123456",
    "timestamp": "2025-11-16T10:30:00.000Z",
    "personalInfo": { ... },
    "ccQuestions": { ... },
    "sqdQuestions": { ... },
    "feedback": { ... }
  }
}
```

**Error Response:**
```
Status: 404 Not Found

{
  "success": false,
  "message": "Survey not found"
}
```

---

## 4. Get Survey Statistics (Admin)

**Endpoint:** `GET /surveys/stats`

**Description:** Get aggregated statistics from surveys

**Request Headers:**
```
Authorization: Bearer {admin_token}
```

**Query Parameters:**
```
from_date: YYYY-MM-DD (optional)
to_date: YYYY-MM-DD (optional)
```

**Success Response:**
```
Status: 200 OK

{
  "success": true,
  "data": {
    "totalSurveys": 150,
    "dateRange": {
      "from": "2025-01-01",
      "to": "2025-11-16"
    },
    "clientTypeDistribution": {
      "Citizen": 100,
      "Business": 30,
      "Government": 20
    },
    "sexDistribution": {
      "Male": 80,
      "Female": 70
    },
    "ccResponses": {
      "cc1": {
        "I know what a CC is and I saw this office's CC.": 50,
        "I know what a CC is but I did NOT see this office's CC.": 40,
        "I learned of the CC only when I saw this office's CC.": 35,
        "I do not know what a CC is and I did not see one in this office.": 25
      },
      "cc2": { ... },
      "cc3": { ... }
    },
    "sqdResponses": {
      "sqd0": {
        "STRONGLY AGREE": 60,
        "AGREE": 50,
        "NEITHER AGREE NOR DISAGREE": 20,
        "DISAGREE": 15,
        "STRONGLY DISAGREE": 5
      },
      "sqd1": { ... },
      ...
    },
    "averageRatings": {
      "sqd0": 4.2,
      "sqd1": 4.0,
      ...
    },
    "suggestions": [
      {
        "text": "Improve waiting time",
        "timestamp": "2025-11-16T10:30:00.000Z"
      }
    ]
  }
}
```

---

## 5. Export Surveys (Admin)

**Endpoint:** `GET /surveys/export`

**Description:** Export surveys in CSV or Excel format

**Request Headers:**
```
Authorization: Bearer {admin_token}
```

**Query Parameters:**
```
format: csv|excel (default: csv)
from_date: YYYY-MM-DD (optional)
to_date: YYYY-MM-DD (optional)
```

**Success Response:**
```
Status: 200 OK
Content-Type: text/csv OR application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

(File download)
```

---

## 6. Delete Survey (Admin)

**Endpoint:** `DELETE /surveys/:id`

**Description:** Delete a specific survey response

**Request Headers:**
```
Authorization: Bearer {admin_token}
```

**Success Response:**
```
Status: 200 OK

{
  "success": true,
  "message": "Survey deleted successfully"
}
```

---

## Error Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request - Validation error |
| 401 | Unauthorized - Missing or invalid token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |

---

## Rate Limiting

- Public endpoints: 60 requests per minute
- Admin endpoints: 300 requests per minute

**Rate Limit Headers:**
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1700000000
```

---

## Data Validation Rules

### Personal Info
- `name`: Required, min 2 characters, max 100 characters
- `clientType`: Required, must be one of: "Citizen", "Business", "Government"
- `sex`: Required, must be one of: "Male", "Female"
- `date`: Required, must be valid date in YYYY-MM-DD format
- `age`: Required, must be numeric, between 1-150
- `region`: Required, min 2 characters
- `serviceAvailed`: Required, min 2 characters

### CC Questions
- `cc1`, `cc2`, `cc3`: Required, non-empty strings

### SQD Questions
- `sqd0` through `sqd8`: Required, must be one of:
  - "STRONGLY AGREE"
  - "AGREE"
  - "NEITHER AGREE NOR DISAGREE"
  - "DISAGREE"
  - "STRONGLY DISAGREE"
  - "NOT APPLICABLE"

### Feedback
- `suggestions`: Optional, max 1000 characters
- `email`: Optional, must be valid email format if provided

---

## Sample Implementation (Node.js/Express)

```javascript
// POST /surveys endpoint
router.post('/surveys', async (req, res) => {
  try {
    const { 
      timestamp, 
      personalInfo, 
      ccQuestions, 
      sqdQuestions, 
      feedback 
    } = req.body;

    // Validate data
    const errors = validateSurveyData(req.body);
    if (errors.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors
      });
    }

    // Save to database
    const survey = await Survey.create({
      timestamp,
      personalInfo,
      ccQuestions,
      sqdQuestions,
      feedback
    });

    res.status(201).json({
      success: true,
      message: 'Survey response submitted successfully',
      data: {
        id: survey.id,
        timestamp: survey.timestamp
      }
    });
  } catch (error) {
    console.error('Error creating survey:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});
```

---

## Database Schema Recommendation

### MongoDB Schema
```javascript
const surveySchema = new Schema({
  timestamp: { type: Date, required: true, index: true },
  personalInfo: {
    name: { type: String, required: true },
    clientType: { type: String, required: true, enum: ['Citizen', 'Business', 'Government'] },
    sex: { type: String, required: true, enum: ['Male', 'Female'] },
    date: { type: String, required: true },
    age: { type: String, required: true },
    region: { type: String, required: true },
    serviceAvailed: { type: String, required: true }
  },
  ccQuestions: {
    cc1: { type: String, required: true },
    cc2: { type: String, required: true },
    cc3: { type: String, required: true }
  },
  sqdQuestions: {
    sqd0: { type: String, required: true },
    sqd1: { type: String, required: true },
    sqd2: { type: String, required: true },
    sqd3: { type: String, required: true },
    sqd4: { type: String, required: true },
    sqd5: { type: String, required: true },
    sqd6: { type: String, required: true },
    sqd7: { type: String, required: true },
    sqd8: { type: String, required: true }
  },
  feedback: {
    suggestions: { type: String, default: '' },
    email: { type: String, default: '' }
  }
}, { timestamps: true });

surveySchema.index({ 'personalInfo.clientType': 1 });
surveySchema.index({ 'personalInfo.date': 1 });
```

---

**Document Version:** 1.0  
**Last Updated:** November 16, 2025
