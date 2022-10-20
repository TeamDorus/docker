import sys
import json
import xmltodict

xml_file = sys.argv[1] 
f = open(xml_file)
xml_content = f.read()
f.close()
print(json.dumps(xmltodict.parse(xml_content), indent=4, sort_keys=True))

