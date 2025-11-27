# ⚔️ Clash Royale Stats & Roast Website

A visually stunning Flask web application that fetches player statistics from the Clash Royale API and provides entertaining roasts based on performance metrics!

## ✨ Features

- 🎮 **Real-time Stats**: Fetch live player data from the official Clash Royale API
- 📊 **Detailed Analytics**: Win rate, trophy count, card levels, and battle history
- 🔥 **Humorous Roasts**: Get roasted based on your performance (all in good fun!)
- 🎨 **Premium Design**: Modern UI with Clash Royale themed colors, animations, and glassmorphism
- 📱 **Responsive**: Works beautifully on desktop, tablet, and mobile

## 🚀 Setup Instructions

### 1. Get Your API Token

1. Visit [https://developer.clashroyale.com](https://developer.clashroyale.com)
2. Create an account (or login)
3. Go to "My Account" → "Create New Key"
4. Enter:
   - **Name**: Any name (e.g., "My Stats App")
   - **Description**: Optional
   - **IP Address**: Your current IP address (find it at https://whatismyipaddress.com)
5. Click "Create Key" and copy your API token

### 2. Install Dependencies

```bash
cd /home/jacky/Desktop/project
pip install -r requirements.txt
```

### 3. Configure API Token

Open `config.py` and replace `YOUR_API_TOKEN_HERE` with your actual API token:

```python
API_TOKEN = "your-actual-token-here"
```

### 4. Run the Application

```bash
python app.py
```

The server will start at **http://127.0.0.1:5000**

## 📖 Usage

1. Open your browser and navigate to `http://127.0.0.1:5000`
2. Enter your Clash Royale player tag (e.g., `#2PP` or just `2PP`)
3. Click "Search Player"
4. View your stats and get roasted! 🔥

### Finding Your Player Tag

1. Open Clash Royale on your device
2. Tap your profile icon
3. Your player tag is displayed under your name (starts with #)

## 🎯 What Gets Analyzed

- **Win Rate**: Overall and recent performance
- **Trophy Count**: Current trophies vs. personal best
- **Card Levels**: Average card level in your collection
- **Battle History**: Recent wins and losses
- **Current Deck**: Your active deck composition
- **Three Crown Wins**: Total domination count

## 🤣 Roast Categories

The app generates roasts based on:

- Low win rate (<50%)
- Trophy count relative to king level
- Card levels below average
- Recent losing streaks
- Poor recent performance

Don't worry - if you're doing well, you'll get compliments instead! 😊

## 🛠️ Technical Stack

- **Backend**: Python Flask
- **Frontend**: HTML5, CSS3, JavaScript
- **API**: Official Clash Royale API
- **Design**: Custom CSS with modern aesthetics

## 🎨 Design Features

- Clash Royale themed color palette
- Smooth animations and transitions
- Glassmorphism effects
- Gradient backgrounds
- Responsive grid layouts
- Interactive hover effects
- Progress bars and badges

## ⚠️ Troubleshooting

### "Error: 403 - Forbidden"
- Your API token is invalid or expired
- Your IP address has changed (regenerate the key with your current IP)

### "Error: 404 - Not Found"
- The player tag is incorrect
- Make sure you're copying the tag correctly from the game

### "Error: 503 - Service Unavailable"
- The Clash Royale API is temporarily down
- Try again in a few minutes

### Rate Limiting
- The API has rate limits
- If you get rate limit errors, wait a few minutes before trying again

## 📝 File Structure

```
project/
├── app.py                 # Main Flask application
├── config.py              # Configuration and roast templates
├── requirements.txt       # Python dependencies
├── static/
│   ├── style.css         # Premium styling
│   └── script.js         # Client-side interactions
└── templates/
    ├── index.html        # Homepage
    ├── player_stats.html # Stats display page
    └── error.html        # Error page
```

## 🎮 Example Player Tags

Try these popular players (if they're still active):
- `#2PP` 
- `#Y9UVY82C`

## 🔒 Privacy & Security

- This app only reads public player data
- No data is stored or logged
- API tokens are kept in your local config file

## 🤝 Contributing

Feel free to fork and improve! Some ideas:
- Add more roast variations
- Include clan statistics
- Compare multiple players
- Add achievement tracking
- Create custom roast themes

## 📄 License

Free to use and modify for personal projects!

---

**Enjoy getting roasted! 🔥⚔️**
