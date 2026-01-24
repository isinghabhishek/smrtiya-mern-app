import mongoose from "mongoose";

// Define the schema for a post message document
const postSchema = mongoose.Schema({
  // Title of the post
  title: String,
  // Main content/body of the post
  message: String,
  // Name of the person who created the post
  name: String,
  // User ID of the creator
  creator: String,
  // Array of tags associated with the post
  tags: [String],
  // URL or file path of the selected image
  selectedFile: String,
  // Array of user IDs who have liked this post
  likes: { type: [String], default: [] },
  // Timestamp when the post was created
  createdAt: {
    type: Date,
    default: new Date(),
  },
});

// Create and export the PostMessage model based on the schema
var PostMessage = mongoose.model("PostMessage", postSchema);

export default PostMessage;
