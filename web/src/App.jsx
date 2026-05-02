import { useState, useEffect } from "react";
import axios from "axios";

const API = "https://todo-lite.onrender.com";

function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");

  
  const fetchTasks = async () => {
    try {
      const res = await axios.get(`${API}/tasks`);
      setTasks(res.data);
    } catch (err) {
      console.error("Error fetching tasks:", err);
    }
  };

  useEffect(() => {
    fetchTasks();
  }, []);


  const addTask = async () => {
    if (!title.trim()) return;

    try {
      await axios.post(`${API}/tasks`, { title });
      setTitle("");
      fetchTasks();
    } catch (err) {
      console.error("Error adding task:", err);
    }
  };

  
  const toggleTask = async (id) => {
    try {
      await axios.put(`${API}/tasks/${id}`);
      fetchTasks();
    } catch (err) {
      console.error("Error toggling task:", err);
    }
  };

  return (
    <div
      style={{
        padding: "30px",
        fontFamily: "Arial",
        maxWidth: "500px",
        margin: "auto",
      }}
    >
      <h2 style={{ textAlign: "center" }}>Todo Lite</h2>

      
      <div style={{ marginBottom: "20px", textAlign: "center" }}>
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Enter task"
          style={{
            padding: "8px",
            width: "70%",
            marginRight: "10px",
          }}
        />
        <button onClick={addTask}>Add</button>
      </div>

     
      <ul style={{ listStyle: "none", padding: 0 }}>
        {tasks.map((t) => (
          <li
            key={t._id}
            style={{
              marginBottom: "12px",
              padding: "10px",
              background: "#f4f4f4",
              borderRadius: "8px",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
            }}
          >
            <span>
              {t.title} -{" "}
              <strong
                style={{
                  color: t.status === "done" ? "green" : "orange",
                }}
              >
                {t.status}
              </strong>
            </span>

            <button onClick={() => toggleTask(t._id)}>
              Toggle
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;