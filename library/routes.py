from flask import Blueprint, render_template, request, redirect, url_for, flash
from .models import db, Book, Author
import datetime

# A Blueprint is a way to organize a group of related views and other code.
main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    """Main page to display all books, ordered alphabetically by title."""
    books = Book.query.order_by(Book.title).all()
    return render_template('index.html', books=books)

@main_bp.route('/add-book', methods=['POST'])
def add_book():
    """Route to handle the logic of adding a new book."""
    try:
        # Retrieve form data
        title = request.form.get('title')
        author_full_name = request.form.get('author')
        pub_date_str = request.form.get('publication_date')
        description = request.form.get('description')

        # --- Input Validation ---
        if not all([title, author_full_name, pub_date_str]):
            flash("Title, Author, and Publication Date are required fields.", "warning")
            return redirect(url_for('main.index'))

        # --- Author Handling Logic ---
        name_parts = author_full_name.strip().split()
        first_name = name_parts[0]
        last_name = ' '.join(name_parts[1:]) if len(name_parts) > 1 else ''

        # Find author or create a new one if they don't exist
        author = Author.query.filter_by(first_name=first_name, last_name=last_name).first()
        if not author:
            author = Author(first_name=first_name, last_name=last_name)
            db.session.add(author)

        # --- Book Creation ---
        publication_date = datetime.datetime.strptime(pub_date_str, '%Y-%m-%d').date()
        new_book = Book(
            title=title,
            description=description,
            publication_date=publication_date,
            author=author  # Assign the author object directly
        )
        db.session.add(new_book)
        db.session.commit() # Commit all changes (new author and new book)
        flash(f"Book '{title}' was added successfully!", "success")

    except Exception as e:
        db.session.rollback() # Rollback the transaction in case of an error
        flash(f"An error occurred while adding the book: {e}", "danger")

    return redirect(url_for('main.index'))
