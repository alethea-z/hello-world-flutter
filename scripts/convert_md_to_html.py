#!/usr/bin/env python3
"""Convert the BDD test_report.md into public/index.html and copy goldens."""
import os
import re
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PUBLIC = os.path.join(ROOT, 'public')
GOLDENS_SRC = os.path.join(ROOT, 'test', 'bdd', 'goldens')
MD_PATH = os.path.join(ROOT, 'test_report.md')

os.makedirs(PUBLIC, exist_ok=True)
os.makedirs(os.path.join(PUBLIC, 'goldens'), exist_ok=True)

# Copy goldens
for f in os.listdir(GOLDENS_SRC):
    if f.endswith('.png'):
        shutil.copy2(os.path.join(GOLDENS_SRC, f), os.path.join(PUBLIC, 'goldens', f))

# Parse markdown report
with open(MD_PATH, 'r', encoding='utf-8') as f:
    md = f.read()

rows = []
for line in md.splitlines():
    if line.startswith('|') and not line.startswith('|---') and 'Feature' not in line:
        cells = [c.strip() for c in line.strip('|').split('|')]
        if len(cells) >= 5:
            rows.append(cells)

def esc(s):
    return s.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;')

html = '''<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>BDD Test Protokoll</title>
  <style>
    body {font-family: Arial, sans-serif; margin: 40px; background:#f9f9f9;}
    h1, h2, h3 {color:#2c3e50;}
    table {border-collapse:collapse; width:100%; margin-bottom:30px;}
    th, td {border:1px solid #ddd; padding:8px; text-align:left; vertical-align:top;}
    th {background-color:#f2f2f2;}
    tr:nth-child(even) {background-color:#fafafa;}
    .passed {color:#27ae60; font-weight:bold;}
    .failed {color:#c0392b; font-weight:bold;}
    .steps {background:#ecf0f1; padding:10px; border-radius:4px; font-family:monospace;}
    .footer {margin-top:40px; font-size:0.9em; color:#7f8c8d;}
    img {max-width:300px; height:auto; border:1px solid #ccc; margin:10px 0;}
  </style>
</head>
<body>
  <h1>BDD Test Protokoll</h1>
  <p>Erzeugt am: ''' + __import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S') + '''</p>
  <h2>Übersicht</h2>
  <table>
    <tr><th>Feature</th><th>Scenario</th><th>Status</th><th>Schritte</th><th>Screenshot</th></tr>
'''

for r in rows:
    feature, scenario, status, steps, screenshot = r[0], r[1], r[2], r[3], r[4]
    status_class = 'passed' if status == 'PASSED' else 'failed'
    # Clean screenshot path
    screenshot = screenshot.replace('`', '')
    html += f'''    <tr>
      <td>{esc(feature)}</td>
      <td>{esc(scenario)}</td>
      <td class="{status_class}">{esc(status)}</td>
      <td class="steps">{esc(steps)}</td>
      <td><img src="goldens/{esc(feature)}.png" alt="{esc(feature)} Screenshot"></td>
    </tr>
'''

html += '''  </table>
  <h2>Feature-Details</h2>
'''

# Group by feature
features = {}
for r in rows:
    f = r[0]
    if f not in features:
        features[f] = []
    features[f].append(r)

for feat, scenarios in features.items():
    html += f'  <h3>Feature: {esc(feat)}</h3>\n'
    for s in scenarios:
        html += f'''  <ul>
    <li><strong>Scenario:</strong> {esc(s[1])}</li>
    <li><strong>Schritte:</strong> {esc(s[3])}</li>
    <li><strong>Screenshot:</strong> <img src="goldens/{esc(feat)}.png" alt="{esc(feat)} Screenshot"></li>
  </ul>
'''

html += '''  <p><strong>Gesamtdauer der Tests:</strong> siehe CI-Lauf</p>
  <div class="footer">
    Dieses Protokoll wurde automatisch aus den BDD-Features und Testergebnissen generiert.
    Screenshots stammen aus den Golden-File-Tests (matchesGoldenFile).
  </div>
</body>
</html>
'''

with open(os.path.join(PUBLIC, 'index.html'), 'w', encoding='utf-8') as f:
    f.write(html)

print(f'HTML report written to {PUBLIC}/index.html')
print(f'Goldens copied: {len(os.listdir(os.path.join(PUBLIC, "goldens")))} files')