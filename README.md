# 🌟 Smrtiyan (स्मृतियां) - Memories MERN Application
[![CI Workflow](https://github.com/isinghabhishek/smrtiya-mern-app/actions/workflows/ci.yml/badge.svg)](https://github.com/isinghabhishek/smrtiya-mern-app/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![React Version](https://img.shields.io/badge/React-v16.12-blue.svg)](https://reactjs.org/)
[![Node Version](https://img.shields.io/badge/Node-v16-green.svg)](https://nodejs.org/)

**Smrtiyan** (derived from the Sanskrit word *Smriti*, meaning *Memories*) is a feature-rich, full-stack MERN application. It serves as a personal and social diary where users can log in, post details about their memorable moments, share pictures, search through posts, and interact with posts created by others.
🔗 **Live Web Application**: [https://smrtiyanmernapp.netlify.app](https://smrtiyanmernapp.netlify.app)
---
## 📸 Application Interface
### Memories Dashboard
![Smrtiyan Dashboard](https://user-images.githubusercontent.com/91690267/190505036-05400505-95e2-4001-b202-28a393ed0307.jpg)
---
## ✨ Key Features
- **🔐 Dual Authentication Modes**:
  - **Custom JWT Sign-in**: Email-based signup and sign-in backed by salted password hashing using `bcryptjs`.
  - **Google OAuth**: One-click login using Google OAuth2 integration (`react-google-login`).
- **📝 Complete CRUD Operations**:
  - Create posts with title, description, tags, and image attachment.
  - Read posts in detail.
  - Update post details dynamically.
  - Delete posts (strictly authorized).
- **🛡️ Granular Access Control**:
  - Public/Guest users can view posts and search.
  - Signed-in users can like any memory and write comments.
  - **Ownership Restriction**: Only the original creator of a post has permissions to update or delete it.
- **🔍 Advanced Search & Filter**:
  - Search memory posts dynamically by title/text.
  - Filter memories by specific tags.
- **📖 Pagination**:
  - Dynamic pagination to divide memories into clean pages, improving client-side rendering speed.
- **💬 Comments System**:
  - Real-time commenting on individual posts to share feedback or thoughts.
---
## 🛠️ Architecture & Tech Stack
### Frontend (Client)
- **Library**: React.js (v16.12)
- **State Management**: Redux & Redux-Thunk (for asynchronous action dispatching)
- **UI Framework**: Material-UI (v4.9) Core, Icons, and Lab
- **Utilities**:
  - `axios`: Promise-based HTTP requests to backend.
  - `jwt-decode`: Token parsing to identify user roles.
  - `react-file-base64`: Converting image uploads to Base64 strings for MongoDB storage.
  - `moment`: Parsing and displaying human-readable timestamps.
### Backend (Server)
- **Environment**: Node.js & Express.js
- **Database**: MongoDB (Atlas) database using **Mongoose** (v5.9) ODM
- **Security**: `bcryptjs` for security and encryption, `jsonwebtoken` for signing and validating JWT tokens.
- **CORS Config**: Enabled cross-origin requests to allow frontend to communicate with API endpoints.
### CI/CD Pipeline
- **GitHub Actions**: Configured via `.github/workflows/ci.yml` running on `ubuntu-latest`. It automatically validates dependency tree setup and executes builds for both client and server code on push and PR triggers to `master` and `main` branches.
---
## 📁 Repository Directory Structure
```text
smrtiya-mern-app/
├── .github/
│   └── workflows/
│       └── ci.yml             # CI build validation pipeline
├── client/                    # React frontend project folder
│   ├── public/                # Public assets
│   ├── src/                   # React source files
│   │   ├── actions/           # Redux actions (auth, posts)
│   │   ├── api/               # Axios API call setup
│   │   ├── components/        # UI Components (Auth, Forms, Home, Navbar, Pagination, Posts)
│   │   ├── constants/         # Redux ActionTypes definitions
│   │   ├── reducers/          # Redux reducers
│   │   ├── App.js             # Main App layout & Routing
│   │   └── index.js           # Client entry point
│   ├── package.json           # Frontend package dependencies & scripts
│   └── .eslintrc.js           # ESLint React configuration rules
└── server/                    # Express backend project folder
    ├── controllers/           # API Controller logic (posts, users)
    ├── middleware/            # Auth middleware (JWT checks)
    ├── models/                # MongoDB Mongoose schemas (postMessage, user)
    ├── routes/                # Express routes (posts.js, user.js)
    ├── index.js               # Backend application entry point
    ├── .Procfile              # Deployment config for cloud hosts
    ├── .env.example           # Reference template for configuration
    └── package.json           # Backend dependencies & scripts
```
---
## ⚙️ Local Configuration & Bug Fixes
### 1. Database Connection URL Setup
> [!IMPORTANT]
> The credential values were removed from `server/index.js` in a recent security sweep. 
> To run the backend successfully, you **must** configure the database string and server configurations using environment variables.
In `server/index.js`, update the connection initialization to fetch from `process.env`:
```javascript
import dotenv from "dotenv";
dotenv.config();
// ... inside index.js
const CONNECTION_URL = process.env.CONNECTION_URL;
```
### 2. Environment Variables (.env)
Create a `.env` file inside the `server/` directory using `.env.example` as a template:
```env
PORT = 5000
CONNECTION_URL = mongodb+srv://<username>:<password>@cluster.mongodb.net/dbname?retryWrites=true&w=majority
JWT_SECRET = <custom-jwt-secret-string-here>
```
---
## 🚀 Installation & Setup
### Prerequisites
- Node.js installed locally (Recommended version: `v16.x`)
- A MongoDB cluster instance (such as MongoDB Atlas)
### Step 1: Install Dependencies
Run the install command inside both directories:
**Server Setup:**
```bash
cd server
npm install
```
**Client Setup:**
```bash
cd ../client
npm install --legacy-peer-deps
```
### Step 2: Running the Application
**Run Server:**
```bash
cd server
npm start
```
The server will boot up and listen on `http://localhost:5000`.
**Run Client:**
```bash
cd client
npm start
```
The client React app will start and run on `http://localhost:3000`.
---
## 🧪 CI/CD Testing & Verifications
The codebase includes automated sanity checks configured via GitHub Actions.
To verify builds locally before pushing:
- **Client Tests and Builds:**
  ```bash
  cd client
  npm test -- --watchAll=false --passWithNoTests
  npm run build
  ```
- **Server Checks:**
  ```bash
  cd server
  # Verify node boots without syntax issues
  node index.js
  ```
---
## 📜 License
Distributed under the **MIT License**. See `LICENSE` for more information.
