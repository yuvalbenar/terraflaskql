import os
import mysql.connector
import random
import time
from flask import Flask, render_template
from dotenv import load_dotenv
from mysql.connector import Error

# Load environment variables from .env file or GitHub secrets
load_dotenv()

app = Flask(__name__)

def get_db_connection():
    retries = 5
    while retries > 0:
        try:
            # Connecting to MySQL database with credentials from the .env file
            connection = mysql.connector.connect(
                host=os.getenv('DATABASE_HOST', 'gif-db'),  # Using the Docker container name for MySQL
                port=int(os.getenv('DATABASE_PORT', 3306)),  # Default MySQL port
                user=os.getenv('DATABASE_USER', 'root'),  # 'root' user by default
                password=os.getenv('DATABASE_PASSWORD', 'password'),  # Password from .env
                database=os.getenv('DATABASE_NAME', 'flaskdb')  # Database name from .env
            )
            if connection.is_connected():
                print("Connected to MySQL database")
                return connection
        except Error as e:
            print(f"Error connecting to MySQL: {e}")
            retries -= 1
            print(f"Retrying... ({retries} retries left)")
            time.sleep(2)
    raise Exception("Failed to connect to the database after multiple attempts")

@app.route('/')
def index():
    # Connect to the database
    connection = get_db_connection()
    cursor = connection.cursor()

    # Query to get a random image URL from the database trolololo
    cursor.execute("SELECT url FROM images ORDER BY RAND() LIMIT 1")
    random_image = cursor.fetchone()[0]  # Get the URL from the query result

    # Close the connection
    cursor.close()
    connection.close()

    # Pass the random image to the template
    return render_template('index.html', image=random_image)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=int(os.getenv('PORT', 5000)))
