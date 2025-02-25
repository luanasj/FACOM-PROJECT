import os
import json
from dotenv import load_dotenv
load_dotenv()


print(os.getenv("commonPathBot"))
print(os.getenv("commonPathBot")+"\\externalLinks.json")

with open(os.getenv("commonPathBot")+"\\externalLinks.json") as file:
    externalLinks = json.load(file)

print(externalLinks)



