const express = require("express");
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Ping route to keep server awake
app.get("/ping", (req, res) => {
  res.status(200).json({ status: "OK", time: Date.now() });
});

// Key validation (no protection)
app.post("/key", (req, res) => {
  const { key } = req.body;

  // Replace this with your actual key check logic
  if (key === "valid-key-example") {
    return res.status(200).json({ success: true, access: "granted" });
  }

  return res.status(401).json({ success: false, error: "Invalid key" });
});

// Catch-all for other routes
app.use((req, res) => {
  res.status(404).json({ error: "Not Found" });
});

app.listen(PORT, () => {
  console.log(`API is running on port ${PORT}`);
});
