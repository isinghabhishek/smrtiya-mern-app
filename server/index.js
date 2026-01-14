import express from "express";
import bodyParser from "body-parser";
import mongoose from "mongoose";
import cors from "cors";

import postRoutes from "./routes/posts.js";
import userRouter from "./routes/user.js";

const app = express();

// Parse incoming JSON requests and limit payload size to avoid large requests
app.use(express.json({ limit: "30mb", extended: true }));
// Parse URL-encoded form data (from HTML forms)
app.use(express.urlencoded({ limit: "30mb", extended: true }));
// Enable CORS so the client (running on a different origin) can talk to this API
app.use(cors());

// Mount route handlers: requests to /posts go to postRoutes, /user to userRouter
app.use("/posts", postRoutes);
app.use("/user", userRouter);

// Simple root endpoint to verify the server is running
app.get("/", (req, res) => {
  res.send("APP IS RUNNING.");
});

// MongoDB connection string (Atlas). Keep credentials secure in environment variables for production.
const CONNECTION_URL =
  "mongodb+srv://isinghabhishek:AbhiShekMGDB05@cluster0.zjaij9d.mongodb.net/smrtiyanapp?retryWrites=true&w=majority";
// Port to listen on; prefer environment-provided value for deployments
const PORT = process.env.PORT || 5000;

// Connect to MongoDB then start the Express server. Log success or connection errors.
mongoose
  .connect(CONNECTION_URL, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() =>
    app.listen(PORT, () =>
      console.log(`Server Running on Port: http://localhost:${PORT}`)
    )
  )
  .catch((error) => console.log(`${error} did not connect`));

// Mongoose configuration: avoid deprecated findAndModify behavior
mongoose.set("useFindAndModify", false);
