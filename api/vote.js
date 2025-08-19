// api/vote.js

export default function handler(req, res) {
  if (req.method === "POST") {
    const data = req.body; // JSON sent from Roblox
    console.log("Received data:", data); // optional: logs in Vercel

    // You can add any logic here later (like storing votes)
    
    // Respond to Roblox
    res.status(200).json({ status: "success" });
  } else {
    res.status(405).json({ status: "error", message: "Method not allowed" });
  }
}
