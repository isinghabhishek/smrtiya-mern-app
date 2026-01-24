import mongoose from "mongoose";

// Define the schema for a user document
const userSchema = mongoose.Schema({
  // User's full name (required field)
  name: { type: String, required: true },
  // User's email address (required field)
  email: { type: String, required: true },
  // User's password (required field)
  password: { type: String, required: true },
  // User's unique ID
  id: { type: String },
});

// Create and export the User model based on the schema
export default mongoose.model("User", userSchema);
