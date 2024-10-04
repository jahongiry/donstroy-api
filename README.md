\*\*Users
POST /api/v1/login
https://donstroy-api-production.up.railway.app/api/v1/login
+
```
{
  "email": "domstroy@gmail.com",
  "password": "dom123"
}
```

\*\*Courses

GET /api/v1/courses

POST /api/v1/courses

```
{
    "course": {
        "name": "Introduction to Programming",
        "description": "A beginner-friendly course to learn programming basics.",
        "teacher": "John Doe"
    }
}
```

DELETE /api/v1/courses/1

PATCH/PUT /courses/1

```
{
    "course": {
        "name": "Introduction to Programming updated",
        "description": "A beginner-friendly course to learn programming basics. updated",
        "teacher": "John Doe updated"
    }
}
```
