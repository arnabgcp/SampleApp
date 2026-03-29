import os
from library import create_app

# Create the application instance using the factory
app = create_app()

if __name__ == '__main__':
    # Get port from environment variable or default to 8081
    port = int(os.environ.get('PORT', 8081))

    # Run the app in debug mode for development
    # host='0.0.0.0' makes it accessible on your local network
    app.run(debug=True, host='0.0.0.0', port=port)
