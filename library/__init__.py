import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from google.cloud.sql.connector import Connector
from dotenv import load_dotenv

# Initialize extensions without an app instance
db = SQLAlchemy()
migrate = Migrate()
connector = Connector()

def create_app():
    """Application factory function."""
    # Load environment variables from the instance folder
    # This is a robust way to handle configuration
    env_path = os.path.join(os.path.dirname(__file__), '..', 'instance', '.env')
    if os.path.exists(env_path):
        load_dotenv(env_path)

    app = Flask(__name__, instance_relative_config=True)

    # --- Database Configuration ---
    db_user = os.environ.get("DB_USER")
    db_pass = os.environ.get("DB_PASS")
    db_name = os.environ.get("DB_NAME")
    instance_connection_name = os.environ.get("INSTANCE_CONNECTION_NAME")

    def getconn():
        """Creates a database connection pool for Cloud SQL."""
        conn = connector.connect(
            instance_connection_name,
            "pg8000",
            user=db_user,
            password=db_pass,
            db=db_name
        )
        return conn

    # Configure SQLAlchemy to use the Cloud SQL connection
    app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql+pg8000://"
    app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {"creator": getconn}
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    # A secret key is needed for flashing messages
    app.config['SECRET_KEY'] = os.urandom(24)

    # Initialize extensions with the app instance
    db.init_app(app)
    migrate.init_app(app, db)

    with app.app_context():
        # Import models here to ensure they are registered with SQLAlchemy
        from . import models

        # Import and register the blueprint for routes
        from . import routes
        app.register_blueprint(routes.main_bp)

        return app
