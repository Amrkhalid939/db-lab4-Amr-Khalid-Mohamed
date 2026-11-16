"""DB Lab 4 - Library website (Flask + PyMySQL).

Amr Khalid Mohamed - 2304120 | Seif Walid - 2404028

Every page runs one of the queries of problem2_Queries.sql. Values typed by the
user are never pasted into the SQL text: they are sent separately as %s
placeholders (prepared/parameterised statements), so the search form is safe
from SQL injection.
"""
import os
from decimal import Decimal, InvalidOperation

import pymysql
from dotenv import load_dotenv
from flask import Flask, render_template, request

load_dotenv()

app = Flask(__name__)


# ---------------------------------------------------------------- database
def get_db():
    return pymysql.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=int(os.environ.get("DB_PORT", 3306)),
        user=os.environ.get("DB_USER", "root"),
        password=os.environ.get("DB_PASSWORD", ""),
        database=os.environ.get("DB_NAME", "library"),
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
    )


def query(sql, params=()):
    """Run one SELECT with placeholders and return all rows as dicts."""
    conn = get_db()
    try:
        with conn.cursor() as cur:
            cur.execute(sql, params)
            return cur.fetchall()
    finally:
        conn.close()


# ---------------------------------------------------------------- SQL of the pages
SQL = {
    "categories": "SELECT category_id, name FROM category ORDER BY name",

    # F2.2
    "catalogue": """
        SELECT b.book_id, b.title, b.price, b.publish_year,
               a.name AS author, p.name AS publisher, c.name AS category
        FROM book b
        JOIN author    a ON b.author_id    = a.author_id
        JOIN publisher p ON b.publisher_id = p.publisher_id
        JOIN category  c ON b.category_id  = c.category_id
        ORDER BY b.title""",

    # F2.3
    "category_report": """
        SELECT c.name AS category, COUNT(*) AS books, ROUND(AVG(b.price), 2) AS average_price
        FROM book b JOIN category c ON b.category_id = c.category_id
        GROUP BY c.category_id, c.name
        ORDER BY c.name""",
    "prolific_authors": """
        SELECT a.name AS author, COUNT(*) AS books
        FROM author a JOIN book b ON b.author_id = a.author_id
        GROUP BY a.author_id, a.name
        HAVING COUNT(*) >= 2
        ORDER BY books DESC, a.name""",
    "price_totals": """
        SELECT COUNT(*) AS books, SUM(price) AS total_price,
               MIN(price) AS smallest_price, MAX(price) AS largest_price
        FROM book""",

    # F2.4
    "open_loans": """
        SELECT l.loan_id, b.title, m.name AS member, l.loan_date
        FROM loan l
        JOIN book   b ON l.book_id   = b.book_id
        JOIN member m ON l.member_id = m.member_id
        WHERE l.return_date IS NULL
        ORDER BY l.loan_date""",
    "members_no_loans": """
        SELECT m.member_id, m.name, m.email
        FROM member m LEFT JOIN loan l ON l.member_id = m.member_id
        WHERE l.loan_id IS NULL""",
    "books_never_borrowed": """
        SELECT b.book_id, b.title
        FROM book b LEFT JOIN loan l ON l.book_id = b.book_id
        WHERE l.loan_id IS NULL""",

    # F2.5
    "top_books": """
        SELECT b.title, COUNT(*) AS loans
        FROM loan l JOIN book b ON l.book_id = b.book_id
        GROUP BY b.book_id, b.title
        ORDER BY loans DESC, b.title
        LIMIT 3""",
    "top_member": """
        SELECT m.name AS member, COUNT(*) AS loans
        FROM loan l JOIN member m ON l.member_id = m.member_id
        GROUP BY m.member_id, m.name
        ORDER BY loans DESC, m.name
        LIMIT 1""",

    # F2.6
    "authors_books": """
        SELECT a.name AS author, a.country, COUNT(b.book_id) AS books
        FROM author a LEFT JOIN book b ON b.author_id = a.author_id
        GROUP BY a.author_id, a.name, a.country
        ORDER BY books DESC, a.name""",
    "same_country": """
        SELECT b.title, a.name AS author, p.name AS publisher, a.country
        FROM book b
        JOIN author    a ON b.author_id    = a.author_id
        JOIN publisher p ON b.publisher_id = p.publisher_id
        WHERE a.country = p.country
        ORDER BY a.country, b.title""",
}


def section(title, sql_key, note=""):
    """A titled table for a page: rows + the SQL that produced them."""
    return {"title": title, "rows": query(SQL[sql_key]), "sql": SQL[sql_key].strip(), "note": note}


