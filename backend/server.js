import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// ================= MODEL =================
const taskSchema = new mongoose.Schema({
  title: String,
  status: {
    type: String,
    default: "pending",
  },
});

const Task = mongoose.model("Task", taskSchema);

// ================= ROUTES =================

// Home route
app.get("/", (req, res) => {
  res.send("🚀 Todo API is running");
});

// GET all tasks
app.get("/tasks", async (req, res) => {
  console.log("🔥 /tasks route hit");

  try {
    const tasks = await Task.find().lean();
    console.log("Tasks:", tasks);

    return res.json(tasks); // always return response
  } catch (err) {
    console.error("ERROR:", err);
    return res.status(500).json({ error: err.message });
  }
});

// CREATE task
app.post("/tasks", async (req, res) => {
  try {
    const task = await Task.create({ title: req.body.title });
    return res.json(task);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

// TOGGLE task status
app.put("/tasks/:id", async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);

    if (!task) {
      return res.status(404).json({ error: "Task not found" });
    }

    task.status = task.status === "pending" ? "done" : "pending";
    await task.save();

    return res.json(task);
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

// ================= DB CONNECTION =================

async function startServer() {
  try {
    console.log("Connecting to DB...");

    await mongoose.connect(process.env.MONGO_URI);

    console.log("✅ MongoDB Connected");

    app.listen(5000, () => {
      console.log("🔥 Server running on http://localhost:5000");
    });

  } catch (err) {
    console.error("❌ DB CONNECTION FAILED:", err);
    process.exit(1);
  }
}

startServer();