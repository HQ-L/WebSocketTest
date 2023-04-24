import json

allData = []

with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)
    for item in params["result"][0]:
        if item["id"][-4:] == '0000':
            allData.append({"id": item["id"], "name": item["fullname"], "longitude": str(format(item["location"]["lng"], '.3f')), "dimension": str(format(item["location"]["lat"], '.3f')), "city": []})

with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)
    for data in allData:
        for item in params["result"][1]:
            if item["id"][-4:] != '0000' and item["id"][-2:] == '00' and data["id"][0:2] == item["id"][0:2]:
                data["city"].append({"id": item["id"], "name": item["fullname"], "longitude": str(format(item["location"]["lng"], '.3f')), "dimension": str(format(item["location"]["lat"], '.3f')), "county": []})

with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)
    for data in allData:
        if data["city"] == []:
            data["city"].append({"id": data["id"], "name": data["name"], "longitude": data["longitude"], "dimension": data["dimension"], "county": []})

with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)
    for data in allData:
        for dataCity in data["city"]:
            for item in params["result"][2]:
                if item["id"][-2:] != '00' and dataCity["id"][0:4] == item["id"][0:4]:
                    dataCity["county"].append({"id": item["id"], "countyName": item["fullname"], "longitude": str(format(item["location"]["lng"], '.3f')), "dimension": str(format(item["location"]["lat"], '.3f'))})

with open('./2.json', 'r', encoding='utf-8') as f:
    for data in allData:
        for dataCity in data["city"]:
            for item in params["result"][1]:
                if item["id"][-2:] != "00" and dataCity["id"][0:2] == item["id"][0:2]:
                    dataCity["county"].append({"id": item["id"], "countyName": item["fullname"], "longitude": str(format(item["location"]["lng"], '.3f')), "dimension": str(format(item["location"]["lat"], '.3f'))})

for data in allData:
    del data["id"]
    for dataCity in data["city"]:
        del dataCity["id"]
        for dataCounty in dataCity["county"]:
            del dataCounty["id"]

jsonData = json.dumps(allData, ensure_ascii=False, indent=4)
with open('output.json', 'w', encoding='utf-8') as jsonFile:
    jsonFile.write(jsonData)