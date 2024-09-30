from dotenv import load_dotenv
load_dotenv()

from langchain import hub
from langchain_core.output_parsers import StrOutputParser
from pprint import pprint

# Prompt
prompt = (
    hub.pull("rlm/rag-prompt")
    + "\nAlso, you must only answer to questions about FACOM - UFBA.\nThe Faculty of Communication at the Federal University of Bahia (FACOM) is a public higher education institution, nationally recognized for training professionals and researchers in the field of Communication. It currently offers two undergraduate courses — Communication with a specialization in Communication and Culture Production, and Journalism (until 2022, a specialization within the Communication course)."


)

pprint(prompt)