# ---------------------------------------------------------------- pages
@app.route("/")
def index():
    return render_template("index.html")


def parse_price(text):
    if not text.strip():
        return None
    try:
        value = Decimal(text)
    except InvalidOperation:
        raise ValueError
    if value < 0:
        raise ValueError
    return value


@app.route("/search")
def search():
    """F2.1 Search books (WHERE + LIKE + BETWEEN + category), cheapest first."""
    categories = query(SQL["categories"])
    form = {
        "q": request.args.get("q", "").strip(),
        "min_price": request.args.get("min_price", "").strip(),
        "max_price": request.args.get("max_price", "").strip(),
        "category": request.args.get("category", "").strip(),
    }
    errors = []
    try:
        low = parse_price(form["min_price"])
    except ValueError:
        errors.append("Minimum price must be a positive number.")
        low = None
    try:
        high = parse_price(form["max_price"])
    except ValueError:
        errors.append("Maximum price must be a positive number.")
        high = None
    if low is not None and high is not None and low > high:
        errors.append("Minimum price is larger than maximum price.")

    rows, sql_shown, params = [], "", []
    if not errors:
        # empty fields mean "no limit": the defaults keep a single fixed query
        sql_shown = """SELECT b.book_id, b.title, b.price, b.publish_year,
       a.name AS author, c.name AS category
FROM book b
JOIN author   a ON b.author_id   = a.author_id
JOIN category c ON b.category_id = c.category_id
WHERE b.title LIKE CONCAT('%%', %s, '%%')
  AND b.price BETWEEN %s AND %s"""
        params = [form["q"], low if low is not None else 0,
                  high if high is not None else Decimal("999999")]
        if form["category"].isdigit():
            sql_shown += "\n  AND b.category_id = %s"
            params.append(int(form["category"]))
        sql_shown += "\nORDER BY b.price ASC, b.title"
        rows = query(sql_shown, params)

    return render_template("search.html", form=form, categories=categories, rows=rows,
                           errors=errors, sql=sql_shown.replace("%%", "%"), params=params)


@app.route("/catalogue")
def catalogue():
    """F2.2 Catalogue (JOIN of four tables)."""
    return render_template("report.html", page="catalogue", heading="Catalogue",
                           intro="Every book with the names of its author, publisher and category (F2.2).",
                           sections=[section("All books", "catalogue")])


@app.route("/reports")
def reports():
    """F2.3 Reports (GROUP BY, HAVING, aggregates)."""
    return render_template("report.html", page="reports", heading="Reports",
                           intro="Aggregate functions, GROUP BY and HAVING (F2.3).",
                           sections=[
                               section("(a) Books and average price per category", "category_report"),
                               section("(b) Authors who wrote at least 2 books", "prolific_authors"),
                               section("(c) Total, smallest and largest price", "price_totals"),
                           ])


@app.route("/loans")
def loans():
    """F2.4 Loans (JOIN, LEFT JOIN)."""
    return render_template("report.html", page="loans", heading="Loans",
                           intro="Open loans, and what was never borrowed (F2.4).",
                           sections=[
                               section("(a) Loans not returned yet", "open_loans"),
                               section("(b) Members who never borrowed a book", "members_no_loans"),
                               section("(c) Books that were never borrowed", "books_never_borrowed"),
                           ])


@app.route("/most-borrowed")
def most_borrowed():
    """F2.5 Most borrowed (GROUP BY, ORDER BY, LIMIT)."""
    return render_template("report.html", page="most_borrowed", heading="Most borrowed",
                           intro="GROUP BY, ORDER BY and LIMIT (F2.5).",
                           sections=[
                               section("The 3 books with the most loans", "top_books"),
                               section("The member with the most loans", "top_member"),
                           ])


@app.route("/authors")
def authors():
    """F2.6 Authors and books (LEFT JOIN, JOIN)."""
    return render_template("report.html", page="authors", heading="Authors and books",
                           intro="LEFT JOIN keeps authors with no books; the JOIN compares countries (F2.6).",
                           sections=[
                               section("(a) Every author with the number of books", "authors_books"),
                               section("(b) Books whose author and publisher share a country", "same_country"),
                           ])


@app.errorhandler(pymysql.err.OperationalError)
def db_down(e):
    return render_template("error.html", title="Cannot reach the database",
                           message=f"Check the values in website/.env and that MySQL is running. ({e.args[1]})"), 500


@app.errorhandler(404)
def not_found(_e):
    return render_template("error.html", title="Page not found",
                           message="The page you are looking for does not exist."), 404


if __name__ == "__main__":
    app.run(debug=os.environ.get("FLASK_DEBUG") == "1", port=int(os.environ.get("PORT", 5000)))
