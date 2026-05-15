const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const userModel = require("../models/userModel");
const categoryModel = require("../models/categoryModel");

const register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        message: "Name, email and password are required",
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        message: "Password must be at least 6 characters",
      });
    }

    const existingUser = await userModel.findByEmail(email);

    if (existingUser) {
      return res.status(400).json({
        message: "Email already exists",
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const userId = await userModel.createUser(name, email, passwordHash);

    await categoryModel.createDefaultCategoriesForUser(userId);

    return res.status(201).json({
      message: "Register successful",
      user: {
        id: userId,
        name,
        email,
      },
    });
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: "Email and password are required",
      });
    }

    const user = await userModel.findByEmail(email);

    if (!user) {
      return res.status(400).json({
        message: "Invalid email or password",
      });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(400).json({
        message: "Invalid email or password",
      });
    }

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    return res.status(200).json({
      message: "Login successful",
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
    });
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const getMe = async (req, res) => {
  try {
    const user = await userModel.findById(req.user.userId);

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    return res.status(200).json({
      user,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

const changePassword = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { oldPassword, newPassword, confirmPassword } = req.body;

    if (!oldPassword || !newPassword || !confirmPassword) {
      return res.status(400).json({
        message: "Old password, new password and confirm password are required",
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        message: "New password must be at least 6 characters",
      });
    }

    if (newPassword !== confirmPassword) {
      return res.status(400).json({
        message: "Confirm password does not match",
      });
    }

    if (oldPassword === newPassword) {
      return res.status(400).json({
        message: "New password must be different from old password",
      });
    }

    const user = await userModel.findAuthById(userId);

    if (!user) {
      return res.status(404).json({
        message: "User not found",
      });
    }

    const isOldPasswordCorrect = await bcrypt.compare(
      oldPassword,
      user.password_hash,
    );

    if (!isOldPasswordCorrect) {
      return res.status(400).json({
        message: "Old password is incorrect",
      });
    }

    const newPasswordHash = await bcrypt.hash(newPassword, 10);

    await userModel.updatePassword(userId, newPasswordHash);

    return res.status(200).json({
      message: "Change password successful",
    });
  } catch (error) {
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
};

module.exports = {
  register,
  login,
  getMe,
  changePassword,
};
