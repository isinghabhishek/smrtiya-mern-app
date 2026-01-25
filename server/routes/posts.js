import express from "express";

// Import all post controller functions for handling post operations
import {
  getPosts,
  getPostsBySearch,
  getPost,
  createPost,
  updatePost,
  likePost,
  deletePost,
} from "../controllers/posts.js";

const router = express.Router();
// Import authentication middleware to protect routes
import auth from "../middleware/auth.js";

// GET routes for retrieving posts
router.get("/search", getPostsBySearch); // Search posts by query parameters
router.get("/", getPosts); // Get all posts with pagination
router.get("/:id", getPost); // Get a single post by ID

// POST route for creating new posts (requires authentication)
router.post("/", auth, createPost);
// PATCH routes for updating posts (requires authentication)
router.patch("/:id", auth, updatePost); // Update a post
router.delete("/:id", auth, deletePost); // Delete a post
router.patch("/:id/likePost", auth, likePost); // Like/unlike a post

export default router;
