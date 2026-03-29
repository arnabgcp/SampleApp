from . import db

class Author(db.Model):
    __tablename__ = 'authors'
    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(80), nullable=False)
    last_name = db.Column(db.String(80), nullable=False)
    
    # This relationship links an author to their books.
    # The 'cascade' option ensures that if an author is deleted, their books are also deleted.
    books = db.relationship('Book', backref='author', lazy=True, cascade="all, delete-orphan")

    def __repr__(self):
        return f'<Author {self.first_name} {self.last_name}>'

class Book(db.Model):
    __tablename__ = 'books'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=True)
    publication_date = db.Column(db.Date, nullable=True)
    
    # The foreign key links a book to its author's id.
    author_id = db.Column(db.Integer, db.ForeignKey('authors.id'), nullable=False)

    def __repr__(self):
        return f'<Book {self.title}>'
