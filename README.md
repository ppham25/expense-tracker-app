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

## Demo Preview

![Demo GIF](assets/images/demo.gif)

## Tech Stack

- Flutter
- Dart
- Node.js
- Express.js
- MySQL

## Screenshots

<table>
  <tr>
    <td align="center">
      <img src="assets/images/login.png" alt="Login Screen" width="220"/><br/>
      <sub>Login</sub>
    </td>
    <td align="center">
      <img src="assets/images/register.png" alt="Register Screen" width="220"/><br/>
      <sub>Register</sub>
    </td>
    <td align="center">
      <img src="assets/images/home.png" alt="Home Screen" width="220"/><br/>
      <sub>Home</sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="assets/images/add.png" alt="Add Screen" width="220"/><br/>
      <sub>Add Expense</sub>
    </td>
    <td align="center">
      <img src="assets/images/undo.png" alt="Undo Screen" width="220"/><br/>
      <sub>Undo Delete</sub>
    </td>
    <td align="center">
      <img src="assets/images/statics.png" alt="Statistics Screen" width="220"/><br/>
      <sub>Statistics</sub>
    </td>
  </tr>
</table>

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
