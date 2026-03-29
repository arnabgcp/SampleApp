from library import create_app

# Create the application instance using the factory
app = create_app()

if __name__ == '__main__':
    # Run the app in debug mode for development
    # host='0.0.0.0' makes it accessible on your local network
    app.run(debug=True, host='0.0.0.0')
