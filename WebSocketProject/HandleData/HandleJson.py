import json

allData = []

# 处理省
with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)
    for item in params["result"][0]:
        if item["id"][-4:] == '0000':
            allData.append({"id": item["id"], "name": item["fullname"], "longitude": str(item["location"]["lng"]), "dimension": str(item["location"]["lat"]), "city": []})

# 处理市
with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)
    for data in allData:
        for item in params["result"][1]:
            if item["id"][-4:] != '0000' and item["id"][-2:] == '00' and data["id"][0:2] == item["id"][0:2]:
                data["city"].append({"id": item["id"], "name": item["fullname"], "longitude": str(item["location"]["lng"]), "dimension": str(item["location"]["lat"]), "county": []})

# 处理直辖市的市
with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)
    for data in allData:
        if data["city"] == []:
            data["city"].append({"id": data["id"], "name": data["name"], "longitude": data["longitude"], "dimension": data["dimension"], "county": []})

# 处理区县
with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)
    for data in allData:
        for dataCity in data["city"]:
            for item in params["result"][2]:
                if item["id"][-2:] != '00' and dataCity["id"][0:4] == item["id"][0:4]:
                    dataCity["county"].append({"id": item["id"], "countyName": item["fullname"], "longitude": str(item["location"]["lng"]), "dimension": str(item["location"]["lat"])})

# 处理非90的直辖市的区县
with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)
    for data in allData:
        for dataCity in data["city"]:
            for item in params["result"][1]:
                if item["id"][-2:] != "00" and dataCity["id"][0:2] == item["id"][0:2] and item["id"][2:4] != "90":
                    dataCity["county"].append({"id": item["id"], "countyName": item["fullname"], "longitude": str(item["location"]["lng"]), "dimension": str(item["location"]["lat"])})

# 处理90的市
with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)    
    for data in allData:
        for item in params["result"][1]:
            if item["id"][2:4] == '90' and data["id"][0:2] == item["id"][0:2]:
                data["city"].append({"id": item["id"], "name": item["fullname"], "longitude": str(item["location"]["lng"]), "dimension": str(item["location"]["lat"]), "county": []})

# 处理90的区县
with open('./2.json', 'r', encoding='utf-8') as f:
    params = json.load(f)
    for data in allData:
        for dataCity in data["city"]:
            for item in params["result"][1]:
                if dataCity["id"] == item["id"] and item["id"][2:4] == "90":
                    print(dataCity["name"], item["fullname"])
                    dataCity["county"].append({"id": item["id"], "countyName": item["fullname"], "longitude": str(item["location"]["lng"]), "dimension": str(item["location"]["lat"])})

for data in allData:
    del data["id"]
    for dataCity in data["city"]:
        del dataCity["id"]
        for dataCounty in dataCity["county"]:
            del dataCounty["id"]

jsonData = json.dumps(allData, ensure_ascii=False, indent=4)
with open('output.json', 'w', encoding='utf-8') as jsonFile:
    jsonFile.write(jsonData)