// pages/index.js
import { useState } from 'react';

export default function Home() {
  const [key, setKey] = useState('');
  const [loading, setLoading] = useState(false);

  const getKey = async () => {
    setLoading(true);
    setKey('');
    try {
      const res = await fetch('/api/generate-key');
      const data = await res.json();
      setKey(data.key);
    } catch (error) {
      setKey('Error fetching key');
    }
    setLoading(false);
  };

  return (
    <div style={{ padding: '2rem', fontFamily: 'Arial, sans-serif' }}>
      <h1>Key Generator</h1>
      <button onClick={getKey} disabled={loading}>
        {loading ? 'Generating...' : 'Generate Key'}
      </button>
      {key && (
        <p style={{ marginTop: '1rem', fontSize: '1.2rem' }}>
          Your key: <strong>{key}</strong>
        </p>
      )}
    </div>
  );
}
