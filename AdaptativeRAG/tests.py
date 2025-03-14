import os
import json
from dotenv import load_dotenv
load_dotenv()


print(os.getenv("commonPathBot"))
print(os.getenv("commonPathBot")+"\\assets\\externalLinks.json")

with open(os.getenv("commonPathBot")+"\\assets\\externalLinks.json") as file:
    externalLinks = json.load(file)

print(externalLinks)



