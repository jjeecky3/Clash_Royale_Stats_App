from flask import Flask, render_template, request, jsonify
import requests
import random
from config import API_TOKEN, API_BASE_URL, ROAST_CONFIG

app = Flask(__name__)

def convert_card_level(star_level, rarity):
    """
    Convert API star level to displayed card level.
    Clash Royale uses different progressions based on rarity:
    - Common: 1-14 (star 1-14 = display 1-14)
    - Rare: 1-11 (star 1-11 = display 3-13, actually maps to 14 total levels)
    - Epic: 1-8 (star 1-8 = display 6-13)
    - Legendary: 1-5 (star 1-5 = display 9-13)
    - Champion: 1-3 (star 1-3 = display 11-13)
    """
    rarity_lower = rarity.lower()
    
    # Based on Clash Royale's leveling system
    if rarity_lower == 'common':
        return star_level  # 1-14 maps directly
    elif rarity_lower == 'rare':
        return star_level + 2  # 1-11 becomes 3-13
    elif rarity_lower == 'epic':
        return star_level + 5  # 1-8 becomes 6-13
    elif rarity_lower == 'legendary':
        return star_level + 8  # 1-5 becomes 9-13
    elif rarity_lower == 'champion':
        return star_level + 10  # 1-3 becomes 11-13
    else:
        return star_level  # Fallback

def format_player_tag(tag):
    """Format player tag to ensure it starts with #"""
    tag = tag.strip().upper()
    if not tag.startswith('#'):
        tag = '#' + tag
    # Remove # for API call (API expects tags without #)
    return tag.replace('#', '%23')

def fetch_player_data(player_tag):
    """Fetch player data from Clash Royale API"""
    formatted_tag = format_player_tag(player_tag)
    headers = {
        'Authorization': f'Bearer {API_TOKEN}'
    }
    
    try:
        # Fetch player profile
        profile_url = f"{API_BASE_URL}/players/{formatted_tag}"
        profile_response = requests.get(profile_url, headers=headers)
        
        if profile_response.status_code != 200:
            return None, f"Error: {profile_response.status_code} - {profile_response.text}"
        
        player_data = profile_response.json()
        
        # Fetch battle log
        battlelog_url = f"{API_BASE_URL}/players/{formatted_tag}/battlelog"
        battlelog_response = requests.get(battlelog_url, headers=headers)
        
        if battlelog_response.status_code == 200:
            player_data['battleLog'] = battlelog_response.json()
        else:
            player_data['battleLog'] = []
        
        return player_data, None
    except Exception as e:
        return None, f"Error fetching data: {str(e)}"

def analyze_stats(player_data):
    """Analyze player stats and calculate metrics"""
    stats = {}
    
    # Basic info
    stats['name'] = player_data.get('name', 'Unknown')
    stats['tag'] = player_data.get('tag', '')
    stats['trophies'] = player_data.get('trophies', 0)
    stats['best_trophies'] = player_data.get('bestTrophies', 0)
    stats['king_level'] = player_data.get('expLevel', 1)
    stats['wins'] = player_data.get('wins', 0)
    stats['losses'] = player_data.get('losses', 0)
    stats['three_crown_wins'] = player_data.get('threeCrownWins', 0)
    
    # Calculate win rate
    total_battles = stats['wins'] + stats['losses']
    stats['total_battles'] = total_battles
    stats['win_rate'] = round((stats['wins'] / total_battles * 100), 1) if total_battles > 0 else 0
    
    # Card analysis - convert to display levels
    cards = player_data.get('cards', [])
    if cards:
        # Calculate average using display levels
        display_levels = [convert_card_level(card.get('level', 1), card.get('rarity', 'common')) for card in cards]
        stats['avg_card_level'] = round(sum(display_levels) / len(display_levels), 1)
        stats['total_cards'] = len(cards)
        stats['max_card_level'] = max(display_levels)
    else:
        stats['avg_card_level'] = 0
        stats['total_cards'] = 0
        stats['max_card_level'] = 0
    
    # Battle log analysis
    battle_log = player_data.get('battleLog', [])
    if battle_log:
        recent_battles = battle_log[:10]  # Last 10 battles
        recent_wins = sum(1 for battle in recent_battles 
                         if battle.get('team', [{}])[0].get('crowns', 0) > 
                            battle.get('opponent', [{}])[0].get('crowns', 0))
        stats['recent_battles'] = len(recent_battles)
        stats['recent_wins'] = recent_wins
        stats['recent_losses'] = len(recent_battles) - recent_wins
        stats['recent_win_rate'] = round((recent_wins / len(recent_battles) * 100), 1)
    else:
        stats['recent_battles'] = 0
        stats['recent_wins'] = 0
        stats['recent_losses'] = 0
        stats['recent_win_rate'] = 0
    
    # Current deck - process to add display levels
    current_deck = player_data.get('currentDeck', [])
    processed_deck = []
    for card in current_deck:
        processed_card = card.copy()
        # Convert star level to display level
        star_level = card.get('level', 1)
        rarity = card.get('rarity', 'common')
        processed_card['displayLevel'] = convert_card_level(star_level, rarity)
        processed_card['starLevel'] = star_level
        # Add evolution info
        if 'evolutionLevel' in card and card['evolutionLevel'] > 0:
            processed_card['hasEvolution'] = True
        else:
            processed_card['hasEvolution'] = False
        processed_deck.append(processed_card)
    stats['current_deck'] = processed_deck
    
    return stats

