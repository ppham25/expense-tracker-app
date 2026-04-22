# Expense Tracker App \_ B23DCCN666

A full-stack expense tracking mobile app built with Flutter, Node.js, Express, and MySQL.

## Features

- Secure user authentication with registration, login, and logout
- Full expense management flow: add, edit, delete, and undo delete
- Organized expense tracking with title, amount, category, and transaction date
- Monthly analytics spending chart - Top 3 largest expenses
- Spending breakdown by category with percentage of monthly total
- Budget overview to monitor spending habits
- Profile screen for basic account information

## Tech Stack

- Flutter
- Dart
- Node.js
- Express.js
- MySQL

## Screenshots

### Login

![Login Screen](assets/images/login.png)
Secure user login with email and password.

### Register

![Register Screen](assets/images/register.png)

### Home

![Home Screen](assets/images/home.png)
View expenses in a clean list with category icons and transaction dates.

### Add and Undo Expense

![Add Screen](assets/images/add.png)
![Undo Screen](assets/images/undo.png)

### Statistics

![Statics Screen](assets/images/statics.png)
Analyze monthly spending with a daily chart, category percentages, and top 3 highest expenses.

## Project Structure

- `lib/` – Flutter frontend
- `src/` – Node.js backend

### Frontend

```bash
flutter pub get
flutter run
```

### Backend

```bash
npm install
npm start
```
