# Save as fix_geojson.py and run with: python fix_geojson.py
import json, re

# Mapping from planning area to HDB town
central_area_set = {
    "MARINA EAST", "MARINA SOUTH", "NEWTON", "ORCHARD", "OUTRAM",
    "RIVER VALLEY", "ROCHOR", "SINGAPORE RIVER"
}
kallang_whampoa_set = {"KALLANG", "NOVENA"}

with open('src/main/resources/planning-area-boundary.geojson', encoding='utf-8') as f:
    data = json.load(f)

for feature in data['features']:
    desc = feature['properties'].get('Description', '')
    # Extract all <th>KEY</th> <td>VALUE</td> pairs
    matches = re.findall(r'<th>([^<]+)</th>\s*<td>([^<]+)</td>', desc)
    for key, value in matches:
        feature['properties'][key.strip()] = value.strip()
    # Get planning area name
    pa_name = feature['properties'].get('PLN_AREA_N', '').upper()
    # Assign HDB_TOWN based on mapping
    if pa_name in central_area_set:
        feature['properties']['HDB_TOWN'] = "CENTRAL AREA"
    elif pa_name in kallang_whampoa_set:
        feature['properties']['HDB_TOWN'] = "KALLANG/WHAMPOA"
    else:
        feature['properties']['HDB_TOWN'] = pa_name.title() if pa_name else ""

with open('src/main/resources/planning-area-boundary.geojson', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)