def generate_roasts(stats):
    """Generate humorous roasts based on player stats"""
    roasts = []
    config = ROAST_CONFIG
    
    # Check win rate
    win_rate = stats['win_rate']
    if win_rate < config['win_rate_thresholds']['terrible']:
        roast = random.choice(config['roasts']['low_win_rate'])
        roasts.append(roast.format(win_rate=win_rate))
    elif win_rate < config['win_rate_thresholds']['mediocre']:
        roast = random.choice(config['roasts']['low_win_rate'])
        roasts.append(roast.format(win_rate=win_rate))
    
    # Check trophies
    trophies = stats['trophies']
    king_level = stats['king_level']
    if trophies < config['trophy_thresholds']['low']:
        roast = random.choice(config['roasts']['low_trophies'])
        roasts.append(roast.format(trophies=trophies, king_level=king_level))
    
    # Check card levels
    avg_card_level = stats['avg_card_level']
    if avg_card_level < 10:
        roast = random.choice(config['roasts']['card_levels'])
        roasts.append(roast.format(avg_card_level=avg_card_level))
    
    # Check recent performance
    if stats['recent_battles'] > 0:
        recent_losses = stats['recent_losses']
        if recent_losses >= 6:  # Lost 6+ of last 10 battles
            roast = random.choice(config['roasts']['losses'])
            roasts.append(roast.format(
                losses=recent_losses,
                total_battles=stats['recent_battles']
            ))
    
    # If no roasts (good player), give some praise with a challenge
    if not roasts:
        roast = random.choice(config['roasts']['good_performance'])
        roasts.append(roast.format(
            win_rate=win_rate,
            trophies=trophies
        ))
    
    return roasts

@app.route('/')
def index():
    """Homepage with player tag input"""
    return render_template('index.html')

@app.route('/player/<player_tag>')
def player_stats(player_tag):
    """Display player stats and roasts"""
    player_data, error = fetch_player_data(player_tag)
    
    if error:
        return render_template('error.html', error=error)
    
    stats = analyze_stats(player_data)
    roasts = generate_roasts(stats)
    
    return render_template('player_stats.html', 
                          stats=stats, 
                          roasts=roasts,
                          player_data=player_data)

@app.route('/api/player/<player_tag>')
def api_player_stats(player_tag):
    """API endpoint for player stats (JSON response)"""
    player_data, error = fetch_player_data(player_tag)
    
    if error:
        return jsonify({'error': error}), 400
    
    stats = analyze_stats(player_data)
    roasts = generate_roasts(stats)
    
    return jsonify({
        'stats': stats,
        'roasts': roasts
    })

if __name__ == '__main__':
    print("🚀 Starting Clash Royale Stats & Roast Server...")
    print("🌐 Server running at http://127.0.0.1:5000")
    print("⚠️  Make sure you've set your API_TOKEN in config.py!")
    app.run(debug=True, host='127.0.0.1', port=5000)
