from langchain_community.document_loaders import AsyncChromiumLoader
from langchain_community.document_transformers import BeautifulSoupTransformer

# Load HTML AsyncChromiumLoader
loader = AsyncChromiumLoader(["https://facom.ufba.br/portal/index.php"])
html = loader.load()
print(html)

# Transform BS4
bs_transformer = BeautifulSoupTransformer()
docs_transformed = bs_transformer.transform_documents(html, tags_to_extract=["h1","p"])

# Result
docs_transformed[0].page_content[0:500]

# from langchain_community.document_loaders import AsyncHtmlLoader


# Load HTML AsyncHtmlLoader (more lightweight as said in langchain docs)
# deu error fetching. Usaremos Asynchromium então. 
# urls = ["https://facom.ufba.br/portal/index.php"]
# loader = AsyncHtmlLoader(urls)
# docs = loader.load()
# print(docs)
