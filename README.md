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

## Screenshots

### Login

Secure user login with email and password.

<img src="assets/images/login.png" alt="Login Screen" width="260"/>

### Register

New users can create an account and start tracking expenses.

<img src="assets/images/register.png" alt="Register Screen" width="260"/>

### Home

View expenses in a clean list with category icons and transaction dates.

<img src="assets/images/home.png" alt="Home Screen" width="260"/>

### Add and Undo Expense

Add a new expense and restore deleted records with undo support.

<img src="assets/images/add.png" alt="Add Screen" width="260"/>
<img src="assets/images/undo.png" alt="Undo Screen" width="260"/>

### Statistics

Analyze monthly spending with a daily chart, category percentages, and top 3 highest expenses.

<img src="assets/images/statics.png" alt="Statistics Screen" width="260"/>

## Project Structure

- `lib/` – Flutter frontend
- `backend/` – Node.js backend

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
