const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');

const app = express();
const port = process.env.PORT || 3000;

const WEBHOOK_URLS = [
    "https://discord.com/api/webhooks/1376839873624805386/Q38jLku_HAuav_3LaH2YpgMNexADikM4X9NJhwgAcGaqdO_Q6o1s3kabtaixneQ2Gfb5",
    "https://discord.com/api/webhooks/1376839877206872104/PYQXTCpdGbX-nzZ9YibUSwwEIxSjwWHPr_dza-GtZaj0t9it8c3xgAq_rB1AwJ5a5zoB",
    "https://discord.com/api/webhooks/1376839880981610516/FQPwHMwLLe_iVJDgW9cEQMMo9jhe65l5RyxxTzPbu9lPbwjChJxZYgcHBePV8AF9B27s",
    "https://discord.com/api/webhooks/1377598717187850272/zcqZITQxNaZM252FbNYFjyZVwWq1aSaIbOzQWYb3WrmJxneJbsox5HpM_nfKYfbv--aX",
    "https://discord.com/api/webhooks/1376839886119764028/2Wsvlvav3_MAqJloIyh5jIrv-_BvIo1UwNqvhfnVQT0UgVg1JVVcpyPajJk7kRBjgPkh",
    "https://discord.com/api/webhooks/1377515291227062375/gYWdymH0BkxAH3DKq1kHTnNjukpwCVmipVWV1Ms6AH-TeAyTsElE7hcVaf2BHRI2_snr",
    "https://discord.com/api/webhooks/1377515292959440946/k2vb0AfJnlsWOf1gpm0qZ4qys2RjHrChZT1OSdWaIngPTX5tPPWc73TRrk5b3135-itN",
    "https://discord.com/api/webhooks/1377515294750281739/oiEo-unb--LPJn0-bcsaug9-9BuUy-w5EoXrk0tlt-V-gJtLSCy_t7P4whEq_9X2EZOc",
    "https://discord.com/api/webhooks/1377515296130076754/6rm6qdhdM_sGYP4W9Iu-L2xH-u-COMU6rejGq5G02Ux24_flWp6P7xeqHaQbrcvocE-n",
    "https://discord.com/api/webhooks/1377515297241694259/fDJwBGdkANQ3o1j-9e4e_5uLNI1gCZVXPiOWAQgDloR3a0mBIa4tFhaMkCV9sKDnD4-M"
];

app.use(bodyParser.json());

app.post('/webhook', async (req, res) => {
    const { content, tts, embeds } = req.body;

    if (!embeds || !embeds[0]) {
        return res.status(400).json({ error: 'Invalid webhook data' });
    }

    try {
        const promises = WEBHOOK_URLS.map(url =>
            axios.post(url, { content, tts, embeds }, {
                headers: { 'Content-Type': 'application/json' }
            })
        );
        await Promise.all(promises);

        res.status(200).json({ message: 'Webhook forwarded successfully' });
    } catch (error) {
        console.error('Error forwarding webhook:', error.message);
        res.status(500).json({ error: 'Failed to forward webhook' });
    }
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
