from dotenv import load_dotenv
load_dotenv()
import os

### RAG over SQL tests

from langchain_community.utilities import SQLDatabase

database_url = os.getenv('DATABASE_URL')

## MYSQL Connection

db = SQLDatabase.from_uri(database_url) #"mysql://:<password>@<host>:<port>/<database>"
print(db.dialect)
print(db.get_usable_table_names())
# print(db.run("SELECT * FROM noticias LIMIT 10;"))


## Convert question to SQL query
from langchain_groq import ChatGroq

llm = ChatGroq(model="llama3-8b-8192")

from langchain.chains import create_sql_query_chain

chain = create_sql_query_chain(llm, db)
response = chain.invoke({"question": "Quantos professores tem lá"})



# string = "nome=João;idade=30;cidade=Salvador"
dicionário = dict(item.split(":") for item in response.split("\n"))
print(dicionário['SQLQuery'])