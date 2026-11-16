# DB Lab 4 — Search Queries in SQL

**Team:** Amr Khalid Mohamed — 2304120 · Seif Walid — 2404028
Introduction to Database Systems · Alexandria National University · Fall 2026

## Files

| File | What it is |
|---|---|
| `problem1_DDL.sql` | Problem 1 – creates the `company` database (5 tables, PKs incl. composite, FKs) |
| `problem1_DML.sql` | Problem 1 – our rows in the five tables |
| `problem1_Answers.txt` | Problem 1 – the SQL of Q1.1–Q1.12 with the output / error of each statement |
| `problem2_DDL.sql` | Problem 2 – creates the `library` database (6 tables, FKs, `ON DELETE CASCADE`) |
| `problem2_DML.sql` | Problem 2 – seed data (5 authors, 4 publishers, 4 categories, 11 books, 6 members, 14 loans) |
| `problem2_Queries.sql` | Problem 2 – the SQL of the pages F2.1–F2.6 (`-- F2.x` before each query) |
| `website/` | The library website (Flask + PyMySQL) with the new search pages |

## Requirements

- MySQL 8 (or MariaDB 10.6+) with the `mysql` command-line client on the PATH
- Python 3.10+

## 1. Problem 1 – COMPANY database

```bash
mysql -u root -p < problem1_DDL.sql      # build the database and its tables
mysql -u root -p < problem1_DML.sql      # insert our rows
mysql -u root -p company                 # then type the queries of problem1_Answers.txt
```

The answers in `problem1_Answers.txt` were produced by running the statements **in order** in one session
right after the DDL + DML (Q1.1–Q1.3 change the data that Q1.4–Q1.12 search). To get the same output,
re-run the DDL and DML first.

## 2. Problem 2 – LIBRARY database

```bash
mysql -u root -p < problem2_DDL.sql      # build the library database
mysql -u root -p < problem2_DML.sql      # seed data
mysql -u root -p < problem2_Queries.sql  # run every page query (F2.1 – F2.6)
```

## Using MySQL Workbench instead of the command line

All scripts also run in MySQL Workbench (tested on MySQL 8.0):

1. **File → Open SQL Script…** and pick `problem1_DDL.sql`, then click the ⚡ **Execute** button
   (runs the whole script). Do the same for `problem1_DML.sql`, `problem2_DDL.sql`,
   `problem2_DML.sql` and `problem2_Queries.sql` — in this order.
2. Click the 🔄 refresh icon in the **Schemas** panel to see `company` and `library`.
3. To type the Q1.x queries, open a new query tab and run `USE company;` first.
4. Workbench turns on **safe updates**, which refuses `DELETE`/`UPDATE` without a `WHERE`
   on a key column (Error 1175). Only Q1.3(c) needs it off — run
   `SET SQL_SAFE_UPDATES = 0;` before it.

## 3. Run the website

Windows (PowerShell / VS Code terminal):

```powershell
cd website
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env        # then open .env and set DB_PASSWORD
python app.py
```

macOS / Linux:

```bash
cd website
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env          # then set DB_PASSWORD
python app.py
```

Open <http://127.0.0.1:5000>.

### Pages

| Page | URL | SQL used |
|---|---|---|
| F2.1 Search books | `/search` | `WHERE … LIKE … BETWEEN … AND category_id = …`, `ORDER BY price` |
| F2.2 Catalogue | `/catalogue` | `JOIN` book + author + publisher + category |
| F2.3 Reports | `/reports` | `COUNT`, `AVG`, `SUM`, `MIN`, `MAX`, `GROUP BY`, `HAVING` |
| F2.4 Loans | `/loans` | `JOIN` with `return_date IS NULL`, `LEFT JOIN … IS NULL` |
| F2.5 Most borrowed | `/most-borrowed` | `GROUP BY`, `ORDER BY … DESC`, `LIMIT` |
| F2.6 Authors and books | `/authors` | `LEFT JOIN` + `COUNT(b.book_id)`, `JOIN` on equal countries |

Every page has a **SQL** box under its table that shows the exact query it ran.

### Bonus – prepared statements

The search form (F2.1) never builds SQL from what the user typed. The query text is fixed and the
values (keyword, min price, max price, category) are sent separately as `%s` placeholders to
`cursor.execute(sql, params)`, so input such as `' OR 1=1 --` is treated as plain text, not SQL.
Empty fields mean “no limit”; invalid prices show an error message instead of running the query.

## Seed data highlights (used in the discussion)

- Two authors from the same country: Naguib Mahfouz & Ahmed Khaled Tawfik (Egypt)
- An author with no books: Paulo Coelho
- Authors with ≥ 2 books: Mahfouz, Orwell, Rowling (3 each), Tawfik (2)
- Author and publisher from the same country: Mahfouz & Dar El Shorouk (Egypt)
- Books priced between 15 and 20: Utopia, Nineteen Eighty-Four, Palace Walk, The Casual Vacancy
- Books never borrowed: The Casual Vacancy, Down and Out in Paris and London
- Member with no loans: Khaled Mostafa
- Loans not returned yet: 5 (return_date `NULL`)
